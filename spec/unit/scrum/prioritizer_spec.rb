require_relative '../spec_helper'

describe Scrum::Prioritizer do
  subject { described_class.new(dummy_settings) }
  let(:trello_planning_board) { Trello::Board.find('neUHHzDo') }
  let(:non_existing_board) { Trello::Board.find('xxxxx123') }

  it 'creates new prioritizer' do
    expect(subject).to be
  end

  context 'default' do
    it 'raises an exception if board is not found', vcr: 'prioritize_no_backlog_list', vcr_record: false do
      expect { subject.prioritize(non_existing_board) }.to raise_error(Trello::Error)
    end

    it 'raises an exception if list is not on board', vcr: 'prioritize_no_backlog_list', vcr_record: false do
      expect { subject.prioritize(trello_planning_board) }.to raise_error("list named 'Backlog' not found on board")
    end

    it 'adds priority text to card titles', vcr: 'prioritize_backlog_list', vcr_record: false do
      expect(STDOUT).to receive(:puts).exactly(13).times
      expect { subject.prioritize(trello_planning_board) }.not_to raise_error
    end
  end

  context 'specifying backlog list as argument' do
    before do
      subject.settings.scrum.list_names['planning_backlog'] = 'Nonexisting List'
    end

    it 'finds backlog list', vcr: 'prioritize_backlog_list', vcr_record: false do
      expect(STDOUT).to receive(:puts).exactly(13).times
      expect do
        subject.prioritize(trello_planning_board, 'Backlog')
      end.not_to raise_error
    end

    it 'throws error when default list does not exist', vcr: 'prioritize_backlog_list', vcr_record: false  do
      expect { subject.prioritize(trello_planning_board) }.to raise_error("list named 'Nonexisting List' not found on board")
    end

    it 'throws error when specified list does not exist', vcr: 'prioritize_backlog_list', vcr_record: false  do
      expect { subject.prioritize(trello_planning_board, 'My Backlog') }.to raise_error("list named 'My Backlog' not found on board")
    end
  end
end

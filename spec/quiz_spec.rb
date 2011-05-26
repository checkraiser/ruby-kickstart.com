require 'spec_helper'
require 'app/models/quiz'

describe Quiz do
  before :all do
    [Quiz, QuizProblem, QuizOption, QuizRegex, QuizMatchAnswerProblem, QuizMultipleChoiceProblem].each(&:delete_all)
    Quiz.add 5, 'Example Problem' do
      add_problem :multiple_choice do
        set_question  'can you see this?'
        add_option    'yes'
        add_option    'no'
      end
      add_problem :match_answer do
        set_question  "what is an object?"
        should_match  /data/i
        should_match  /methods/i
      end
    end
  end
    
  context 'one quiz' do
    subject { Quiz.find_by_number 5 }
    specify { subject.each_problem { |pr| p pr }}
    its(:name) { should == 'Example Problem' }
    its(:inspect) { should == "<Quiz:Example Problem>" }
    it { should == Quiz.find_by_number(5) }
    it { should have(2).problems }
    it 'should yield both problems to each_problem' do
      problems = Array.new
      subject.each_problem { |problem| problems << problem }
      problems.should == subject.problems
    end
  end  
  
  describe 'multiple choice problem' do
    subject { Quiz.find_by_number(5).problems.first }
    its(:question) { should == 'can you see this?' }
    its(:options) { should == %w(yes no) }
    describe '#each_option' do
      it 'should yield both options' do
        options = Array.new
        subject.each_option { |_,option| options << option }
        options.should == subject.options
      end
      it 'should yield increasing numbers beginning at 1' do
        numbers = Array.new
        subject.each_option { |number,_| numbers << number }
        numbers.should == [1,2]
      end
    end
  end
  
  describe 'match answer problem' do
    subject { Quiz.find_by_number(5).problems.last }
    its(:question) { should == 'what is an object?' }
    specify '#each_regex should yield both regexes' do
      regexes = Array.new
      subject.each_regex { |regex| regexes << regex }
      regexes.should == [/data/i,/methods/i]
    end
  end
  
end

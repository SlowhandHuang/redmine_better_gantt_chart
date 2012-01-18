require 'active_support'
require File.expand_path('spec/helpers')
require File.expand_path('../../../lib/redmine_better_gantt_chart/redmine_better_gantt_chart', __FILE__)
require File.expand_path('../../../lib/redmine_better_gantt_chart/calendar', __FILE__)

describe RedmineBetterGanttChart::Calendar do
  include Helpers

  before(:each) do
    work_on_weekends true
  end

  let!(:thursday) { subject.next_day_of_week(4) }
  let!(:friday)   { subject.next_day_of_week(5) }
  let!(:saturday) { subject.next_day_of_week(6) }

  it "should tell next requested day of week" do
    yesterday_date_of_week = Date.yesterday.wday
    subject.next_day_of_week(yesterday_date_of_week).should == Date.today + 6.days
  end

  it "should have 8 working days between today and 1 week later if work on weekends enabled" do
    subject.workdays_between(Date.today, Date.today + 1.week).should == 8
  end

  it "should have 4 working days between today and 1 week later if work on weekends disabled" do
    work_on_weekends false
    subject.workdays_between(Date.today, Date.today + 1.week).should == 6
  end

  it "should have 1 working days between the same start and end dates" do
    subject.workdays_between(friday, friday).should == 1
  end

  it "should have 2 working day between today and tomorrow" do
    subject.workdays_between(thursday, friday).should == 2
  end

  it "should have 6 working days between saturday and next_monday if work on weekends disabled" do
    work_on_weekends false
    subject.workdays_between(saturday, saturday + 9).should == 6
  end

  it "should calculate the difference if date to is earlier than date from" do
    subject.workdays_between(friday, thursday).should ==
    subject.workdays_between(thursday, friday).should
  end

  it "should tell next working day is friday if today is friday" do
    subject.next_working_day(friday).should == friday
  end

  it "should tell next working day is saturday if today is saturday and work on weekends is enabled" do
    subject.next_working_day(saturday).should == saturday
  end

  it "should tell next working day is monday if today is saturday and work on weekends is disabled" do
    work_on_weekends false
    subject.next_working_day(saturday).should == saturday + 2.days
  end

  it "should let calculate finish date based on duration and start date with work on weekends enabled" do
    subject.workdays_from_date(Date.today, 7).should == Date.today + 1.week
  end

  it "should let calculate finish date based on duration and start date wihout work on weekends" do
    work_on_weekends false
    subject.workdays_from_date(Date.today, 5).should == Date.today + 1.week
  end

  it "should calculate start date based on duration and finish date" do
    subject.should_receive(:workdays_from_date).with(Date.today, -5)
    subject.workdays_before_date(Date.today, 5)
  end

  it "should say that 6 working days from saturday is monday if work on weekends disabled" do
    work_on_weekends false
    next_monday = saturday + 9.days
    subject.workdays_from_date(saturday, 6).should == next_monday
  end

  it "should say that 6 working from sunday is monday if work on weekends disabled" do
    work_on_weekends false
    sunday = saturday + 1.day
    next_monday = sunday + 8.days
    subject.workdays_from_date(sunday, 6).should == next_monday
  end
end
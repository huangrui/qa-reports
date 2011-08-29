require 'test_set'

class MeegoTestSessionSweeper < ActionController::Caching::Sweeper
  observe MeegoTestSession, MeegoTestCase

  def after_save(record)
    test_session = record.is_a?(MeegoTestSession) ? record : record.meego_test_session
    expire_cache(test_session)
    expire_index_for(test_session)
  end

  private


  def expire_index_for(test_session)
    expire_paging_action :controller => "report_groups", :action => "show", :release_version => test_session.release_version, :target => test_session.target, :testset => test_session.testset, :product => test_session.product
    expire_paging_action :controller => "report_groups", :action => "show", :release_version => test_session.release_version, :target => test_session.target, :testset => test_session.testset
    expire_paging_action :controller => "report_groups", :action => "show", :release_version => test_session.release_version, :target => test_session.target
  end

  def expire_fragments_for(test_session)
  	return if not test_session
    expire_fragment "show_page_#{test_session.id}"
    expire_fragment "print_page_#{test_session.id}"
  end

  def expire_cache(test_session)
    expire_fragments_for test_session

  	prev_session = test_session.prev_session
  	next_session = test_session.next_session

  	expire_fragments_for prev_session
  	expire_fragments_for next_session

  	next_session = next_session.try(:next_session)
  	expire_fragments_for next_session

    TestSet.invalidate_cache
  end

end

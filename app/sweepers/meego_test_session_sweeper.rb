class MeegoTestSessionSweeper < ActionController::Caching::Sweeper
  observe MeegoTestSession
  
  def after_save(test_session)
    expire_cache(test_session)
  end
 
  private
   
  def expire_cache(test_session)
    expire_fragments_for test_session

	prev_session = test_session.prev_session
	next_session = test_session.next_session

	expire_fragments_for prev_session
	expire_fragments_for next_session

	next_session = next_session.try(:next_session)
	expire_fragments_for next_session
  end

  def expire_fragments_for(test_session)
    return if not test_session
    expire_fragment "preview_page_#{test_session.id}"
    expire_fragment "view_page_#{test_session.id}"
    expire_fragment "edit_page_#{test_session.id}"
    expire_fragment "print_page_#{test_session.id}"
  end
end

module CacheHelper
  def expire_index_for(test_session)
    expire_paging_action :controller => "report_groups", :action => "show", :release_version => test_session.release_version, :target => test_session.target, :testset => test_session.testset, :product => test_session.product
    expire_paging_action :controller => "report_groups", :action => "show", :release_version => test_session.release_version, :target => test_session.target, :testset => test_session.testset
    expire_paging_action :controller => "report_groups", :action => "show", :release_version => test_session.release_version, :target => test_session.target
  end

  def expire_paging_action(args)
    expire_action args
    20.times{|page|
      # FIXME find a better way to flush paging
      expire_action args.merge({:page => page})
    }
  end

  def expire_fragments_for(test_session)
    return if not test_session
    expire_fragment "preview_page_#{test_session.id}"
    expire_fragment "show_page_#{test_session.id}"
    expire_fragment "edit_page_#{test_session.id}"
    expire_fragment "print_page_#{test_session.id}"
  end

  def expire_caches_for(test_session, results = false)
    logger.info "******* Expiring caches for #{test_session.inspect}"

    expire_fragments_for test_session

    if results
      prev_session = test_session.prev_session
      next_session = test_session.next_session

      expire_fragments_for prev_session
      expire_fragments_for next_session

      next_session = next_session.try(:next_session)
      expire_fragments_for next_session
    end
  end
end

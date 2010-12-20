module CacheHelper
  def expire_index_for(test_session)
    expire_page :controller => 'index', :action => :index
    expire_page :controller => 'upload', :action => :upload_form

    expire_paging_action :controller => "index", :action => "filtered_list", :release_version => test_session.release_version, :target => test_session.target, :testtype => test_session.testtype, :hwproduct => test_session.hwproduct
    expire_paging_action :controller => "index", :action => "filtered_list", :release_version => test_session.release_version, :target => test_session.target, :testtype => test_session.testtype
    expire_paging_action :controller => "index", :action => "filtered_list", :release_version => test_session.release_version, :target => test_session.target
  end

  def expire_paging_action(args)
    expire_action args
    20.times{|page|
      # FIXME find a better way to flush paging
      expire_action args.merge({:page => page})
    }
  end

  def expire_caches_for(test_session, results = false)
    logger.info "******* Expiring caches for #{test_session.inspect}"

    expire_fragment "test_results_for_#{test_session.id}"

    if results
      prev_session = test_session.prev_session
      next_session = test_session.next_session

      expire_fragment "test_results_for_#{prev_session.id}" if prev_session
      expire_fragment "test_results_for_#{next_session.id}" if next_session

      next_session = next_session.try(:next_session)
      expire_fragment "test_results_for_#{next_session.id}" if next_session
    end
  end  
end
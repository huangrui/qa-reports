module CacheHelper
  def expire_index_for(test_session)
    expire_page :controller => 'index', :action => :index
    expire_page :controller => 'upload', :action => :upload_form

    ver_label = VersionLabel.find(test_session.version_label_id).label 
    expire_paging_action :controller => "index", :action => "filtered_list", :release_version => ver_label, :target => test_session.target, :testtype => test_session.testtype, :hwproduct => test_session.hwproduct
    expire_paging_action :controller => "index", :action => "filtered_list", :release_version => ver_label, :target => test_session.target, :testtype => test_session.testtype
    expire_paging_action :controller => "index", :action => "filtered_list", :release_version => ver_label, :target => test_session.target
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
    expire_fragment "view_page_#{test_session.id}"
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

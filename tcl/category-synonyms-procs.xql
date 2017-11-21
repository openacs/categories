<?xml version="1.0"?>
<queryset>

  <fullquery name="category_synonym::search_sweeper.delete_old_searches">
    <querytext>
      delete from category_search
      where last_queried < current_timestamp - interval '1' day
    </querytext>
  </fullquery>

</queryset>

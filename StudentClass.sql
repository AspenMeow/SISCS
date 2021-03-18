   with dat as (
    select    
              --Key Fields
              p_class_tbl_se_vw.emplid
             ,p_class_tbl_se_vw.acad_career
             ,p_class_tbl_se_vw.institution
             ,p_class_tbl_se_vw.strm
             ,p_class_tbl_se_vw.class_nbr
             ,nvl(c_crse_attr_value.crse_attr_value,' ') as location_detail
              --Non Key Fields
             ,s_term_val_tbl.descrshort as term_descrshort
             ,p_class_tbl_se_vw.session_code
             ,session_code.xlatlongname as session_code_descr
             ,p_class_tbl_se_vw.acad_prog as primary_acad_prog
             ,p_class_tbl_se_vw.subject
             ,p_class_tbl_se_vw.catalog_nbr
             ,trim(p_class_tbl_se_vw.catalog_nbr) as crse_code
             ,p_class_tbl_se_vw.crse_grade_off
             ,p_class_tbl_se_vw.crse_grade_input
             ,p_class_tbl_se_vw.dyn_class_nbr
             ,p_class_tbl_se_vw.class_section
             ,p_class_tbl_se_vw.crse_id
             ,p_class_tbl_se_vw.strm || p_class_tbl_se_vw.class_nbr as section_id
             ,p_class_tbl_se_vw.crse_offer_nbr
             ,p_class_tbl_se_vw.crse_career
             ,p_class_tbl_se_vw.earn_credit
             ,p_class_tbl_se_vw.include_in_gpa
             ,p_class_tbl_se_vw.stdnt_enrl_status
             ,stdnt_enrl_status.xlatlongname as stdnt_enrl_status_descr
             ,p_class_tbl_se_vw.repeat_code
             ,p_class_tbl_se_vw.unt_taken
             ,p_class_tbl_se_vw.unt_billing
             ,p_class_tbl_se_vw.unt_earned
             ,p_class_tbl_se_vw.unt_prgrss
             ,p_class_tbl_se_vw.grading_basis_enrl
             ,p_class_tbl_se_vw.descr as course_title_descr
             ,p_class_tbl_se_vw.location
             ,c_crse_attr_value.descrformal as location_detail_descr
             ,p_class_tbl_se_vw.enrl_add_dt
             ,p_class_tbl_se_vw.enrl_drop_dt
             ,p_class_tbl_se_vw.enrl_status_reason
             ,enrl_status_reason.xlatshortname as enrl_reason_descrshort
             ,enrl_status_reason.xlatlongname as enrl_reason_descrlong
             ,case
                when c_crse_attributes.crse_attr = 'HON' then
                  'Y'
                else
                  'N'
              end as honors_course
             ,case
                when c_class_attribute_hon.crse_attr = 'HON' then
                  'Y'
                else
                  'N'
              end as honors_section
             ,case
                when p_class_tbl_se_vw.rqmnt_designtn = 'H' then
                  'Y'
                else
                  'N'
              end as honors_option
             ,p_class_tbl_se_vw.stdnt_positin
    from      siscs.p_class_tbl_se_vw_v  p_class_tbl_se_vw
    left join (select * from siscs.c_crse_attributes_av where edw_actv_ind='Y' and edw_curr_ind='Y') c_crse_attributes on c_crse_attributes.crse_id = p_class_tbl_se_vw.crse_id
                                       and c_crse_attributes.crse_attr = 'HON'


    left join (select * from siscs.c_class_attribute_av where edw_actv_ind='Y' and edw_curr_ind='Y') c_class_attribute_hon on p_class_tbl_se_vw.strm = c_class_attribute_hon.strm
                                                              and c_class_attribute_hon.crse_id = p_class_tbl_se_vw.crse_id
                                                              and c_class_attribute_hon.crse_offer_nbr = p_class_tbl_se_vw.crse_offer_nbr
                                                              and c_class_attribute_hon.session_code = p_class_tbl_se_vw.session_code
                                                              and c_class_attribute_hon.class_section = p_class_tbl_se_vw.class_section
                                                              and c_class_attribute_hon.crse_attr = 'HON'


    left join (select * from siscs.c_class_attribute_av where edw_actv_ind='Y' and edw_curr_ind='Y') c_class_attribute_off on p_class_tbl_se_vw.strm = c_class_attribute_off.strm
                                                              and c_class_attribute_off.crse_id = p_class_tbl_se_vw.crse_id
                                                              and c_class_attribute_off.crse_offer_nbr = p_class_tbl_se_vw.crse_offer_nbr
                                                              and c_class_attribute_off.session_code = p_class_tbl_se_vw.session_code
                                                              and c_class_attribute_off.class_section = p_class_tbl_se_vw.class_section
                                                              and c_class_attribute_off.crse_attr = 'OFF'


    left join (select * from siscs.c_crse_attr_value_av where edw_actv_ind='Y' and edw_curr_ind='Y')c_crse_attr_value on c_crse_attr_value.crse_attr_value = c_class_attribute_off.crse_attr_value
                                       and c_crse_attr_value.crse_attr = c_class_attribute_off.crse_attr


    left join (select * from siscs.s_term_val_tbl_av where edw_actv_ind='Y' and edw_curr_ind='Y')s_term_val_tbl on p_class_tbl_se_vw.strm = s_term_val_tbl.strm


    left join (select * from siscs.t_xlatitem_av where edw_actv_ind='Y' and edw_curr_ind='Y') stdnt_enrl_status on stdnt_enrl_status.fieldvalue = p_class_tbl_se_vw.stdnt_enrl_status
                                                  and stdnt_enrl_status.fieldname = 'STDNT_ENRL_STATUS'


    left join (select * from siscs.t_xlatitem_av where edw_actv_ind='Y' and edw_curr_ind='Y') enrl_status_reason on enrl_status_reason.fieldvalue = p_class_tbl_se_vw.enrl_status_reason
                                                   and enrl_status_reason.fieldname = 'ENRL_STATUS_REASON'


    left join (select * from siscs.t_xlatitem_av where edw_actv_ind='Y' and edw_curr_ind='Y') session_code on session_code.fieldvalue = p_class_tbl_se_vw.session_code
                                             and session_code.fieldname = 'SESSION_CODE'


    where     1 = 1

    and       (c_crse_attributes.effdt = (select   max(c_ed.effdt)
                                          from     siscs.c_crse_attributes_av c_ed
                                          where    c_crse_attributes.crse_id = c_ed.crse_id
                                          --Actitve records only--
                                          and c_ed.edw_actv_ind='Y' and c_ed.edw_curr_ind='Y'
                                          and      c_ed.effdt <= sysdate
                                         )     
    or        c_crse_attributes.effdt is null)
    and       (c_crse_attr_value.effdt = (select   max(f_ed.effdt)
                                           from     siscs.c_crse_attr_value_av f_ed
                                           where    c_crse_attr_value.crse_attr = f_ed.crse_attr
                                           --Actitve records only--
                                          and f_ed.edw_actv_ind='Y' and f_ed.edw_curr_ind='Y'
                                           and      f_ed.effdt <= sysdate
                                          )
               or 
               c_crse_attr_value.effdt is null 
              )
    and       (stdnt_enrl_status.effdt = (select   max(g_ed.effdt)
                                         from     siscs.t_xlatitem_av g_ed
                                         where    stdnt_enrl_status.fieldname = g_ed.fieldname
                                         and      stdnt_enrl_status.fieldvalue = g_ed.fieldvalue
                                         --Actitve records only--
                                          and g_ed.edw_actv_ind='Y' and g_ed.edw_curr_ind='Y'
                                         and      g_ed.effdt <= sysdate
                                        )
              or stdnt_enrl_status.effdt is null )
    and       (enrl_status_reason.effdt = (select   max(h_ed.effdt)
                                          from     siscs.t_xlatitem_av h_ed
                                          where    enrl_status_reason.fieldname = h_ed.fieldname
                                          and      enrl_status_reason.fieldvalue = h_ed.fieldvalue
                                          --Actitve records only--
                                          and h_ed.edw_actv_ind='Y' and h_ed.edw_curr_ind='Y'
                                          and      h_ed.effdt <= sysdate
                                         )
                or enrl_status_reason.effdt is null)
    and       (session_code.effdt = (select   max(i_ed.effdt)
                                    from     siscs.t_xlatitem_av i_ed
                                    where    session_code.fieldname = i_ed.fieldname
                                    and      session_code.fieldvalue = i_ed.fieldvalue
                                    --Actitve records only--
                                          and i_ed.edw_actv_ind='Y' and i_ed.edw_curr_ind='Y'
                                    and      i_ed.effdt <= sysdate
                                   )
                or session_code.effdt is null) 
                )
                
                select count(*)
                from dat
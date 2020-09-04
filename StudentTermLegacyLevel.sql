--Revised on 09/03/2020
--Created by Di
--Population Included : Records should be same as what's in Student Car Term. Keys on Emplid, STRM, Acad_Career. Only primary plan for the career is included
--Dependency table :  R_PRIMACY_RV need to be executed prior to this ---
--Note : Continuing Discussion on whether to drill down to legacy student level (CPP Group) for many of those flag variables.
--For now, I created both version for first_term_at_career/lvl,cohort_entry, Term_Classification
--becasue the table with admit typpe has not been available yet, variables depending on that are not included yet are : First_Prim_Ugrd_Flag, First_Prim_at_GRAD_Masters, First_Prim_at_GRAD_Doctoral,Entry_Status_Code
with termlvlenrl as (
select distinct
ct.emplid,
ct.strm,
ct.institution,
ct.acad_level_bot,
tm.descrshort as term_descrshort,
(case 
    when ct.ELIG_TO_ENROLL='N' then 'N'
    when en.enrl=1 then 'E'
    when en.drp=0 then 'D'
    when en.waitlist=0 then 'L'
    when ct.withdraw_code='WDR' then 'W'
    when en.cancl=0 then 'C'
    when en.disenrl=0 then 'S'
   when en.emplid is null then 'A'
end ) as enrollment_status,
ct.acad_career,
prim.PRIMARY_CAR_FLAG,
prim.acad_plan,
prim.ACAD_PLAN_ACAD_PROG as acad_prog,
prim.primary_plan_flag, 
(case when ct.ACAD_CAREER='NON' and prim.ACAD_PLAN_ACAD_PROG	='NONU'  and substr(prim.acad_plan,-4) in ('ELCT','NOEL') then 'EL' 
when ct.ACAD_CAREER='GCRT' and prim.ACAD_PLAN_ACAD_PROG='GCERT' then 'GC'
when  ct.ACAD_CAREER='NON' and prim.ACAD_PLAN_ACAD_PROG='NONG' and substr(prim.acad_plan,-4) in ('NOHG') then 'HG'
when  ct.ACAD_CAREER='NON' and prim.ACAD_PLAN_ACAD_PROG='NONU' and substr(prim.acad_plan,-4) in ('NOHU') then 'HU'
when  ct.ACAD_CAREER='NON' and prim.ACAD_PLAN_ACAD_PROG='NLAW'  and substr(prim.acad_plan,-4) in ('NOLD') then 'LD'
when  ct.ACAD_CAREER='NON' and prim.ACAD_PLAN_ACAD_PROG='NONG' and substr(prim.acad_plan,-4) in ('NOLG') then 'LG'
when  ct.ACAD_CAREER='NON' and prim.ACAD_PLAN_ACAD_PROG='NONU' and substr(prim.acad_plan,-4) in ('NOLU') then 'LU'
when  ct.ACAD_CAREER='NON' and prim.ACAD_PLAN_ACAD_PROG='NONG' and substr(prim.acad_plan,-4) in ('NOPD') then 'PD'
when ct.ACAD_CAREER='GCRT' and prim.ACAD_PLAN_ACAD_PROG='TEACH' then 'TE'
when ct.acad_career='AGTC' then 'AT'
when ct.acad_career='NONL' then 'DL'
when ct.acad_career='GRAD' then 'GR'
when ct.acad_career='HMED' then 'HM'
when ct.acad_career='LAWM' then 'LM'
when ct.acad_career='LAW' then 'LW'
when ct.acad_career='OMED' then 'OM'
when ct.acad_career='UGRD' then 'UN'
when ct.acad_career='VMED' then 'VM'
else '' end ) as student_level
from SISCS.P_STDNT_CAR_TERM_V ct
inner join SISCS.S_TERM_TBL_V tm
on ct.strm=tm.strm and ct.acad_career=tm.acad_career
left join 
    (select emplid,
            acad_career,
            institution,
            strm,
            max(case when stdnt_enrl_status='E' then 1 else 0 end ) as enrl,
            max(case when stdnt_enrl_status='D' then 0 else 1 end) as drp,
            max(case when stdnt_enrl_status='W' then 0 else 1 end) as waitlist,
            max(case when enrl_status_reason='CANC' then 0 else 1 end) as cancl,
            max(case when ENRL_ACTN_RSN_LAST='DSEN' then 0 else 1 end) as disenrl
    from SISCS.P_STDNT_ENRL_V 
    group by emplid,
    acad_career,
    institution,
    strm) en
on ct.emplid=en.emplid
and ct.acad_career=en.acad_career
and ct.institution=en.institution
and ct.strm=en.strm
--a dependency here
left join siscs.R_PRIMACY_RV prim
on ct.emplid= prim.emplid
and ct.acad_career= prim.acad_career
and ct.institution= prim.institution
and ct.strm=prim.strm
--testing pids, need to remove 
where ct.emplid in ('156333912','126863026','156297326','158749061','159690642','108417322','149697444','139244349')

),


dat2 as (
select a.*,d.MSU_Atnd_Preced_Flag,d.Enrld_MSU_Prior,
(case when a.PRIMARY_CAR_FLAG='N' or a.PRIMARY_CAR_FLAG is null then 'N' when  First_Term_Rpt_Level=a.strm then 'Y' else 'N' end ) as First_STRM_RPT_LVL,
(case when a.PRIMARY_CAR_FLAG='N' or a.PRIMARY_CAR_FLAG is null then 'N' when First_Term_Career=a.strm then 'Y' else 'N' end ) as First_STRM_Career, 
(case when a.PRIMARY_CAR_FLAG='N' or a.PRIMARY_CAR_FLAG is null then ''
when First_Term_Rpt_Level=a.strm and d.Enrld_MSU_Prior='Y' then 'CONT'
when First_Term_Rpt_Level=a.strm then 'NEW'
when d.MSU_Atnd_Preced_Flag='Y' then 'RTRN'
else 'RGAP' end )   as Term_Classif_Code_Lvl,
(case when a.PRIMARY_CAR_FLAG='N' or a.PRIMARY_CAR_FLAG is null then ''
when First_Term_Career=a.strm and d.Enrld_MSU_Prior='Y' then 'CONT'
when First_Term_Career=a.strm then 'NEW'
when d.MSU_Atnd_Preced_Flag='Y' then 'RTRN'
else 'RGAP' end ) as Term_Classif_Code_Career,
cohort_entry,entrycohortlvl.cohort_entry_lvl,
(case when mintermplan=a.strm then 'Y' else 'N' end ) as First_Term_In_Plan,
(case when honr.stdnt_group is null then 'N' else 'Y' end ) as Honors_College_Member,
(case when substr(a.term_descrshort,1,1)='F' and  (LAG((case when a.PRIMARY_CAR_FLAG='N' or a.PRIMARY_CAR_FLAG is null then ''
when First_Term_Rpt_Level=a.strm and d.Enrld_MSU_Prior='Y' then 'CONT'
when First_Term_Rpt_Level=a.strm then 'NEW'
when d.MSU_Atnd_Preced_Flag='Y' then 'RTRN'
else 'RGAP' end ) , 1, '') OVER(PARTITION BY a.emplid , a.student_level ORDER BY  a.emplid,a.student_level, a.strm ) in ('NEW','CONT') or (case when a.PRIMARY_CAR_FLAG='N' or a.PRIMARY_CAR_FLAG is null then ''
when First_Term_Rpt_Level=a.strm and d.Enrld_MSU_Prior='Y' then 'CONT'
when First_Term_Rpt_Level=a.strm then 'NEW'
when d.MSU_Atnd_Preced_Flag='Y' then 'RTRN'
else 'RGAP' end ) in ('NEW','CONT') )then 'Y'
else 'N' end ) as IPEDS_Fall_Cohort_New,

(case when greatest(nvl(exawd.postdeg,0),nvl(intawd.postdeg,0))=1 then '06'
when greatest(nvl(exawd.postdeg,0),nvl(intawd.postdeg,0))=2 then '10'
when greatest(nvl(exawd.postdeg,0),nvl(intawd.postdeg,0))=3 then '13'
when greatest(nvl(exawd.postdeg,0),nvl(intawd.postdeg,0))=4 then '14'
when greatest(nvl(exawd.postdeg,0),nvl(intawd.postdeg,0))=5 then '19'
when greatest(nvl(exawd.postdeg,0),nvl(intawd.postdeg,0))=6 then '17'
when greatest(nvl(exawd.postdeg,0),nvl(intawd.postdeg,0))=7 then '18'
when greatest(nvl(exawd.postdeg,0),nvl(intawd.postdeg,0))=8 then '15'
when greatest(nvl(exawd.postdeg,0),nvl(intawd.postdeg,0))=9 then '21'
end)  highest_education_lvl

from termlvlenrl a
--first term at lvl
left join 
   ( select emplid, institution, student_level,strm,
            COUNT(*) OVER(PARTITION BY emplid, institution, student_level
                          ORDER BY
                             emplid, institution, student_level, strm
                        )   as cnt,
            MIN( strm) OVER(PARTITION BY  emplid,institution,student_level
                          ORDER BY
                            emplid,institution,student_level,strm
                        )   as First_Term_Rpt_Level
        from (select * from termlvlenrl 
            where  PRIMARY_CAR_FLAG='Y' and primary_plan_flag='Y' and enrollment_status in ('E','C','W'))
        ) b
on a.emplid=b.emplid 
and a.institution=b.institution
and  b.cnt=1
and a.student_level=b.student_level
--and a.strm=b.strm
left join 
    (--first term at career
    select  emplid, institution, ACAD_CAREER,strm,
            COUNT(*) OVER(PARTITION BY emplid, institution, ACAD_CAREER
                          ORDER BY
                             emplid, institution, ACAD_CAREER, strm
                        )   as cnt,
            MIN( strm) OVER(PARTITION BY  emplid,institution,ACAD_CAREER
                          ORDER BY
                            emplid,institution,ACAD_CAREER,strm
                        )   as First_Term_Career
        from (select distinct emplid, institution,ACAD_CAREER,strm  from termlvlenrl 
            where  PRIMARY_CAR_FLAG='Y' and primary_plan_flag='Y' and enrollment_status in ('E','C','W')
    )) c
on a.emplid=c.emplid 
and a.institution=c.institution
and  c.cnt=1
and a.acad_career=c.acad_career
---MSU_Atnd_Preced_Flag
--Enrld_MSU_Prior
left join (
        select emplid, strm, descrshort, MSU_Atnd_Preced_Flag,
        (case when LAG(enrlincludcur, 1, '') OVER(PARTITION BY emplid  ORDER BY emplid, strm ) is  null then 'N'
        when  LAG(enrlincludcur, 1, '') OVER(PARTITION BY emplid  ORDER BY  emplid, strm ) =1 then 'Y'
        else 'N' end ) as Enrld_MSU_Prior
        from (
               select emplid, strm, descrshort,
                (case when LAG(strm1, 1, '') OVER(PARTITION BY emplid  ORDER BY  emplid, strm ) is not null then 'Y'
                when substr(descrshort,1,1)='F' and  LAG(strm1, 2, '') OVER(PARTITION BY emplid  ORDER BY  emplid, strm ) is not null then 'Y'
                else 'N' end ) as MSU_Atnd_Preced_Flag,
                max(case when strm1 is null then 0 else 1 end ) OVER(PARTITION BY emplid ORDER BY    emplid, strm ) as enrlincludcur
                
        from (
        
        select distinct b.emplid, a.strm,a.descrshort, tm.strm as strm1
                from SISCS.S_TERM_VAL_TBL_V a
                inner join (
                            select emplid, min(strm) as minterm, max(strm) as maxterm
                            from SISCS.P_STDNT_CAR_TERM_V
                            group by emplid
                            ) b
                on a.strm >= minterm and a.strm <=maxterm
                left join  termlvlenrl tm
                on b.emplid=tm.emplid and a.strm=tm.strm and tm.enrollment_status in ('E','C','W')))
        ) d
on  a.emplid= d.emplid
and a.strm=d.strm
--cohort entry based on career
left join (select a.*, b.acad_year as cohort_entry
            from (
                    select  emplid, institution, acad_career,
                    (case when acad_career='GRAD' then acad_level_bot else acad_career end ) as acad_gr_lvl,
                    min(strm) as minstrm
                    from termlvlenrl
                   where  enrollment_status in ('E','C','W')
                and PRIMARY_CAR_FLAG ='Y'
            group by emplid, institution,  acad_career,
                            (case when acad_career='GRAD' then acad_level_bot else acad_career end )
         ) a
    inner join siscs.s_term_tbl_v b
    on a.institution=b.institution
    and a.acad_career=b.acad_career
    and a.minstrm=b.strm
) entrycohort
on a.emplid=entrycohort.emplid
and a.institution=entrycohort.institution
and a.acad_career=entrycohort.acad_career
and  (case when a.acad_career='GRAD' then a.acad_level_bot else a.acad_career end )= entrycohort.acad_gr_lvl
--cohort entry based on lvl
left join (select a.*, b.acad_year as cohort_entry_lvl
            from (
                    select  emplid, institution, acad_career,student_level,
                    (case when student_level='GRAD' then acad_level_bot else student_level end ) as acad_gr_lvl,
                    min(strm) as minstrm
                    from termlvlenrl
                   where  enrollment_status in ('E','C','W')
                and PRIMARY_CAR_FLAG ='Y'
            group by emplid, institution, acad_career, student_level,
                            (case when student_level='GRAD' then acad_level_bot else student_level end )
         ) a
    inner join siscs.s_term_tbl_v b
    on a.institution=b.institution
    and a.acad_career=b.acad_career
    and a.minstrm=b.strm
) entrycohortlvl
on a.emplid=entrycohortlvl.emplid
and a.institution=entrycohortlvl.institution
and a.student_level=entrycohortlvl.student_level
and  (case when a.student_level='GRAD' then a.acad_level_bot else a.student_level end )= entrycohortlvl.acad_gr_lvl
--first time at plan (primary plan/career is not considered)
left join 
        (select distinct emplid,institution,acad_career,acad_plan, min(strm) as mintermplan
        from termlvlenrl
           where  enrollment_status in ('E','C','W')
        group by emplid,institution,acad_career,acad_plan
) firstplan
on a.emplid=firstplan.emplid
and a.institution= firstplan.institution
and a.acad_career= firstplan.acad_career
and a.ACAD_PLAN=firstplan.acad_plan
--highest prior degree
left join 
(
select a.emplid,  a.strm, 
max(case when d.education_lvl='06' then 1
when d.education_lvl='10' then 2
when d.education_lvl='13' then 3
when d.education_lvl='14' then 4
when d.education_lvl='19' then 5
when d.education_lvl='17' then 6
when d.education_lvl='18' then 7
when d.education_lvl='15' then 8
when d.education_lvl='21' then 9 else 0 end ) postdeg
from   SISCS.P_STDNT_CAR_TERM_V a
inner join siscs.p_ext_degree_v b
on a.emplid=b.emplid
inner join siscs.s_term_tbl_v t
on a.strm=t.strm and a.institution=t.institution and a.acad_career=t.acad_career
inner join siscs.s_degree_tbl_v d
on b.degree=d.degree
where b.degree_dt < t.term_begin_dt
and d.effdt = (select max(effdt) 
                from siscs.s_degree_tbl_v d1
                where d1.effdt<=sysdate and d.degree=d1.degree)
group by a.emplid, a.strm ) exawd
on a.emplid= exawd.emplid
and a.strm= exawd.strm
--higest internal degree
left join (select ct.emplid, ct.strm, max(dg.postdeg) as postdeg
from   SISCS.P_STDNT_CAR_TERM_V ct
inner join (

select a.emplid,  (case when d.education_lvl='06' then 1
when d.education_lvl='10' then 2
when d.education_lvl='13' then 3
when d.education_lvl='14' then 4
when d.education_lvl='19' then 5
when d.education_lvl='17' then 6
when d.education_lvl='18' then 7
when d.education_lvl='15' then 8
when d.education_lvl='21' then 9 else 0 end ) postdeg, min(a.completion_term) as minterm
from siscs.p_acad_degr_v a 
inner join siscs.s_degree_tbl_v d
on a.degree=d.degree
and d.effdt = (select max(effdt) 
                from siscs.s_degree_tbl_v d1
                where d1.effdt<=sysdate and d.degree=d1.degree)

group by a.emplid,  (case when d.education_lvl='06' then 1
when d.education_lvl='10' then 2
when d.education_lvl='13' then 3
when d.education_lvl='14' then 4
when d.education_lvl='19' then 5
when d.education_lvl='17' then 6
when d.education_lvl='18' then 7
when d.education_lvl='15' then 8
when d.education_lvl='21' then 9 else 0 end )) dg
on ct.emplid=dg.emplid
and ct.strm> dg.minterm
group by ct.emplid, ct.strm) intawd
on a.emplid= intawd.emplid
and a.strm= intawd.strm

--honors Honors_College_Member
left join (
            select g.emplid,scar.strm,t.descrshort,g.institution, g.stdnt_group,scar.acad_career
            from siscs.p_stdnt_grps_hist_v g,
            SISCS.P_STDNT_CAR_TERM_V scar,
            siscs.s_term_tbl_v t
            where g.institution=scar.institution
            and g.emplid=scar.emplid
            and g.institution=t.institution
            and scar.acad_career=t.acad_career
            and t.strm=scar.strm
            and g.effdt <= t.term_end_dt
            and g.effdt = (select max(effdt)
                            from  siscs.p_stdnt_grps_hist_v a
                            where g.emplid=a.emplid 
                            and g.stdnt_group=a.stdnt_group
                            and g.institution=a.institution
                            and a.institution=t.institution
                            and t.strm=scar.strm
                            and a.emplid=scar.emplid
                            and scar.acad_career= t.acad_career
                            and a.effdt <= t.term_end_dt
                            --and t.term_begin_dt <= sysdate
                            )
            and g.eff_status='A'
            and  g.stdnt_group='XHON') honr
on a.emplid=honr.emplid
and a.acad_career= honr.acad_career
and a.institution=honr.institution
and a.strm=honr.strm

where 
( a.primary_plan_flag='Y' or a.PRIMARY_CAR_FLAG is null) 
--and a.emplid in ('159690642')
order by a.emplid, a.strm, a.acad_career, a.primary_plan_flag
)

select a.EMPLID,a.STRM,a.INSTITUTION,a.TERM_DESCRSHORT,
a.ENROLLMENT_STATUS,a.ACAD_CAREER,a.PRIMARY_CAR_FLAG,a.ACAD_PLAN,
a.ACAD_PROG,a.PRIMARY_PLAN_FLAG,a.STUDENT_LEVEL as CPP_Grp,a.MSU_ATND_PRECED_FLAG as MSU_Enrld_Preced,
a.ENRLD_MSU_PRIOR,
a.FIRST_STRM_RPT_LVL as First_Prim_CPP_Grp,
a.FIRST_STRM_CAREER as First_Prim_Career,
b.TERM_CLASSIF_CODE_LVL,
b.TERM_CLASSIF_CODE_CAREER,
(case when a.PRIMARY_CAR_FLAG='Y' then     a.COHORT_ENTRY end ) as Cohort_Prim_Entry, 
(case when a.PRIMARY_CAR_FLAG='Y' then a.cohort_entry_lvl end ) as Cohort_Prim_Entry_CPP_Grp,
a.FIRST_TERM_IN_PLAN,
a.HONORS_COLLEGE_MEMBER,
a.IPEDS_FALL_COHORT_NEW,
a.HIGHEST_EDUCATION_LVL as Prior_High_Degree,
(case when a.STRM>= res.effective_term then res.residency end) as residency,
(case when ct.ELIG_TO_ENROLL='Y' and ct.unt_passd_gpa>=12 and cur_gpa>=3.5 then 'Y' else 'N' end) as deans_list_flag,
--additional variables from student car term directly
ct.stdnt_car_nbr,
ct.elig_to_enroll,
ct.acad_level_bot,
ct.acad_level_eot,
ct.acad_level_proj,
ct.cur_gpa,
ct.unt_term_tot,
ct.unt_taken_prgrss,
ct.unt_passd_gpa,
ct.unt_taken_gpa,
ct.grade_points,
ct.cum_gpa,
ct.tot_cumulative,
ct.tot_taken_prgrss,
ct.tot_passd_gpa,
(ct.TOT_INPROG_GPA + ct.TOT_INPROG_NOGPA) as TOT_PROJ_UNITS,
ct.TOT_TRNSFR as TOT_TRNSFR_CRS,
ct.tot_taken_gpa,
ct.tot_grade_points,
ct.cum_resident_terms,
ct.academic_load,
ct.academic_load_dt,
ct.withdraw_code,
ct.withdraw_reason,
ct.withdraw_date

from dat2 a
left join (select emplid, strm, institution, Term_Classif_Code_Career, Term_Classif_Code_Lvl
            from dat2 
            where PRIMARY_CAR_FLAG='Y') b
on a.emplid=b.emplid
and a.strm=b.strm
and a.institution=b.institution
--adding additional columns from stdnt car term
inner join 
SISCS.P_STDNT_CAR_TERM_V ct
on a.emplid=ct.emplid
and a.strm=ct.strm
and a.institution=ct.institution
and a.acad_career=ct.acad_career
inner join siscs.p_residency_off_v res
on ct.emplid=res.emplid
and ct.acad_career=res.acad_career
and ct.institution=res.institution
and res.effective_term= (
    select max(effective_term)
        from siscs.p_residency_off_v r
        where ct.emplid= r.emplid
        and  ct.acad_career= r.acad_career
        and ct.institution= r.institution
      -- and ct.strm >= r.effective_term
)


--Created on 09/03/2020
--Created by Di
--Last updated on 03/30/2021
--Population Included : Records should be same as what's in Student Car Term. Keys on Emplid, STRM, Acad_Career. Only primary plan for the career is included
--Dependency table :  R_PRIMACY_RV need to be executed prior to this ---
--add enrollment_career
with a as 
 ((
 SELECT 
T.emplid,
T.strm,
T.institution,
T.acad_level_bot,
T.term_descrshort,
T.enrollment_status,
T.acad_career,
T.PRIMARY_CAR_FLAG,
T.acad_plan,
T.acad_prog,
T.primary_plan_flag,
T.student_level,
T.RNUM
FROM
(SELECT T.emplid,
T.strm,
T.institution,
T.acad_level_bot,
T.term_descrshort,
T.enrollment_status,
T.acad_career,
T.PRIMARY_CAR_FLAG,
T.acad_plan,
T.acad_prog,
T.primary_plan_flag,
T.student_level,
ROW_NUMBER() OVER( PARTITION BY T.emplid,
T.strm,
T.institution,
T.acad_level_bot,
T.term_descrshort,
T.enrollment_status,
T.acad_career,
T.PRIMARY_CAR_FLAG,
T.acad_plan,
T.acad_prog,
T.primary_plan_flag,
T.student_level ORDER BY T.emplid ASC) AS RNUM
FROM 
(select 
P_STDNT_CAR_TERM.emplid,
P_STDNT_CAR_TERM.strm,
P_STDNT_CAR_TERM.institution,
P_STDNT_CAR_TERM.acad_level_bot,
S_TERM_TBL.descrshort as term_descrshort,
(case 
    when P_STDNT_CAR_TERM.ELIG_TO_ENROLL='N' then 'N'
    when P_STDNT_CAR_TERM.withdraw_code='WDR' then 'W'
    when P_STDNT_ENRL.enrl=1 then 'E'
    when P_STDNT_ENRL.drp=0 then 'D'
    when P_STDNT_ENRL.waitlist=0 then 'L'
   when P_STDNT_ENRL.emplid is null then 'A'
   else ''
end ) as enrollment_status,
P_STDNT_CAR_TERM.acad_career,
R_PRIMACY_R.PRIMARY_CAR_FLAG,
R_PRIMACY_R.acad_plan,
R_PRIMACY_R.ACAD_PLAN_ACAD_PROG as acad_prog,
R_PRIMACY_R.primary_plan_flag,
(case when P_STDNT_CAR_TERM.ACAD_CAREER in ('NON','GCRT' ) then P_STDNT_CAR_TERM.ACAD_CAREER||'_'||R_PRIMACY_R.degree else P_STDNT_CAR_TERM.ACAD_CAREER end) as student_level
from (select * from SISCS.P_STDNT_CAR_TERM_av where edw_actv_ind='Y' and edw_curr_ind='Y') P_STDNT_CAR_TERM
left join  siscs.R_PRIMACY_Rv  R_PRIMACY_R
on P_STDNT_CAR_TERM.emplid= R_PRIMACY_R.emplid
and P_STDNT_CAR_TERM.acad_career= R_PRIMACY_R.acad_career
and P_STDNT_CAR_TERM.institution= R_PRIMACY_R.institution
and P_STDNT_CAR_TERM.strm=R_PRIMACY_R.strm
inner join (select * from SISCS.S_TERM_TBL_av where edw_actv_ind='Y' and edw_curr_ind='Y') S_TERM_TBL
on P_STDNT_CAR_TERM.strm=S_TERM_TBL.strm and P_STDNT_CAR_TERM.acad_career=S_TERM_TBL.acad_career and P_STDNT_CAR_TERM.institution=S_TERM_TBL.institution
left join 
    (select  emplid,
            acad_career,
            institution,
            strm,
            max(case when stdnt_enrl_status='E' then 1 else 0 end ) as enrl,
            max(case when stdnt_enrl_status='D' then 0 else 1 end) as drp,
            max(case when stdnt_enrl_status='W' then 0 else 1 end) as waitlist
    from SISCS.P_STDNT_ENRL_AV 
    where EDW_ACTV_IND='Y' and edw_curr_ind='Y'
    group by emplid,
    acad_career,
    institution,
    strm) P_STDNT_ENRL
on P_STDNT_CAR_TERM.emplid=P_STDNT_ENRL.emplid
and P_STDNT_CAR_TERM.acad_career=P_STDNT_ENRL.acad_career
and P_STDNT_CAR_TERM.institution=P_STDNT_ENRL.institution
and P_STDNT_CAR_TERM.strm=P_STDNT_ENRL.strm)T)T
WHERE T.RNUM=1
and T.emplid in ('156333912','126863026','156297326','158749061','159690642','108417322','149697444','139244349','105044362','148452186','150387028')
 ) 
 ),
 termlvlenrl as (
 
 select a.emplid, a.strm,a.institution,a.acad_level_bot,a.term_descrshort, 
 (case when ordering=1 then 'E' when ordering =2 then 'W' 
 when ordering =3 then 'L' when ordering =4 then 'D' when ordering =5 then 'A' when ordering =6 then 'N' else '' end) as enrollment_status,
 acad_career, primary_car_flag, acad_plan, acad_prog, primary_plan_flag, student_level,enrollment_status as enrollment_career
 from   a 
 inner join (
 select emplid, strm, institution, min(case when enrollment_status='E' then 1 
when enrollment_status='W' then 2
when enrollment_status='L' then 3
when enrollment_status='D' then 4
when enrollment_status='A' then 5
when enrollment_status='N' then 6 else 7 end ) as ordering
 from a
 group by emplid, strm, institution ) b
 on a.emplid =b.emplid and a.strm=b.strm and a.institution=b.institution
)




select ct.EMPLID,ct.STRM, ct.INSTITUTION, a.TERM_DESCRSHORT, ct.ACAD_CAREER, a.ENROLLMENT_STATUS as Enroll_Status,a.ACAD_PROG,a.ACAD_PLAN,  a.PRIMARY_CAR_FLAG,  a.PRIMARY_PLAN_FLAG,
ct.stdnt_car_nbr,ct.elig_to_enroll,
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
ct.withdraw_date,
res.residency  as residency,
res.residency_dt  as residency_date,
res.admission_res  as admission_res,
res.tuition_res  as tuition_res,
res.FIN_AID_FED_RES,
(case when ct.ELIG_TO_ENROLL='Y' and ct.unt_passd_gpa>=12 and cur_gpa>=3.5 then 'Y' else 'N' end) as deans_list_flag,
--milestone COMP EXAM GRAD Only
(case when ct.acad_career <> 'GRAD' or a.PRIMARY_CAR_FLAG ='N' then ' '
when milestone.emplid is null then 'N' else 'Y' end ) as COMP_EXAM_COMPLETED,
milestone.date_completed as COMP_EXAM_CMPL_DATE,
(case when a.PRIMARY_CAR_FLAG='N' or a.PRIMARY_CAR_FLAG is null or First_Term_Career is null then ' ' 
when First_Term_Career=a.strm then 'Y' else 'N' end ) as First_PRIM_Career, 
d.MSU_Atnd_Preced_Flag as MSU_ENRLD_PRECED,d.Enrld_MSU_Prior as MSU_ENRLD_PRIOR,
(case when a.PRIMARY_CAR_FLAG='N' or a.PRIMARY_CAR_FLAG is null or First_Term_Career is null then ' '
when First_Term_Career=a.strm and  adm.basis_admit_code='FY' and a.ACAD_CAREER='UGRD' then 'Y'
else 'N' end) as FIRST_PRIM_UGRD ,
(case when a.ACAD_CAREER<>'UGRD' then 'OTHR'
when adm.basis_admit_code='FY' then 'FRST'
when adm.basis_admit_code='TR' then 'TRAN' 
else ' ' end ) as Entry_Status_Code,
(case when a.PRIMARY_CAR_FLAG='N' or a.PRIMARY_CAR_FLAG is null or First_Term_Career is null then ' '
when First_Term_Career=a.strm and  adm.basis_admit_code='GR' and a.ACAD_CAREER='GRAD' and ct.ACAD_LEVEL_BOT = 'MAS' then 'Y'
else 'N' end) as FIRST_PRIM_GRAD_MASTERS ,
(case when a.PRIMARY_CAR_FLAG='N' or a.PRIMARY_CAR_FLAG is null or First_Term_Career is null then ' '
when First_Term_Career=a.strm and  adm.basis_admit_code='GR' and a.ACAD_CAREER='GRAD' and ct.ACAD_LEVEL_BOT = 'PHD' then 'Y'
else 'N' end) as First_Prim_GRAD_Doctoral  ,
(case when a.PRIMARY_CAR_FLAG='N' or a.PRIMARY_CAR_FLAG is null or First_Term_Career is null then ' '
when First_Term_Career=a.strm and d.Enrld_MSU_Prior='Y' then 'CONT'
when First_Term_Career=a.strm then 'NEW'
when d.MSU_Atnd_Preced_Flag='Y' then 'RTRN'
else 'RGAP' end ) as Term_Classif_Code,
(case when a.PRIMARY_CAR_FLAG='N' or a.PRIMARY_CAR_FLAG is null or cohort_entry is null then ' ' else cohort_entry end) as COHORT_PRIM_ENTRY,
--(case when mintermplan=a.strm then 'Y' else 'N' end ) as First_Term_In_Plan,
mintermplan  as First_Term_In_Plan,
(case when honr.stdnt_group is null then 'N' else 'Y' end ) as Honors_College_Member,
(case when substr(a.term_descrshort,1,1)<>'F' or a.Enrollment_status not in ('E','W') or  a.PRIMARY_CAR_FLAG='N' or a.PRIMARY_CAR_FLAG is null then ' '
when substr(a.term_descrshort,1,1)='F' and  (LAG((case when a.PRIMARY_CAR_FLAG='N' or a.PRIMARY_CAR_FLAG is null then ''
when First_Term_Career=a.strm and d.Enrld_MSU_Prior='Y' then 'CONT'
when First_Term_Career=a.strm then 'NEW'
when d.MSU_Atnd_Preced_Flag='Y' then 'RTRN'
else 'RGAP' end ) , 1, '') OVER(PARTITION BY a.emplid , a.student_level ORDER BY  a.emplid,a.student_level, a.strm ) in ('NEW','CONT') or 
(case when a.PRIMARY_CAR_FLAG='N' or a.PRIMARY_CAR_FLAG is null then ''
when First_Term_Career=a.strm and d.Enrld_MSU_Prior='Y' then 'CONT'
when First_Term_Career=a.strm then 'NEW'
when d.MSU_Atnd_Preced_Flag='Y' then 'RTRN'
else 'RGAP' end ) in ('NEW','CONT') )then 'Y'
else 'N' end ) as Fall_Entering_Cohort,

(case when greatest(nvl(exawd.postdeg,0),nvl(intawd.postdeg,0))=1 then '06'
when greatest(nvl(exawd.postdeg,0),nvl(intawd.postdeg,0))=2 then '10'
when greatest(nvl(exawd.postdeg,0),nvl(intawd.postdeg,0))=3 then '13'
when greatest(nvl(exawd.postdeg,0),nvl(intawd.postdeg,0))=4 then '14'
when greatest(nvl(exawd.postdeg,0),nvl(intawd.postdeg,0))=5 then '19'
when greatest(nvl(exawd.postdeg,0),nvl(intawd.postdeg,0))=6 then '17'
when greatest(nvl(exawd.postdeg,0),nvl(intawd.postdeg,0))=7 then '18'
when greatest(nvl(exawd.postdeg,0),nvl(intawd.postdeg,0))=8 then '15'
when greatest(nvl(exawd.postdeg,0),nvl(intawd.postdeg,0))=9 then '21'
else ' '
end)  Prior_High_Degree ,acdstd.ACAD_STNDNG_ACTN ,acdstd.ACAD_STNDNG_STAT,
a.STUDENT_LEVEL as RPT_DEGREE_CAREER,
(case when a.PRIMARY_CAR_FLAG='N' or a.PRIMARY_CAR_FLAG is null or First_Term_Rpt_Level is null then ' ' 
when  First_Term_Rpt_Level=a.strm then 'Y' else 'N' end ) as RPT_FIRST_PRIM_DEGR_CAR,
(case when a.PRIMARY_CAR_FLAG='N' or a.PRIMARY_CAR_FLAG is null or First_Term_Rpt_Level is null then ' '
when First_Term_Rpt_Level=a.strm and d.Enrld_MSU_Prior='Y' then 'CONT'
when First_Term_Rpt_Level=a.strm then 'NEW'
when d.MSU_Atnd_Preced_Flag='Y' then 'RTRN'
else 'RGAP' end )   as Term_Classif_Code_CAR_DEGR,
(case when a.PRIMARY_CAR_FLAG='N' or a.PRIMARY_CAR_FLAG is null or entrycohortlvl.cohort_entry_lvl is null then ' ' else entrycohortlvl.cohort_entry_lvl end) as RPT_COHORT_PRIM_ENTRY,
(case when substr(a.term_descrshort,1,1)<>'F' or a.Enrollment_status not in ('E','W') or  a.PRIMARY_CAR_FLAG='N' or a.PRIMARY_CAR_FLAG is null then ' '
when substr(a.term_descrshort,1,1)='F' and  (LAG((case when a.PRIMARY_CAR_FLAG='N' or a.PRIMARY_CAR_FLAG is null then ''
when First_Term_Rpt_Level=a.strm and d.Enrld_MSU_Prior='Y' then 'CONT'
when First_Term_Rpt_Level=a.strm then 'NEW'
when d.MSU_Atnd_Preced_Flag='Y' then 'RTRN'
else 'RGAP' end ) , 1, '') OVER(PARTITION BY a.emplid , a.student_level ORDER BY  a.emplid,a.student_level, a.strm ) in ('NEW','CONT') or 
(case when a.PRIMARY_CAR_FLAG='N' or a.PRIMARY_CAR_FLAG is null then ''
when First_Term_Rpt_Level=a.strm and d.Enrld_MSU_Prior='Y' then 'CONT'
when First_Term_Rpt_Level=a.strm then 'NEW'
when d.MSU_Atnd_Preced_Flag='Y' then 'RTRN'
else 'RGAP' end ) in ('NEW','CONT') )then 'Y'
else 'N' end ) as RPT_IPEDS_FALL_COHORT,
a.enrollment_career
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
            where  PRIMARY_CAR_FLAG='Y' and primary_plan_flag='Y' and enrollment_status in ('E','W'))
        ) b
on a.emplid=b.emplid 
and a.institution=b.institution
and  b.cnt=1
and a.student_level=b.student_level
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
            where  PRIMARY_CAR_FLAG='Y' and primary_plan_flag='Y' and enrollment_status in ('E','W')
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
                            where EDW_ACTV_IND='Y'
                            group by emplid
                            ) b
                on a.strm >= minterm and a.strm <=maxterm
                left join  termlvlenrl tm
                on b.emplid=tm.emplid and a.strm=tm.strm and tm.enrollment_status in ('E','W')
                where a.EDW_ACTV_IND='Y'
                ))
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
                   where  enrollment_status in ('E','W')
                and PRIMARY_CAR_FLAG ='Y' and primary_plan_flag='Y'
            group by emplid, institution,  acad_career,
                            (case when acad_career='GRAD' then acad_level_bot else acad_career end )
         ) a
    inner join siscs.s_term_tbl_v b
    on a.institution=b.institution
    and a.acad_career=b.acad_career
    and a.minstrm=b.strm
    where b.EDW_ACTV_IND='Y'
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
                   where  enrollment_status in ('E','W')
                and PRIMARY_CAR_FLAG ='Y' and primary_plan_flag='Y'
            group by emplid, institution, acad_career, student_level,
                            (case when student_level='GRAD' then acad_level_bot else student_level end )
         ) a
    inner join siscs.s_term_tbl_v b
    on a.institution=b.institution
    and a.acad_career=b.acad_career
    and a.minstrm=b.strm
    where b.EDW_ACTV_IND='Y'
) entrycohortlvl
on a.emplid=entrycohortlvl.emplid
and a.institution=entrycohortlvl.institution
and a.student_level=entrycohortlvl.student_level
and  (case when a.student_level='GRAD' then a.acad_level_bot else a.student_level end )= entrycohortlvl.acad_gr_lvl
--first time at plan (primary plan/career is not considered)
left join 
        (select distinct emplid,institution,acad_career,acad_plan, min(strm) as mintermplan
        from termlvlenrl
           where  enrollment_status in ('E','W')
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
                where d1.effdt<=sysdate and d.degree=d1.degree 
                and d1.EDW_ACTV_IND='Y')
and a.EDW_ACTV_IND='Y'
and t.EDW_ACTV_IND='Y'
and b.EDW_ACTV_IND='Y'
and d.EDW_ACTV_IND='Y'
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
                where d1.effdt<=sysdate and d.degree=d1.degree and d1.EDW_ACTV_IND='Y')
where a.EDW_ACTV_IND='Y' 
and d.EDW_ACTV_IND='Y'
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
where ct.EDW_ACTV_IND='Y'
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
                            --and a.institution=t.institution
                            --and t.strm=scar.strm
                            --and a.emplid=scar.emplid
                            --and scar.acad_career= t.acad_career
                            and a.effdt <= t.term_end_dt
                            and a.EDW_ACTV_IND='Y'
                            --and t.term_begin_dt <= sysdate
                            )
            and g.eff_status='A'
            and  g.stdnt_group='XHON'
            and g.EDW_ACTV_IND='Y' 
            and scar.EDW_ACTV_IND='Y'
            and t.EDW_ACTV_IND='Y') honr
on a.emplid=honr.emplid
and a.acad_career= honr.acad_career
and a.institution=honr.institution
and a.strm=honr.strm
inner join SISCS.P_STDNT_CAR_TERM_V ct
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
        and r.EDW_ACTV_IND='Y'
      and ct.strm >= r.effective_term
)
--add comp exam milestones for grad
left join ( select a.emplid, a.institution,a.acad_career,a.acad_plan_acad_prog,ms.milestone, ms.date_completed, ms.MILESTONE_COMPLETE, a.strm
             from SISCS.R_PRIMACY_RV a
             left join siscs.p_stdnt_car_mlstn_v ms
            on a.emplid=ms.emplid
            and a.institution=ms.institution
            and a.acad_career=ms.acad_career
            and a.acad_plan_acad_prog=ms.acad_prog
            and a.primary_plan_flag='Y'
            and ms.effdt = (select max(effdt)
                            from siscs.p_stdnt_car_mlstn_v ms1
                            where ms.emplid=ms1.emplid
                            and ms.institution=ms1.institution
                            and ms.acad_career=ms1.acad_career
                            and ms.acad_prog=ms1.acad_prog
                            and ms1.EDW_ACTV_IND='Y'
                            )
            and ms.EDW_ACTV_IND='Y'
) milestone
on a.emplid=milestone.emplid
and a.institution=milestone.institution
and a.strm=milestone.strm
and a.acad_career=milestone.acad_career
and a.acad_prog = milestone.acad_plan_acad_prog
and milestone.milestone='GCOMPEXAM'
and milestone.ACAD_CAREER = 'GRAD' 
and milestone.MILESTONE_COMPLETE = 'Y'
left join siscs.p_adm_basis_admit_v adm
on a.emplid= adm.emplid
and a.institution= adm.institution
and a.acad_career= adm.acad_career
-- add academic standing end term
left join (
select acadstdng1.emplid, acadstdng1.acad_career, acadstdng1.institution, acadstdng1.strm, effdt,effseq,ACAD_STNDNG_ACTN ,ACAD_STNDNG_STAT ,
COUNT(*) OVER(
          PARTITION BY acadstdng1.emplid, acadstdng1.acad_career, acadstdng1.institution, acadstdng1.strm
          ORDER BY
           acadstdng1.emplid, acadstdng1.acad_career, acadstdng1.institution, acadstdng1.strm, effdt,effseq
        ) AS seqorder
 from  siscs.P_ACAD_STDNG_ACTN_V acadstdng1 
 inner join  siscs.s_term_tbl_v t 
 on  acadstdng1.institution=t.institution
and acadstdng1.acad_career=t.acad_career
and t.strm=acadstdng1.strm
where  acadstdng1.effdt <= t.term_end_dt
 and acadstdng1.EDW_ACTV_IND='Y') acdstd
 
on acdstd.seqorder=1
and a.emplid= acdstd.emplid
and a.institution= acdstd.institution
and a.acad_career= acdstd.acad_career
and a.strm= acdstd.strm

where 
 a.primary_plan_flag='Y' 
and ct.EDW_ACTV_IND='Y'
and res.EDW_ACTV_IND='Y'
order by a.emplid, a.strm, a.acad_career, a.primary_plan_flag


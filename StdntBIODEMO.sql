select		
p_pers_data_effdt.emplid,		
--p_names.name                           as university_name,		
p_names.last_name ||','||(case	when p_namesc.first_name <> ' ' then	p_namesc.first_name	else p_names.first_name	end	)|| COALESCE(' ' || p_names.middle_name, '') as university_name,	
(
case
when p_namesc.first_name <> ' ' then
p_namesc.first_name
else
p_names.first_name
end
) as university_first_name,
p_names.middle_name                    as university_middle_name,		
p_names.last_name                      as university_last_name,		
p_names.name_suffix,		
p_citizenship.citizenship_status,		
s_citizen_sts_tbl.descrshort           as citizenship_descrshort,		
p_person.birthdate,		
p_pers_data_effdt.sex,		
p_scc_caf_persbiog.scc_caf_attr_tval   as gender_pref,		
p_person.dt_of_death,		
case		
when p_person.dt_of_death is null then		
'N'		
else		
'Y'		
end as deceased_flag,		
ipeds_groups_tbl.ipeds_group             as ipeds_race_ethnicity,		
ipeds_groups_tbl.ipeds_code,		
ipeds_groups_tbl.ipeds_group_short as ipeds_race_ethnicity_short_descr, 		
msu_race_table.ipeds_group               as race_ethnicity,				
p_scc_caf_persbioh.scc_caf_attr_tval   as tribal_affiliation,		
residency_off.city as res_city,		
residency_off.country as res_country,		
residency_off.county as res_county,		
residency_off.state as res_state     ,		
sa.campus_id		
from		
( ( ( ( ( ( (select * from siscs.p_pers_data_effdt_av where edw_actv_ind='Y' and edw_curr_ind='Y')  p_pers_data_effdt		
left outer join (select * from siscs.p_names_av  where edw_actv_ind='Y' and edw_curr_ind='Y')     p_namesc on p_pers_data_effdt.emplid = p_namesc.emplid		
and p_namesc.name_type = 'PRF' )		
left outer join (select * from siscs.p_scc_caf_persbio_av  where edw_actv_ind='Y' and edw_curr_ind='Y') p_scc_caf_persbiog on p_pers_data_effdt.emplid = p_scc_caf_persbiog.emplid		
and p_scc_caf_persbiog.scc_caf_attrib_nm = 'MSU_CC_GENDER_PREF'		
)		
left outer join (select * from siscs.p_scc_caf_persbio_av where edw_actv_ind='Y' and edw_curr_ind='Y')  p_scc_caf_persbioh on p_pers_data_effdt.emplid = p_scc_caf_persbioh.emplid		
and p_scc_caf_persbioh.scc_caf_attrib_nm = 'MSU_CC_TRIB_AFFL_NBR'		
)		
left outer join (SELECT		
p_citizenship.emplid,		
'International' AS ipeds_group	,	
'T' as ipeds_code,		
'Intl' as ipeds_group_short		
FROM		
( SELECT		
* from siscs.p_citizenship_av where edw_actv_ind='Y' and edw_curr_ind='Y')p_citizenship		
where		
p_citizenship.country = 'USA'		
and p_citizenship.citizenship_status = '4'		
union		
select		
p_citizenship.emplid,		
'Hispanic/Latino' as ipeds_group,		
'H' as ipeds_code,		
'Hispanic' as ipeds_group_short		
from		
(select * from siscs.p_citizenship_av where edw_actv_ind='Y' and edw_curr_ind='Y') p_citizenship		
where		
p_citizenship.country = 'USA'		
and p_citizenship.citizenship_status <> '4'		
and exists (		
select		
p_ethnicity_dtl.emplid		
from		
(select * from siscs.p_ethnicity_dtl_av where edw_actv_ind='Y' and edw_curr_ind='Y')p_ethnicity_dtl		
where		
p_ethnicity_dtl.emplid = p_citizenship.emplid		
and p_ethnicity_dtl.hisp_latino = 'Y'		
)		
union		
select		
p_citizenship.emplid,		
case		
when length(b.ethnic_list) > 1 then		
'Two or More Races'		
else		
t_xlattable_vw.xlatlongname		
end as ipeds_group	,	
case		
when length(b.ethnic_list) > 1 then	'M'	
when	t_xlattable_vw.XLATSHORTNAME	='Am. Indian' then '5'
when	t_xlattable_vw.XLATSHORTNAME	='Asian' then '11'
when	t_xlattable_vw.XLATSHORTNAME	='Black' then '2'
when	t_xlattable_vw.XLATSHORTNAME	='Hawaiian' then '10'
when	t_xlattable_vw.XLATSHORTNAME	='NS' then 'N'
when	t_xlattable_vw.XLATSHORTNAME	='White' then '1'
end as ipeds_code,		
case		
when length(b.ethnic_list) > 1 then	'Multiple'	
when	t_xlattable_vw.XLATSHORTNAME	='Am. Indian' then 'Amer Ind'
when	t_xlattable_vw.XLATSHORTNAME	='Hawaiian' then 'Hawaiian/PI'
when	t_xlattable_vw.XLATSHORTNAME	='NS' then 'Not Spcfd'
else	t_xlattable_vw.XLATSHORTNAME	
end as ipeds_group_short		
		
from		
(select * from siscs.p_citizenship_av where edw_actv_ind='Y' and edw_curr_ind='Y')    p_citizenship, (		
select		
z.emplid,		
listagg(z.ethnic_group, '') within group(		
order by		
z.ethnic_group		
) as ethnic_list		
from		
(		
select distinct		
p_ethnicity_dtl.emplid,		
s_ethnic_grp_tbl.ethnic_group		
from		
(select * from siscs.p_ethnicity_dtl_av where edw_actv_ind='Y' and edw_curr_ind='Y')   p_ethnicity_dtl,		
(select * from siscs.s_ethnic_grp_tbl_av where edw_actv_ind='Y' and edw_curr_ind='Y')  s_ethnic_grp_tbl		
where		
p_ethnicity_dtl.ethnic_grp_cd = s_ethnic_grp_tbl.ethnic_grp_cd		
and s_ethnic_grp_tbl.setid = 'USA'		
and s_ethnic_grp_tbl.effdt = (		
select		
max(b_ed.effdt)		
from		
siscs.s_ethnic_grp_tbl_av b_ed		
where		
s_ethnic_grp_tbl.setid = b_ed.setid		
and s_ethnic_grp_tbl.ethnic_grp_cd = b_ed.ethnic_grp_cd		
and b_ed.edw_actv_ind='Y' and b_ed.edw_curr_ind='Y'		
and b_ed.effdt <= sysdate		
)		
and not exists (		
select		
p_ethnicity_dtl_hispy.emplid		
from		
(select * from siscs.p_ethnicity_dtl_av where edw_actv_ind='Y' and edw_curr_ind='Y') p_ethnicity_dtl_hispy		
where		
p_ethnicity_dtl_hispy.emplid = p_ethnicity_dtl.emplid		
and p_ethnicity_dtl_hispy.hisp_latino = 'Y'		
)		
) z		
group by		
z.emplid		
) b		
left outer join (select * from siscs.t_xlattable_vw_av where edw_actv_ind='Y' and edw_curr_ind='Y')  t_xlattable_vw on t_xlattable_vw.fieldname = 'ETHNIC_GROUP'		
and t_xlattable_vw.fieldvalue = b.ethnic_list		
and t_xlattable_vw.eff_status = 'A'		
where		
p_citizenship.emplid = b.emplid		
and p_citizenship.country = 'USA'		
and p_citizenship.citizenship_status <> '4')ipeds_groups_tbl on p_pers_data_effdt.emplid = ipeds_groups_tbl.emplid )		
left outer join (SELECT		
p_citizenship.emplid,		
'Hispanic/Latino' AS ipeds_group,		
'H' as ipeds_code,		
'Hispanic' as ipeds_group_short		
FROM		
siscs.p_citizenship_av p_citizenship		
WHERE		
p_citizenship.country = 'USA'		
AND edw_actv_ind = 'Y'		
AND edw_curr_ind = 'Y'		
AND EXISTS (		
SELECT		
p_ethnicity_dtl.emplid		
FROM		
siscs.p_ethnicity_dtl_av p_ethnicity_dtl		
WHERE		
p_ethnicity_dtl.emplid = p_citizenship.emplid		
AND p_ethnicity_dtl.hisp_latino = 'Y'		
AND p_ethnicity_dtl.edw_actv_ind = 'Y'		
AND p_ethnicity_dtl.edw_curr_ind = 'Y'		
)		
UNION		
SELECT		
p_citizenship.emplid,		
CASE		
WHEN length(b.ethnic_list) > 1 THEN		
'Two or More Races' 		
ELSE		
t_xlattable_vw.xlatlongname		
END AS ipeds_group	,	
case		
when length(b.ethnic_list) > 1 then	'M'	
when	t_xlattable_vw.XLATSHORTNAME	='Am. Indian' then '5'
when	t_xlattable_vw.XLATSHORTNAME	='Asian' then '11'
when	t_xlattable_vw.XLATSHORTNAME	='Black' then '2'
when	t_xlattable_vw.XLATSHORTNAME	='Hawaiian' then '10'
when	t_xlattable_vw.XLATSHORTNAME	='NS' then 'N'
when	t_xlattable_vw.XLATSHORTNAME	='White' then '1'
end as ipeds_code,		
case		
when length(b.ethnic_list) > 1 then	'Multiple'	
when	t_xlattable_vw.XLATSHORTNAME	='Am. Indian' then 'Amer Ind'
when	t_xlattable_vw.XLATSHORTNAME	='Hawaiian' then 'Hawaiian/PI'
when	t_xlattable_vw.XLATSHORTNAME	='NS' then 'Not Spcfd'
else	t_xlattable_vw.XLATSHORTNAME	
end as ipeds_group_short		
FROM		
(		
SELECT		
*		
FROM		
siscs.p_citizenship_av		
WHERE		
edw_actv_ind = 'Y'		
AND edw_curr_ind = 'Y'		
) p_citizenship, (		
SELECT		
z.emplid,		
LISTAGG(z.ethnic_group, '') WITHIN GROUP(		
ORDER BY		
z.ethnic_group		
) AS ethnic_list		
FROM		
(		
SELECT DISTINCT		
p_ethnicity_dtl.emplid,		
s_ethnic_grp_tbl.ethnic_group		
FROM		
(		
SELECT		
*		
FROM		
siscs.p_ethnicity_dtl_av		
WHERE		
edw_actv_ind = 'Y'		
AND edw_curr_ind = 'Y'		
) p_ethnicity_dtl,		
(		
SELECT		
*		
FROM		
siscs.s_ethnic_grp_tbl_av		
WHERE		
edw_actv_ind = 'Y'		
AND edw_curr_ind = 'Y'		
) s_ethnic_grp_tbl		
WHERE		
p_ethnicity_dtl.ethnic_grp_cd = s_ethnic_grp_tbl.ethnic_grp_cd		
AND s_ethnic_grp_tbl.setid = 'USA'		
AND s_ethnic_grp_tbl.effdt = (		
SELECT		
MAX(b_ed.effdt)		
FROM		
(		
SELECT		
*		
FROM		
siscs.s_ethnic_grp_tbl_av		
WHERE		
edw_actv_ind = 'Y'		
AND edw_curr_ind = 'Y'		
) b_ed		
WHERE		
s_ethnic_grp_tbl.setid = b_ed.setid		
AND s_ethnic_grp_tbl.ethnic_grp_cd = b_ed.ethnic_grp_cd		
AND b_ed.effdt <= sysdate		
)		
AND NOT EXISTS (		
SELECT		
p_ethnicity_dtl_hispy.emplid		
FROM		
(		
SELECT		
*		
FROM		
siscs.p_ethnicity_dtl_av		
WHERE		
edw_actv_ind = 'Y'		
AND edw_curr_ind = 'Y'		
) p_ethnicity_dtl_hispy		
WHERE		
p_ethnicity_dtl_hispy.emplid = p_ethnicity_dtl.emplid		
AND p_ethnicity_dtl_hispy.hisp_latino = 'Y'		
)		
) z		
GROUP BY		
z.emplid		
) b		
LEFT OUTER JOIN (		
SELECT		
*		
FROM		
siscs.t_xlattable_vw_av		
WHERE		
edw_actv_ind = 'Y'		
AND edw_curr_ind = 'Y'		
) t_xlattable_vw ON t_xlattable_vw.fieldname = 'ETHNIC_GROUP'		
AND t_xlattable_vw.fieldvalue = b.ethnic_list		
AND t_xlattable_vw.eff_status = 'A'		
WHERE		
p_citizenship.emplid = b.emplid		
AND p_citizenship.country = 'USA')msu_race_table  on p_pers_data_effdt.emplid = msu_race_table.emplid )		
left outer join (SELECT		
a.emplid,		
a.acad_career,		
a.city,		
a.state,		
a.county,		
a.country,		
ROW_NUMBER() OVER(		
PARTITION BY a.emplid		
ORDER BY		
a.acad_career DESC		
) AS res_rank		
FROM		
siscs.p_residency_off_av a		
WHERE		
(a.effective_term = (		
SELECT		
MIN(a_et.effective_term)		
FROM		
siscs.p_residency_off_v a_et		
WHERE		
a.emplid = a_et.emplid		
AND a.acad_career = a_et.acad_career		
)or a.effective_term is null	)	
AND a.edw_actv_ind='Y' and a.edw_curr_ind='Y')                   residency_off ON p_pers_data_effdt.emplid = residency_off.emplid		
and residency_off.res_rank = 1 )		
inner join 		
(select * from siscs.p_names_Av  where edw_actv_ind='Y' and edw_curr_ind='Y')           p_names		
on  p_pers_data_effdt.emplid = p_names.emplid		
left join		
(select * from siscs.p_citizenship_av  where edw_actv_ind='Y' and edw_curr_ind='Y')     p_citizenship		
on p_pers_data_effdt.emplid = p_citizenship.emplid		
and p_citizenship.country = 'USA'		
left join 		
(select * from siscs.s_citizen_sts_tbl_av where edw_actv_ind='Y' and edw_curr_ind='Y')  s_citizen_sts_tbl		
on  p_citizenship.citizenship_status = s_citizen_sts_tbl.citizenship_status		
and s_citizen_sts_tbl.country = p_citizenship.country		
inner join  (select * from siscs.p_person_av   where edw_actv_ind='Y' and edw_curr_ind='Y')         p_person		
on  p_pers_data_effdt.emplid = p_person.emplid		
left join  siscs.p_person_sa_v sa		
on p_pers_data_effdt.emplid=sa.emplid		
		
where		
(p_pers_data_effdt.effdt = (		
select		
max(a_ed.effdt)		
from		
siscs.p_pers_data_effdt_av a_ed		
where		
p_pers_data_effdt.emplid = a_ed.emplid		
and a_ed.effdt <= sysdate		
and a_ed.edw_actv_ind='Y' and a_ed.edw_curr_ind='Y'		
) or p_pers_data_effdt.effdt is null)		
and ( p_scc_caf_persbiog.effdt = (		
select		
max(g_ed.effdt)		
from		
siscs.p_scc_caf_persbio_av g_ed		
where		
p_scc_caf_persbiog.emplid = g_ed.emplid		
and g_ed.edw_actv_ind='Y' and g_ed.edw_curr_ind='Y'		
and g_ed.effdt <= sysdate		
)		
or p_scc_caf_persbiog.effdt is null )		
and ( p_scc_caf_persbioh.effdt = (		
select		
max(h_ed.effdt)		
from		
siscs.p_scc_caf_persbio_av h_ed		
where		
p_scc_caf_persbioh.emplid = h_ed.emplid		
and h_ed.edw_actv_ind='Y' and h_ed.edw_curr_ind='Y'		
and h_ed.effdt <= sysdate		
)		
or p_scc_caf_persbioh.effdt is null )		
	
and (p_names.effdt = (		
select		
max(b_ed.effdt)		
from		
siscs.p_names_av b_ed		
where		
p_names.emplid = b_ed.emplid		
and p_names.name_type = b_ed.name_type		
and b_ed.edw_actv_ind='Y' and b_ed.edw_curr_ind='Y'		
and b_ed.effdt <= sysdate		
)OR p_names.effdt IS NULL)		
and p_names.name_type = 'PRI'		
and ( p_namesc.effdt = (		
select		
max(c_ed.effdt)		
from		
siscs.p_names_av c_ed		
where		
p_namesc.emplid = c_ed.emplid		
and p_namesc.name_type = c_ed.name_type		
and c_ed.edw_actv_ind='Y' and c_ed.edw_curr_ind='Y'		
and c_ed.effdt <= sysdate		
)		
or p_namesc.effdt is null )		
and p_pers_data_effdt.emplid in (
'102497123')
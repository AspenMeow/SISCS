        SELECT
            p_stdnt_car_term.strm,
            s_term_val_tbl.descrshort    AS term_descrshort,
            p_stdnt_car_term.emplid,
            p_stdnt_car_term.institution,
            p_stdnt_car_term.acad_career,
            (
                CASE
                    WHEN p_stdnt_car_term.acad_career = p_stdnt_car_term.billing_career
                 /*and p_acad_prog.prog_status = 'ac'*/ THEN
                        'Y'
                    ELSE
                        'N'
                END
            ) AS primary_car_flag,
            --p_stdnt_car_term.stdnt_car_nbr,
            p_acad_prog.stdnt_car_nbr,
            p_acad_prog.EXP_GRAD_TERM,
            p_acad_plan.acad_plan,
            (
                CASE
                    WHEN p_acad_plan.acad_plan = p_stdnt_equtn_var.variable_char1
                 /*and p_acad_prog.prog_status = 'ac'*/ THEN
                        'Y'
                    ELSE
                        'N'
                END
            ) AS primary_plan_flag,
            s_acad_plan_tbl.descr        AS acad_plan_descr,
            s_acad_plan_tbl.descrshort   AS acad_plan_descrshort,
            p_acad_prog.acad_prog        AS acad_plan_acad_prog,
            s_acad_prog_tbl.descr        AS acad_prog_descr,
            s_acad_prog_tbl.descrshort   AS acad_prog_descrshort,
            s_acad_plan_tbl.degree,
            s_acad_plan_tbl.descr        AS degree_descr,
            s_acad_plan_tbl.descrshort   AS degree_descrshort,
            s_degree_tbl.education_lvl,
            t_xlatitem.xlatlongname education_lvl_xlatlongname ,
            t_xlatitem.xlatshortname education_lvl_xlatshortname
        FROM
            siscs.p_stdnt_car_term_av p_stdnt_car_term
            LEFT OUTER JOIN (
                SELECT
                    *
                FROM
                    siscs.p_stdnt_equtn_var_av
                WHERE
                    edw_actv_ind='Y' and edw_curr_ind='Y'
            ) p_stdnt_equtn_var ON p_stdnt_car_term.emplid = p_stdnt_equtn_var.emplid
                                   AND p_stdnt_car_term.institution = p_stdnt_equtn_var.institution
                                   AND p_stdnt_car_term.strm = p_stdnt_equtn_var.strm
                                   AND p_stdnt_equtn_var.billing_career = p_stdnt_car_term.acad_career
            INNER JOIN (
                SELECT
                    *
                FROM
                    siscs.p_acad_prog_av
                WHERE
                    edw_actv_ind='Y' and edw_curr_ind='Y'
            ) p_acad_prog ON p_stdnt_car_term.emplid = p_acad_prog.emplid
                             AND p_stdnt_car_term.acad_career = p_acad_prog.acad_career
                             AND p_stdnt_car_term.institution = p_acad_prog.institution
            INNER JOIN (
                SELECT
                    *
                FROM
                    siscs.p_acad_plan_av
                WHERE
                    edw_actv_ind='Y' and edw_curr_ind='Y'
            ) p_acad_plan ON p_acad_prog.emplid = p_acad_plan.emplid
                             AND p_acad_prog.acad_career = p_acad_plan.acad_career
                             AND p_acad_prog.stdnt_car_nbr = p_acad_plan.stdnt_car_nbr
                             AND p_acad_plan.effdt = p_acad_prog.effdt
                             AND p_acad_prog.effseq = p_acad_plan.effseq
            INNER JOIN (
                SELECT
                    *
                FROM
                    siscs.s_term_tbl_av
                WHERE
                    edw_actv_ind='Y' and edw_curr_ind='Y'
            ) s_term_tbl ON p_stdnt_car_term.acad_career = s_term_tbl.acad_career
                            AND p_stdnt_car_term.institution = s_term_tbl.institution
                            AND p_stdnt_car_term.strm = s_term_tbl.strm
            INNER JOIN (
                SELECT
                    *
                FROM
                    siscs.s_acad_plan_tbl_av
                WHERE
                    edw_actv_ind='Y' and edw_curr_ind='Y'
            ) s_acad_plan_tbl ON p_stdnt_car_term.institution = s_acad_plan_tbl.institution
                                 AND p_acad_plan.acad_plan = s_acad_plan_tbl.acad_plan
            INNER JOIN (
                SELECT
                    *
                FROM
                    siscs.s_acad_prog_tbl_av
                WHERE
                    edw_actv_ind='Y' and edw_curr_ind='Y'
            ) s_acad_prog_tbl ON p_acad_prog.institution = s_acad_prog_tbl.institution
                                 AND p_acad_prog.acad_prog = s_acad_prog_tbl.acad_prog
            INNER JOIN (
                SELECT
                    *
                FROM
                    siscs.s_term_val_tbl_av
                WHERE
                    edw_actv_ind='Y' and edw_curr_ind='Y'
            ) s_term_val_tbl ON p_stdnt_car_term.strm = s_term_val_tbl.strm
            --INNER JOIN siscs.gtt_s_dreg_tbl      gtt_s_dreg_tbl ON s_acad_plan_tbl.degree = gtt_s_dreg_tbl.degree 
            INNER JOIN (
                SELECT
                    *
                FROM
                    siscs.s_degree_tbl_av
                WHERE
                    edw_actv_ind='Y' and edw_curr_ind='Y'
            ) s_degree_tbl ON s_acad_plan_tbl.degree = s_degree_tbl.degree
            LEFT OUTER JOIN (
                SELECT
                    *
                FROM
                    siscs.t_xlatitem_av t_xlatitem
                WHERE
                    edw_actv_ind='Y' and edw_curr_ind='Y'
                    AND ( t_xlatitem.effdt = (
                SELECT
                    MAX(x_ed.effdt)             --ADDED
                FROM
                    siscs.t_xlatitem_av x_ed                    --ADDED
                WHERE
                    x_ed.edw_actv_ind = 'Y' and x_ed.edw_curr_ind='Y'
                    AND x_ed.fieldname = t_xlatitem.fieldname      --ADDED
                    AND x_ed.fieldvalue = t_xlatitem.fieldvalue     --ADDED

                    AND x_ed.effdt <= sysdate
            )       --ADDED
                  OR t_xlatitem.effdt IS NULL )
            ) t_xlatitem ON s_degree_tbl.education_lvl = t_xlatitem.fieldvalue
                            AND t_xlatitem.fieldname = 'EDUCATION_LVL'
        WHERE
            p_stdnt_car_term.edw_actv_ind='Y' and  p_stdnt_car_term.edw_curr_ind='Y'
            AND ( s_acad_prog_tbl.effdt = (
                SELECT
                    MAX(g_ed.effdt)
                FROM
                    siscs.s_acad_prog_tbl_av g_ed
                WHERE
                    g_ed.edw_actv_ind = 'Y' and g_ed.edw_curr_ind='Y'
                    AND s_acad_prog_tbl.institution = g_ed.institution
                    AND s_acad_prog_tbl.acad_prog = g_ed.acad_prog

                    AND g_ed.effdt <= s_term_tbl.term_end_dt --<= s_term_tbl.term_end_dt
            )
                  OR s_acad_prog_tbl.effdt IS NULL )
            AND ( s_acad_plan_tbl.effdt = (
                SELECT
                    MAX(f_ed.effdt)
                FROM
                    siscs.s_acad_plan_tbl_av f_ed
                WHERE
                    f_ed.edw_actv_ind = 'Y' and f_ed.edw_curr_ind='Y'
                    AND s_acad_plan_tbl.institution = f_ed.institution
                    AND s_acad_plan_tbl.acad_plan = f_ed.acad_plan

                    AND f_ed.effdt <= s_term_tbl.term_end_dt
            )
                  OR s_acad_plan_tbl.effdt IS NULL )
            AND ( p_acad_prog.effdt = (
                SELECT
                    MAX(b_ed.effdt)
                FROM
                    siscs.p_acad_prog_av b_ed
                WHERE
                    b_ed.edw_actv_ind = 'Y' and b_ed.edw_curr_ind='Y'
                    AND p_acad_prog.emplid = b_ed.emplid
                    AND p_acad_prog.acad_career = b_ed.acad_career
                    AND p_acad_prog.stdnt_car_nbr = b_ed.stdnt_car_nbr

                    AND b_ed.effdt <= s_term_tbl.term_end_dt
            )
                  OR p_acad_prog.effdt IS NULL )
            AND ( p_acad_prog.effseq = (
                SELECT
                    MAX(b_es.effseq)
                FROM
                    siscs.p_acad_prog_av b_es
                WHERE
                    b_es.edw_actv_ind = 'Y' and b_es.edw_curr_ind='Y'
                    AND p_acad_prog.emplid = b_es.emplid
                    AND p_acad_prog.acad_career = b_es.acad_career
                    AND p_acad_prog.stdnt_car_nbr = b_es.stdnt_car_nbr

                    AND p_acad_prog.effdt = b_es.effdt
            )
                  OR p_acad_prog.effseq IS NULL )                      --ADDED
            AND ( s_degree_tbl.effdt = (
                SELECT
                    MAX(i_ed.effdt)               --ADDED
                FROM
                    siscs.s_degree_tbl_av i_ed             --ADDED   
                WHERE
                    i_ed.edw_actv_ind = 'Y' and i_ed.edw_curr_ind='Y'
                    AND i_ed.degree = s_degree_tbl.degree         --ADDED

                    AND i_ed.effdt <= s_term_tbl.term_end_dt
            )
                  OR s_degree_tbl.effdt IS NULL );
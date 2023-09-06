/*
 * calculate enrollment count for each course after Fall 2020
 * join PS_F_CLASS_ENRLMT to get person_SID
 * join PS_D_TERM to get term infor
 * join PS_D_CLASS to get class details
 * join PS_D_ENRLMT_STAT
 * Q: there are a lot of course with only 1 person enrolled: count > 5 
 * Q: Do we need to limit the acad program to only undergrad? acad = ugrd
 */


 

WITH DFW_count AS (
	SELECT  
		count (PFCE.PERSON_SID) AS dfw_student
		,PDT.TERM_CD 
		,PDT.TERM_SD 
	  	,PDC2.CATALOG_NBR
	   ,PDC2.CRSE_CD  
	   ,PDC2.CRSE_LD
	   ,PDC2.SESSION_CD 
	   ,PDC2.SESSION_SD 
	   ,PDAC.ACAD_CAR_CD 
FROM SYSADM.PS_F_CLASS_ENRLMT pfce 
LEFT JOIN SYSADM.PS_D_GRADE pdg -- GET geade IN (D,F,W)
ON pfce.GRADE_SID = pdg.GRADE_SID 
LEFT JOIN SYSADM.PS_D_ENRLMT_STAT pdes -- GET the enrollment stat TO see who drops
ON PFCE.ENRLMT_STAT_SID = PDES.ENRLMT_STAT_SID
LEFT JOIN SYSADM.PS_D_CRSE pdc -- GET the course sid
ON pfce.CRSE_SID = pdc.CRSE_SID 
LEFT JOIN SYSADM.PS_D_CLASS pdc2  -- GET the course name
ON pfce.CLASS_SID = PDC2.CLASS_SID AND PFCE.SESSION_SID = PDC2.SESSION_SID 
LEFT JOIN SYSADM.PS_D_TERM pdt 
ON PFCE.TERM_SID = PDT.TERM_SID 
LEFT JOIN sysadm.ps_d_acad_car pdac
ON  pdac.acad_car_sid = pfce.acad_car_sid
LEFT JOIN sysadm.ps_d_campus camp
ON  camp.campus_sid = pfce.campus_sid
WHERE 1=1
AND PFCE.INSTITUTION_SID = 2
AND camp.campus_cd = 'BLDR'
AND PDES.ENRLMT_STAT_ID IN ( 'E', 'D')
AND pdt.TERM_CD >= '2207' -- remove 2020 Spring AND 2020 summer FOR different acad program)
AND pdac.ACAD_CAR_CD != 'NOCR' --Non-credit
AND pdac.ACAD_CAR_CD != 'NDGR' --Graduate Non-DEGREE
AND PDC2.SESSION_SD NOT LIKE 'CE%'
AND pdg.GRADE_CD IN ('D','F','W')
GROUP BY 	
	  	 PDT.TERM_CD 
		,PDT.TERM_SD 
	  	,PDC2.CATALOG_NBR
	   ,PDC2.CRSE_CD  
	   ,PDC2.CRSE_LD
	   ,PDAC.ACAD_CAR_CD 
	   ,PDC2.SESSION_CD 
	   ,PDC2.SESSION_SD 
	   ),
DF_count AS (
	SELECT  
		count (PFCE.PERSON_SID) AS DF_student
		,PDT.TERM_CD 
		,PDT.TERM_SD 
	  	,PDC2.CATALOG_NBR
	   ,PDC2.CRSE_CD  
	   ,PDC2.CRSE_LD
	   ,PDC2.SESSION_CD 
	   ,PDC2.SESSION_SD 
	   ,PDAC.ACAD_CAR_CD 
FROM SYSADM.PS_F_CLASS_ENRLMT pfce 
LEFT JOIN SYSADM.PS_D_GRADE pdg -- GET geade IN (D,F,W)
ON pfce.GRADE_SID = pdg.GRADE_SID 
LEFT JOIN SYSADM.PS_D_ENRLMT_STAT pdes -- GET the enrollment stat TO see who drops
ON PFCE.ENRLMT_STAT_SID = PDES.ENRLMT_STAT_SID
LEFT JOIN SYSADM.PS_D_CRSE pdc -- GET the course sid
ON pfce.CRSE_SID = pdc.CRSE_SID 
LEFT JOIN SYSADM.PS_D_CLASS pdc2  -- GET the course name
ON pfce.CLASS_SID = PDC2.CLASS_SID AND PFCE.SESSION_SID = PDC2.SESSION_SID 
LEFT JOIN SYSADM.PS_D_TERM pdt 
ON PFCE.TERM_SID = PDT.TERM_SID 
LEFT JOIN sysadm.ps_d_acad_car pdac
ON  pdac.acad_car_sid = pfce.acad_car_sid
LEFT JOIN sysadm.ps_d_campus camp
ON  camp.campus_sid = pfce.campus_sid
WHERE 1=1
AND PFCE.INSTITUTION_SID = 2
AND camp.campus_cd = 'BLDR'
AND PDES.ENRLMT_STAT_ID IN ( 'E', 'D')
AND pdt.TERM_CD >= '2207'  -- remove 2020 Spring AND 2020 summer FOR different acad program)
AND pdt.ACAD_CAR_CD != 'NOCR' --Non-credit
AND pdt.ACAD_CAR_CD != 'NDGR' --Graduate Non-DEGREE
AND PDC2.SESSION_SD NOT LIKE 'CE%'
AND pdg.GRADE_CD IN ('D','F')
GROUP BY 	
	  	 PDT.TERM_CD 
		,PDT.TERM_SD 
	  	,PDC2.CATALOG_NBR
	   ,PDC2.CRSE_CD  
	   ,PDC2.CRSE_LD
	   ,PDAC.ACAD_CAR_CD 
	   ,PDC2.SESSION_CD 
	   ,PDC2.SESSION_SD 
),	   
student_count AS 
(SELECT 
		count (PFCE.PERSON_SID) AS student_count
		,PDT.TERM_CD 
		,PDT.TERM_SD 
	    ,PDC2.CATALOG_NBR
	    ,PDC2.CRSE_CD 
	    ,PDC2.CRSE_LD
		,PDT.ACAD_CAR_CD
	    ,PDC2.SESSION_CD 
	    ,PDC2.SESSION_SD 
FROM SYSADM.PS_F_CLASS_ENRLMT pfce 
LEFT JOIN SYSADM.PS_D_ENRLMT_STAT pdes -- GET the enrollment stat TO see who drops
ON PFCE.ENRLMT_STAT_SID = PDES.ENRLMT_STAT_SID
LEFT JOIN SYSADM.PS_D_CRSE pdc -- GET the course sid
ON pfce.CRSE_SID = pdc.CRSE_SID 
LEFT JOIN SYSADM.PS_D_CLASS pdc2 -- GET the course name
ON pfce.CLASS_SID = PDC2.CLASS_SID AND PFCE.SESSION_SID = PDC2.SESSION_SID 
LEFT JOIN SYSADM.PS_D_TERM pdt -- GET the term infro
ON PFCE.TERM_SID = PDT.TERM_SID 
LEFT JOIN sysadm.ps_d_acad_car pdac
ON  pdac.acad_car_sid = pfce.acad_car_sid
LEFT JOIN sysadm.ps_d_campus camp
ON  camp.campus_sid = pfce.campus_sid
WHERE 1=1
AND PFCE.INSTITUTION_SID = 2
AND camp.campus_cd = 'BLDR'
AND PDES.ENRLMT_STAT_ID IN ( 'E', 'D')-- ONLY show enrolled 
AND pdt.TERM_CD >= '2207' -- remove 2020 Spring AND 2020 summer FOR different acad program)
AND PDAC.ACAD_CAR_CD  = 'UGRD' -- undergrad 
AND PDAC.ACAD_CAR_CD != 'NOCR' --Non-credit
AND PDAC.ACAD_CAR_CD != 'NDGR' --Graduate Non-DEGREE
AND PDC2.SESSION_SD NOT LIKE 'CE%'
GROUP BY 	
	     PDT.TERM_CD 
		,PDT.TERM_SD 
		,PDT.ACAD_CAR_CD
	    ,PDC2.CATALOG_NBR
	    ,PDC2.CRSE_CD 
	    ,PDC2.CRSE_LD
	    ,PDC2.SESSION_CD 
	    ,PDC2.SESSION_SD 
)
SELECT  
		SC.TERM_CD 
		,SC.TERM_SD 
		,SC.ACAD_CAR_CD
	    ,SC.CATALOG_NBR
	    ,SC.CRSE_CD 
	    ,SC.CRSE_LD
	    ,SC.SESSION_CD 
	    ,SC.SESSION_SD 
	    ,SC.student_count
	    ,DFW.dfw_student
	    ,DF.DF_student
		,(ROUND(DFW.dfw_student/SC.STUDENT_COUNT,4)) * 100 AS DFW_PERCENTAGE
		,(ROUND(DF.DF_student/SC.STUDENT_COUNT,4))* 100 AS DF_PERCENTAGE
FROM student_count SC
LEFT JOIN DFW_count dfw
ON SC.TERM_CD  = dfw.TERM_CD AND SC.CRSE_CD = dfw.CRSE_CD AND SC.session_cd = DFW.session_cd
LEFT JOIN DF_count DF
ON SC.TERM_CD  = DF.TERM_CD AND SC.CRSE_CD = DF.CRSE_CD AND SC.session_cd = DF.session_cd
--WHERE (ROUND(DFW.dfw_student/SC.STUDENT_COUNT,4)) * 100 = 100

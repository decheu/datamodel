--------
-- View for the swmm module class storages
-- 20190329 qgep code sprint SB, TP
--------
CREATE OR REPLACE VIEW qgep_swmm.vw_storages AS

SELECT
	wn.obj_id as Name,
	coalesce(wn.bottom_level,0) as InvertElev,
	coalesce((co.level-wn.bottom_level),0) as MaxDepth,
	0 as InitDepth,
	'FUNCTIONAL' as Shape,
	1000 as CurveCoefficientOrCurveName, -- curve coefficient if FONCTIONAL curve name if TABULAR
	0 as CurveExponent, -- if FONCTIONAL
	0 as CurveConstant, -- if FONCTIONAL
	0 as SurchargeDepth,
	0 as Fevap,
	NULL as Psi,
	NULL as Ksat, -- conductivity
	NULL as IMD,	
	ws.identifier::text as description,
	CONCAT_WS(',','special_structure', ssf.value_en) as tag,
	wn.situation_geometry as geom,
	CASE 
		WHEN status IN (7959, 6529, 6526) THEN 'planned'
		ELSE 'current'
	END as state
FROM qgep_od.special_structure ss
LEFT JOIN qgep_od.wastewater_structure ws ON ws.obj_id::text = ss.obj_id::text
LEFT JOIN qgep_od.wastewater_networkelement we ON we.fk_wastewater_structure::text = ws.obj_id::text
LEFT JOIN qgep_od.wastewater_node wn on wn.obj_id = we.obj_id
LEFT JOIN qgep_od.cover co on ws.fk_main_cover = co.obj_id
LEFT JOIN qgep_vl.special_structure_function ssf on ss.function = ssf.code
WHERE ss.function IN ( -- must be the same list in vw_swmm_junctions
6397, --"pit_without_drain"
-- 245, --"drop_structure"
6398, --"hydrolizing_tank"
-- 5371, --"other"
-- 386, --"venting"
-- 3234, --"inverse_syphon_chamber"
-- 5091, --"syphon_head"
-- 6399, --"septic_tank_two_chambers"
3348, --"terrain_depression"
336, --"bolders_bedload_catchement_dam"
-- 5494, --"cesspit"
6478, --"septic_tank"
-- 2998, --"manhole"
-- 2768, --"oil_separator"
-- 246, --"pump_station"
3673, --"stormwater_tank_with_overflow"
3674, --"stormwater_tank_retaining_first_flush"
5574, --"stormwater_retaining_channel"
3675, --"stormwater_sedimentation_tank"
3676, --"stormwater_retention_tank"
5575, --"stormwater_retention_channel"
5576, --"stormwater_storage_channel"
3677 --"stormwater_composite_tank"
-- 5372 --"stormwater_overflow"
-- 5373, --"floating_material_separator"
-- 383	, --"side_access"
-- 227, --"jetting_manhole"
-- 4799, --"separating_structure"
-- 3008, --"unknown"
-- 2745, --"vortex_manhole"
)
AND ws._function_hierarchic in (5066, 5068, 5069, 5070, 5064, 5071, 5062, 5072, 5074)
AND status IN (6530, 6533, 8493, 6529, 6526, 7959)
UNION ALL
SELECT
	wn.obj_id as Name,
	coalesce(wn.bottom_level,0) as InvertElev,
	coalesce((ii.upper_elevation-wn.bottom_level),0) as MaxDepth,
	0 as InitDepth,
	'FUNCTIONAL' as Shape,
	1000 as CurveCoefficientOrCurveName, -- curve coefficient if FONCTIONAL curve name if TABULAR
	0 as CurveExponent, -- if FONCTIONAL
	0 as CurveConstant, -- if FONCTIONAL
	0 as SurchargeDepth,
	0 as Fevap,
	NULL as Psi,
	(((absorption_capacity * 60 * 60) / 1000) / effective_area) * 1000 as Ksat, -- conductivity (liter/s * 60 * 60) -> liter/h, (liter/h / 1000)	-> m3/h,  (m/h *1000) -> mm/h
	NULL as IMD,
	ws.identifier::text as description,
	CONCAT_WS(',','infiltration_installation', iik.value_en) as tag,
	wn.situation_geometry as geom,
	CASE 
		WHEN status IN (7959, 6529, 6526) THEN 'planned'
		ELSE 'current'
	END as state
FROM qgep_od.infiltration_installation as ii
LEFT JOIN qgep_od.wastewater_structure ws ON ws.obj_id::text = ii.obj_id::text
LEFT JOIN qgep_od.wastewater_networkelement we ON we.fk_wastewater_structure::text = ws.obj_id::text
LEFT JOIN qgep_od.wastewater_node wn on wn.obj_id = we.obj_id
LEFT JOIN qgep_vl.infiltration_installation_kind iik on ii.kind = iik.code
WHERE ii.kind IN (
--3282	--"with_soil_passage"
--3285	--"without_soil_passage"
--3279	--"surface_infiltration"
--277	--"gravel_formation"
--3284	--"combination_manhole_pipe"
--3281	--"swale_french_drain_infiltration"
--3087	--"unknown"
--3280	--"percolation_over_the_shoulder"
276		--"infiltration_basin"
--278	--"adsorbing_well"
--3283	--"infiltration_pipe_sections_gallery"
)
AND ws._function_hierarchic in (5066, 5068, 5069, 5070, 5064, 5071, 5062, 5072, 5074)
AND status IN (6530, 6533, 8493, 6529, 6526, 7959);

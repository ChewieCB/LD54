extends Node

enum Officer {
	NONE,
	PRESSLEY,
	TORGON,
	FAROQ_KHAN, # Boost food production
	SAM_CARTER,
	GOVERNOR_JERREROD, # Boost habitation capacity
	MARY_WATNEY,
	DR_DORIAN
}

enum CrewmateStatus {
	NONE,
	HEALTHY,
	INFECTED,
	INJURED,
	CRITICAL,
}

enum BuildingType {
	NONE,
	FOOD,
	WATER,
	AIR,
	METAL,
	HABITATION,
	CRYO_POD,
	STORAGE,
	SECTOR
}

enum ResourceType {
	NONE,
	POPULATION,
	STORAGE,
	HOUSING,
	MORALE,
	FOOD,
	WATER,
	AIR,
	METAL,
}

enum AlertType {
	POPULATION,
	WORKER,
	FOOD,
	WATER,
	AIR,
	MORALE,
	PROXIMITY,
	RESEARCH
}


# Do not add id mid-array, always add it at the end, even if it
# look messy. Add mid-array will break the research trees.
# We will do a refactor when this look messy enough.
enum UpgradeId {
	NONE,
	CREW_SUPPLIES_FOOD_2,
	CREW_SUPPLIES_FOOD_3,
	CREW_SUPPLIES_WATER_2,
	CREW_SUPPLIES_WATER_3,
	CREW_SUPPLIES_AIR_2,
	CREW_SUPPLIES_AIR_3,
	HABITATION_MEDICAL_HOUSE_2,
	HABITATION_MEDICAL_HOUSE_3,
	HABITATION_MEDICAL_CLINIC_1,
	HABITATION_MEDICAL_CLINIC_2,
	HABITATION_MEDICAL_CLINIC_3,
	MANUFACTURE_PREFAB_FAC_1,
	MANUFACTURE_PREFAB_FAC_2,
	MANUFACTURE_PREFAB_FAC_3,
	MANUFACTURE_TOOL_WS_1,
	MANUFACTURE_TOOL_WS_2,
	MANUFACTURE_TOOL_WS_3,
	MANUFACTURE_ELECTRO_1,
	MANUFACTURE_ELECTRO_2,
	MANUFACTURE_ELECTRO_3,
	MANUFACTURE_METAMAT_1,
	MANUFACTURE_METAMAT_2,
	MANUFACTURE_METAMAT_3,
	CONSTRUCTION_LOGIC_WAREHOUSE,
	CONSTRUCTION_LOGIC_STOCK_ANALYSIS,
	CONSTRUCTION_LOGIC_ADV_LOGISTIC,
	CONSTRUCTION_LOGIC_ADV_SORTERS,
	CONSTRUCTION_LOGIC_AUTOMATED_WAREHOUSES,
	CONSTRUCTION_LOGIC_CREW_CHIEF,
	CONSTRUCTION_LOGIC_DEEP_SPACE,
	CONSTRUCTION_LOGIC_DRONE,
	CONSTRUCTION_LOGIC_IMPROVE_SCHEMATICS,
	CONSTRUCTION_LOGIC_AI_ENHANCED_SCHEMATICS,
	CONSTRUCTION_LOGIC_AI_GENERATED_SCHEMATICS,
	SHIP_INFRA_TIGHTBEAM_COMM,
	SHIP_INFRA_QUANTUM_COMM,
	SHIP_INFRA_SCANNER_ARRAY,
	SHIP_INFRA_SURVEY_DRONE,
	SHIP_INFRA_REDUNDANT_ENGINE,
	SHIP_INFRA_AI_REACTOR_MANAGEMENT,
	SHIP_INFRA_PRECISE_JUMP,
	SHIP_INFRA_AI_ASTRONAVIGATION,
	SHIP_INFRA_HULL_UPGRADE_EXPERTISE,
	SHIP_INFRA_TITANIUM_HULL,
	SHIP_INFRA_EMERGENCY_COMPARTMENT,
	SHIP_INFRA_MODULAR_HULL_PLATES,
	AGRI_SPACEDUST,
	AGRI_PHOTOSYNTHESIS,
	AGRI_EXTRACT_FUILD,
	AGRI_SPACEDUST_ENHANCED,
	AGRI_HARMONIC_CYCLE,
	AGRI_ACCEL_GROWTH,
	AGRI_OPTIMIZED_DESIGN,
	CONSTRUCTION_LOGIC_SPECIALIZED_WAREHOUSE,

}

# FIXME - find a better place to store this
var BUILD_VERSION: String
# Flag to enable all buildings from start for debugging
var debug_buildings: bool = false

func _ready():
	var file = FileAccess.open("res://build_tag.cfg", FileAccess.READ)
	BUILD_VERSION = file.get_as_text()
	file.close()

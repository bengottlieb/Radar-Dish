

#define		kDefaults_RadarUsernameKey				@"radar_username"
#define		kDefaults_RadarPasswordKey				@"radar_password"

#define		kDefaults_OpenRadarUsernameKey			@"openradar_username"
#define		kDefaults_OpenRadarPasswordKey			@"openradar_password"

#define		kDefaults_versionOptions				@"frequent_versions"


#define		kDefaults_LastUsedProduct				@"last_used: product"
#define		kDefaults_LastUsedClassification		@"last_used: classification"
#define		kDefaults_LastUsedVersion				@"last_used: version"
#define		kDefaults_LastUsedReproducibility		@"last_used: reproducibility"

#define		kNotification_connectionStatusChanged	@"connection_status_changed"




typedef enum {
	radar_submit_state_notStarted,
	radar_submit_state_credentialEntryLoading,
	radar_submit_state_welcomeScreenLoading,
	radar_submit_state_newProblemScreenLoading,
	radar_submit_state_submitting,
	radar_submit_state_idle
} radar_submit_state;



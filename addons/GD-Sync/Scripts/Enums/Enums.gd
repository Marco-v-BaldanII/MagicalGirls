class_name ENUMS
## @deprecated

#Copyright (c) 2024 GD-Sync.
#All rights reserved.
#
#Redistribution and use in source form, with or without modification,
#are permitted provided that the following conditions are met:
#
#1. Redistributions of source code must retain the above copyright notice,
#   this list of conditions and the following disclaimer.
#
#2. Neither the name of GD-Sync nor the names of its contributors may be used
#   to endorse or promote products derived from this software without specific
#   prior written permission.
#
#THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
#EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
#OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
#SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
#INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
#TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
#BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
#CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
#ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
#SUCH DAMAGE.

enum CONNECTION_STATUS
{
	LOBBY_SWITCH = -1,
	DISABLED,
	FINDING_LB,
	PINGING_SERVERS,
	CONNECTING,
	CONNECTED,
	CONNECTION_SECURED,
}

enum PACKET_CHANNEL
{
	SETUP,
	SERVER,
	RELIABLE,
	UNRELIABLE,
	INTERNAL,
}

enum PACKET_VALUE
{
	PADDING,
	CLIENT_REQUESTS,
	SERVER_REQUESTS,
	INTERNAL_REQUESTS,
}

enum REQUEST_TYPE
{
	VALIDATE_KEY,
	SECURE_CONNECTION,
	MESSAGE,
	SET_VARIABLE,
	CALL_FUNCTION,
	SET_VARIABLE_CACHED,
	CALL_FUNCTION_CACHED,
	CACHE_NODE_PATH,
	ERASE_NODE_PATH_CACHE,
	CACHE_NAME,
	ERASE_NAME_CACHE,
	SET_MC_OWNER,
	CREATE_LOBBY,
	JOIN_LOBBY,
	LEAVE_LOBBY,
	OPEN_LOBBY,
	CLOSE_LOBBY,
	SET_LOBBY_TAG,
	ERASE_LOBBY_TAG,
	SET_LOBBY_DATA,
	ERASE_LOBBY_DATA,
	SET_LOBBY_VISIBILITY,
	SET_LOBBY_PLAYER_LIMIT,
	SET_LOBBY_PASSWORD,
	GET_PUBLIC_LOBBIES,
	SET_PLAYER_USERNAME,
	SET_PLAYER_DATA,
	ERASE_PLAYER_DATA,
	SET_CONNECT_TIME,
	SET_SETTING,
	CREATE_ACCOUNT,
	DELETE_ACCOUNT,
	VERIFY_ACCOUNT,
	LOGIN,
	LOGIN_FROM_SESSION,
	LOGOUT,
	SET_PLAYER_DOCUMENT,
	HAS_PLAYER_DOCUMENT,
	GET_PLAYER_DOCUMENT,
	DELETE_PLAYER_DOCUMENT,
}

enum MESSAGE_TYPE
{
	CRITICAL_ERROR,
	CLIENT_ID_RECEIVED,
	CLIENT_KEY_RECEIVED,
	INVALID_PUBLIC_KEY,
	SET_NODE_PATH_CACHE,
	ERASE_NODE_PATH_CACHE,
	SET_NAME_CACHE,
	ERASE_NAME_CACHE,
	SET_MC_OWNER,
	HOST_CHANGED,
	LOBBY_CREATED,
	LOBBY_CREATION_FAILED,
	LOBBY_JOINED,
	SWITCH_SERVER,
	LOBBY_JOIN_FAILED,
	LOBBIES_RECEIVED,
	LOBBY_DATA_RECEIVED,
	LOBBY_DATA_CHANGED,
	LOBBY_TAGS_CHANGED,
	PLAYER_DATA_RECEIVED,
	PLAYER_DATA_CHANGED,
	CLIENT_JOINED,
	CLIENT_LEFT,
	SET_CONNECT_TIME,
	SET_SENDER_ID,
	SET_DATA_USAGE,
}

enum SETTING
{
	API_VERSION,
	USE_SENDER_ID,
}

enum DATA
{
	REQUEST_TYPE,
	NAME,
	VALUE,
	TARGET_CLIENT = 3,
}

enum LOBBY_DATA
{
	NAME = 1,
	PASSWORD = 2,
	PARAMETERS = 1,
	VISIBILITY = 1,
	VALUE = 2,
}

enum FUNCTION_DATA
{
	NODE_PATH = 1,
	NAME = 2,
	PARAMETERS = 4
}

enum VAR_DATA
{
	NODE_PATH = 1,
	NAME = 2,
	VALUE = 4
}

enum MESSAGE_DATA
{
	TYPE = 1,
	VALUE = 2,
	ERROR = 3,
	VALUE2 = 3,
}

enum CRITICAL_ERROR
{
	LOBBY_DATA_FULL,
	LOBBY_TAGS_FULL,
	PLAYER_DATA_FULL,
	REQUEST_TOO_LARGE,
}

enum INTERNAL_MESSAGE
{
	LOBBY_UPDATED,
	LOBBY_DELETED,
	REQUEST_LOBBIES,
	INCREASE_DATA_USAGE,
}

enum CONNECTION_FAILED
{
	INVALID_PUBLIC_KEY,
	TIMEOUT,
}

enum LOBBY_CREATION_ERROR
{
	LOBBY_ALREADY_EXISTS,
	NAME_TOO_SHORT,
	NAME_TOO_LONG,
	PASSWORD_TOO_LONG,
	TAGS_TOO_LARGE,
	DATA_TOO_LARGE,
	ON_COOLDOWN,
}

enum LOBBY_JOIN_ERROR
{
	LOBBY_DOES_NOT_EXIST,
	LOBBY_IS_CLOSED,
	LOBBY_IS_FULL,
	INCORRECT_PASSWORD,
	DUPLICATE_USERNAME,
}

enum NODE_REPLICATION_SETTINGS
{
	INSTANTIATOR,
	SYNC_STARTING_CHANGES,
	EXCLUDED_PROPERTIES,
	SCENE,
	TARGET,
	ORIGINAL_PROPERTIES,
}

enum NODE_REPLICATION_DATA
{
	ID,
	CHANGED_PROPERTIES,
}

enum ACCOUNT_CREATION_RESPONSE_CODE
{
	SUCCESS,
	NO_RESPONSE_FROM_SERVER,
	DATA_CAP_REACHED,
	RATE_LIMIT_EXCEEDED,
	NO_DATABASE,
	STORAGE_FULL,
	INVALID_EMAIL,
	INVALID_USERNAME,
	EMAIL_ALREADY_EXISTS,
	USERNAME_ALREADY_EXISTS,
	USERNAME_TOO_SHORT,
	USERNAME_TOO_LONG,
	PASSWORD_TOO_SHORT,
	PASSWORD_TOO_LONG,
}

enum ACCOUNT_DELETION_RESPONSE_CODE
{
	SUCCESS,
	NO_RESPONSE_FROM_SERVER,
	DATA_CAP_REACHED,
	RATE_LIMIT_EXCEEDED,
	NO_DATABASE,
	EMAIL_OR_PASSWORD_INCORRECT,
}

enum RESEND_VERIFICATION_RESPONSE_CODE
{
	SUCCESS,
	NO_RESPONSE_FROM_SERVER,
	DATA_CAP_REACHED,
	RATE_LIMIT_EXCEEDED,
	NO_DATABASE,
	VERIFICATION_DISABLED,
	ON_COOLDOWN,
	ALREADY_VERIFIED,
	EMAIL_OR_PASSWORD_INCORRECT,
	BANNED,
}

enum ACCOUNT_VERIFICATION_RESPONSE_CODE
{
	SUCCESS,
	NO_RESPONSE_FROM_SERVER,
	DATA_CAP_REACHED,
	RATE_LIMIT_EXCEEDED,
	NO_DATABASE,
	INCORRECT_CODE,
	CODE_EXPIRED,
	ALREADY_VERIFIED,
	BANNED,
}

enum IS_VERIFIED_RESPONSE_CODE
{
	SUCCESS,
	NO_RESPONSE_FROM_SERVER,
	DATA_CAP_REACHED,
	RATE_LIMIT_EXCEEDED,
	NO_DATABASE,
	NOT_LOGGED_IN,
	USER_DOESNT_EXIST,
}

enum LOGIN_RESPONSE_CODE
{
	SUCCESS,
	NO_RESPONSE_FROM_SERVER,
	DATA_CAP_REACHED,
	RATE_LIMIT_EXCEEDED,
	NO_DATABASE,
	EMAIL_OR_PASSWORD_INCORRECT,
	NOT_VERIFIED,
	EXPIRED_SESSION,
	BANNED,
}

enum LOGOUT_RESPONSE_CODE
{
	SUCCESS,
	NO_RESPONSE_FROM_SERVER,
	DATA_CAP_REACHED,
	RATE_LIMIT_EXCEEDED,
	NO_DATABASE,
	NOT_LOGGED_IN,
}

enum CHANGE_PASSWORD_RESPONSE_CODE
{
	SUCCESS,
	NO_RESPONSE_FROM_SERVER,
	DATA_CAP_REACHED,
	RATE_LIMIT_EXCEEDED,
	NO_DATABASE,
	ON_COOLDOWN,
	EMAIL_OR_PASSWORD_INCORRECT,
	NOT_VERIFIED,
	BANNED,
}

enum CHANGE_USERNAME_RESPONSE_CODE
{

	SUCCESS,
	NO_RESPONSE_FROM_SERVER,
	DATA_CAP_REACHED,
	RATE_LIMIT_EXCEEDED,
	NO_DATABASE,
	NOT_LOGGED_IN,
	ON_COOLDOWN,
	USERNAME_ALREADY_EXISTS,
	USERNAME_TOO_SHORT,
	USERNAME_TOO_LONG,
	INVALID_USERNAME
}

enum RESET_PASSWORD_RESPONSE_CODE
{
	SUCCESS,
	NO_RESPONSE_FROM_SERVER,
	DATA_CAP_REACHED,
	RATE_LIMIT_EXCEEDED,
	NO_DATABASE,
	EMAIL_OR_CODE_INCORRECT,
	CODE_EXPIRED,
}

enum REQUEST_PASSWORD_RESET_RESPONSE_CODE
{
	SUCCESS,
	NO_RESPONSE_FROM_SERVER,
	DATA_CAP_REACHED,
	RATE_LIMIT_EXCEEDED,
	NO_DATABASE,
	ON_COOLDOWN,
	EMAIL_DOESNT_EXIST,
	BANNED,
}

enum SET_PLAYER_DOCUMENT_RESPONSE_CODE
{
	SUCCESS,
	NO_RESPONSE_FROM_SERVER,
	DATA_CAP_REACHED,
	RATE_LIMIT_EXCEEDED,
	NO_DATABASE,
	NOT_LOGGED_IN,
	STORAGE_FULL,
}

enum GET_PLAYER_DOCUMENT_RESPONSE_CODE
{
	SUCCESS,
	NO_RESPONSE_FROM_SERVER,
	DATA_CAP_REACHED,
	RATE_LIMIT_EXCEEDED,
	NO_DATABASE,
	NOT_LOGGED_IN,
	DOESNT_EXIST,
}

enum BROWSE_PLAYER_COLLECTION_RESPONSE_CODE
{
	SUCCESS,
	NO_RESPONSE_FROM_SERVER,
	DATA_CAP_REACHED,
	RATE_LIMIT_EXCEEDED,
	NO_DATABASE,
	NOT_LOGGED_IN,
	DOESNT_EXIST,
}

enum SET_EXTERNAL_VISIBLE_RESPONSE_CODE
{
	SUCCESS,
	NO_RESPONSE_FROM_SERVER,
	DATA_CAP_REACHED,
	RATE_LIMIT_EXCEEDED,
	NO_DATABASE,
	NOT_LOGGED_IN,
	DOESNT_EXIST,
}


enum HAS_PLAYER_DOCUMENT_RESPONSE_CODE
{
	SUCCESS,
	NO_RESPONSE_FROM_SERVER,
	DATA_CAP_REACHED,
	RATE_LIMIT_EXCEEDED,
	NO_DATABASE,
	NOT_LOGGED_IN,
}

enum DELETE_PLAYER_DOCUMENT_RESPONSE_CODE
{
	SUCCESS,
	NO_RESPONSE_FROM_SERVER,
	DATA_CAP_REACHED,
	RATE_LIMIT_EXCEEDED,
	NO_DATABASE,
	NOT_LOGGED_IN,
	DOESNT_EXIST,
}

enum REPORT_USER_RESPONSE_CODE
{
	SUCCESS,
	NO_RESPONSE_FROM_SERVER,
	DATA_CAP_REACHED,
	RATE_LIMIT_EXCEEDED,
	NO_DATABASE,
	NOT_LOGGED_IN,
	STORAGE_FULL,
	REPORT_TOO_LONG,
	TOO_MANY_REPORTS,
	USER_DOESNT_EXIST,
}

enum SUBMIT_SCORE_RESPONSE_CODE
{
	SUCCESS,
	NO_RESPONSE_FROM_SERVER,
	DATA_CAP_REACHED,
	RATE_LIMIT_EXCEEDED,
	NO_DATABASE,
	NOT_LOGGED_IN,
	STORAGE_FULL,
	LEADERBOARD_DOESNT_EXIST
}

enum DELETE_SCORE_RESPONSE_CODE
{
	SUCCESS,
	NO_RESPONSE_FROM_SERVER,
	DATA_CAP_REACHED,
	RATE_LIMIT_EXCEEDED,
	NO_DATABASE,
	NOT_LOGGED_IN,
	LEADERBOARD_DOESNT_EXIST
}

enum GET_LEADERBOARDS_RESPONSE_CODE
{
	SUCCESS,
	NO_RESPONSE_FROM_SERVER,
	DATA_CAP_REACHED,
	RATE_LIMIT_EXCEEDED,
	NO_DATABASE,
	NOT_LOGGED_IN
}

enum HAS_LEADERBOARD_RESPONSE_CODE
{
	SUCCESS,
	NO_RESPONSE_FROM_SERVER,
	DATA_CAP_REACHED,
	RATE_LIMIT_EXCEEDED,
	NO_DATABASE,
	NOT_LOGGED_IN
}

enum BROWSE_LEADERBOARD_RESPONSE_CODE
{
	SUCCESS,
	NO_RESPONSE_FROM_SERVER,
	DATA_CAP_REACHED,
	RATE_LIMIT_EXCEEDED,
	NO_DATABASE,
	NOT_LOGGED_IN,
	LEADERBOARD_DOESNT_EXIST
}

enum GET_LEADERBOARD_SCORE_RESPONSE_CODE
{
	SUCCESS,
	NO_RESPONSE_FROM_SERVER,
	DATA_CAP_REACHED,
	RATE_LIMIT_EXCEEDED,
	NO_DATABASE,
	NOT_LOGGED_IN,
	LEADERBOARD_DOESNT_EXIST,
	USER_DOESNT_EXIST
}

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS(SELECT name from sys.sysdatabases where name = 'VERNE')
BEGIN
CREATE DATABASE [VERNE]
ALTER DATABASE [VERNE] SET RECOVERY SIMPLE 
ALTER DATABASE [VERNE] SET  MULTI_USER
END
GO


USE VERNE
GO

--Create table wait_types_names

CREATE TABLE [dbo].[wait_types_names](
[wait_type_checksum] [int] NOT NULL,
[wait_type] [nvarchar](130) NOT NULL,
CONSTRAINT [pk_wait_types_names] PRIMARY KEY CLUSTERED 
([wait_type_checksum])
) ON [PRIMARY];
GO


-- populate wait_types table
INSERT INTO [dbo].[wait_types_names]
SELECT CHECKSUM (wait_type), wait_type
FROM sys.dm_os_wait_stats;
GO	



--Create table wait_stats_current

CREATE TABLE [dbo].[wait_stats_current](
	[wait_type] [nvarchar](130) NOT NULL,
	[requests] [bigint] NULL,
	[wait_time] [bigint] NULL,
	[signal_wait_time] [bigint] NULL,
	[capture_time] [datetime] NULL,
 CONSTRAINT [ci_wait_stats_current] UNIQUE CLUSTERED 
(
	[wait_type] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[wait_stats_current] ADD  DEFAULT (getdate()) FOR [capture_time]
GO

--Create unique clustered index ci_wait_stats_current

/*
ALTER TABLE [dbo].[wait_stats_current] ADD  CONSTRAINT [ci_wait_stats_current] UNIQUE CLUSTERED 
(
	[wait_type] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
*/

--Create table wait_stats_last

CREATE TABLE [dbo].[wait_stats_last](
	[wait_type] [nvarchar](130) NOT NULL,
	[requests] [bigint] NULL,
	[wait_time] [bigint] NULL,
	[signal_wait_time] [bigint] NULL,
	[capture_time] [datetime] NULL,
 CONSTRAINT [ci_wait_stats_last] UNIQUE CLUSTERED 
(
	[wait_type] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[wait_stats_last] ADD  DEFAULT (getdate()) FOR [capture_time]
GO

--Create unique clustered index ci_wait_stats_last

/*
ALTER TABLE [dbo].[wait_stats_last] ADD  CONSTRAINT [ci_wait_stats_last] UNIQUE CLUSTERED 
(
	[wait_type] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
*/

--Create table wait_stats_history

CREATE TABLE [dbo].[wait_stats_history](
	[wait_type_checksum] [int] NULL,
	[requests] [bigint] NULL,
	[wait_time] [bigint] NULL,
	[signal_wait_time] [bigint] NULL,
	[measure_time_ms] [int] NULL,
	[capture_time] [datetime] NOT NULL,
	[capture_date] [smalldatetime] NOT NULL,
	[hour] [tinyint] NOT NULL,
	[minute] [tinyint] NOT NULL,
 CONSTRAINT [ci_wait_stats_history] UNIQUE CLUSTERED 
(
	[capture_time] ASC,
	[wait_type_checksum] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE PROCEDURE [dbo].[sproc_capture_wait_stats]
--WITH ENCRYPTION
AS
begin
SET NOCOUNT ON

		DECLARE @current_time DATETIME
		--
		-- clear out wait_stats
		--
		--DBCC SQLPERF ('sys.dm_os_wait_stats', CLEAR) 

		DECLARE @clear_time DATETIME
		SET @clear_time = GETDATE()

		
			--
			-- truncate the last values inserted
			--
			TRUNCATE TABLE dbo.wait_stats_last

			--
			-- insert into "last" tables the current values in working tables
			--
			INSERT INTO dbo.wait_stats_last
			SELECT * FROM dbo.wait_stats_current

			--
			-- truncate current values table
			--
			TRUNCATE TABLE dbo.wait_stats_current

			--
			-- insert into current table values from sys.dm_os_wait_stats
			--
			IF OBJECT_ID('tempdb..#temp') IS NOT NULL
				DROP TABLE #TEMP

			SELECT wait_type, waiting_tasks_count, wait_time_ms, signal_wait_time_ms into #TEMP
			FROM sys.dm_os_wait_stats
			
			INSERT INTO dbo.wait_stats_current (
				wait_type,
				requests,
				wait_time,
				signal_wait_time )
			SELECT DISTINCT wait_type, waiting_tasks_count, wait_time_ms, signal_wait_time_ms from #TEMP
			
			DROP TABLE #TEMP
			
			SET @current_time = GETDATE()

			--
			-- Insert deltas and accumulates values in history table...
			--
			INSERT INTO dbo.wait_stats_history (
				wait_type_checksum 
				, measure_time_ms
				, capture_time 
				, capture_date
				, [hour]
				, [minute]
				, requests 
				, wait_time 
				, signal_wait_time 
			)
			SELECT 
				CHECKSUM (v.wait_type)
				, v.measure_time_ms
				, v.capture_time
				, v.capture_date
				, v.[hour]
				, v.[minute]
				, CASE	
						WHEN v.measure_time_ms = 0
						THEN 0
						ELSE v.requests_delta
						END AS requests_delta
				, CASE	
						WHEN v.measure_time_ms = 0
						THEN 0
						ELSE v.wait_time_delta
						END AS wait_time_delta
				, CASE	
						WHEN v.measure_time_ms = 0
						THEN 0
						ELSE v.signal_wait_time_delta
						END AS signal_wait_time_delta
			FROM (
					SELECT
						cur.wait_type
						, cur.requests AS requests
						, cur.wait_time AS wait_time
						, cur.signal_wait_time AS signal_wait_time
						, cur.requests 
							- ISNULL(last.requests, 0) 
							AS requests_delta
						, cur.wait_time 
							- ISNULL(last.wait_time, 0) 
							AS wait_time_delta
						, cur.signal_wait_time 
							- ISNULL(last.signal_wait_time, 0) 
							AS signal_wait_time_delta
						, CASE 
								WHEN 
									cur.requests 				- ISNULL(last.requests, 0) 			< 0 
									OR cur.wait_time 			- ISNULL(last.wait_time, 0) 		< 0 
									OR cur.signal_wait_time 	- ISNULL(last.signal_wait_time, 0) 	< 0 
								THEN 0
								ELSE
									CASE
										WHEN ISNULL(last.requests, -1) = -1 
										THEN DATEDIFF(ms, @clear_time, @current_time) 
										ELSE DATEDIFF(ms, last.capture_time, cur.capture_time) 
										END 
								END AS measure_time_ms
						, cur.capture_time
						, CAST (CONVERT (CHAR(8), cur.capture_time, 112) AS SMALLDATETIME) AS capture_date
						, DATEPART (hh, cur.capture_time) AS [hour]
						, DATEPART (mi, cur.capture_time) AS [minute]
					FROM dbo.wait_stats_current cur
					LEFT JOIN dbo.wait_stats_last last ON cur.wait_type = last.wait_type
					WHERE
						cur.wait_type NOT IN ('WAITFOR', 'SLEEP')
						AND cur.requests - ISNULL(last.requests, 0) <> 0
						AND cur.wait_time - ISNULL(last.wait_time, 0) <> 0
						AND cur.signal_wait_time - ISNULL(last.signal_wait_time, 0) <> 0
				) AS v
END

GO

BEGIN TRANSACTION

USE [msdb]
GO

DECLARE @ReturnCode INT
SELECT @ReturnCode = 0

IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'VerneTech_capture_WaitStats', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Run WaitStats SP', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'exec sproc_capture_wait_stats', 
		@database_name=N'VERNE', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 5 minutes', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=5, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20170913, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
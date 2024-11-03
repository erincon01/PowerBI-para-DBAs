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

--Create table sysmaster_files_history 

CREATE TABLE [dbo].[sysmaster_files_history](
	[database_id] [smallint] NULL,
	[file_id] [int] NULL,
	[capture_date] [smalldatetime] NOT NULL,
	[database_name] [nvarchar](130) NOT NULL,
	[name] [nvarchar](130) NOT NULL,
	[filename] [nvarchar](520) NOT NULL,
 CONSTRAINT [ci_sysaltfiles_history] UNIQUE CLUSTERED 
(
	[database_id] ASC,
	[file_id] ASC,
	[capture_date] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
--Create UNIQUE Clustered Index ci_sysaltfiles_history

/*
ALTER TABLE [dbo].[sysmaster_files_history] ADD  CONSTRAINT [ci_sysaltfiles_history] UNIQUE CLUSTERED 
(
	[database_id] ASC,
	[file_id] ASC,
	[capture_date] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
*/

--Create table file_stats_current 

CREATE TABLE [dbo].[file_stats_current](
	[database_id] [smallint] NULL,
	[file_id] [int] NULL,
	[sample_ms] [bigint] NULL,
	[num_of_reads] [bigint] NULL,
	[num_of_writes] [bigint] NULL,
	[num_of_bytes_read] [bigint] NULL,
	[num_of_bytes_written] [bigint] NULL,
	[io_stall_read_ms] [bigint] NULL,
	[io_stall_write_ms] [bigint] NULL,
	[io_stall_ms] [bigint] NULL,
	[capture_time] [datetime] NOT NULL,
 CONSTRAINT [nci_file_stats_current] UNIQUE NONCLUSTERED 
(
	[database_id] ASC,
	[file_id] ASC,
	[sample_ms] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[file_stats_current] ADD  DEFAULT (getdate()) FOR [capture_time]

GO

--Create UNIQUE Non-Clustered Index nci_file_stats_current

/*
ALTER TABLE [dbo].[file_stats_current] ADD  CONSTRAINT [nci_file_stats_current] UNIQUE NONCLUSTERED 
(
	[database_id] ASC,
	[file_id] ASC,
	[sample_ms] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
*/

--Create table file_stats_last

CREATE TABLE [dbo].[file_stats_last](
	[database_id] [smallint] NULL,
	[file_id] [int] NULL,
	[sample_ms] [bigint] NULL,
	[num_of_reads] [bigint] NULL,
	[num_of_writes] [bigint] NULL,
	[num_of_bytes_read] [bigint] NULL,
	[num_of_bytes_written] [bigint] NULL,
	[io_stall_read_ms] [bigint] NULL,
	[io_stall_write_ms] [bigint] NULL,
	[io_stall_ms] [bigint] NULL,
	[capture_time] [datetime] NOT NULL,
 CONSTRAINT [nci_file_stats_last] UNIQUE NONCLUSTERED 
(
	[database_id] ASC,
	[file_id] ASC,
	[sample_ms] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[file_stats_last] ADD  DEFAULT (getdate()) FOR [capture_time]

GO

--Create UNIQUE Non-Clustered Index nci_file_stats_last

/*
ALTER TABLE [dbo].[file_stats_last] ADD  CONSTRAINT [nci_file_stats_last] UNIQUE NONCLUSTERED 
(
	[database_id] ASC,
	[file_id] ASC,
	[sample_ms] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
*/

--Create table file_stats_history

CREATE TABLE [dbo].[file_stats_history](
	[database_id] [smallint] NULL,
	[file_id] [int] NULL,
	[capture_time] [datetime] NULL,
	[capture_date] [smalldatetime] NOT NULL,
	[hour] [tinyint] NULL,
	[minute] [tinyint] NULL,
	[num_of_reads] [bigint] NULL,
	[num_of_writes] [bigint] NULL,
	[num_of_bytes_read] [bigint] NULL,
	[num_of_bytes_written] [bigint] NULL,
	[io_stall_read_ms] [bigint] NULL,
	[io_stall_write_ms] [bigint] NULL,
	[io_stall_ms] [bigint] NULL,
	[reads_per_second] [decimal](15, 3) NULL,
	[writes_per_second] [decimal](15, 3) NULL,
 CONSTRAINT [nci_file_stats_history] UNIQUE NONCLUSTERED 
(
	[database_id] ASC,
	[file_id] ASC,
	[capture_time] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]


GO

--Create UNIQUE Non-Clustered Index nci_file_stats_history

/*
ALTER TABLE [dbo].[file_stats_history] ADD  CONSTRAINT [nci_file_stats_history] UNIQUE NONCLUSTERED 
(
	[database_id] ASC,
	[file_id] ASC,
	[capture_time] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
*/


--Create SP sproc_capture_file_stats

CREATE PROCEDURE [dbo].[sproc_capture_file_stats]
--WITH ENCRYPTION
AS
BEGIN
        SET NOCOUNT ON

        DECLARE @current_time DATETIME

        --
        -- insert current sysfiles values in capture_sysmaster_files_history table
        --
        INSERT dbo.sysmaster_files_history (
            database_id, file_id, capture_date, database_name, name, filename)
        SELECT
            s.database_id
            , s.file_id
            , CAST (CONVERT (CHAR(8), GETDATE(), 112) AS SMALLDATETIME) AS capture_date
            , db_name(s.database_id) as database_name
            , s.name
            , s.physical_name
        FROM
            sys.master_files s
        left join dbo.sysmaster_files_history h
        on s.database_id = h.database_id
        and s.file_id = h.file_id
        and CAST (CONVERT (CHAR(8), GETDATE(), 112) AS SMALLDATETIME) = h.capture_date
        WHERE
        h.database_id IS NULL

            -- truncate the last values inserted
            --
            TRUNCATE TABLE dbo.file_stats_last

            --
            -- insert into "last" tables the current values in working tables
            --
            INSERT INTO dbo.file_stats_last
            SELECT * FROM dbo.file_stats_current

            --
            -- truncate current values
            --
            TRUNCATE TABLE dbo.file_stats_current

            --
            -- insert into actual table values from fn_virtualfilestats
            --
            INSERT INTO dbo.file_stats_current
            SELECT 
                database_id, file_id, sample_ms, 
                num_of_reads, num_of_writes, 
                num_of_bytes_read, num_of_bytes_written, 
                io_stall_read_ms, io_stall_write_ms, 
                io_stall, GETDATE()
            FROM
                sys.dm_io_virtual_file_stats(NULL, NULL)


            SET @current_time = GETDATE()

            --
            -- Insert deltas and accumulates values in history table...
            --
            INSERT INTO dbo.file_stats_history (
                database_id, file_id
                , num_of_reads, num_of_writes
                , num_of_bytes_read, num_of_bytes_written
                , io_stall_read_ms, io_stall_write_ms, io_stall_ms
                , capture_time, capture_date, [hour], [minute]
                , reads_per_second, writes_per_second
            )
            SELECT 
                v.database_id
                , v.file_id
                , CASE 
                    WHEN v.measure_time_ms = 0
                    THEN 0
                    ELSE v.num_of_reads
                    END AS num_of_reads
                , CASE 
                    WHEN v.measure_time_ms = 0
                    THEN 0
                    ELSE v.num_of_writes
                    END AS num_of_writes
                , CASE 
                    WHEN v.measure_time_ms = 0
                    THEN 0
                    ELSE v.num_of_bytes_read
                    END AS num_of_bytes_read
                , CASE 
                    WHEN v.measure_time_ms = 0
                    THEN 0
                    ELSE v.num_of_bytes_written
                    END AS num_of_bytes_written
                , CASE 
                    WHEN v.measure_time_ms = 0
                    THEN 0
                    ELSE v.io_stall_read_ms
                    END AS io_stall_read_ms
                , CASE 
                    WHEN v.measure_time_ms = 0
                    THEN 0
                    ELSE v.io_stall_write_ms
                    END AS io_stall_write_ms
                , CASE 
                    WHEN v.measure_time_ms = 0
                    THEN 0
                    ELSE v.io_stall
                    END AS io_stall
                , v.capture_time
                , CAST (CONVERT (CHAR(8), v.capture_time, 112) AS SMALLDATETIME) AS capture_date
                , DATEPART (hh, v.capture_time) AS [hour]
                , DATEPART (mi, v.capture_time) AS [minute]
                , CASE 
                    WHEN v.measure_time_ms = 0
                    THEN 0
                    ELSE v.num_of_reads * CAST (1000 AS DECIMAL) / v.measure_time_ms
                    END AS Reads
                , CASE 
                    WHEN v.measure_time_ms = 0
                    THEN 0
                    ELSE v.num_of_writes * CAST (1000 AS DECIMAL) / v.measure_time_ms
                    END AS Writes
            FROM
                (
                    SELECT 
                        cur.database_id, cur.file_id, cur.sample_ms
                        , CASE 
                            WHEN 
                                cur.num_of_reads            - ISNULL(last.num_of_reads,0)           < 0 
                                OR cur.num_of_writes        - ISNULL(last.num_of_writes,0)          < 0 
                                OR cur.num_of_bytes_read    - ISNULL(last.num_of_bytes_read,0)      < 0 
                                OR cur.num_of_bytes_written - ISNULL(last.num_of_bytes_written,0)   < 0 
                                OR cur.io_stall_read_ms     - ISNULL(last.io_stall_read_ms,0)       < 0 
                                OR cur.io_stall_write_ms    - ISNULL(last.io_stall_write_ms,0)      < 0 
                                OR cur.io_stall_ms          - ISNULL(last.io_stall_ms,0)            < 0 
                                OR cur.sample_ms            - ISNULL(last.sample_ms,0)              < 0 
                            THEN 0
                            ELSE cur.num_of_reads - ISNULL(last.num_of_reads,0) 
                            END AS num_of_reads
                        , CASE 
                            WHEN 
                                cur.num_of_reads            - ISNULL(last.num_of_reads,0)           < 0 
                                OR cur.num_of_writes        - ISNULL(last.num_of_writes,0)          < 0 
                                OR cur.num_of_bytes_read    - ISNULL(last.num_of_bytes_read,0)      < 0 
                                OR cur.num_of_bytes_written - ISNULL(last.num_of_bytes_written,0)   < 0 
                                OR cur.io_stall_read_ms     - ISNULL(last.io_stall_read_ms,0)       < 0 
                                OR cur.io_stall_write_ms    - ISNULL(last.io_stall_write_ms,0)      < 0 
                                OR cur.io_stall_ms          - ISNULL(last.io_stall_ms,0)            < 0 
                                OR cur.sample_ms            - ISNULL(last.sample_ms,0)              < 0 
                            THEN 0
                            ELSE cur.num_of_writes - ISNULL(last.num_of_writes,0) 
                            END AS num_of_writes
                        , CASE 
                            WHEN 
                                cur.num_of_reads            - ISNULL(last.num_of_reads,0)           < 0 
                                OR cur.num_of_writes        - ISNULL(last.num_of_writes,0)          < 0 
                                OR cur.num_of_bytes_read    - ISNULL(last.num_of_bytes_read,0)      < 0 
                                OR cur.num_of_bytes_written - ISNULL(last.num_of_bytes_written,0)   < 0 
                                OR cur.io_stall_read_ms     - ISNULL(last.io_stall_read_ms,0)       < 0 
                                OR cur.io_stall_write_ms    - ISNULL(last.io_stall_write_ms,0)      < 0 
                                OR cur.io_stall_ms          - ISNULL(last.io_stall_ms,0)            < 0 
                                OR cur.sample_ms            - ISNULL(last.sample_ms,0)              < 0 
                            THEN 0
                            ELSE cur.num_of_bytes_read - ISNULL(last.num_of_bytes_read,0) 
                            END AS num_of_bytes_read
                        , CASE 
                            WHEN 
                                cur.num_of_reads            - ISNULL(last.num_of_reads,0)           < 0 
                                OR cur.num_of_writes        - ISNULL(last.num_of_writes,0)          < 0 
                                OR cur.num_of_bytes_read    - ISNULL(last.num_of_bytes_read,0)      < 0 
                                OR cur.num_of_bytes_written - ISNULL(last.num_of_bytes_written,0)   < 0 
                                OR cur.io_stall_read_ms     - ISNULL(last.io_stall_read_ms,0)       < 0 
                                OR cur.io_stall_write_ms    - ISNULL(last.io_stall_write_ms,0)      < 0 
                                OR cur.io_stall_ms          - ISNULL(last.io_stall_ms,0)            < 0 
                                OR cur.sample_ms            - ISNULL(last.sample_ms,0)              < 0 
                            THEN 0
                            ELSE cur.num_of_bytes_written - ISNULL(last.num_of_bytes_written,0) 
                            END AS num_of_bytes_written
                        , CASE 
                            WHEN 
                                cur.num_of_reads            - ISNULL(last.num_of_reads,0)           < 0 
                                OR cur.num_of_writes        - ISNULL(last.num_of_writes,0)          < 0 
                                OR cur.num_of_bytes_read    - ISNULL(last.num_of_bytes_read,0)      < 0 
                                OR cur.num_of_bytes_written - ISNULL(last.num_of_bytes_written,0)   < 0 
                                OR cur.io_stall_read_ms     - ISNULL(last.io_stall_read_ms,0)       < 0 
                                OR cur.io_stall_write_ms    - ISNULL(last.io_stall_write_ms,0)      < 0 
                                OR cur.io_stall_ms          - ISNULL(last.io_stall_ms,0)            < 0 
                                OR cur.sample_ms            - ISNULL(last.sample_ms,0)              < 0 
                            THEN 0
                            ELSE cur.io_stall_read_ms - ISNULL(last.io_stall_read_ms,0) 
                            END AS io_stall_read_ms
                        , CASE 
                            WHEN 
                                cur.num_of_reads            - ISNULL(last.num_of_reads,0)           < 0 
                                OR cur.num_of_writes        - ISNULL(last.num_of_writes,0)          < 0 
                                OR cur.num_of_bytes_read    - ISNULL(last.num_of_bytes_read,0)      < 0 
                                OR cur.num_of_bytes_written - ISNULL(last.num_of_bytes_written,0)   < 0 
                                OR cur.io_stall_read_ms     - ISNULL(last.io_stall_read_ms,0)       < 0 
                                OR cur.io_stall_write_ms    - ISNULL(last.io_stall_write_ms,0)      < 0 
                                OR cur.io_stall_ms          - ISNULL(last.io_stall_ms,0)            < 0 
                                OR cur.sample_ms            - ISNULL(last.sample_ms,0)              < 0 
                            THEN 0
                            ELSE cur.io_stall_write_ms - ISNULL(last.io_stall_write_ms,0) 
                            END AS io_stall_write_ms
                        , CASE 
                            WHEN 
                                cur.num_of_reads            - ISNULL(last.num_of_reads,0)           < 0 
                                OR cur.num_of_writes        - ISNULL(last.num_of_writes,0)          < 0 
                                OR cur.num_of_bytes_read    - ISNULL(last.num_of_bytes_read,0)      < 0 
                                OR cur.num_of_bytes_written - ISNULL(last.num_of_bytes_written,0)   < 0 
                                OR cur.io_stall_read_ms     - ISNULL(last.io_stall_read_ms,0)       < 0 
                                OR cur.io_stall_write_ms    - ISNULL(last.io_stall_write_ms,0)      < 0 
                                OR cur.io_stall_ms          - ISNULL(last.io_stall_ms,0)            < 0 
                                OR cur.sample_ms            - ISNULL(last.sample_ms,0)              < 0 
                            THEN 0
                            ELSE cur.io_stall_ms - ISNULL(last.io_stall_ms,0) 
                            END AS io_stall
                        , CASE 
                            WHEN 
                                cur.num_of_reads            - ISNULL(last.num_of_reads,0)           < 0 
                                OR cur.num_of_writes        - ISNULL(last.num_of_writes,0)          < 0 
                                OR cur.num_of_bytes_read    - ISNULL(last.num_of_bytes_read,0)      < 0 
                                OR cur.num_of_bytes_written - ISNULL(last.num_of_bytes_written,0)   < 0 
                                OR cur.io_stall_read_ms     - ISNULL(last.io_stall_read_ms,0)       < 0 
                                OR cur.io_stall_write_ms    - ISNULL(last.io_stall_write_ms,0)      < 0 
                                OR cur.io_stall_ms          - ISNULL(last.io_stall_ms,0)            < 0 
                                OR cur.sample_ms            - ISNULL(last.sample_ms,0)              < 0 
                            THEN 0
                            ELSE cur.sample_ms - ISNULL(last.sample_ms,0) 
                            END AS measure_time_ms
                        , cur.capture_time
                    FROM dbo.file_stats_current cur
                    LEFT JOIN dbo.file_stats_last last ON (
                        cur.database_id = last.database_id 
                        AND cur.file_id = last.file_id 
                    )
                ) AS v
                WHERE 
                    v.num_of_reads <> 0
                    OR v.num_of_writes <> 0		
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
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'VerneTech_capture_FileIOStats', 
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

EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Run FileIOStats SP', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'SET NOCOUNT ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
SET ARITHABORT ON
SET CONCAT_NULL_YIELDS_NULL ON
SET QUOTED_IDENTIFIER ON
SET NUMERIC_ROUNDABORT OFF

EXEC dbo.sproc_capture_file_stats', 
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


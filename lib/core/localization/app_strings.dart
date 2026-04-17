import 'app_language.dart';
import 'demo_task_public_state.dart';

class AppStrings {
  const AppStrings({
    required this.language,
    required this.loginTitle,
    required this.loginSubtitle,
    required this.loginDescription,
    required this.loginDevPathWithoutSession,
    required this.loginContinueToTasks,
    required this.authLabelEmail,
    required this.authLabelPassword,
    required this.authHintEmail,
    required this.authHintPassword,
    required this.authSignInButton,
    required this.authSignOutButton,
    required this.authSignInFailed,
    required this.authAnonymousNotWorkerWarning,
    required this.authFillEmailPassword,
    required this.loginDevBypassButton,
    required this.tasksAppBarSignOut,
    required this.authLoadingWorkerProfile,
    required this.workerProfileRequiredTitle,
    required this.workerProfileRequiredMessage,
    required this.tasksAppTitle,
    required this.navTabTasks,
    required this.navTabRequest,
    required this.navTabProfile,
    required this.navTabArchive,
    required this.archiveAppBarTitle,
    required this.archiveSectionHeader,
    required this.archiveEmptyTitle,
    required this.archiveEmptySubtitle,
    required this.archiveLabelCompletedOn,
    required this.archiveLabelFinalStatus,
    required this.archiveLabelDuration,
    required this.archiveOpenResultHint,
    required this.archiveOpenReviewHint,
    required this.archiveReviewNoLocalSnapshot,
    required this.tasksAllCompletedSeeArchive,
    required this.profileScreenTitle,
    required this.tasksSectionAssignedRounds,
    required this.statusInProgress,
    required this.statusPending,
    required this.statusCompleted,
    required this.taskDetailAppTitle,
    required this.labelObject,
    required this.labelStatus,
    required this.labelShift,
    required this.sectionInspectionRoute,
    required this.startRoundButton,
    required this.inspectionExecutionAppTitle,
    required this.labelTask,
    required this.labelProgress,
    required this.sectionInspectionObjects,
    required this.openCurrentObjectButton,
    required this.snackbarObjectInspectionNext,
    required this.badgeCurrent,
    required this.badgePending,
    required this.languageMenuLabel,
    required this.langNameRu,
    required this.langNameTr,
    required this.langNameEn,
    required this.mockShift0,
    required this.mockShift1,
    required this.mockShift2,
    required this.mockTask0Title,
    required this.mockTask0Area,
    required this.mockTask1Title,
    required this.mockTask1Area,
    required this.mockTask2Title,
    required this.mockTask2Area,
    required this.r0i0n,
    required this.r0i0s,
    required this.r0i1n,
    required this.r0i1s,
    required this.r0i2n,
    required this.r0i2s,
    required this.r0i3n,
    required this.r0i3s,
    required this.r1i0n,
    required this.r1i0s,
    required this.r1i1n,
    required this.r1i1s,
    required this.r1i2n,
    required this.r1i2s,
    required this.r1i3n,
    required this.r1i3s,
    required this.r1i4n,
    required this.r1i4s,
    required this.r2i0n,
    required this.r2i0s,
    required this.r2i1n,
    required this.r2i1s,
    required this.r2i2n,
    required this.r2i2s,
    required this.r2i3n,
    required this.r2i3s,
    required this.inspectionObjectAppTitle,
    required this.inspectionRouteItemUnavailable,
    required this.labelZone,
    required this.sectionChecklist,
    required this.checklistItemVisualOk,
    required this.checklistItemNoLeaks,
    required this.checklistItemNoNoise,
    required this.checklistItemAccessClear,
    required this.sectionNote,
    required this.noteHint,
    required this.saveLocallyButton,
    required this.completeObjectButton,
    required this.inspectionSendButton,
    required this.inspectionSendingLabel,
    required this.inspectionOfflineQueuedTitle,
    required this.inspectionOfflineQueuedSubtitle,
    required this.routeBadgeAwaitingSync,
    required this.snackbarLocalSaveSuccess,
    required this.sectionMeasurements,
    required this.labelMeasurementTemperature,
    required this.labelMeasurementPressure,
    required this.labelMeasurementVibration,
    required this.hintMeasurementValue,
    required this.unitCelsius,
    required this.unitPressureBar,
    required this.unitVibrationMmS,
    required this.sectionDefect,
    required this.defectToggleLabel,
    required this.labelDefectDescription,
    required this.hintDefectDescription,
    required this.labelDefectPriority,
    required this.priorityLow,
    required this.priorityMedium,
    required this.priorityHigh,
    required this.routeStatusHasIssue,
    required this.sectionPhotoEvidence,
    required this.addPhotoButton,
    required this.photoItemSubtitleLocal,
    required this.removePhotoButton,
    required this.snackbarPhotoLimitReached,
    required this.photoPreviewClose,
    required this.photoPreviewDemoCaption,
    required this.voiceNoteSectionTitle,
    required this.voiceStartRecording,
    required this.voiceStopRecording,
    required this.voiceDeleteRecording,
    required this.voiceStateRecording,
    required this.voiceStateRecorded,
    required this.snackbarPhotoPickerCancelled,
    required this.snackbarPhotoPickerFailed,
    required this.snackbarMicrophoneDenied,
    required this.snackbarVoiceNoteAdded,
    required this.snackbarUploadFailed,
    required this.snackbarUploadSuccess,
    required this.errorSupabaseNotConfigured,
    required this.errorAuthAnonymousFailed,
    required this.errorMissingTaskId,
    required this.errorMissingEquipmentId,
    required this.errorReportInsertFailed,
    required this.errorReportReturningEmpty,
    required this.errorReportForeignKey,
    required this.errorReportRlsBlocked,
    required this.errorMediaInsertFailed,
    required this.errorMediaMetadataAfterReportOk,
    required this.errorPhotoUploadFailed,
    required this.errorAudioUploadFailed,
    required this.errorDatabaseSaveFailed,
    required this.errorRecordingNotFound,
    required this.errorSaveFailed,
    required this.errorUnknownSave,
    required this.errorPermissionDenied,
    required this.completeObjectInProgress,
    required this.appMaterialTitle,
    required this.inspectionTaskSummaryTitle,
    required this.sectionSummaryResults,
    required this.labelSummaryTotalObjects,
    required this.labelSummaryCompletedOk,
    required this.labelSummaryWithIssues,
    required this.summaryBackToTasksButton,
    required this.statusCompletedWithIssues,
    required this.taskListProgressNotStarted,
    required this.taskListProgressActive,
    required this.taskListProgressCompletedFull,
    required this.taskListProgressCompletedFullWithIssues,
    required this.taskOpenResultButton,
    required this.completedReportAppTitle,
    required this.sectionCompletedReportInspectionSummary,
    required this.labelReportPhotoCount,
    required this.labelReportAudioCount,
    required this.labelReportObjectsWithDefects,
    required this.taskDetailSectionOutcome,
    required this.labelFinalTaskState,
    required this.completedReportNotAvailable,
    required this.labelDueAt,
    required this.tasksUntitledTask,
    required this.tasksScheduleNotSpecified,
    required this.tasksLoading,
    required this.tasksLoadFailed,
    required this.tasksShowingDemoFallback,
    required this.tasksNoWorkerIdentity,
    required this.tasksSupabaseNotReady,
    required this.tasksNoAssignments,
    required this.tasksSectionDemoTasks,
    required this.tasksDemoSectionDebugHint,
    required this.workerDevWorkerIdBadge,
    required this.workerProfileNotInDatabase,
    required this.workerProfileMissingAuthenticated,
    required this.labelEquipmentCode,
    required this.labelAssignmentStatus,
    required this.sectionTaskInstructions,
    required this.taskDetailInstructionsEmpty,
    required this.tasksRetry,
    required this.workerSectionTitle,
    required this.workerProfileNameLabel,
    required this.workerProfileCodeLabel,
    required this.taskRequestScreenTitle,
    required this.taskRequestActionTooltip,
    required this.labelRequestTitle,
    required this.hintRequestTitle,
    required this.labelRequestSiteName,
    required this.hintRequestSiteName,
    required this.labelRequestAreaName,
    required this.hintRequestAreaName,
    required this.labelRequestDescription,
    required this.hintRequestDescription,
    required this.labelRequestPriority,
    required this.taskRequestSubmitButton,
    required this.taskRequestSuccess,
    required this.taskRequestErrorNoWorker,
    required this.taskRequestErrorNotReady,
    required this.taskRequestErrorInsert,
    required this.taskRequestErrorNoAuthSession,
    required this.taskRequestErrorProfileMissing,
    required this.taskRequestErrorSupabaseNotConfigured,
    required this.taskRequestErrorRlsDenied,
    required this.taskRequestErrorSchemaMismatch,
    required this.taskRequestErrorNetwork,
    required this.taskRequestErrorUnknown,
    required this.taskRequestValidationNeedTitle,
    required this.taskRequestValidationNeedDescription,
    required this.inspectionObjectEditTitle,
    required this.editResultBannerHint,
    required this.summaryEditResultButton,
    required this.editResultPickObjectTitle,
    required this.editResultNoCachedState,
    required this.taskRequestSectionBasic,
    required this.taskRequestSectionEquipment,
    required this.taskRequestSectionProblem,
    required this.labelRequestShift,
    required this.hintRequestShift,
    required this.labelRequestIssueSummary,
    required this.hintRequestIssueSummary,
    required this.labelRequestDetailedDescription,
    required this.hintRequestDetailedDescription,
    required this.labelRequestEquipmentName,
    required this.hintRequestEquipmentName,
    required this.labelRequestEquipmentLocation,
    required this.hintRequestEquipmentLocation,
    required this.labelRequestEquipmentCode,
    required this.hintRequestEquipmentCode,
    required this.labelRequestPreferredDueDate,
    required this.hintRequestPreferredDueDateOptional,
    required this.labelRequestType,
    required this.requestTypeInspection,
    required this.requestTypeMaintenance,
    required this.requestTypeDefect,
    required this.requestTypeRepair,
    required this.taskRequestSelectDueDate,
    required this.taskRequestClearDueDate,
    required this.taskRequestValidationNeedIssueOrDetail,
    required this.taskRequestEquipmentLoading,
    required this.taskRequestEquipmentLoadFailed,
    required this.taskRequestEquipmentEmpty,
    required this.taskRequestValidationNeedEquipment,
    required this.taskRequestEquipmentSectionSubtitle,
    required this.taskRequestEquipmentListHeading,
    required this.taskRequestDescriptionMultipleLocationsNote,
    required this.labelTaskDuration,
    required this.taskChatOpenAction,
    required this.taskChatSectionTitle,
    required this.taskChatProfileEntryTitle,
    required this.taskChatProfileEntrySubtitle,
    required this.taskChatContextSubtitle,
    required this.taskChatContextStatus,
    required this.taskChatMessageHint,
    required this.taskChatSend,
    required this.taskChatAttachImage,
    required this.taskChatAttachVideo,
    required this.taskChatAttachFile,
    required this.taskChatAttachMenuTitle,
    required this.taskChatSenderAdmin,
    required this.taskChatSenderWorker,
    required this.taskChatYou,
    required this.taskChatPickTaskTitle,
    required this.taskChatLoading,
    required this.taskChatEmpty,
    required this.taskChatNotAvailableOffline,
    required this.taskChatAttachmentOpen,
    required this.taskChatAttachmentImage,
    required this.taskChatAttachmentVideo,
    required this.taskChatAttachmentPdf,
    required this.taskChatAttachmentFile,
    required this.taskChatErrorMessageSendFailed,
    required this.taskChatFailedToSendFile,
    required this.taskChatErrorUploadFailed,
    required this.taskChatErrorStorageUnavailable,
    required this.taskChatErrorUnavailable,
    required this.taskChatErrorNoAuthSession,
    required this.taskChatErrorNoTaskSelected,
    required this.taskChatErrorNoActiveTasks,
    required this.taskChatErrorUnsupportedFile,
    required this.taskChatErrorFileTooLarge,
    required this.taskChatPickerSectionActive,
    required this.taskChatPickerSectionArchive,
    required this.taskChatBadgeArchived,
    required this.taskChatBadgeHasHistory,
    required this.taskChatNoTasksForChat,
    required this.taskChatUnableToLoad,
    required this.taskChatThreadNotFound,
    required this.taskChatReadOnlyClosedTask,
    required this.taskChatLoadingConversationHint,
    required this.taskChatEmptySubtitle,
    required this.taskChatPhotoFromGallery,
    required this.taskChatTakePhoto,
    required this.taskChatAttachPdfDocument,
    required this.taskChatChooseAttachment,
    required this.taskChatPhotoPreviewTitle,
    required this.taskChatAttachmentCaptionHint,
    required this.taskChatMediaSending,
    required this.taskChatErrorProfileRequired,
    required this.taskChatErrorTimeout,
    required this.taskChatErrorConnection,
    required this.taskChatPermissionDenied,
    required this.taskChatErrorAnonymousSession,
    required this.taskChatErrorCreateThreadFailed,
    required this.taskChatErrorDatabaseInsertFailed,
    required this.taskChatErrorRlsInsertDenied,
    required this.taskChatErrorServerSchemaMismatch,
    required this.redAlertRequestEmergencyTitle,
    required this.redAlertRequestEmergencyBody,
    required this.redAlertRequestOpenButton,
    required this.redAlertScreenTitle,
    required this.redAlertLoadingCatalog,
    required this.redAlertCatalogEmpty,
    required this.redAlertIntroTitle,
    required this.redAlertIntroBody,
    required this.redAlertSelectMachine,
    required this.redAlertMachineHint,
    required this.redAlertMachineSearchHint,
    required this.redAlertNoMachinesFound,
    required this.redAlertPrefillHint,
    required this.redAlertShortReasonLabel,
    required this.redAlertShortReasonHint,
    required this.redAlertDescriptionLabel,
    required this.redAlertDescriptionHint,
    required this.redAlertSendButton,
    required this.redAlertConfirmTitle,
    required this.redAlertConfirmBody,
    required this.redAlertCancel,
    required this.redAlertConfirmSend,
    required this.redAlertSuccessTitle,
    required this.redAlertSuccessBody,
    required this.redAlertSuccessDone,
    required this.redAlertErrorNoAuth,
    required this.redAlertErrorNotReady,
    required this.redAlertErrorProfileMissing,
    required this.redAlertErrorInvalidMachine,
    required this.redAlertErrorShortReason,
    required this.redAlertErrorRlsDenied,
    required this.redAlertErrorSchemaMismatch,
    required this.redAlertErrorSendFailed,
    required this.redAlertChooseMachineFirst,
    required this.redAlertCatalogTaskRoute,
    required this.redAlertCatalogEquipmentDirectory,
    required this.redAlertTaskDetailCta,
    required this.qrScanActionTooltip,
    required this.qrScanScreenTitle,
    required this.qrScanInstruction,
    required this.qrScanRecognized,
    required this.qrScanScannedValueLabel,
    required this.qrScanPhase2Message,
    required this.qrScanAgain,
    required this.qrScanClose,
    required this.qrScanBackTooltip,
    required this.qrScanPermissionTitle,
    required this.qrScanPermissionBody,
    required this.qrScanOpenSettings,
    required this.qrScanRetry,
    required this.qrScanStartFailed,
    required this.qrScanUnavailable,
    required this.qrScanGenericErrorHint,
  });

  final AppLanguage language;
  final String loginTitle;
  final String loginSubtitle;
  final String loginDescription;
  final String loginDevPathWithoutSession;
  final String loginContinueToTasks;
  final String authLabelEmail;
  final String authLabelPassword;
  final String authHintEmail;
  final String authHintPassword;
  final String authSignInButton;
  final String authSignOutButton;
  final String authSignInFailed;
  final String authAnonymousNotWorkerWarning;
  final String authFillEmailPassword;
  final String loginDevBypassButton;
  final String tasksAppBarSignOut;
  final String authLoadingWorkerProfile;
  final String workerProfileRequiredTitle;
  final String workerProfileRequiredMessage;
  final String tasksAppTitle;
  final String navTabTasks;
  final String navTabRequest;
  final String navTabProfile;
  final String navTabArchive;
  final String archiveAppBarTitle;
  final String archiveSectionHeader;
  final String archiveEmptyTitle;
  final String archiveEmptySubtitle;
  final String archiveLabelCompletedOn;
  final String archiveLabelFinalStatus;
  final String archiveLabelDuration;
  final String archiveOpenResultHint;
  final String archiveOpenReviewHint;
  final String archiveReviewNoLocalSnapshot;
  final String tasksAllCompletedSeeArchive;
  final String profileScreenTitle;
  final String tasksSectionAssignedRounds;
  final String statusInProgress;
  final String statusPending;
  final String statusCompleted;
  final String taskDetailAppTitle;
  final String labelObject;
  final String labelStatus;
  final String labelShift;
  final String sectionInspectionRoute;
  final String startRoundButton;
  final String inspectionExecutionAppTitle;
  final String labelTask;
  final String labelProgress;
  final String sectionInspectionObjects;
  final String openCurrentObjectButton;
  final String snackbarObjectInspectionNext;
  final String badgeCurrent;
  final String badgePending;
  final String languageMenuLabel;
  final String langNameRu;
  final String langNameTr;
  final String langNameEn;
  final String mockShift0;
  final String mockShift1;
  final String mockShift2;
  final String mockTask0Title;
  final String mockTask0Area;
  final String mockTask1Title;
  final String mockTask1Area;
  final String mockTask2Title;
  final String mockTask2Area;
  final String r0i0n;
  final String r0i0s;
  final String r0i1n;
  final String r0i1s;
  final String r0i2n;
  final String r0i2s;
  final String r0i3n;
  final String r0i3s;
  final String r1i0n;
  final String r1i0s;
  final String r1i1n;
  final String r1i1s;
  final String r1i2n;
  final String r1i2s;
  final String r1i3n;
  final String r1i3s;
  final String r1i4n;
  final String r1i4s;
  final String r2i0n;
  final String r2i0s;
  final String r2i1n;
  final String r2i1s;
  final String r2i2n;
  final String r2i2s;
  final String r2i3n;
  final String r2i3s;
  final String inspectionObjectAppTitle;
  final String inspectionRouteItemUnavailable;
  final String labelZone;
  final String sectionChecklist;
  final String checklistItemVisualOk;
  final String checklistItemNoLeaks;
  final String checklistItemNoNoise;
  final String checklistItemAccessClear;
  final String sectionNote;
  final String noteHint;
  final String saveLocallyButton;
  final String completeObjectButton;
  final String inspectionSendButton;
  final String inspectionSendingLabel;
  final String inspectionOfflineQueuedTitle;
  final String inspectionOfflineQueuedSubtitle;
  final String routeBadgeAwaitingSync;
  final String snackbarLocalSaveSuccess;
  final String sectionMeasurements;
  final String labelMeasurementTemperature;
  final String labelMeasurementPressure;
  final String labelMeasurementVibration;
  final String hintMeasurementValue;
  final String unitCelsius;
  final String unitPressureBar;
  final String unitVibrationMmS;
  final String sectionDefect;
  final String defectToggleLabel;
  final String labelDefectDescription;
  final String hintDefectDescription;
  final String labelDefectPriority;
  final String priorityLow;
  final String priorityMedium;
  final String priorityHigh;
  final String routeStatusHasIssue;
  final String sectionPhotoEvidence;
  final String addPhotoButton;
  final String photoItemSubtitleLocal;
  final String removePhotoButton;
  final String snackbarPhotoLimitReached;
  final String photoPreviewClose;
  final String photoPreviewDemoCaption;
  final String voiceNoteSectionTitle;
  final String voiceStartRecording;
  final String voiceStopRecording;
  final String voiceDeleteRecording;
  final String voiceStateRecording;
  final String voiceStateRecorded;
  final String snackbarPhotoPickerCancelled;
  final String snackbarPhotoPickerFailed;
  final String snackbarMicrophoneDenied;
  final String snackbarVoiceNoteAdded;
  final String snackbarUploadFailed;
  final String snackbarUploadSuccess;
  final String errorSupabaseNotConfigured;
  final String errorAuthAnonymousFailed;
  final String errorMissingTaskId;
  final String errorMissingEquipmentId;
  final String errorReportInsertFailed;
  final String errorReportReturningEmpty;
  final String errorReportForeignKey;
  final String errorReportRlsBlocked;
  final String errorMediaInsertFailed;
  final String errorMediaMetadataAfterReportOk;
  final String errorPhotoUploadFailed;
  final String errorAudioUploadFailed;
  final String errorDatabaseSaveFailed;
  final String errorRecordingNotFound;
  final String errorSaveFailed;
  final String errorUnknownSave;
  final String errorPermissionDenied;
  final String completeObjectInProgress;
  final String appMaterialTitle;
  final String inspectionTaskSummaryTitle;
  final String sectionSummaryResults;
  final String labelSummaryTotalObjects;
  final String labelSummaryCompletedOk;
  final String labelSummaryWithIssues;
  final String summaryBackToTasksButton;
  final String statusCompletedWithIssues;
  final String taskListProgressNotStarted;
  final String taskListProgressActive;
  final String taskListProgressCompletedFull;
  final String taskListProgressCompletedFullWithIssues;
  final String taskOpenResultButton;
  final String completedReportAppTitle;
  final String sectionCompletedReportInspectionSummary;
  final String labelReportPhotoCount;
  final String labelReportAudioCount;
  final String labelReportObjectsWithDefects;
  final String taskDetailSectionOutcome;
  final String labelFinalTaskState;
  final String completedReportNotAvailable;
  final String labelDueAt;
  final String tasksUntitledTask;
  final String tasksScheduleNotSpecified;
  final String tasksLoading;
  final String tasksLoadFailed;
  final String tasksShowingDemoFallback;
  final String tasksNoWorkerIdentity;
  final String tasksSupabaseNotReady;
  final String tasksNoAssignments;
  final String tasksSectionDemoTasks;
  final String tasksDemoSectionDebugHint;
  final String workerDevWorkerIdBadge;
  final String workerProfileNotInDatabase;
  final String workerProfileMissingAuthenticated;
  final String labelEquipmentCode;
  final String labelAssignmentStatus;
  final String sectionTaskInstructions;
  final String taskDetailInstructionsEmpty;
  final String tasksRetry;
  final String workerSectionTitle;
  final String workerProfileNameLabel;
  final String workerProfileCodeLabel;
  final String taskRequestScreenTitle;
  final String taskRequestActionTooltip;
  final String labelRequestTitle;
  final String hintRequestTitle;
  final String labelRequestSiteName;
  final String hintRequestSiteName;
  final String labelRequestAreaName;
  final String hintRequestAreaName;
  final String labelRequestDescription;
  final String hintRequestDescription;
  final String labelRequestPriority;
  final String taskRequestSubmitButton;
  final String taskRequestSuccess;
  final String taskRequestErrorNoWorker;
  final String taskRequestErrorNotReady;
  final String taskRequestErrorInsert;
  final String taskRequestErrorNoAuthSession;
  final String taskRequestErrorProfileMissing;
  final String taskRequestErrorSupabaseNotConfigured;
  final String taskRequestErrorRlsDenied;
  final String taskRequestErrorSchemaMismatch;
  final String taskRequestErrorNetwork;
  final String taskRequestErrorUnknown;
  final String taskRequestValidationNeedTitle;
  final String taskRequestValidationNeedDescription;
  final String inspectionObjectEditTitle;
  final String editResultBannerHint;
  final String summaryEditResultButton;
  final String editResultPickObjectTitle;
  final String editResultNoCachedState;
  final String taskRequestSectionBasic;
  final String taskRequestSectionEquipment;
  final String taskRequestSectionProblem;
  final String labelRequestShift;
  final String hintRequestShift;
  final String labelRequestIssueSummary;
  final String hintRequestIssueSummary;
  final String labelRequestDetailedDescription;
  final String hintRequestDetailedDescription;
  final String labelRequestEquipmentName;
  final String hintRequestEquipmentName;
  final String labelRequestEquipmentLocation;
  final String hintRequestEquipmentLocation;
  final String labelRequestEquipmentCode;
  final String hintRequestEquipmentCode;
  final String labelRequestPreferredDueDate;
  final String hintRequestPreferredDueDateOptional;
  final String labelRequestType;
  final String requestTypeInspection;
  final String requestTypeMaintenance;
  final String requestTypeDefect;
  final String requestTypeRepair;
  final String taskRequestSelectDueDate;
  final String taskRequestClearDueDate;
  final String taskRequestValidationNeedIssueOrDetail;
  final String taskRequestEquipmentLoading;
  final String taskRequestEquipmentLoadFailed;
  final String taskRequestEquipmentEmpty;
  final String taskRequestValidationNeedEquipment;
  final String taskRequestEquipmentSectionSubtitle;
  final String taskRequestEquipmentListHeading;
  final String taskRequestDescriptionMultipleLocationsNote;
  final String labelTaskDuration;
  final String taskChatOpenAction;
  final String taskChatSectionTitle;
  final String taskChatProfileEntryTitle;
  final String taskChatProfileEntrySubtitle;
  final String taskChatContextSubtitle;
  final String taskChatContextStatus;
  final String taskChatMessageHint;
  final String taskChatSend;
  final String taskChatAttachImage;
  final String taskChatAttachVideo;
  final String taskChatAttachFile;
  final String taskChatAttachMenuTitle;
  final String taskChatSenderAdmin;
  final String taskChatSenderWorker;
  final String taskChatYou;
  final String taskChatPickTaskTitle;
  final String taskChatLoading;
  final String taskChatEmpty;
  final String taskChatNotAvailableOffline;
  final String taskChatAttachmentOpen;
  final String taskChatAttachmentImage;
  final String taskChatAttachmentVideo;
  final String taskChatAttachmentPdf;
  final String taskChatAttachmentFile;
  final String taskChatErrorMessageSendFailed;
  final String taskChatFailedToSendFile;
  final String taskChatErrorUploadFailed;
  final String taskChatErrorStorageUnavailable;
  final String taskChatErrorUnavailable;
  final String taskChatErrorNoAuthSession;
  final String taskChatErrorNoTaskSelected;
  final String taskChatErrorNoActiveTasks;
  final String taskChatErrorUnsupportedFile;
  final String taskChatErrorFileTooLarge;
  final String taskChatPickerSectionActive;
  final String taskChatPickerSectionArchive;
  final String taskChatBadgeArchived;
  final String taskChatBadgeHasHistory;
  final String taskChatNoTasksForChat;
  final String taskChatUnableToLoad;
  final String taskChatThreadNotFound;
  final String taskChatReadOnlyClosedTask;
  final String taskChatLoadingConversationHint;
  final String taskChatEmptySubtitle;
  final String taskChatPhotoFromGallery;
  final String taskChatTakePhoto;
  final String taskChatAttachPdfDocument;
  final String taskChatChooseAttachment;
  final String taskChatPhotoPreviewTitle;
  final String taskChatAttachmentCaptionHint;
  final String taskChatMediaSending;
  final String taskChatErrorProfileRequired;
  final String taskChatErrorTimeout;
  final String taskChatErrorConnection;
  final String taskChatPermissionDenied;
  final String taskChatErrorAnonymousSession;
  final String taskChatErrorCreateThreadFailed;
  final String taskChatErrorDatabaseInsertFailed;
  final String taskChatErrorRlsInsertDenied;
  final String taskChatErrorServerSchemaMismatch;
  final String redAlertRequestEmergencyTitle;
  final String redAlertRequestEmergencyBody;
  final String redAlertRequestOpenButton;
  final String redAlertScreenTitle;
  final String redAlertLoadingCatalog;
  final String redAlertCatalogEmpty;
  final String redAlertIntroTitle;
  final String redAlertIntroBody;
  final String redAlertSelectMachine;
  final String redAlertMachineHint;
  final String redAlertMachineSearchHint;
  final String redAlertNoMachinesFound;
  final String redAlertPrefillHint;
  final String redAlertShortReasonLabel;
  final String redAlertShortReasonHint;
  final String redAlertDescriptionLabel;
  final String redAlertDescriptionHint;
  final String redAlertSendButton;
  final String redAlertConfirmTitle;
  final String redAlertConfirmBody;
  final String redAlertCancel;
  final String redAlertConfirmSend;
  final String redAlertSuccessTitle;
  final String redAlertSuccessBody;
  final String redAlertSuccessDone;
  final String redAlertErrorNoAuth;
  final String redAlertErrorNotReady;
  final String redAlertErrorProfileMissing;
  final String redAlertErrorInvalidMachine;
  final String redAlertErrorShortReason;
  final String redAlertErrorRlsDenied;
  final String redAlertErrorSchemaMismatch;
  final String redAlertErrorSendFailed;
  final String redAlertChooseMachineFirst;
  final String redAlertCatalogTaskRoute;
  final String redAlertCatalogEquipmentDirectory;
  final String redAlertTaskDetailCta;
  final String qrScanActionTooltip;
  final String qrScanScreenTitle;
  final String qrScanInstruction;
  final String qrScanRecognized;
  final String qrScanScannedValueLabel;
  final String qrScanPhase2Message;
  final String qrScanAgain;
  final String qrScanClose;
  final String qrScanBackTooltip;
  final String qrScanPermissionTitle;
  final String qrScanPermissionBody;
  final String qrScanOpenSettings;
  final String qrScanRetry;
  final String qrScanStartFailed;
  final String qrScanUnavailable;
  final String qrScanGenericErrorHint;

  String taskRequestAutoTitleInspection(int equipmentCount) {
    switch (language) {
      case AppLanguage.ru:
        return 'Осмотр: $equipmentCount ед. оборудования';
      case AppLanguage.tr:
        return 'Muayene: $equipmentCount ekipman';
      case AppLanguage.en:
        return 'Inspection: $equipmentCount unit(s)';
    }
  }

  String taskDurationMinutesValue(int minutes) {
    switch (language) {
      case AppLanguage.ru:
        return '$minutes мин';
      case AppLanguage.tr:
        return '$minutes dk';
      case AppLanguage.en:
        return '$minutes min';
    }
  }

  String archiveCountSummary(int count) {
    switch (language) {
      case AppLanguage.ru:
        return 'В архиве: $count';
      case AppLanguage.tr:
        return 'Arşivde: $count';
      case AppLanguage.en:
        return 'In archive: $count';
    }
  }

  /// Local calendar date for task due (stored as timestamptz).
  String formatDueDate(DateTime utc) {
    final d = utc.toLocal();
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yyyy = d.year.toString();
    switch (language) {
      case AppLanguage.ru:
      case AppLanguage.tr:
        return '$dd.$mm.$yyyy';
      case AppLanguage.en:
        return '$mm/$dd/$yyyy';
    }
  }

  String inspectionTaskRemoteStatusCaption(String? raw) {
    return taskStateLabel(demoTaskStateFromRemoteInspectionStatus(raw));
  }

  String taskStateLabel(DemoTaskPublicState state) {
    switch (state) {
      case DemoTaskPublicState.pending:
        return statusPending;
      case DemoTaskPublicState.inProgress:
        return statusInProgress;
      case DemoTaskPublicState.completed:
        return statusCompleted;
      case DemoTaskPublicState.completedWithIssues:
        return statusCompletedWithIssues;
    }
  }

  String taskListProgressLine({
    required DemoTaskPublicState state,
    required int routeTotal,
  }) {
    switch (state) {
      case DemoTaskPublicState.pending:
        return '$taskListProgressNotStarted · $routeTotal';
      case DemoTaskPublicState.inProgress:
        return '$taskListProgressActive · $routeTotal';
      case DemoTaskPublicState.completed:
        return taskListProgressCompletedFull;
      case DemoTaskPublicState.completedWithIssues:
        return taskListProgressCompletedFullWithIssues;
    }
  }

  String progressObjectsChecked(int completed, int total) {
    switch (language) {
      case AppLanguage.ru:
        return '$completed из $total объектов проверено';
      case AppLanguage.tr:
        return '$total nesneden $completed tanesi kontrol edildi';
      case AppLanguage.en:
        return '$completed of $total objects checked';
    }
  }

  String mockPhotoTitle(int ordinal) {
    switch (language) {
      case AppLanguage.ru:
        return 'Фото $ordinal';
      case AppLanguage.tr:
        return 'Fotoğraf $ordinal';
      case AppLanguage.en:
        return 'Photo $ordinal';
    }
  }
}

AppStrings stringsFor(AppLanguage lang) {
  switch (lang) {
    case AppLanguage.ru:
      return _ru;
    case AppLanguage.tr:
      return _tr;
    case AppLanguage.en:
      return _en;
  }
}

const AppStrings _ru = AppStrings(
  language: AppLanguage.ru,
  loginTitle: 'Мобильный обходчик',
  loginSubtitle: 'Контроль оборудования и обходы',
  loginDescription:
      'Войдите почтой и паролем исполнителя (учётная запись создаётся администратором в Supabase). Тогда задачи загрузятся из назначений.',
  loginDevPathWithoutSession:
      'Сессия Supabase не активна: ниже — путь для разработки (например DEV_WORKER_USER_ID). Рабочий режим — после входа исполнителя.',
  loginContinueToTasks: 'Перейти к задачам',
  authLabelEmail: 'Эл. почта',
  authLabelPassword: 'Пароль',
  authHintEmail: 'worker@company.com',
  authHintPassword: '••••••••',
  authSignInButton: 'Войти',
  authSignOutButton: 'Выйти из аккаунта',
  authSignInFailed: 'Не удалось войти. Проверьте почту и пароль.',
  authAnonymousNotWorkerWarning:
      'Активна анонимная сессия — это не учётная запись исполнителя. Выйдите и войдите почтой и паролем, как задал администратор.',
  authFillEmailPassword: 'Введите почту и пароль',
  loginDevBypassButton: 'Отладка: обход с DEV_WORKER_USER_ID',
  tasksAppBarSignOut: 'Выйти',
  authLoadingWorkerProfile: 'Загрузка профиля исполнителя…',
  workerProfileRequiredTitle: 'Профиль не найден',
  workerProfileRequiredMessage:
      'Для этой учётной записи нет строки в profiles. Администратор должен создать профиль с тем же id, что и в Supabase Auth. Выйдите и войдите снова после исправления.',
  tasksAppTitle: 'Задачи',
  navTabTasks: 'Задачи',
  navTabRequest: 'Запрос',
  navTabProfile: 'Профиль',
  navTabArchive: 'Архив',
  archiveAppBarTitle: 'Архив',
  archiveSectionHeader: 'Архивные задачи',
  archiveEmptyTitle: 'Архив пуст',
  archiveEmptySubtitle:
      'Завершённые обходы появятся здесь после выполнения.',
  archiveLabelCompletedOn: 'Завершено',
  archiveLabelFinalStatus: 'Итоговый статус',
  archiveLabelDuration: 'Длительность',
  archiveOpenResultHint: 'Открыть отчёт',
  archiveOpenReviewHint: 'Просмотр',
  archiveReviewNoLocalSnapshot:
      'Подробный отчёт на этом устройстве недоступен. Доступны сведения о задаче и маршруте.',
  tasksAllCompletedSeeArchive:
      'Все назначенные обходы завершены. Откройте вкладку «Архив», чтобы просмотреть их.',
  profileScreenTitle: 'Профиль',
  tasksSectionAssignedRounds: 'Назначенные обходы',
  statusInProgress: 'В процессе',
  statusPending: 'Ожидает',
  statusCompleted: 'Выполнено',
  taskDetailAppTitle: 'Детали задачи',
  labelObject: 'Объект',
  labelStatus: 'Статус',
  labelShift: 'Смена',
  sectionInspectionRoute: 'Маршрут обхода',
  startRoundButton: 'Начать обход',
  inspectionExecutionAppTitle: 'Выполнение обхода',
  labelTask: 'Задача',
  labelProgress: 'Прогресс',
  sectionInspectionObjects: 'Объекты обхода',
  openCurrentObjectButton: 'Открыть текущий объект',
  snackbarObjectInspectionNext:
      'Экран осмотра объекта будет добавлен следующим шагом',
  badgeCurrent: 'Текущий',
  badgePending: 'Ожидает',
  languageMenuLabel: 'Язык',
  langNameRu: 'Русский',
  langNameTr: 'Türkçe',
  langNameEn: 'English',
  mockShift0: 'Смена А, 16.04.2026',
  mockShift1: 'Смена Б, 16.04.2026',
  mockShift2: 'Смена А, 15.04.2026',
  mockTask0Title: 'Обход котельной №1',
  mockTask0Area: 'Котельная, зона А',
  mockTask1Title: 'Плановый осмотр трансформаторной',
  mockTask1Area: 'ТП-12',
  mockTask2Title: 'Обход насосной станции',
  mockTask2Area: 'Насосная — корпус 2',
  r0i0n: 'Насос Н-12',
  r0i0s: 'Котельная, линия подачи',
  r0i1n: 'Клапан К-3',
  r0i1s: 'Зона А, узел регулировки',
  r0i2n: 'Датчик температуры T-7',
  r0i2s: 'Коллектор горячей воды',
  r0i3n: 'Щит управления ШУ-2',
  r0i3s: 'Помещение автоматики',
  r1i0n: 'Силовой трансформатор Т-1',
  r1i0s: 'ТП-12, камера 1',
  r1i1n: 'Разъединитель Р-5',
  r1i1s: 'Ячейка ввода',
  r1i2n: 'Датчик температуры T-7',
  r1i2s: 'Секция шин',
  r1i3n: 'Щит управления ШУ-2',
  r1i3s: 'Пульт оператора',
  r1i4n: 'Клапан К-3',
  r1i4s: 'Пожарный сегмент',
  r2i0n: 'Насос Н-12',
  r2i0s: 'Насосная, агрегат 1',
  r2i1n: 'Клапан К-3',
  r2i1s: 'Обвязка напорная',
  r2i2n: 'Датчик температуры T-7',
  r2i2s: 'Резервуар, датчик погружной',
  r2i3n: 'Щит управления ШУ-2',
  r2i3s: 'Корпус 2, щитовая',
  inspectionObjectAppTitle: 'Осмотр объекта',
  inspectionRouteItemUnavailable:
      'Позиция маршрута недоступна. Вернитесь к маршруту и откройте объект снова.',
  labelZone: 'Зона',
  sectionChecklist: 'Чек-лист',
  checklistItemVisualOk: 'Внешнее состояние в норме',
  checklistItemNoLeaks: 'Нет признаков протечек',
  checklistItemNoNoise: 'Нет постороннего шума',
  checklistItemAccessClear: 'Зона доступа свободна',
  sectionNote: 'Комментарий',
  noteHint: 'Добавьте комментарий',
  saveLocallyButton: 'Сохранить локально',
  completeObjectButton: 'Завершить объект',
  inspectionSendButton: 'Отправить',
  inspectionSendingLabel: 'Отправка…',
  inspectionOfflineQueuedTitle: 'Нет сети. Сохранено локально',
  inspectionOfflineQueuedSubtitle:
      'Отправится автоматически при появлении связи',
  routeBadgeAwaitingSync: 'Ожидает отправки',
  snackbarLocalSaveSuccess: 'Данные сохранены локально',
  sectionMeasurements: 'Показания',
  labelMeasurementTemperature: 'Температура',
  labelMeasurementPressure: 'Давление',
  labelMeasurementVibration: 'Вибрация',
  hintMeasurementValue: 'Введите значение',
  unitCelsius: '°C',
  unitPressureBar: 'бар',
  unitVibrationMmS: 'мм/с',
  sectionDefect: 'Дефект',
  defectToggleLabel: 'Обнаружен дефект',
  labelDefectDescription: 'Описание',
  hintDefectDescription: 'Опишите проблему',
  labelDefectPriority: 'Приоритет',
  priorityLow: 'Низкий',
  priorityMedium: 'Средний',
  priorityHigh: 'Высокий',
  routeStatusHasIssue: 'Есть проблема',
  sectionPhotoEvidence: 'Фотофиксация',
  addPhotoButton: 'Добавить фото',
  photoItemSubtitleLocal: 'Локальное вложение',
  removePhotoButton: 'Удалить',
  snackbarPhotoLimitReached: 'Можно добавить не более 3 фото',
  photoPreviewClose: 'Закрыть',
  photoPreviewDemoCaption: 'Локальное вложение (предпросмотр)',
  voiceNoteSectionTitle: 'Голосовая заметка',
  voiceStartRecording: 'Начать запись',
  voiceStopRecording: 'Остановить',
  voiceDeleteRecording: 'Удалить запись',
  voiceStateRecording: 'Идёт запись…',
  voiceStateRecorded: 'Запись готова',
  snackbarPhotoPickerCancelled: 'Выбор фото отменён',
  snackbarPhotoPickerFailed: 'Не удалось выбрать фото',
  snackbarMicrophoneDenied: 'Нет доступа к микрофону',
  snackbarVoiceNoteAdded: 'Голосовая заметка добавлена',
  snackbarUploadFailed: 'Не удалось сохранить отчёт',
  snackbarUploadSuccess: 'Отчёт успешно сохранён',
  errorSupabaseNotConfigured: 'Сервер данных не настроен (Supabase)',
  errorAuthAnonymousFailed:
      'Не удалось войти анонимно (проверьте Anonymous в Supabase Auth)',
  errorMissingTaskId: 'Не указан идентификатор задачи',
  errorMissingEquipmentId: 'Не указан идентификатор оборудования',
  errorReportInsertFailed:
      'Не удалось записать отчёт (inspection_reports). См. лог Postgrest.',
  errorReportReturningEmpty:
      'Сервер не вернул строку отчёта. Добавьте политику SELECT для inspection_reports (часто из‑за RLS).',
  errorReportForeignKey:
      'Задача или оборудование не найдены в базе (проверьте id или данные)',
  errorReportRlsBlocked:
      'Запись запрещена политикой безопасности (RLS в Supabase)',
  errorMediaInsertFailed:
      'Не удалось записать медиа (inspection_media). См. лог Postgrest.',
  errorMediaMetadataAfterReportOk:
      'Отчёт сохранён, но не удалось записать медиа в базу. Проверьте inspection_media.',
  errorPhotoUploadFailed: 'Не удалось загрузить фото',
  errorAudioUploadFailed: 'Не удалось загрузить аудио',
  errorDatabaseSaveFailed: 'Ошибка записи в базу данных',
  errorRecordingNotFound: 'Файл записи не найден',
  errorSaveFailed: 'Сохранение не выполнено',
  errorUnknownSave: 'Неизвестная ошибка',
  errorPermissionDenied: 'Недостаточно разрешений',
  completeObjectInProgress: 'Отправка…',
  appMaterialTitle: 'Обход оборудования',
  inspectionTaskSummaryTitle: 'Обход завершён',
  sectionSummaryResults: 'Итоги маршрута',
  labelSummaryTotalObjects: 'Всего объектов',
  labelSummaryCompletedOk: 'Завершено без замечаний',
  labelSummaryWithIssues: 'С замечаниями',
  summaryBackToTasksButton: 'Вернуться к задачам',
  statusCompletedWithIssues: 'Завершено с замечаниями',
  taskListProgressNotStarted: 'Не начато',
  taskListProgressActive: 'В процессе',
  taskListProgressCompletedFull: 'Завершено: 100% (все объекты проверены)',
  taskListProgressCompletedFullWithIssues:
      'Завершено: 100% (есть замечания по маршруту)',
  taskOpenResultButton: 'Открыть результат',
  completedReportAppTitle: 'Результат обхода',
  sectionCompletedReportInspectionSummary: 'Сводка осмотра',
  labelReportPhotoCount: 'Фото',
  labelReportAudioCount: 'Аудио',
  labelReportObjectsWithDefects: 'Объектов с дефектом',
  taskDetailSectionOutcome: 'Итог обхода',
  labelFinalTaskState: 'Итоговый статус',
  completedReportNotAvailable: 'Результат обхода недоступен',
  labelDueAt: 'Срок',
  tasksUntitledTask: 'Задача без названия',
  tasksScheduleNotSpecified: 'Не указано',
  tasksLoading: 'Загрузка задач…',
  tasksLoadFailed: 'Не удалось загрузить задачи',
  tasksShowingDemoFallback: 'Показаны демо-задачи (нет назначений или ошибка сети)',
  tasksNoWorkerIdentity: 'Нет учётной записи исполнителя. Войдите или задайте DEV_WORKER_USER_ID',
  tasksSupabaseNotReady: 'Подключение к серверу недоступно',
  tasksNoAssignments: 'Нет назначенных задач',
  tasksSectionDemoTasks: 'Демо-задачи',
  tasksDemoSectionDebugHint:
      'Только в сборке отладки: пример данных, не реальные назначения.',
  workerDevWorkerIdBadge: 'Режим DEV_WORKER_USER_ID',
  workerProfileNotInDatabase: 'Профиль в базе не найден',
  workerProfileMissingAuthenticated:
      'В таблице profiles нет строки для этого пользователя. Администратор должен создать профиль исполнителя с тем же id, что и в Supabase Auth.',
  labelEquipmentCode: 'Код оборудования',
  labelAssignmentStatus: 'Статус назначения',
  sectionTaskInstructions: 'Инструкции',
  taskDetailInstructionsEmpty:
      'Дополнительных указаний нет. Следуйте стандартной процедуре обхода.',
  tasksRetry: 'Повторить',
  workerSectionTitle: 'Исполнитель',
  workerProfileNameLabel: 'ФИО',
  workerProfileCodeLabel: 'Табельный номер',
  taskRequestScreenTitle: 'Запрос на задачу',
  taskRequestActionTooltip: 'Запросить задачу',
  labelRequestTitle: 'Название',
  hintRequestTitle: 'Кратко опишите работу',
  labelRequestSiteName: 'Объект / площадка',
  hintRequestSiteName: 'Например, цех, станция',
  labelRequestAreaName: 'Зона / участок',
  hintRequestAreaName: 'Например, линия, корпус',
  labelRequestDescription: 'Описание',
  hintRequestDescription: 'Что нужно проверить или выполнить',
  labelRequestPriority: 'Приоритет',
  taskRequestSubmitButton: 'Отправить на согласование',
  taskRequestSuccess: 'Запрос отправлен руководителю',
  taskRequestErrorNoWorker: 'Нет учётной записи исполнителя',
  taskRequestErrorNotReady: 'Сервер недоступен',
  taskRequestErrorInsert: 'Не удалось отправить запрос',
  taskRequestErrorNoAuthSession:
      'Войдите в аккаунт исполнителя (не анонимно), чтобы отправить запрос.',
  taskRequestErrorProfileMissing:
      'Профиль не найден в базе. Обратитесь к администратору.',
  taskRequestErrorSupabaseNotConfigured:
      'Приложение не подключено к серверу. Проверьте настройки.',
  taskRequestErrorRlsDenied:
      'Нет прав на отправку запроса. Проверьте учётную запись и политики доступа.',
  taskRequestErrorSchemaMismatch:
      'Сервер не совместим с приложением. Нужно обновить схему базы (миграции).',
  taskRequestErrorNetwork:
      'Нет сети или сервер не отвечает. Повторите попытку позже.',
  taskRequestErrorUnknown:
      'Не удалось отправить запрос. Попробуйте ещё раз.',
  taskRequestValidationNeedTitle: 'Укажите краткое описание запроса',
  taskRequestValidationNeedDescription: 'Укажите подробное описание',
  inspectionObjectEditTitle: 'Редактирование результата',
  editResultBannerHint:
      'Вы редактируете ранее отправленный результат. Изменения будут сохранены как новая версия отчёта после отправки.',
  summaryEditResultButton: 'Редактировать результат',
  editResultPickObjectTitle: 'Какой объект изменить?',
  editResultNoCachedState:
      'Нет сохранённых данных для редактирования (сессия сброшена или файлы удалены). Пройдите обход снова.',
  taskRequestSectionBasic: 'Основное',
  taskRequestSectionEquipment: 'Оборудование',
  taskRequestSectionProblem: 'Запрос / проблема',
  labelRequestShift: 'Смена',
  hintRequestShift: 'Например, смена А, ночная',
  labelRequestIssueSummary: 'Кратко о проблеме',
  hintRequestIssueSummary: 'Одна строка: что не так или что нужно',
  labelRequestDetailedDescription: 'Подробное описание',
  hintRequestDetailedDescription: 'Детали, обстоятельства, что сделать',
  labelRequestEquipmentName: 'Название оборудования',
  hintRequestEquipmentName: 'Агрегат, узел, линия',
  labelRequestEquipmentLocation: 'Местоположение',
  hintRequestEquipmentLocation: 'Цех, этаж, зона',
  labelRequestEquipmentCode: 'Код / инв. номер (необязательно)',
  hintRequestEquipmentCode: 'Если известен',
  labelRequestPreferredDueDate: 'Желаемый срок',
  hintRequestPreferredDueDateOptional: 'Необязательно',
  labelRequestType: 'Тип запроса',
  requestTypeInspection: 'Обход / осмотр',
  requestTypeMaintenance: 'Обслуживание',
  requestTypeDefect: 'Дефект',
  requestTypeRepair: 'Ремонт',
  taskRequestSelectDueDate: 'Выбрать дату',
  taskRequestClearDueDate: 'Сбросить дату',
  taskRequestValidationNeedIssueOrDetail:
      'Укажите краткое описание проблемы или подробности',
  taskRequestEquipmentLoading: 'Загрузка объектов…',
  taskRequestEquipmentLoadFailed: 'Не удалось загрузить дерево оборудования',
  taskRequestEquipmentEmpty: 'Нет активных узлов. Обратитесь к администратору.',
  taskRequestValidationNeedEquipment: 'Выберите хотя бы одну единицу оборудования',
  taskRequestEquipmentSectionSubtitle:
      'Иерархия как на странице «Объекты»: отметьте нужные единицы.',
  taskRequestEquipmentListHeading: 'Выбранное оборудование:',
  taskRequestDescriptionMultipleLocationsNote:
      'Примечание: выбраны единицы с разных площадок или участков; поля объекта/зоны объединены.',
  labelTaskDuration: 'Длительность выполнения',
  taskChatOpenAction: 'Чат по задаче',
  taskChatSectionTitle: 'Связь с администратором',
  taskChatProfileEntryTitle: 'Чаты по задачам',
  taskChatProfileEntrySubtitle:
      'Активные и архивные задачи, история сообщений',
  taskChatContextSubtitle: 'Обсуждение этой задачи',
  taskChatContextStatus: 'Статус задачи',
  taskChatMessageHint: 'Сообщение…',
  taskChatSend: 'Отправить',
  taskChatAttachImage: 'Фото',
  taskChatAttachVideo: 'Видео',
  taskChatAttachFile: 'Файл',
  taskChatAttachMenuTitle: 'Вложение',
  taskChatSenderAdmin: 'Администратор',
  taskChatSenderWorker: 'Исполнитель',
  taskChatYou: 'Вы',
  taskChatPickTaskTitle: 'Выберите задачу',
  taskChatLoading: 'Загрузка чата…',
  taskChatEmpty: 'Пока нет сообщений',
  taskChatNotAvailableOffline: 'Чат доступен только для назначенных задач из базы',
  taskChatAttachmentOpen: 'Открыть',
  taskChatAttachmentImage: 'Изображение',
  taskChatAttachmentVideo: 'Видео',
  taskChatAttachmentPdf: 'PDF',
  taskChatAttachmentFile: 'Файл',
  taskChatErrorMessageSendFailed: 'Не удалось отправить сообщение',
  taskChatFailedToSendFile: 'Не удалось отправить файл',
  taskChatErrorUploadFailed: 'Не удалось загрузить файл',
  taskChatErrorStorageUnavailable: 'Хранилище файлов недоступно',
  taskChatErrorUnavailable: 'Чат временно недоступен',
  taskChatErrorNoAuthSession: 'Нет сессии. Войдите в аккаунт.',
  taskChatErrorNoTaskSelected: 'Задача не выбрана',
  taskChatErrorNoActiveTasks: 'Нет активных задач для чата',
  taskChatErrorUnsupportedFile: 'Неподдерживаемый тип файла',
  taskChatErrorFileTooLarge: 'Файл слишком большой',
  taskChatPickerSectionActive: 'Текущие задачи',
  taskChatPickerSectionArchive: 'Архив и история',
  taskChatBadgeArchived: 'Архив',
  taskChatBadgeHasHistory: 'Есть переписка',
  taskChatNoTasksForChat: 'Нет задач для чата',
  taskChatUnableToLoad: 'Не удалось загрузить чат',
  taskChatThreadNotFound: 'Переписка недоступна',
  taskChatReadOnlyClosedTask:
      'Задача завершена — переписку можно только просматривать.',
  taskChatLoadingConversationHint: 'Загрузка переписки…',
  taskChatEmptySubtitle: 'Начните обсуждение этой задачи',
  taskChatPhotoFromGallery: 'Фото из галереи',
  taskChatTakePhoto: 'Сделать фото',
  taskChatAttachPdfDocument: 'PDF-документ',
  taskChatChooseAttachment: 'Выберите вложение',
  taskChatPhotoPreviewTitle: 'Отправка фото',
  taskChatAttachmentCaptionHint: 'Добавить подпись (необязательно)',
  taskChatMediaSending: 'Отправка…',
  taskChatErrorProfileRequired:
      'Для чата нужен профиль работника. Обратитесь к администратору.',
  taskChatErrorTimeout:
      'Превышено время ожидания. Проверьте сеть и повторите.',
  taskChatErrorConnection:
      'Проблема с подключением. Повторите позже.',
  taskChatPermissionDenied:
      'Нет разрешения. Разрешите доступ в настройках.',
  taskChatErrorAnonymousSession:
      'Войдите под учётной записью исполнителя (не анонимно), чтобы писать в чат.',
  taskChatErrorCreateThreadFailed:
      'Не удалось создать переписку по задаче. Проверьте назначение, сеть и права доступа.',
  taskChatErrorDatabaseInsertFailed:
      'Сообщение не сохранено: ошибка сервера или схемы. Проверьте профиль исполнителя и политики RLS.',
  taskChatErrorRlsInsertDenied:
      'Отправка запрещена политикой безопасности (RLS): нет права вставлять сообщение для этой задачи или потока чата.',
  taskChatErrorServerSchemaMismatch:
      'Сообщение не сохранено: в таблице task_chat_messages нет столбца body (ошибка PGRST204) или схема устарела. В Supabase → SQL Editor выполните: 20260422150000_task_chat_messages_ensure_body_column.sql, затем при необходимости 20260422103000_task_chat_ensure_trigger_and_access.sql. Веб-панель должна читать тот же столбец body.',
  redAlertRequestEmergencyTitle: 'Критический инцидент',
  redAlertRequestEmergencyBody:
      'Срочное сообщение в панель администратора: остановка агрегата, опасная неисправность, срочный осмотр или немедленное обслуживание.',
  redAlertRequestOpenButton: 'Красная тревога',
  redAlertScreenTitle: 'Красная тревога',
  redAlertLoadingCatalog: 'Загрузка списка оборудования…',
  redAlertCatalogEmpty:
      'Нет доступного оборудования. Проверьте назначения или справочник.',
  redAlertIntroTitle: 'Только для срочных случаев',
  redAlertIntroBody:
      'Используйте при критических ситуациях: остановка, опасная неисправность, срочный осмотр, немедленное ТО.',
  redAlertSelectMachine: 'Выберите оборудование',
  redAlertMachineHint: 'Нажмите, чтобы выбрать',
  redAlertMachineSearchHint: 'Поиск по названию или задаче',
  redAlertNoMachinesFound: 'Ничего не найдено',
  redAlertPrefillHint:
      'Оборудование выбрано по текущей задаче; при необходимости укажите другое.',
  redAlertShortReasonLabel: 'Краткая причина',
  redAlertShortReasonHint:
      'Например: остановка насоса, утечка под давлением',
  redAlertDescriptionLabel: 'Описание',
  redAlertDescriptionHint: 'Что произошло, риски, что видите на месте',
  redAlertSendButton: 'Отправить критическое оповещение',
  redAlertConfirmTitle: 'Подтвердить отправку',
  redAlertConfirmBody:
      'Критическое оповещение будет немедленно отправлено в панель администратора. Продолжить?',
  redAlertCancel: 'Отмена',
  redAlertConfirmSend: 'Отправить',
  redAlertSuccessTitle: 'Оповещение отправлено',
  redAlertSuccessBody:
      'Критическое оповещение отправлено в панель администратора.',
  redAlertSuccessDone: 'Готово',
  redAlertErrorNoAuth:
      'Войдите в аккаунт исполнителя, чтобы отправить оповещение.',
  redAlertErrorNotReady: 'Сервер недоступен. Повторите позже.',
  redAlertErrorProfileMissing:
      'Профиль исполнителя не найден. Обратитесь к администратору.',
  redAlertErrorInvalidMachine: 'Некорректные данные оборудования.',
  redAlertErrorShortReason: 'Укажите краткую причину.',
  redAlertErrorRlsDenied:
      'Нет прав на отправку. Проверьте учётную запись и политики доступа.',
  redAlertErrorSchemaMismatch:
      'Таблица оповещений недоступна. Нужно обновить схему базы.',
  redAlertErrorSendFailed: 'Не удалось отправить оповещение.',
  redAlertChooseMachineFirst: 'Сначала выберите оборудование.',
  redAlertCatalogTaskRoute: 'Из маршрута задачи',
  redAlertCatalogEquipmentDirectory: 'Справочник оборудования',
  redAlertTaskDetailCta: 'Красная тревога',
  qrScanActionTooltip: 'Сканировать QR',
  qrScanScreenTitle: 'Сканер QR',
  qrScanInstruction: 'Наведите камеру на QR-код',
  qrScanRecognized: 'QR распознан',
  qrScanScannedValueLabel: 'Считанное значение',
  qrScanPhase2Message:
      'Привязка QR к задаче и оборудованию будет подключена на следующем этапе.',
  qrScanAgain: 'Сканировать снова',
  qrScanClose: 'Закрыть',
  qrScanBackTooltip: 'Назад',
  qrScanPermissionTitle: 'Нужен доступ к камере',
  qrScanPermissionBody:
      'Разрешите использование камеры в настройках устройства, чтобы сканировать QR-коды.',
  qrScanOpenSettings: 'Открыть настройки',
  qrScanRetry: 'Повторить',
  qrScanStartFailed: 'Не удалось запустить камеру',
  qrScanUnavailable: 'Сканирование на этом устройстве недоступно',
  qrScanGenericErrorHint:
      'Проверьте разрешения и повторите попытку. На симуляторе камера может отсутствовать.',
);

const AppStrings _tr = AppStrings(
  language: AppLanguage.tr,
  loginTitle: 'Mobil saha denetçisi',
  loginSubtitle: 'Ekipman kontrolü ve turlar',
  loginDescription:
      'Yöneticinin Supabase’te oluşturduğu işçi e-postası ve şifresiyle giriş yapın. Görevler atamalardan yüklenir.',
  loginDevPathWithoutSession:
      'Supabase oturumu yok: aşağıdaki yol geliştirme içindir (ör. DEV_WORKER_USER_ID). Gerçek kullanım için işçi girişi gerekir.',
  loginContinueToTasks: 'Görevlere devam et',
  authLabelEmail: 'E-posta',
  authLabelPassword: 'Şifre',
  authHintEmail: 'isci@sirket.com',
  authHintPassword: '••••••••',
  authSignInButton: 'Giriş yap',
  authSignOutButton: 'Oturumu kapat',
  authSignInFailed: 'Giriş başarısız. E-posta ve şifreyi kontrol edin.',
  authAnonymousNotWorkerWarning:
      'Anonim oturum açık — bu geçerli bir işçi hesabı değil. Çıkış yapıp yöneticinin verdiği e-posta ve şifre ile girin.',
  authFillEmailPassword: 'E-posta ve şifre girin',
  loginDevBypassButton: 'Hata ayıklama: DEV_WORKER_USER_ID ile devam',
  tasksAppBarSignOut: 'Çıkış',
  authLoadingWorkerProfile: 'İşçi profili yükleniyor…',
  workerProfileRequiredTitle: 'Profil bulunamadı',
  workerProfileRequiredMessage:
      'Bu hesap için profiles tablosunda kayıt yok. Yönetici, Supabase Auth ile aynı id’de profil oluşturmalı. Düzeltmeden sonra çıkış yapıp tekrar girin.',
  tasksAppTitle: 'Görevler',
  navTabTasks: 'Görevler',
  navTabRequest: 'Talep',
  navTabProfile: 'Profil',
  navTabArchive: 'Arşiv',
  archiveAppBarTitle: 'Arşiv',
  archiveSectionHeader: 'Arşivlenen görevler',
  archiveEmptyTitle: 'Arşiv boş',
  archiveEmptySubtitle:
      'Tamamlanan turlar tamamlandıktan sonra burada listelenir.',
  archiveLabelCompletedOn: 'Tamamlanma',
  archiveLabelFinalStatus: 'Son durum',
  archiveLabelDuration: 'Süre',
  archiveOpenResultHint: 'Raporu aç',
  archiveOpenReviewHint: 'İncele',
  archiveReviewNoLocalSnapshot:
      'Bu cihazda ayrıntılı rapor yok. Görev ve güzergâh bilgileri görüntülenir.',
  tasksAllCompletedSeeArchive:
      'Atanan görevlerin tamamı tamamlandı. İncelemek için Arşiv sekmesini açın.',
  profileScreenTitle: 'Profil',
  tasksSectionAssignedRounds: 'Atanmış görevler',
  statusInProgress: 'Devam ediyor',
  statusPending: 'Bekliyor',
  statusCompleted: 'Tamamlandı',
  taskDetailAppTitle: 'Görev ayrıntıları',
  labelObject: 'Tesis / konum',
  labelStatus: 'Durum',
  labelShift: 'Vardiya',
  sectionInspectionRoute: 'Kontrol güzergâhı',
  startRoundButton: 'Tura başla',
  inspectionExecutionAppTitle: 'Tur yürütme',
  labelTask: 'Görev',
  labelProgress: 'İlerleme',
  sectionInspectionObjects: 'Tur nesneleri',
  openCurrentObjectButton: 'Geçerli nesneyi aç',
  snackbarObjectInspectionNext:
      'Nesne inceleme ekranı bir sonraki adımda eklenecek',
  badgeCurrent: 'Geçerli',
  badgePending: 'Bekliyor',
  languageMenuLabel: 'Dil',
  langNameRu: 'Русский',
  langNameTr: 'Türkçe',
  langNameEn: 'English',
  mockShift0: 'Vardiya A, 16.04.2026',
  mockShift1: 'Vardiya B, 16.04.2026',
  mockShift2: 'Vardiya A, 15.04.2026',
  mockTask0Title: 'Kazan dairesi turu №1',
  mockTask0Area: 'Kazan dairesi, A bölgesi',
  mockTask1Title: 'Planlı trafo incelemesi',
  mockTask1Area: 'TP-12',
  mockTask2Title: 'Pompa istasyonu turu',
  mockTask2Area: 'Pompa istasyonu — bina 2',
  r0i0n: 'Pompa N-12',
  r0i0s: 'Kazan dairesi, besleme hattı',
  r0i1n: 'Vana K-3',
  r0i1s: 'A bölgesi, regülasyon ünitesi',
  r0i2n: 'Sıcaklık sensörü T-7',
  r0i2s: 'Sıcak su kollektörü',
  r0i3n: 'Kontrol panosu ŞU-2',
  r0i3s: 'Otomasyon odası',
  r1i0n: 'Güç transformatörü T-1',
  r1i0s: 'TP-12, hücre 1',
  r1i1n: 'Ayırıcı R-5',
  r1i1s: 'Giriş hücresi',
  r1i2n: 'Sıcaklık sensörü T-7',
  r1i2s: 'Bara bölümü',
  r1i3n: 'Kontrol panosu ŞU-2',
  r1i3s: 'Operatör konsolu',
  r1i4n: 'Vana K-3',
  r1i4s: 'Yangın segmenti',
  r2i0n: 'Pompa N-12',
  r2i0s: 'Pompa istasyonu, ünite 1',
  r2i1n: 'Vana K-3',
  r2i1s: 'Basınçlı hat bağlantısı',
  r2i2n: 'Sıcaklık sensörü T-7',
  r2i2s: 'Tank, daldırma sensörü',
  r2i3n: 'Kontrol panosu ŞU-2',
  r2i3s: 'Bina 2, pano odası',
  inspectionObjectAppTitle: 'Ekipman kontrolü',
  inspectionRouteItemUnavailable:
      'Güzergâh öğesi kullanılamıyor. Güzergâha dönüp nesneyi yeniden açın.',
  labelZone: 'Bölge',
  sectionChecklist: 'Kontrol listesi',
  checklistItemVisualOk: 'Görsel durum normal',
  checklistItemNoLeaks: 'Sızıntı tespit edilmedi',
  checklistItemNoNoise: 'Olağandışı gürültü yok',
  checklistItemAccessClear: 'Erişim alanı açık',
  sectionNote: 'Not',
  noteHint: 'Not ekleyin',
  saveLocallyButton: 'Yerel kaydet',
  completeObjectButton: 'Ekipmanı tamamla',
  inspectionSendButton: 'Gönder',
  inspectionSendingLabel: 'Gönderiliyor…',
  inspectionOfflineQueuedTitle: 'İnternet yok. Yerel olarak kaydedildi',
  inspectionOfflineQueuedSubtitle:
      'Bağlantı gelince otomatik gönderilecek',
  routeBadgeAwaitingSync: 'Gönderim bekliyor',
  snackbarLocalSaveSuccess: 'Veriler yerel olarak kaydedildi',
  sectionMeasurements: 'Ölçümler',
  labelMeasurementTemperature: 'Sıcaklık',
  labelMeasurementPressure: 'Basınç',
  labelMeasurementVibration: 'Titreşim',
  hintMeasurementValue: 'Değer girin',
  unitCelsius: '°C',
  unitPressureBar: 'bar',
  unitVibrationMmS: 'mm/s',
  sectionDefect: 'Arıza',
  defectToggleLabel: 'Arıza tespit edildi',
  labelDefectDescription: 'Açıklama',
  hintDefectDescription: 'Sorunu açıklayın',
  labelDefectPriority: 'Öncelik',
  priorityLow: 'Düşük',
  priorityMedium: 'Orta',
  priorityHigh: 'Yüksek',
  routeStatusHasIssue: 'Sorun var',
  sectionPhotoEvidence: 'Fotoğraf kaydı',
  addPhotoButton: 'Fotoğraf ekle',
  photoItemSubtitleLocal: 'Yerel ek',
  removePhotoButton: 'Sil',
  snackbarPhotoLimitReached: 'En fazla 3 fotoğraf eklenebilir',
  photoPreviewClose: 'Kapat',
  photoPreviewDemoCaption: 'Yerel ek önizlemesi',
  voiceNoteSectionTitle: 'Ses notu',
  voiceStartRecording: 'Kayda başla',
  voiceStopRecording: 'Durdur',
  voiceDeleteRecording: 'Kaydı sil',
  voiceStateRecording: 'Kayıt yapılıyor…',
  voiceStateRecorded: 'Kayıt hazır',
  snackbarPhotoPickerCancelled: 'Fotoğraf seçimi iptal edildi',
  snackbarPhotoPickerFailed: 'Fotoğraf seçilemedi',
  snackbarMicrophoneDenied: 'Mikrofon izni yok',
  snackbarVoiceNoteAdded: 'Ses notu eklendi',
  snackbarUploadFailed: 'Rapor kaydedilemedi',
  snackbarUploadSuccess: 'Rapor başarıyla kaydedildi',
  errorSupabaseNotConfigured: 'Supabase yapılandırılmadı',
  errorAuthAnonymousFailed:
      'Anonim oturum açılamadı (Supabase Auth → Anonymous)',
  errorMissingTaskId: 'Görev kimliği eksik',
  errorMissingEquipmentId: 'Ekipman kimliği eksik',
  errorReportInsertFailed:
      'Rapor satırı yazılamadı (inspection_reports). Log’a bakın.',
  errorReportReturningEmpty:
      'Sunucu rapor satırı döndürmedi. inspection_reports için SELECT RLS politikası ekleyin.',
  errorReportForeignKey:
      'Görev veya ekipman sunucuda yok (id / FK kontrol edin)',
  errorReportRlsBlocked:
      'Güvenlik politikası yazmayı engelliyor (Supabase RLS)',
  errorMediaInsertFailed:
      'Medya satırı yazılamadı (inspection_media). Log’a bakın.',
  errorMediaMetadataAfterReportOk:
      'Rapor kaydedildi ancak medya bilgisi veritabanına yazılamadı.',
  errorPhotoUploadFailed: 'Fotoğraf yüklenemedi',
  errorAudioUploadFailed: 'Ses yüklenemedi',
  errorDatabaseSaveFailed: 'Veritabanına kayıt başarısız',
  errorRecordingNotFound: 'Kayıt dosyası bulunamadı',
  errorSaveFailed: 'Kayıt başarısız',
  errorUnknownSave: 'Bilinmeyen hata',
  errorPermissionDenied: 'İzin reddedildi',
  completeObjectInProgress: 'Gönderiliyor…',
  appMaterialTitle: 'Saha denetimi',
  inspectionTaskSummaryTitle: 'Tur tamamlandı',
  sectionSummaryResults: 'Güzergâh özeti',
  labelSummaryTotalObjects: 'Toplam nesne',
  labelSummaryCompletedOk: 'Sorunsuz tamamlandı',
  labelSummaryWithIssues: 'Sorunlu',
  summaryBackToTasksButton: 'Görevlere dön',
  statusCompletedWithIssues: 'Sorunlarla tamamlandı',
  taskListProgressNotStarted: 'Başlanmadı',
  taskListProgressActive: 'Devam ediyor',
  taskListProgressCompletedFull: 'Tamamlandı: %100 (tüm nesneler kontrol edildi)',
  taskListProgressCompletedFullWithIssues:
      'Tamamlandı: %100 (güzergâhta sorun var)',
  taskOpenResultButton: 'Sonucu aç',
  completedReportAppTitle: 'Tur sonucu',
  sectionCompletedReportInspectionSummary: 'Kontrol özeti',
  labelReportPhotoCount: 'Fotoğraf',
  labelReportAudioCount: 'Ses',
  labelReportObjectsWithDefects: 'Arızalı nesne',
  taskDetailSectionOutcome: 'Tur özeti',
  labelFinalTaskState: 'Son durum',
  completedReportNotAvailable: 'Tur sonucu yok',
  labelDueAt: 'Son tarih',
  tasksUntitledTask: 'Adsız görev',
  tasksScheduleNotSpecified: 'Belirtilmedi',
  tasksLoading: 'Görevler yükleniyor…',
  tasksLoadFailed: 'Görevler yüklenemedi',
  tasksShowingDemoFallback: 'Demo görevler gösteriliyor (atama yok veya ağ hatası)',
  tasksNoWorkerIdentity: 'İşçi oturumu yok. Giriş yapın veya DEV_WORKER_USER_ID ayarlayın',
  tasksSupabaseNotReady: 'Sunucu bağlantısı hazır değil',
  tasksNoAssignments: 'Atanan görev yok',
  tasksSectionDemoTasks: 'Demo görevler',
  tasksDemoSectionDebugHint:
      'Yalnızca hata ayıklama derlemesi: örnek veri, gerçek atama değil.',
  workerDevWorkerIdBadge: 'DEV_WORKER_USER_ID modu',
  workerProfileNotInDatabase: 'Veritabanında profil yok',
  workerProfileMissingAuthenticated:
      'profiles tablosunda bu kullanıcı için kayıt yok. Yönetici, Supabase Auth ile aynı id’de işçi profili oluşturmalı.',
  labelEquipmentCode: 'Ekipman kodu',
  labelAssignmentStatus: 'Atama durumu',
  sectionTaskInstructions: 'Talimatlar',
  taskDetailInstructionsEmpty:
      'Ek talimat yok. Standart tur prosedürünü uygulayın.',
  tasksRetry: 'Yenile',
  workerSectionTitle: 'İşçi',
  workerProfileNameLabel: 'Ad soyad',
  workerProfileCodeLabel: 'Sicil no',
  taskRequestScreenTitle: 'Görev talebi',
  taskRequestActionTooltip: 'Görev talep et',
  labelRequestTitle: 'Başlık',
  hintRequestTitle: 'İşi kısaca yazın',
  labelRequestSiteName: 'Tesis / saha',
  hintRequestSiteName: 'Örn. atölye, istasyon',
  labelRequestAreaName: 'Bölge',
  hintRequestAreaName: 'Örn. hat, bina',
  labelRequestDescription: 'Açıklama',
  hintRequestDescription: 'Ne kontrol veya iş yapılacak',
  labelRequestPriority: 'Öncelik',
  taskRequestSubmitButton: 'Onaya gönder',
  taskRequestSuccess: 'Talep yöneticiye gönderildi',
  taskRequestErrorNoWorker: 'İşçi oturumu yok',
  taskRequestErrorNotReady: 'Sunucu hazır değil',
  taskRequestErrorInsert: 'Talep gönderilemedi',
  taskRequestErrorNoAuthSession:
      'Talep göndermek için işçi hesabıyla (anonim değil) giriş yapın.',
  taskRequestErrorProfileMissing:
      'Profil veritabanında yok. Yöneticiye başvurun.',
  taskRequestErrorSupabaseNotConfigured:
      'Uygulama sunucuya bağlı değil. Yapılandırmayı kontrol edin.',
  taskRequestErrorRlsDenied:
      'Gönderim izni yok. Hesabınızı ve erişim kurallarını kontrol edin.',
  taskRequestErrorSchemaMismatch:
      'Sunucu şeması uygulama ile uyumsuz. Veritabanı güncellenmeli.',
  taskRequestErrorNetwork:
      'Ağ yok veya sunucu yanıt vermiyor. Sonra tekrar deneyin.',
  taskRequestErrorUnknown:
      'Talep gönderilemedi. Tekrar deneyin.',
  taskRequestValidationNeedTitle: 'Kısa özet girin',
  taskRequestValidationNeedDescription: 'Ayrıntılı açıklama girin',
  inspectionObjectEditTitle: 'Nesneyi düzenle',
  editResultBannerHint:
      'Daha önce gönderilmiş sonucu düzenliyorsunuz. Gönderdikten sonra rapor yeni bir sürüm olarak kaydedilir.',
  summaryEditResultButton: 'Sonucu düzenle',
  editResultPickObjectTitle: 'Hangi nesne düzenlensin?',
  editResultNoCachedState:
      'Düzenleme için yerel veri yok (oturum sıfırlandı veya dosyalar silindi). Turu yeniden yapın.',
  taskRequestSectionBasic: 'Temel bilgi',
  taskRequestSectionEquipment: 'Ekipman',
  taskRequestSectionProblem: 'Talep / sorun',
  labelRequestShift: 'Vardiya',
  hintRequestShift: 'Örn. vardiya A, gece',
  labelRequestIssueSummary: 'Kısa özet',
  hintRequestIssueSummary: 'Tek satır: sorun veya ihtiyaç',
  labelRequestDetailedDescription: 'Ayrıntılı açıklama',
  hintRequestDetailedDescription: 'Detaylar, yapılacak iş',
  labelRequestEquipmentName: 'Ekipman adı',
  hintRequestEquipmentName: 'Ünite, hat',
  labelRequestEquipmentLocation: 'Konum',
  hintRequestEquipmentLocation: 'Tesis, kat, bölge',
  labelRequestEquipmentCode: 'Kod / envanter no (isteğe bağlı)',
  hintRequestEquipmentCode: 'Biliniyorsa',
  labelRequestPreferredDueDate: 'İstenen tarih',
  hintRequestPreferredDueDateOptional: 'İsteğe bağlı',
  labelRequestType: 'Talep türü',
  requestTypeInspection: 'Tur / inceleme',
  requestTypeMaintenance: 'Bakım',
  requestTypeDefect: 'Kusur',
  requestTypeRepair: 'Onarım',
  taskRequestSelectDueDate: 'Tarih seç',
  taskRequestClearDueDate: 'Tarihi temizle',
  taskRequestValidationNeedIssueOrDetail:
      'Kısa özet veya ayrıntılı açıklama girin',
  taskRequestEquipmentLoading: 'Nesneler yükleniyor…',
  taskRequestEquipmentLoadFailed: 'Ekipman ağacı yüklenemedi',
  taskRequestEquipmentEmpty: 'Aktif düğüm yok. Yöneticiye başvurun.',
  taskRequestValidationNeedEquipment: 'En az bir ekipman seçin',
  taskRequestEquipmentSectionSubtitle:
      '«Nesneler» sayfasındaki gibi hiyerarşi; ihtiyaç duyduklarınızı işaretleyin.',
  taskRequestEquipmentListHeading: 'Seçilen ekipman:',
  taskRequestDescriptionMultipleLocationsNote:
      'Not: farklı sahalardan veya bölgelerden birimler seçildi; alan alanları birleştirildi.',
  labelTaskDuration: 'Gerçekleşme süresi',
  taskChatOpenAction: 'Görev sohbeti',
  taskChatSectionTitle: 'Yönetici ile iletişim',
  taskChatProfileEntryTitle: 'Görev sohbetleri',
  taskChatProfileEntrySubtitle:
      'Aktif ve arşiv görevleri, mesaj geçmişi',
  taskChatContextSubtitle: 'Bu görev hakkında',
  taskChatContextStatus: 'Görev durumu',
  taskChatMessageHint: 'Mesaj…',
  taskChatSend: 'Gönder',
  taskChatAttachImage: 'Fotoğraf',
  taskChatAttachVideo: 'Video',
  taskChatAttachFile: 'Dosya',
  taskChatAttachMenuTitle: 'Ek',
  taskChatSenderAdmin: 'Yönetici',
  taskChatSenderWorker: 'Saha çalışanı',
  taskChatYou: 'Siz',
  taskChatPickTaskTitle: 'Görev seçin',
  taskChatLoading: 'Sohbet yükleniyor…',
  taskChatEmpty: 'Henüz mesaj yok',
  taskChatNotAvailableOffline: 'Sohbet yalnızca veritabanından atanan görevler için kullanılabilir',
  taskChatAttachmentOpen: 'Aç',
  taskChatAttachmentImage: 'Görüntü',
  taskChatAttachmentVideo: 'Video',
  taskChatAttachmentPdf: 'PDF',
  taskChatAttachmentFile: 'Dosya',
  taskChatErrorMessageSendFailed: 'Mesaj gönderilemedi',
  taskChatFailedToSendFile: 'Dosya gönderilemedi',
  taskChatErrorUploadFailed: 'Dosya yüklenemedi',
  taskChatErrorStorageUnavailable: 'Dosya depolaması kullanılamıyor',
  taskChatErrorUnavailable: 'Sohbet şu anda kullanılamıyor',
  taskChatErrorNoAuthSession: 'Oturum yok. Lütfen giriş yapın.',
  taskChatErrorNoTaskSelected: 'Görev seçilmedi',
  taskChatErrorNoActiveTasks: 'Sohbet için aktif görev yok',
  taskChatErrorUnsupportedFile: 'Desteklenmeyen dosya türü',
  taskChatErrorFileTooLarge: 'Dosya çok büyük',
  taskChatPickerSectionActive: 'Güncel görevler',
  taskChatPickerSectionArchive: 'Arşiv ve geçmiş',
  taskChatBadgeArchived: 'Arşiv',
  taskChatBadgeHasHistory: 'Yazışma var',
  taskChatNoTasksForChat: 'Sohbet için görev yok',
  taskChatUnableToLoad: 'Sohbet yüklenemedi',
  taskChatThreadNotFound: 'Sohbet kullanılamıyor',
  taskChatReadOnlyClosedTask:
      'Görev tamamlandı — yalnızca geçmişi okuyabilirsiniz.',
  taskChatLoadingConversationHint: 'Yazışma yükleniyor…',
  taskChatEmptySubtitle: 'Bu görev hakkında yazışmaya başlayın',
  taskChatPhotoFromGallery: 'Galeriden fotoğraf',
  taskChatTakePhoto: 'Fotoğraf çek',
  taskChatAttachPdfDocument: 'PDF belgesi',
  taskChatChooseAttachment: 'Ek seçin',
  taskChatPhotoPreviewTitle: 'Fotoğraf gönder',
  taskChatAttachmentCaptionHint: 'İsteğe bağlı açıklama',
  taskChatMediaSending: 'Gönderiliyor…',
  taskChatErrorProfileRequired:
      'Sohbet için işçi profili gerekir. Yöneticinize başvurun.',
  taskChatErrorTimeout:
      'Zaman aşımı. Ağı kontrol edip tekrar deneyin.',
  taskChatErrorConnection:
      'Bağlantı sorunu. Daha sonra tekrar deneyin.',
  taskChatPermissionDenied:
      'İzin yok. Ayarlardan erişime izin verin.',
  taskChatErrorAnonymousSession:
      'Sohbete yazmak için anonim değil, işçi hesabıyla giriş yapın.',
  taskChatErrorCreateThreadFailed:
      'Görev sohbeti oluşturulamadı. Atamayı, ağı ve erişim kurallarını kontrol edin.',
  taskChatErrorDatabaseInsertFailed:
      'Mesaj kaydedilemedi: sunucu veya şema hatası. İşçi profilini ve RLS kurallarını kontrol edin.',
  taskChatErrorRlsInsertDenied:
      'Güvenlik politikası (RLS) mesaj eklemeyi reddetti: bu görev veya sohbet için izin yok.',
  taskChatErrorServerSchemaMismatch:
      'Mesaj kaydedilemedi: veritabanında task_chat_messages tablosunda body sütunu yok (PGRST204). Supabase → SQL Editor’de sırayla çalıştırın: 20260422150000_task_chat_messages_ensure_body_column.sql ve gerekirse 20260422103000_task_chat_ensure_trigger_and_access.sql. Web paneli aynı tabloda body alanını okuyup yazmalı; fotoğraf/PDF için task_chat_attachments + depolama kullanılır.',
  redAlertRequestEmergencyTitle: 'Kritik olay',
  redAlertRequestEmergencyBody:
      'Yönetici paneline acil bildirim: makine durdu, tehlikeli arıza, acil kontrol veya bakım.',
  redAlertRequestOpenButton: 'Kırmızı alarm',
  redAlertScreenTitle: 'Kırmızı alarm',
  redAlertLoadingCatalog: 'Ekipman listesi yükleniyor…',
  redAlertCatalogEmpty:
      'Seçilebilir ekipman yok. Atamaları veya dizini kontrol edin.',
  redAlertIntroTitle: 'Yalnızca acil durumlar için',
  redAlertIntroBody:
      'Makine durması, tehlikeli arıza, acil denetim veya derhal bakım gerektiğinde kullanın.',
  redAlertSelectMachine: 'Ekipman seçin',
  redAlertMachineHint: 'Seçmek için dokunun',
  redAlertMachineSearchHint: 'Ad veya göreve göre ara',
  redAlertNoMachinesFound: 'Sonuç yok',
  redAlertPrefillHint:
      'Ekipman mevcut göreve göre seçildi; gerekirse değiştirebilirsiniz.',
  redAlertShortReasonLabel: 'Kısa neden',
  redAlertShortReasonHint: 'Örn. pompa durdu, basınçlı kaçak',
  redAlertDescriptionLabel: 'Açıklama',
  redAlertDescriptionHint: 'Ne oldu, riskler, sahadaki gözlem',
  redAlertSendButton: 'Kritik alarm gönder',
  redAlertConfirmTitle: 'Gönderimi onayla',
  redAlertConfirmBody:
      'Kritik alarm yönetici paneline hemen iletilecek. Devam edilsin mi?',
  redAlertCancel: 'İptal',
  redAlertConfirmSend: 'Gönder',
  redAlertSuccessTitle: 'Alarm gönderildi',
  redAlertSuccessBody: 'Kritik alarm yönetici paneline iletildi.',
  redAlertSuccessDone: 'Tamam',
  redAlertErrorNoAuth:
      'Alarm göndermek için işçi hesabıyla giriş yapın.',
  redAlertErrorNotReady: 'Sunucu hazır değil. Sonra deneyin.',
  redAlertErrorProfileMissing:
      'İşçi profili bulunamadı. Yöneticiye başvurun.',
  redAlertErrorInvalidMachine: 'Ekipman verisi geçersiz.',
  redAlertErrorShortReason: 'Kısa nedeni yazın.',
  redAlertErrorRlsDenied:
      'Gönderim izni yok. Hesap ve erişim kurallarını kontrol edin.',
  redAlertErrorSchemaMismatch:
      'Uyarı tablosu yok veya şema uyumsuz. Veritabanını güncelleyin.',
  redAlertErrorSendFailed: 'Alarm gönderilemedi.',
  redAlertChooseMachineFirst: 'Önce ekipman seçin.',
  redAlertCatalogTaskRoute: 'Görev güzergâhından',
  redAlertCatalogEquipmentDirectory: 'Ekipman dizininden',
  redAlertTaskDetailCta: 'Kırmızı alarm',
  qrScanActionTooltip: 'QR tara',
  qrScanScreenTitle: 'QR tarayıcı',
  qrScanInstruction: 'Kamerayı QR koda doğrultun',
  qrScanRecognized: 'QR tanındı',
  qrScanScannedValueLabel: 'Okunan değer',
  qrScanPhase2Message:
      'QR ile görev ve ekipman eşlemesi bir sonraki aşamada bağlanacak.',
  qrScanAgain: 'Yeniden tara',
  qrScanClose: 'Kapat',
  qrScanBackTooltip: 'Geri',
  qrScanPermissionTitle: 'Kamera izni gerekli',
  qrScanPermissionBody:
      'QR kodları taramak için ayarlardan kamera erişimine izin verin.',
  qrScanOpenSettings: 'Ayarları aç',
  qrScanRetry: 'Yeniden dene',
  qrScanStartFailed: 'Kamera başlatılamadı',
  qrScanUnavailable: 'Bu cihazda tarama kullanılamıyor',
  qrScanGenericErrorHint:
      'İzinleri kontrol edip tekrar deneyin. Simülatörde kamera olmayabilir.',
);

const AppStrings _en = AppStrings(
  language: AppLanguage.en,
  loginTitle: 'Mobile field inspector',
  loginSubtitle: 'Equipment control and rounds',
  loginDescription:
      'Sign in with the worker email and password your admin created in Supabase. Assigned tasks load from the database.',
  loginDevPathWithoutSession:
      'No Supabase session: the button below is a development path (e.g. DEV_WORKER_USER_ID). Production use requires worker sign-in.',
  loginContinueToTasks: 'Continue to tasks',
  authLabelEmail: 'Email',
  authLabelPassword: 'Password',
  authHintEmail: 'worker@company.com',
  authHintPassword: '••••••••',
  authSignInButton: 'Sign in',
  authSignOutButton: 'Sign out',
  authSignInFailed: 'Sign-in failed. Check email and password.',
  authAnonymousNotWorkerWarning:
      'You are signed in anonymously — not as a worker account. Sign out and sign in with the email and password your admin created.',
  authFillEmailPassword: 'Enter email and password',
  loginDevBypassButton: 'Debug: continue with DEV_WORKER_USER_ID',
  tasksAppBarSignOut: 'Sign out',
  authLoadingWorkerProfile: 'Loading worker profile…',
  workerProfileRequiredTitle: 'Profile not found',
  workerProfileRequiredMessage:
      'There is no profiles row for this account. An admin must create a profile with the same id as in Supabase Auth. Sign out and try again after it is fixed.',
  tasksAppTitle: 'Tasks',
  navTabTasks: 'Tasks',
  navTabRequest: 'Request',
  navTabProfile: 'Profile',
  navTabArchive: 'Archive',
  archiveAppBarTitle: 'Archive',
  archiveSectionHeader: 'Archived tasks',
  archiveEmptyTitle: 'No archived tasks',
  archiveEmptySubtitle:
      'Completed rounds will appear here after you finish them.',
  archiveLabelCompletedOn: 'Completed on',
  archiveLabelFinalStatus: 'Final status',
  archiveLabelDuration: 'Duration',
  archiveOpenResultHint: 'Open report',
  archiveOpenReviewHint: 'Review',
  archiveReviewNoLocalSnapshot:
      'A detailed report is not stored on this device. Task and route details are still available.',
  tasksAllCompletedSeeArchive:
      'All assigned tasks are finished. Open the Archive tab to review them.',
  profileScreenTitle: 'Profile',
  tasksSectionAssignedRounds: 'Assigned tasks',
  statusInProgress: 'In progress',
  statusPending: 'Pending',
  statusCompleted: 'Completed',
  taskDetailAppTitle: 'Task details',
  labelObject: 'Site / location',
  labelStatus: 'Status',
  labelShift: 'Shift',
  sectionInspectionRoute: 'Inspection route',
  startRoundButton: 'Start round',
  inspectionExecutionAppTitle: 'Round in progress',
  labelTask: 'Task',
  labelProgress: 'Progress',
  sectionInspectionObjects: 'Round objects',
  openCurrentObjectButton: 'Open current object',
  snackbarObjectInspectionNext:
      'Object inspection screen will be added in the next step',
  badgeCurrent: 'Current',
  badgePending: 'Pending',
  languageMenuLabel: 'Language',
  langNameRu: 'Русский',
  langNameTr: 'Türkçe',
  langNameEn: 'English',
  mockShift0: 'Shift A, 16 Apr 2026',
  mockShift1: 'Shift B, 16 Apr 2026',
  mockShift2: 'Shift A, 15 Apr 2026',
  mockTask0Title: 'Boiler house round No. 1',
  mockTask0Area: 'Boiler house, zone A',
  mockTask1Title: 'Scheduled transformer inspection',
  mockTask1Area: 'SS-12',
  mockTask2Title: 'Pumping station round',
  mockTask2Area: 'Pump station — building 2',
  r0i0n: 'Pump N-12',
  r0i0s: 'Boiler house, feed line',
  r0i1n: 'Valve K-3',
  r0i1s: 'Zone A, regulating node',
  r0i2n: 'Temperature sensor T-7',
  r0i2s: 'Hot water manifold',
  r0i3n: 'Control panel CP-2',
  r0i3s: 'Automation room',
  r1i0n: 'Power transformer T-1',
  r1i0s: 'SS-12, bay 1',
  r1i1n: 'Disconnector R-5',
  r1i1s: 'Incoming bay',
  r1i2n: 'Temperature sensor T-7',
  r1i2s: 'Bus section',
  r1i3n: 'Control panel CP-2',
  r1i3s: 'Operator desk',
  r1i4n: 'Valve K-3',
  r1i4s: 'Fire segment',
  r2i0n: 'Pump N-12',
  r2i0s: 'Pump station, unit 1',
  r2i1n: 'Valve K-3',
  r2i1s: 'Pressure piping',
  r2i2n: 'Temperature sensor T-7',
  r2i2s: 'Tank, immersion sensor',
  r2i3n: 'Control panel CP-2',
  r2i3s: 'Building 2, switchgear room',
  inspectionObjectAppTitle: 'Object inspection',
  inspectionRouteItemUnavailable:
      'This route item is unavailable. Return to the route and open the object again.',
  labelZone: 'Zone',
  sectionChecklist: 'Checklist',
  checklistItemVisualOk: 'Visual condition is normal',
  checklistItemNoLeaks: 'No leaks detected',
  checklistItemNoNoise: 'No unusual noise',
  checklistItemAccessClear: 'Access area is clear',
  sectionNote: 'Note',
  noteHint: 'Add a note',
  saveLocallyButton: 'Save locally',
  completeObjectButton: 'Complete object',
  inspectionSendButton: 'Send',
  inspectionSendingLabel: 'Sending…',
  inspectionOfflineQueuedTitle: 'No internet. Saved locally',
  inspectionOfflineQueuedSubtitle: 'Will send automatically when online',
  routeBadgeAwaitingSync: 'Awaiting sync',
  snackbarLocalSaveSuccess: 'Data saved locally',
  sectionMeasurements: 'Measurements',
  labelMeasurementTemperature: 'Temperature',
  labelMeasurementPressure: 'Pressure',
  labelMeasurementVibration: 'Vibration',
  hintMeasurementValue: 'Enter value',
  unitCelsius: '°C',
  unitPressureBar: 'bar',
  unitVibrationMmS: 'mm/s',
  sectionDefect: 'Defect',
  defectToggleLabel: 'Defect found',
  labelDefectDescription: 'Description',
  hintDefectDescription: 'Describe the issue',
  labelDefectPriority: 'Priority',
  priorityLow: 'Low',
  priorityMedium: 'Medium',
  priorityHigh: 'High',
  routeStatusHasIssue: 'Has issue',
  sectionPhotoEvidence: 'Photo evidence',
  addPhotoButton: 'Add photo',
  photoItemSubtitleLocal: 'Local attachment',
  removePhotoButton: 'Remove',
  snackbarPhotoLimitReached: 'You can add up to 3 photos',
  photoPreviewClose: 'Close',
  photoPreviewDemoCaption: 'Local attachment preview',
  voiceNoteSectionTitle: 'Voice note',
  voiceStartRecording: 'Start recording',
  voiceStopRecording: 'Stop',
  voiceDeleteRecording: 'Delete recording',
  voiceStateRecording: 'Recording…',
  voiceStateRecorded: 'Recording ready',
  snackbarPhotoPickerCancelled: 'Photo selection cancelled',
  snackbarPhotoPickerFailed: 'Could not pick photo',
  snackbarMicrophoneDenied: 'Microphone permission denied',
  snackbarVoiceNoteAdded: 'Voice note added',
  snackbarUploadFailed: 'Could not save report',
  snackbarUploadSuccess: 'Report saved successfully',
  errorSupabaseNotConfigured: 'Supabase is not configured',
  errorAuthAnonymousFailed:
      'Anonymous sign-in failed (enable Anonymous in Supabase Auth)',
  errorMissingTaskId: 'Task id is missing',
  errorMissingEquipmentId: 'Equipment id is missing',
  errorReportInsertFailed:
      'Report row insert failed (inspection_reports). Check logs.',
  errorReportReturningEmpty:
      'Server returned no report row. Add a SELECT policy on inspection_reports (RLS).',
  errorReportForeignKey:
      'Task or equipment id is missing on the server (check FK / seed data)',
  errorReportRlsBlocked:
      'Write blocked by security policy (check Supabase RLS)',
  errorMediaInsertFailed:
      'Media row insert failed (inspection_media). Check logs.',
  errorMediaMetadataAfterReportOk:
      'Report saved, but media metadata could not be saved.',
  errorPhotoUploadFailed: 'Photo upload failed',
  errorAudioUploadFailed: 'Audio upload failed',
  errorDatabaseSaveFailed: 'Database save failed',
  errorRecordingNotFound: 'Recording file not found',
  errorSaveFailed: 'Save failed',
  errorUnknownSave: 'Unknown error',
  errorPermissionDenied: 'Permission denied',
  completeObjectInProgress: 'Submitting…',
  appMaterialTitle: 'Field inspection',
  inspectionTaskSummaryTitle: 'Round completed',
  sectionSummaryResults: 'Route results',
  labelSummaryTotalObjects: 'Total objects',
  labelSummaryCompletedOk: 'Completed (OK)',
  labelSummaryWithIssues: 'With issues',
  summaryBackToTasksButton: 'Back to tasks',
  statusCompletedWithIssues: 'Completed with issues',
  taskListProgressNotStarted: 'Not started',
  taskListProgressActive: 'In progress',
  taskListProgressCompletedFull: 'Completed: 100% (all objects checked)',
  taskListProgressCompletedFullWithIssues:
      'Completed: 100% (issues on the route)',
  taskOpenResultButton: 'Open result',
  completedReportAppTitle: 'Round result',
  sectionCompletedReportInspectionSummary: 'Inspection summary',
  labelReportPhotoCount: 'Photos',
  labelReportAudioCount: 'Audio',
  labelReportObjectsWithDefects: 'Objects with defect',
  taskDetailSectionOutcome: 'Round outcome',
  labelFinalTaskState: 'Final status',
  completedReportNotAvailable: 'Round result is not available',
  labelDueAt: 'Due',
  tasksUntitledTask: 'Untitled task',
  tasksScheduleNotSpecified: 'Not specified',
  tasksLoading: 'Loading tasks…',
  tasksLoadFailed: 'Could not load tasks',
  tasksShowingDemoFallback: 'Showing demo tasks (no assignments or load error)',
  tasksNoWorkerIdentity: 'No worker session. Sign in or set DEV_WORKER_USER_ID',
  tasksSupabaseNotReady: 'Server connection not ready',
  tasksNoAssignments: 'No assigned tasks',
  tasksSectionDemoTasks: 'Demo tasks',
  tasksDemoSectionDebugHint:
      'Debug build only: sample data, not real assignments.',
  workerDevWorkerIdBadge: 'DEV_WORKER_USER_ID mode',
  workerProfileNotInDatabase: 'No profile row in database',
  workerProfileMissingAuthenticated:
      'There is no profiles row for this account. An admin must create a worker profile with the same id as in Supabase Auth.',
  labelEquipmentCode: 'Equipment code',
  labelAssignmentStatus: 'Assignment status',
  sectionTaskInstructions: 'Instructions',
  taskDetailInstructionsEmpty:
      'No additional instructions. Follow the standard round procedure.',
  tasksRetry: 'Retry',
  workerSectionTitle: 'Worker',
  workerProfileNameLabel: 'Name',
  workerProfileCodeLabel: 'Employee ID',
  taskRequestScreenTitle: 'Task request',
  taskRequestActionTooltip: 'Request a task',
  labelRequestTitle: 'Title',
  hintRequestTitle: 'Short summary of the work',
  labelRequestSiteName: 'Site',
  hintRequestSiteName: 'e.g. shop, station',
  labelRequestAreaName: 'Area',
  hintRequestAreaName: 'e.g. line, building',
  labelRequestDescription: 'Description',
  hintRequestDescription: 'What to inspect or do',
  labelRequestPriority: 'Priority',
  taskRequestSubmitButton: 'Submit for approval',
  taskRequestSuccess: 'Request sent to supervisor',
  taskRequestErrorNoWorker: 'No worker session',
  taskRequestErrorNotReady: 'Server not ready',
  taskRequestErrorInsert: 'Could not submit request',
  taskRequestErrorNoAuthSession:
      'Sign in with a worker account (not anonymous) to submit a request.',
  taskRequestErrorProfileMissing:
      'No profile in the database. Contact an administrator.',
  taskRequestErrorSupabaseNotConfigured:
      'App is not connected to the server. Check configuration.',
  taskRequestErrorRlsDenied:
      'You do not have permission to submit. Check your account and access policies.',
  taskRequestErrorSchemaMismatch:
      'Server schema does not match the app. Database migrations may be required.',
  taskRequestErrorNetwork:
      'No network or the server did not respond. Try again later.',
  taskRequestErrorUnknown:
      'Could not submit the request. Please try again.',
  taskRequestValidationNeedTitle: 'Enter a short summary',
  taskRequestValidationNeedDescription: 'Enter a detailed description',
  inspectionObjectEditTitle: 'Edit inspection',
  editResultBannerHint:
      'You are editing a previously submitted result. Sending saves a new report version.',
  summaryEditResultButton: 'Edit result',
  editResultPickObjectTitle: 'Which object should be edited?',
  editResultNoCachedState:
      'No saved edit state (session reset or files removed). Complete the route again.',
  taskRequestSectionBasic: 'Basics',
  taskRequestSectionEquipment: 'Equipment',
  taskRequestSectionProblem: 'Request / issue',
  labelRequestShift: 'Shift',
  hintRequestShift: 'e.g. Shift A, night',
  labelRequestIssueSummary: 'Short summary',
  hintRequestIssueSummary: 'One line: what is wrong or needed',
  labelRequestDetailedDescription: 'Detailed description',
  hintRequestDetailedDescription: 'Context and required work',
  labelRequestEquipmentName: 'Equipment name',
  hintRequestEquipmentName: 'Unit, skid, line',
  labelRequestEquipmentLocation: 'Location',
  hintRequestEquipmentLocation: 'Building, floor, zone',
  labelRequestEquipmentCode: 'Code / tag (optional)',
  hintRequestEquipmentCode: 'If known',
  labelRequestPreferredDueDate: 'Preferred date',
  hintRequestPreferredDueDateOptional: 'Optional',
  labelRequestType: 'Request type',
  requestTypeInspection: 'Inspection round',
  requestTypeMaintenance: 'Maintenance',
  requestTypeDefect: 'Defect',
  requestTypeRepair: 'Repair',
  taskRequestSelectDueDate: 'Pick date',
  taskRequestClearDueDate: 'Clear date',
  taskRequestValidationNeedIssueOrDetail:
      'Enter a short summary or detailed description',
  taskRequestEquipmentLoading: 'Loading objects…',
  taskRequestEquipmentLoadFailed: 'Could not load equipment tree',
  taskRequestEquipmentEmpty: 'No active nodes. Contact an administrator.',
  taskRequestValidationNeedEquipment: 'Select at least one equipment item',
  taskRequestEquipmentSectionSubtitle:
      'Same hierarchy as «Objects» on the web: check the units you need.',
  taskRequestEquipmentListHeading: 'Selected equipment:',
  taskRequestDescriptionMultipleLocationsNote:
      'Note: items span multiple sites or areas; site/area fields list a combined value.',
  labelTaskDuration: 'Time to complete',
  taskChatOpenAction: 'Task chat',
  taskChatSectionTitle: 'Contact administrator',
  taskChatProfileEntryTitle: 'Task chats',
  taskChatProfileEntrySubtitle:
      'Active and archived tasks, message history',
  taskChatContextSubtitle: 'Discussion for this task',
  taskChatContextStatus: 'Task status',
  taskChatMessageHint: 'Message…',
  taskChatSend: 'Send',
  taskChatAttachImage: 'Photo',
  taskChatAttachVideo: 'Video',
  taskChatAttachFile: 'File',
  taskChatAttachMenuTitle: 'Attachment',
  taskChatSenderAdmin: 'Administrator',
  taskChatSenderWorker: 'Field worker',
  taskChatYou: 'You',
  taskChatPickTaskTitle: 'Choose a task',
  taskChatLoading: 'Loading chat…',
  taskChatEmpty: 'No messages yet',
  taskChatNotAvailableOffline: 'Chat is only available for database-assigned tasks',
  taskChatAttachmentOpen: 'Open',
  taskChatAttachmentImage: 'Image',
  taskChatAttachmentVideo: 'Video',
  taskChatAttachmentPdf: 'PDF',
  taskChatAttachmentFile: 'File',
  taskChatErrorMessageSendFailed: 'Could not send message',
  taskChatFailedToSendFile: 'Failed to send file',
  taskChatErrorUploadFailed: 'Could not upload file',
  taskChatErrorStorageUnavailable: 'File storage is unavailable',
  taskChatErrorUnavailable: 'Chat is unavailable',
  taskChatErrorNoAuthSession: 'No session. Please sign in.',
  taskChatErrorNoTaskSelected: 'No task selected',
  taskChatErrorNoActiveTasks: 'No active tasks for chat',
  taskChatErrorUnsupportedFile: 'Unsupported file type',
  taskChatErrorFileTooLarge: 'File is too large',
  taskChatPickerSectionActive: 'Active tasks',
  taskChatPickerSectionArchive: 'Archive & history',
  taskChatBadgeArchived: 'Archived',
  taskChatBadgeHasHistory: 'Chat history',
  taskChatNoTasksForChat: 'No tasks for chat',
  taskChatUnableToLoad: 'Could not load chat',
  taskChatThreadNotFound: 'Conversation unavailable',
  taskChatReadOnlyClosedTask:
      'Task is completed — you can only read this chat.',
  taskChatLoadingConversationHint: 'Loading conversation…',
  taskChatEmptySubtitle: 'Start the conversation about this task',
  taskChatPhotoFromGallery: 'Photo from gallery',
  taskChatTakePhoto: 'Take photo',
  taskChatAttachPdfDocument: 'PDF document',
  taskChatChooseAttachment: 'Choose attachment',
  taskChatPhotoPreviewTitle: 'Send photo',
  taskChatAttachmentCaptionHint: 'Add a caption (optional)',
  taskChatMediaSending: 'Sending…',
  taskChatErrorProfileRequired:
      'Worker profile is required for chat. Contact your administrator.',
  taskChatErrorTimeout:
      'Request timed out. Check your network and try again.',
  taskChatErrorConnection:
      'Connection problem. Try again later.',
  taskChatPermissionDenied:
      'Permission denied. Allow access in settings.',
  taskChatErrorAnonymousSession:
      'Sign in with a worker account (not anonymous) to use chat.',
  taskChatErrorCreateThreadFailed:
      'Could not create the task conversation. Check assignment, network, and access policies.',
  taskChatErrorDatabaseInsertFailed:
      'Message was not saved: server or schema error. Check your worker profile and RLS policies.',
  taskChatErrorRlsInsertDenied:
      'Security policy (RLS) blocked sending: no insert permission for this task or chat thread.',
  taskChatErrorServerSchemaMismatch:
      'Message was not saved: task_chat_messages is missing the body column (PGRST204) or the schema cache is stale. In Supabase → SQL Editor run: 20260422150000_task_chat_messages_ensure_body_column.sql, then if needed 20260422103000_task_chat_ensure_trigger_and_access.sql. The admin web app must read/write the same body column; files use task_chat_attachments + storage.',
  redAlertRequestEmergencyTitle: 'Critical incident',
  redAlertRequestEmergencyBody:
      'Urgent notice to the admin panel: machine down, dangerous fault, urgent inspection, or immediate maintenance.',
  redAlertRequestOpenButton: 'Red alert',
  redAlertScreenTitle: 'Red alert',
  redAlertLoadingCatalog: 'Loading equipment…',
  redAlertCatalogEmpty:
      'No equipment available. Check assignments or the equipment directory.',
  redAlertIntroTitle: 'For emergencies only',
  redAlertIntroBody:
      'Use for critical cases: machine stopped, dangerous malfunction, urgent inspection, or immediate maintenance.',
  redAlertSelectMachine: 'Select equipment',
  redAlertMachineHint: 'Tap to choose',
  redAlertMachineSearchHint: 'Search by name or task',
  redAlertNoMachinesFound: 'No matches',
  redAlertPrefillHint:
      'Equipment was prefilled from the current task; change it if needed.',
  redAlertShortReasonLabel: 'Short reason',
  redAlertShortReasonHint: 'e.g. pump tripped, pressurized leak',
  redAlertDescriptionLabel: 'Description',
  redAlertDescriptionHint: 'What happened, risks, what you see on site',
  redAlertSendButton: 'Send critical alert',
  redAlertConfirmTitle: 'Confirm send',
  redAlertConfirmBody:
      'A critical alert will be sent to the admin panel immediately. Continue?',
  redAlertCancel: 'Cancel',
  redAlertConfirmSend: 'Send',
  redAlertSuccessTitle: 'Alert sent',
  redAlertSuccessBody: 'Critical alert sent to the admin panel.',
  redAlertSuccessDone: 'Done',
  redAlertErrorNoAuth: 'Sign in with a worker account to send an alert.',
  redAlertErrorNotReady: 'Server not ready. Try again later.',
  redAlertErrorProfileMissing:
      'Worker profile not found. Contact an administrator.',
  redAlertErrorInvalidMachine: 'Invalid equipment data.',
  redAlertErrorShortReason: 'Enter a short reason.',
  redAlertErrorRlsDenied:
      'No permission to send. Check your account and access policies.',
  redAlertErrorSchemaMismatch:
      'Alerts table missing or schema mismatch. Update the database.',
  redAlertErrorSendFailed: 'Could not send the alert.',
  redAlertChooseMachineFirst: 'Choose equipment first.',
  redAlertCatalogTaskRoute: 'From task route',
  redAlertCatalogEquipmentDirectory: 'Equipment directory',
  redAlertTaskDetailCta: 'Red alert',
  qrScanActionTooltip: 'Scan QR',
  qrScanScreenTitle: 'QR scanner',
  qrScanInstruction: 'Point the camera at the QR code',
  qrScanRecognized: 'QR recognized',
  qrScanScannedValueLabel: 'Scanned value',
  qrScanPhase2Message:
      'Machine and task linking from QR will be connected in the next stage.',
  qrScanAgain: 'Scan again',
  qrScanClose: 'Close',
  qrScanBackTooltip: 'Back',
  qrScanPermissionTitle: 'Camera permission needed',
  qrScanPermissionBody:
      'Allow camera access in your device settings to scan QR codes.',
  qrScanOpenSettings: 'Open settings',
  qrScanRetry: 'Try again',
  qrScanStartFailed: 'Failed to start camera',
  qrScanUnavailable: 'Scanning is not available on this device',
  qrScanGenericErrorHint:
      'Check permissions and try again. Simulators may have no camera.',
);

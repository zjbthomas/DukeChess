// Fill out your copyright notice in the Description page of Project Settings.


#include "GUIPlayerController.h"

#include "Kismet/GameplayStatics.h"

#include "GlobalGameInstance.h"
#include "GUIGameModeBase.h"

#include "LoadingUserWidget.h"

void AGUIPlayerController::BeginPlay()
{
	Super::BeginPlay();

	// Always show cursor
	bShowMouseCursor = true;
	SetInputMode(FInputModeUIOnly{});

	AGUIGameModeBase* GM = GetWorld()->GetAuthGameMode<AGUIGameModeBase>();
	if (!GM) return;

	switch (GM->UILevelKind) {
	case EUILevelKind::InitLoad:
		break;
	case EUILevelKind::ModeLoad:
		ModeLoadGameResources();

		UGameplayStatics::OpenLevel(this, FName(TEXT("MainMap")));
		break;
	default:
		break;
	}
}

void AGUIPlayerController::RegisterLoadingUserWidget(ULoadingUserWidget* InWidget)
{
	LoadingUserWidget = InWidget;
}

void AGUIPlayerController::ModeLoadGameResources() {
	UGlobalGameInstance* Global = Cast<UGlobalGameInstance>(GetGameInstance());
	if (!Global) {
		UE_LOG(LogTemp, Error, TEXT("GlobalGameInstance cast failed!"));
		return;
	}

	LoadingUserWidget->SetProgress(100);

	UE_LOG(LogTemp, Warning, TEXT("ModeLoadGameResources!"));
}
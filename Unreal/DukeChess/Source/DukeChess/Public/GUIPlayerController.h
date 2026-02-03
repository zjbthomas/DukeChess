// Fill out your copyright notice in the Description page of Project Settings.

#pragma once

#include "CoreMinimal.h"
#include "GameFramework/PlayerController.h"
#include "GUIPlayerController.generated.h"

class ULoadingUserWidget;
class UGlobalGameInstance;

/**
 * 
 */
UCLASS()
class DUKECHESS_API AGUIPlayerController : public APlayerController
{
	GENERATED_BODY()

protected:
	// Called when the game starts or when spawned
	virtual void BeginPlay() override;

public:
	void RegisterLoadingUserWidget(ULoadingUserWidget* InWidget);

private:
	UPROPERTY()
	ULoadingUserWidget* LoadingUserWidget = nullptr;

	UGlobalGameInstance* Global;

	bool bModeLoadOK = true;

	void ModeLoadGameResources();
};

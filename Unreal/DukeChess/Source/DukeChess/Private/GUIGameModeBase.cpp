// Fill out your copyright notice in the Description page of Project Settings.


#include "GUIGameModeBase.h"

#include "GUIPlayerController.h"

AGUIGameModeBase::AGUIGameModeBase()
{
	// No pawn at all
	DefaultPawnClass = nullptr;

	// Use your GUI-only PlayerController
	PlayerControllerClass = AGUIPlayerController::StaticClass();

	// Optional but recommended for UI-only maps
	HUDClass = nullptr;
	SpectatorClass = nullptr;
}

void AGUIGameModeBase::RestartPlayer(AController* NewPlayer)
{
	// Intentionally do nothing: UI-only level
	// This prevents FindPlayerStart + SpawnDefaultPawn attempts.
}
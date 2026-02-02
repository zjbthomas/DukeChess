// Fill out your copyright notice in the Description page of Project Settings.


#include "MainPlayerController.h"

#include "Kismet/GameplayStatics.h"

#include "BoardActor.h"

void AMainPlayerController::BeginPlay()
{
    Super::BeginPlay();

    bShowMouseCursor = true;
    bEnableClickEvents = true;
    bEnableMouseOverEvents = true;

    FInputModeGameAndUI Mode;
    Mode.SetHideCursorDuringCapture(false);
    SetInputMode(Mode);

    FindBoard();

    if (Board)
    {
        TargetPitch = Board->GetBoardPitchDegrees();
    }
}

void AMainPlayerController::PlayerTick(float DeltaTime)
{
    Super::PlayerTick(DeltaTime);

    if (!Board) return;

    const float Current = Board->GetBoardPitchDegrees();
    const float Smoothed = FMath::FInterpTo(Current, TargetPitch, DeltaTime, PitchInterpSpeed);

    Board->SetBoardPitchDegrees(Smoothed);
}

void AMainPlayerController::SetupInputComponent()
{
    Super::SetupInputComponent();

    // Actions (bind in Project Settings -> Input)
    InputComponent->BindAction("BoardRotateHold", IE_Pressed, this, &AMainPlayerController::OnRMBPressed);
    InputComponent->BindAction("BoardRotateHold", IE_Released, this, &AMainPlayerController::OnRMBReleased);
    InputComponent->BindAction("BoardResetPitch", IE_Pressed, this, &AMainPlayerController::OnMMBPressed);

    // Axis (mouse Y)
    InputComponent->BindAxis("MouseY", this, &AMainPlayerController::OnMouseY);
}

void AMainPlayerController::FindBoard()
{
    // Assumes exactly one board manager in the level
    AActor* Found = UGameplayStatics::GetActorOfClass(GetWorld(), ABoardActor::StaticClass());
    Board = Cast<ABoardActor>(Found);
}

void AMainPlayerController::OnRMBPressed()
{
    bRotatingBoard = true;
}

void AMainPlayerController::OnRMBReleased()
{
    bRotatingBoard = false;
}

void AMainPlayerController::OnMMBPressed()
{
    TargetPitch = 0.0f; // smoothing will move it back
}

void AMainPlayerController::OnMouseY(float Value)
{
    if (!bRotatingBoard || FMath::IsNearlyZero(Value) || !Board)
        return;

    // Update target
    TargetPitch = FMath::Clamp(TargetPitch - Value * PitchSpeed, -45.0f, 0.0f);
}
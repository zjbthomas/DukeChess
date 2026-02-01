// Fill out your copyright notice in the Description page of Project Settings.


#include "BoardActor.h"

// Sets default values
ABoardActor::ABoardActor()
{
 	// Set this actor to call Tick() every frame.  You can turn this off to improve performance if you don't need it.
	PrimaryActorTick.bCanEverTick = true;

	Root = CreateDefaultSubobject<USceneComponent>(TEXT("Root"));
	RootComponent = Root;
}

// Called when the game starts or when spawned
void ABoardActor::BeginPlay()
{
	Super::BeginPlay();

	InitBoard();
}

// Called every frame
void ABoardActor::Tick(float DeltaTime)
{
	Super::Tick(DeltaTime);

}

void ABoardActor::SetBoardPitchDegrees(float PitchDeg)
{
	PitchDeg = FMath::Clamp(PitchDeg, -45.0f, 0.0f); // TODO: magic number

	FRotator R = GetActorRotation();
	R.Pitch = PitchDeg;
	SetActorRotation(R);
}

float ABoardActor::GetBoardPitchDegrees() const
{
	return GetActorRotation().Pitch;
}

void ABoardActor::InitBoard() {
	UGlobalGameInstance* Global = Cast<UGlobalGameInstance>(GetGameInstance());
	if (!Global) {
		UE_LOG(LogTemp, Error, TEXT("GlobalGameInstance cast failed!"));
		return;
	}

	for (int32 ir = 0; ir < Global->MAXR; ir++) {
		for (int32 ic = 0; ic < Global->MAXC; ic++) {
			float X = ir * TileSize - (Global->MAXR - 1) * TileSize * 0.5f;
			float Y = ic * TileSize - (Global->MAXC - 1) * TileSize * 0.5f;

			const FVector LocalOffset(X, Y, 0.f);

			FVector SpawnLoc = GetActorLocation() + FVector(X, Y, 0.f);

			AChessTileActor* ChessTile = GetWorld()->SpawnActor<AChessTileActor>(ChessTileActorClass, GetActorLocation(), GetActorRotation());

			if (!ChessTile) continue;

			ChessTile->AttachToComponent(RootComponent, FAttachmentTransformRules::KeepWorldTransform);
			ChessTile->SetActorRelativeLocation(LocalOffset);

			ChessTile->SetRC(ir, ic);

			ChessTile->UpdateMaterial();

			ChessTile->OnTileClicked.AddDynamic(this, &ABoardActor::HandleTileClicked);
		}
	}
}

void ABoardActor::HandleTileClicked(int32 Row, int32 Col) {
	UE_LOG(LogTemp, Warning, TEXT("Tile clicked: Row=%d Col=%d"), Row, Col);
}

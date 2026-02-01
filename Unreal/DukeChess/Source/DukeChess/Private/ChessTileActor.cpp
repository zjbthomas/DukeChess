// Fill out your copyright notice in the Description page of Project Settings.


#include "ChessTileActor.h"

// Sets default values
AChessTileActor::AChessTileActor()
{
 	// Set this actor to call Tick() every frame.  You can turn this off to improve performance if you don't need it.
	PrimaryActorTick.bCanEverTick = false;

    Root = CreateDefaultSubobject<USceneComponent>(TEXT("Root"));
    RootComponent = Root;

    TileCube = CreateDefaultSubobject<UStaticMeshComponent>(TEXT("TileCube"));
    TileCube->SetupAttachment(Root);

    // This is important for mouse picking:
    TileCube->SetCollisionEnabled(ECollisionEnabled::QueryOnly);
    TileCube->SetCollisionResponseToAllChannels(ECR_Ignore);
    TileCube->SetCollisionResponseToChannel(ECC_Visibility, ECR_Block);
    TileCube->SetGenerateOverlapEvents(false);

    SelectorPlane = CreateDefaultSubobject<UStaticMeshComponent>(TEXT("SelectorPlane"));
    SelectorPlane->SetupAttachment(Root);

    // The highlight plane should NOT interfere with mouse hit testing
    SelectorPlane->SetCollisionEnabled(ECollisionEnabled::NoCollision);
    SelectorPlane->SetGenerateOverlapEvents(false);
}

// Called when the game starts or when spawned
void AChessTileActor::BeginPlay()
{
	Super::BeginPlay();

    SelectorPlane->SetVisibility(false, true);
	
    TileCube->OnBeginCursorOver.AddDynamic(this, &AChessTileActor::HandleBeginCursorOver);
    TileCube->OnEndCursorOver.AddDynamic(this, &AChessTileActor::HandleEndCursorOver);
    TileCube->OnClicked.AddDynamic(this, &AChessTileActor::HandleClicked);
}

// Called every frame
void AChessTileActor::Tick(float DeltaTime)
{
	Super::Tick(DeltaTime);

}

void AChessTileActor::UpdateMaterial() {
    TileCube->SetMaterial(0, ((Row + Col) % 2 == 0) ? Material1 : Material2);
}

void AChessTileActor::HandleBeginCursorOver(UPrimitiveComponent* TouchedComponent)
{
    SelectorPlane->SetVisibility(true, true);
}

void AChessTileActor::HandleEndCursorOver(UPrimitiveComponent* TouchedComponent)
{
    SelectorPlane->SetVisibility(false, true);
}

void AChessTileActor::HandleClicked(UPrimitiveComponent* TouchedComponent, FKey ButtonPressed)
{
    OnTileClicked.Broadcast(Row, Col);
}
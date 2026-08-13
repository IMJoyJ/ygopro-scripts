--アーティファクト－ラブリュス
-- 效果：
-- 这张卡可以当作魔法卡使用从手卡到魔法与陷阱卡区域盖放。魔法与陷阱卡区域盖放的这张卡在对方回合被破坏送去墓地时，这张卡特殊召唤。此外，名字带有「古遗物」的卡被破坏送去自己墓地时才能发动。这张卡从手卡特殊召唤。
function c47863787.initial_effect(c)
	-- 这张卡可以当作魔法卡使用从手卡到魔法与陷阱卡区域盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MONSTER_SSET)
	e1:SetValue(TYPE_SPELL)
	c:RegisterEffect(e1)
	-- 魔法与陷阱卡区域盖放的这张卡在对方回合被破坏送去墓地时，这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(47863787,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c47863787.spcon)
	e2:SetTarget(c47863787.sptg)
	e2:SetOperation(c47863787.spop)
	c:RegisterEffect(e2)
	-- 此外，名字带有「古遗物」的卡被破坏送去自己墓地时才能发动。这张卡从手卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(47863787,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetRange(LOCATION_HAND)
	e3:SetCondition(c47863787.spcon2)
	e3:SetTarget(c47863787.sptg2)
	e3:SetOperation(c47863787.spop)
	c:RegisterEffect(e3)
end
-- 判定满足特殊召唤的条件：此卡在被破坏前位于魔法与陷阱区域且为里侧表示、原控制者为效果发动者，并且是被破坏送去墓地且在对方回合。
function c47863787.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_SZONE) and c:IsPreviousPosition(POS_FACEDOWN)
		and c:IsPreviousControler(tp)
		-- 进一步确认这张卡是因为破坏而被送去墓地，且当前回合为对方回合（满足“对方回合被破坏”的条件）。
		and c:IsReason(REASON_DESTROY) and Duel.GetTurnPlayer()~=tp
end
-- 发动时确认：必发效果无需额外条件即返回true，并设置特殊召唤的操作信息。
function c47863787.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记本次连锁将进行特殊召唤的操作信息，用于后续时点检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：若此卡仍与效果关联，则将其以表侧表示特殊召唤。
function c47863787.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 执行特殊召唤：将此卡以表侧表示特殊召唤到其持有者的场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 筛选条件：该卡的控制者为发动玩家、属于「古遗物」系列、并且是被破坏送去墓地。
function c47863787.cfilter(c,tp)
	return c:IsControler(tp) and c:IsSetCard(0x97) and c:IsReason(REASON_DESTROY)
end
-- 触发条件：本次送去墓地的卡组中存在至少1张满足“古遗物”且被破坏送去自己墓地的卡。
function c47863787.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c47863787.cfilter,1,nil,tp)
end
-- 发动时确认：自己的主要怪兽区域有空位，且手牌的这张卡可以特殊召唤。
function c47863787.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主要怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记本次连锁将进行特殊召唤的操作信息，用于后续时点检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end

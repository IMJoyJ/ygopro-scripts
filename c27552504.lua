--永遠の淑女 ベアトリーチェ
-- 效果：
-- 6星怪兽×2
-- 这张卡也能把手卡1只「彼岸」怪兽送去墓地，在自己场上的「但丁」怪兽上面重叠来超量召唤。这个方法特殊召唤的回合，这张卡的①的效果不能发动。
-- ①：自己·对方回合1次，把这张卡1个超量素材取除才能发动。从卡组选1张卡送去墓地。
-- ②：这张卡被对方破坏送去墓地的场合才能发动。从额外卡组把1只「彼岸」怪兽无视召唤条件特殊召唤。
function c27552504.initial_effect(c)
	aux.AddXyzProcedure(c,nil,6,2,c27552504.ovfilter,aux.Stringid(27552504,0),2,c27552504.xyzop)  --"在自己场上的「但丁」怪兽上面重叠来超量召唤？"
	c:EnableReviveLimit()
	-- ①：自己·对方回合1次，把这张卡1个超量素材取除才能发动。从卡组选1张卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27552504,1))  --"从卡组选1张卡送去墓地"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1)
	e1:SetCost(c27552504.tgcost)
	e1:SetTarget(c27552504.tgtg)
	e1:SetOperation(c27552504.tgop)
	c:RegisterEffect(e1)
	-- ②：这张卡被对方破坏送去墓地的场合才能发动。从额外卡组把1只「彼岸」怪兽无视召唤条件特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(27552504,2))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c27552504.spcon)
	e2:SetTarget(c27552504.sptg)
	e2:SetOperation(c27552504.spop)
	c:RegisterEffect(e2)
end
-- 筛选可作为超量召唤手续代价从手卡丢弃的「彼岸」怪兽：必须是「彼岸」怪兽且能从手卡送去墓地。
function c27552504.cfilter(c)
	return c:IsSetCard(0xb1) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 筛选可作为超量召唤叠放对象的我方场上的表侧表示「但丁」怪兽。
function c27552504.ovfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xd5)
end
-- 超量召唤的追加操作：检查手卡有无可丢弃的「彼岸」怪兽，丢弃1只并给此卡设置标记，使本回合①效果不能发动。
function c27552504.xyzop(e,tp,chk)
	-- 检查是否存在满足丢弃条件的手卡「彼岸」怪兽，以决定该超量召唤追加操作能否执行。
	if chk==0 then return Duel.IsExistingMatchingCard(c27552504.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 从手卡挑选并丢弃1只满足条件的「彼岸」怪兽作为超量召唤的特殊代价。
	Duel.DiscardHand(tp,c27552504.cfilter,1,1,REASON_COST,nil)
	e:GetHandler():RegisterFlagEffect(27552504,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END,0,1)
end
-- ①效果的发动代价：取除此卡的1个超量素材。
function c27552504.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- ①效果的发动条件：此卡没有被本回合特殊召唤手续标记限制，且卡组中有可送去墓地的卡。
function c27552504.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(27552504)==0
		-- 同时要求卡组中存在至少1张能够送去墓地的卡，用作效果处理时的检索目标。
		and Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_DECK,0,1,nil) end
	-- 将本次连锁操作信息设定为“从卡组把1张卡送去墓地”，供其他卡效果进行对应。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理时：从卡组选择1张卡送去墓地。
function c27552504.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中选择1张可以送去墓地的卡（必须选1张）。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡送去墓地，完成①效果。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- ②效果发动条件：此卡被对方破坏并送去墓地的场合才能发动，且破坏前控制权必须属于自己。
function c27552504.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousControler(tp) and rp==1-tp and c:IsReason(REASON_DESTROY)
end
-- 筛选可被②效果特殊召唤的额外卡组「彼岸」怪兽，并确认有足够额外怪兽区域空格。
function c27552504.spfilter(c,e,tp)
	-- 判断额外卡组中的卡是否满足「彼岸」、可无视召唤条件特殊召唤，以及场上是否有额外怪兽区域空格。
	return c:IsSetCard(0xb1) and c:IsCanBeSpecialSummoned(e,0,tp,true,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- ②效果的发动目标：检查额外卡组是否存在符合条件的「彼岸」怪兽，并设置特殊召唤的操作信息。
function c27552504.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组是否存在可特殊召唤的「彼岸」怪兽且场上区域允许。
	if chk==0 then return Duel.IsExistingMatchingCard(c27552504.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 将本次连锁操作信息设定为“从额外卡组特殊召唤1只怪兽”，供其他卡效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ②效果处理时：从额外卡组选择1只「彼岸」怪兽，无视召唤条件特殊召唤。
function c27552504.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组中选择1只符合条件的「彼岸」怪兽。
	local g=Duel.SelectMatchingCard(tp,c27552504.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽无视召唤条件特殊召唤，表示形式为表侧攻击表示。
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end

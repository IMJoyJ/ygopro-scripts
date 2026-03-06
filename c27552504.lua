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
-- 过滤函数，用于判断手卡中是否存在满足条件的「彼岸」怪兽（怪兽卡且能作为墓地代价）
function c27552504.cfilter(c)
	return c:IsSetCard(0xb1) and c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
end
-- 过滤函数，用于判断场上是否存在满足条件的「但丁」怪兽（表侧表示且为「但丁」卡组）
function c27552504.ovfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xd5)
end
-- 超量召唤时的处理函数，检查手卡是否存在「彼岸」怪兽并将其丢弃作为召唤代价，并设置标志位防止①效果在本回合发动
function c27552504.xyzop(e,tp,chk)
	-- 检查手卡是否存在满足条件的「彼岸」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c27552504.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 将手卡中满足条件的「彼岸」怪兽丢弃作为召唤代价
	Duel.DiscardHand(tp,c27552504.cfilter,1,1,REASON_COST,nil)
	e:GetHandler():RegisterFlagEffect(27552504,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END,0,1)
end
-- 效果发动时的费用处理函数，检查是否能移除1个超量素材作为费用
function c27552504.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果发动时的取对象处理函数，检查是否满足发动条件（未在本回合发动过①效果且卡组存在可送去墓地的卡）
function c27552504.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(27552504)==0
		-- 检查卡组是否存在至少1张可送去墓地的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，指定效果处理时将从卡组选择1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果发动时的处理函数，提示玩家选择从卡组送去墓地的卡并执行送去墓地操作
function c27552504.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的卡从卡组送去墓地
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 效果发动的条件函数，判断该卡是否被对方破坏并送去墓地
function c27552504.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousControler(tp) and rp==1-tp and c:IsReason(REASON_DESTROY)
end
-- 过滤函数，用于判断额外卡组中是否存在满足条件的「彼岸」怪兽（可特殊召唤且有召唤空间）
function c27552504.spfilter(c,e,tp)
	-- 判断是否为「彼岸」卡组、可特殊召唤且场上存在召唤空间
	return c:IsSetCard(0xb1) and c:IsCanBeSpecialSummoned(e,0,tp,true,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果发动时的取对象处理函数，检查是否满足发动条件（额外卡组存在满足条件的「彼岸」怪兽）
function c27552504.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组是否存在满足条件的「彼岸」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c27552504.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置连锁操作信息，指定效果处理时将从额外卡组特殊召唤1只「彼岸」怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果发动时的处理函数，提示玩家选择从额外卡组特殊召唤的「彼岸」怪兽并执行特殊召唤操作
function c27552504.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的「彼岸」怪兽从额外卡组特殊召唤
	local g=Duel.SelectMatchingCard(tp,c27552504.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的「彼岸」怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end

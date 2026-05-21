--ブラック・ブルドラゴ
-- 效果：
-- 调整＋调整以外的二重怪兽1只以上
-- 1回合1次，可以从手卡把1只二重怪兽送去墓地，选择对方场上存在的1张魔法·陷阱卡破坏。这张卡被破坏送去墓地时，可以选择自己墓地存在的1只二重怪兽特殊召唤。这个效果特殊召唤的二重怪兽变成再度召唤的状态。
function c96029574.initial_effect(c)
	-- 添加同调召唤手续：调整+调整以外的二重怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsSynchroType,TYPE_DUAL),1)
	c:EnableReviveLimit()
	-- 1回合1次，可以从手卡把1只二重怪兽送去墓地，选择对方场上存在的1张魔法·陷阱卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(96029574,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c96029574.descost)
	e1:SetTarget(c96029574.destg)
	e1:SetOperation(c96029574.desop)
	c:RegisterEffect(e1)
	-- 这张卡被破坏送去墓地时，可以选择自己墓地存在的1只二重怪兽特殊召唤。这个效果特殊召唤的二重怪兽变成再度召唤的状态。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(96029574,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c96029574.spcon)
	e2:SetTarget(c96029574.sptg)
	e2:SetOperation(c96029574.spop)
	c:RegisterEffect(e2)
end
-- 过滤手卡中可作为代价送去墓地的二重怪兽
function c96029574.cfilter(c)
	return c:IsType(TYPE_DUAL) and c:IsAbleToGraveAsCost()
end
-- 破坏效果的代价（Cost）处理：从手卡将1只二重怪兽送去墓地
function c96029574.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在至少1只可以作为代价送去墓地的二重怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c96029574.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家选择手卡中1只满足条件的二重怪兽
	local g=Duel.SelectMatchingCard(tp,c96029574.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的二重怪兽作为代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤对方场上的魔法·陷阱卡
function c96029574.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 破坏效果的对象（Target）处理：选择对方场上1张魔法·陷阱卡
function c96029574.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c96029574.desfilter(chkc) end
	-- 检查对方场上是否存在可以作为对象的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c96029574.desfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择对方场上1张魔法·陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,c96029574.desfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息为“破坏选中的1张卡”
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的操作（Operation）处理：破坏选中的魔法·陷阱卡
function c96029574.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果选中的对象卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果破坏选中的卡片
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 检查特殊召唤效果的发动条件：此卡是否因被破坏而送去墓地
function c96029574.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY)
end
-- 过滤自己墓地中可以特殊召唤的二重怪兽
function c96029574.spfilter(c,e,tp)
	return c:IsType(TYPE_DUAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的对象（Target）处理：选择自己墓地1只二重怪兽
function c96029574.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c96029574.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查自己墓地是否存在可以特殊召唤的二重怪兽
		and Duel.IsExistingTarget(c96029574.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家选择自己墓地1只二重怪兽作为特殊召唤的对象
	local g=Duel.SelectTarget(tp,c96029574.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息为“特殊召唤选中的1张卡”
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤效果的操作（Operation）处理：特殊召唤选中的二重怪兽并使其变成再度召唤状态
function c96029574.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取特殊召唤效果选中的对象卡片
	local tc=Duel.GetFirstTarget()
	-- 若对象卡片仍符合条件，则将其以表侧表示特殊召唤到场上
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		tc:EnableDualState()
	end
	-- 完成特殊召唤的后续处理
	Duel.SpecialSummonComplete()
end

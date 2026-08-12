--第一の棺
-- 效果：
-- 在对方的每1个结束阶段时，按照「第二之棺」「第三之棺」的顺序将其中1张卡从自己的手卡·卡组以表侧表示放到自己场上。当其中任意1张离场时，将这些卡全部送去墓地。当自己场上凑齐所有卡时，将这些卡全部送去墓地，从自己的手卡·卡组特殊召唤1只「法老之灵」上场。
function c31076103.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e1)
	-- 在对方的每1个结束阶段时，按照「第二之棺」「第三之棺」的顺序将其中1张卡从自己的手卡·卡组以表侧表示放到自己场上。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(31076103,0))  --"放置"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1)
	e2:SetCondition(c31076103.condition)
	e2:SetOperation(c31076103.operation)
	c:RegisterEffect(e2)
	-- 当自己场上凑齐所有卡时，将这些卡全部送去墓地，从自己的手卡·卡组特殊召唤1只「法老之灵」上场。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(31076103,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetCountLimit(1)
	e3:SetCondition(c31076103.condition)
	e3:SetCost(c31076103.spcost)
	e3:SetTarget(c31076103.sptg)
	e3:SetOperation(c31076103.spop)
	c:RegisterEffect(e3)
	-- 当其中任意1张离场时，将这些卡全部送去墓地。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetCondition(c31076103.tgcon)
	e4:SetOperation(c31076103.tgop)
	c:RegisterEffect(e4)
	-- 当其中任意1张离场时，将这些卡全部送去墓地。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetCode(EVENT_LEAVE_FIELD)
	e5:SetOperation(c31076103.tgop)
	c:RegisterEffect(e5)
end
-- 判断是否为对方的结束阶段
function c31076103.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为对方的结束阶段
	return Duel.GetTurnPlayer()~=tp
end
-- 过滤函数：检查场上是否存在指定code的表侧表示怪兽
function c31076103.cfilter1(c,code)
	return c:IsFaceup() and c:IsCode(code)
end
-- 在对方的每1个结束阶段时，按照「第二之棺」「第三之棺」的顺序将其中1张卡从自己的手卡·卡组以表侧表示放到自己场上。
function c31076103.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 若场上没有可用的魔法区域则不执行效果
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 若场上没有「第二之棺」则执行放置「第二之棺」的效果
	if not Duel.IsExistingMatchingCard(c31076103.cfilter1,tp,LOCATION_SZONE,0,1,nil,4081094) then
		-- 提示玩家选择要表侧表示放到自己场上的卡
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(31076103,2))  --"请选择要表侧表示放到自己场上的卡"
		-- 从手卡或卡组中选择一张「第二之棺」
		local g=Duel.SelectMatchingCard(tp,Card.IsCode,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,4081094)
		if g:GetCount()>0 then
			-- 将选中的「第二之棺」放置到场上
			Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		end
	-- 若场上没有「第三之棺」则执行放置「第三之棺」的效果
	elseif not Duel.IsExistingMatchingCard(c31076103.cfilter1,tp,LOCATION_SZONE,0,1,nil,78697395) then
		-- 提示玩家选择要表侧表示放到自己场上的卡
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(31076103,2))  --"请选择要表侧表示放到自己场上的卡"
		-- 从手卡或卡组中选择一张「第三之棺」
		local g=Duel.SelectMatchingCard(tp,Card.IsCode,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,78697395)
		if g:GetCount()>0 then
			-- 将选中的「第三之棺」放置到场上
			Duel.MoveToField(g:GetFirst(),tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		end
	end
end
-- 过滤函数：检查场上是否存在指定code的表侧表示怪兽且能作为墓地代价
function c31076103.cfilter2(c,code)
	return c:IsFaceup() and c:IsCode(code) and c:IsAbleToGraveAsCost()
end
-- 过滤函数：检查场上是否存在「第一之棺」「第二之棺」「第三之棺」的表侧表示怪兽且能作为墓地代价
function c31076103.cfilter3(c)
	return c:IsFaceup() and c:IsCode(31076103,4081094,78697395) and c:IsAbleToGraveAsCost()
end
-- 特殊召唤的发动费用：将自身送去墓地，并确保场上存在「第二之棺」和「第三之棺」
function c31076103.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost()
		-- 确保场上存在「第二之棺」
		and Duel.IsExistingMatchingCard(c31076103.cfilter2,tp,LOCATION_SZONE,0,1,nil,4081094)
		-- 确保场上存在「第三之棺」
		and Duel.IsExistingMatchingCard(c31076103.cfilter2,tp,LOCATION_SZONE,0,1,nil,78697395) end
	-- 获取场上所有「第一之棺」「第二之棺」「第三之棺」的表侧表示怪兽
	local g=Duel.GetMatchingGroup(c31076103.cfilter3,tp,LOCATION_SZONE,0,nil)
	-- 将这些怪兽全部送去墓地作为特殊召唤的费用
	Duel.SendtoGrave(g,REASON_COST)
end
-- 设置特殊召唤的处理信息
function c31076103.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置特殊召唤的处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 过滤函数：检查是否可以特殊召唤「法老之灵」
function c31076103.spfilter(c,e,tp)
	return c:IsCode(25343280) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 特殊召唤「法老之灵」
function c31076103.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若场上没有可用的怪兽区域则不执行效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡或卡组中选择一张「法老之灵」
	local g=Duel.SelectMatchingCard(tp,c31076103.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	-- 执行特殊召唤操作
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)>0 then
		g:GetFirst():CompleteProcedure()
	end
end
-- 过滤函数：检查是否为「第一之棺」「第二之棺」「第三之棺」
function c31076103.cfilter4(c)
	return c:IsCode(31076103,4081094,78697395)
end
-- 过滤函数：检查场上是否存在「第一之棺」「第二之棺」「第三之棺」的表侧表示怪兽
function c31076103.cfilter5(c)
	return c:IsFaceup() and c:IsCode(31076103,4081094,78697395)
end
-- 判断是否有「第一之棺」「第二之棺」「第三之棺」离场
function c31076103.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c31076103.cfilter4,1,nil)
end
-- 将场上所有「第一之棺」「第二之棺」「第三之棺」送去墓地
function c31076103.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有「第一之棺」「第二之棺」「第三之棺」的表侧表示怪兽
	local g=Duel.GetMatchingGroup(c31076103.cfilter5,tp,LOCATION_SZONE,0,nil)
	-- 将这些怪兽全部送去墓地
	Duel.SendtoGrave(g,REASON_EFFECT)
end

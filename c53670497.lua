--復活の聖刻印
-- 效果：
-- 对方回合1次，可以从卡组把1只名字带有「圣刻」的怪兽送去墓地。此外，自己回合1次，可以选择从游戏中除外的1只自己的名字带有「圣刻」的怪兽回到墓地。场上表侧表示存在的这张卡被送去墓地时，选择自己墓地1只名字带有「圣刻」的怪兽特殊召唤。
function c53670497.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e1)
	-- 对方回合1次，可以从卡组把1只名字带有「圣刻」的怪兽送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(53670497,0))  --"是否现在使用「复活之圣刻印」的效果？"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1)
	e2:SetCondition(c53670497.condition1)
	e2:SetTarget(c53670497.target1)
	e2:SetOperation(c53670497.activate1)
	c:RegisterEffect(e2)
	-- 自己回合1次，可以选择从游戏中除外的1只自己的名字带有「圣刻」的怪兽回到墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(53670497,1))  --"送去墓地"
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCountLimit(1)
	e3:SetCondition(c53670497.condition2)
	e3:SetTarget(c53670497.target2)
	e3:SetOperation(c53670497.activate2)
	c:RegisterEffect(e3)
	-- 场上表侧表示存在的这张卡被送去墓地时，选择自己墓地1只名字带有「圣刻」的怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(53670497,2))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(c53670497.spcon)
	e4:SetTarget(c53670497.sptg)
	e4:SetOperation(c53670497.spop)
	c:RegisterEffect(e4)
end
-- 判断是否为对方回合，是则效果可用
function c53670497.condition1(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为对方回合，是则效果可用
	return Duel.IsTurnPlayer(1-tp)
end
-- 过滤函数，用于筛选卡组中名字带有「圣刻」的怪兽
function c53670497.filter1(c)
	return c:IsSetCard(0x69) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 设置效果目标，检查卡组中是否存在满足条件的怪兽
function c53670497.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c53670497.filter1,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示将要从卡组送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 发动效果，提示选择卡组中的怪兽并将其送去墓地
function c53670497.activate1(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组中选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c53670497.filter1,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选中的怪兽送去墓地
	Duel.SendtoGrave(g,REASON_EFFECT)
end
-- 判断是否为己方回合，是则效果可用
function c53670497.condition2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为己方回合，是则效果可用
	return Duel.IsTurnPlayer(tp)
end
-- 过滤函数，用于筛选除外区中名字带有「圣刻」的表侧表示怪兽
function c53670497.filter2(c)
	return c:IsFaceup() and c:IsSetCard(0x69) and c:IsType(TYPE_MONSTER)
end
-- 设置效果目标，检查除外区中是否存在满足条件的怪兽
function c53670497.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c53670497.filter2(chkc) end
	-- 检查除外区中是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c53670497.filter2,tp,LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(53670497,3))  --"特殊召唤"
	-- 从除外区中选择满足条件的怪兽
	local g=Duel.SelectTarget(tp,c53670497.filter2,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置操作信息，表示将要将选中的怪兽送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
-- 发动效果，将选中的怪兽从除外区送回墓地
function c53670497.activate2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		-- 将选中的怪兽送回墓地
		Duel.SendtoGrave(tc,REASON_EFFECT+REASON_RETURN)
	end
end
-- 判断此卡是否为表侧表示从场上送去墓地
function c53670497.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤函数，用于筛选墓地中名字带有「圣刻」且可特殊召唤的怪兽
function c53670497.filter(c,e,tp)
	return c:IsSetCard(0x69) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果目标，检查墓地中是否存在满足条件的怪兽
function c53670497.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c53670497.filter(chkc,e,tp) end
	-- 检查场上是否有足够的召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地中是否存在满足条件的怪兽
		and Duel.IsExistingTarget(c53670497.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从墓地中选择满足条件的怪兽
	local g=Duel.SelectTarget(tp,c53670497.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息，表示将要特殊召唤选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 发动效果，将选中的怪兽特殊召唤到场上
function c53670497.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

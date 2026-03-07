--ゴーティスの陰影スノーピオス
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段，从自己的手卡·墓地把2只鱼族怪兽除外才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡特殊召唤的场合，以场上1张表侧表示卡为对象才能发动。那张卡从场上离开的场合除外。
-- ③：这张卡被除外的场合，从自己墓地把1只鱼族怪兽除外才能发动。这张卡加入手卡。
local s,id,o=GetID()
-- 创建三个效果，分别对应①②③效果
function s.initial_effect(c)
	-- ①：自己·对方的主要阶段，从自己的手卡·墓地把2只鱼族怪兽除外才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡特殊召唤的场合，以场上1张表侧表示卡为对象才能发动。那张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.flagtg)
	e2:SetOperation(s.flagop)
	c:RegisterEffect(e2)
	-- ③：这张卡被除外的场合，从自己墓地把1只鱼族怪兽除外才能发动。这张卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_REMOVE)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCost(s.thcost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- 效果发动条件：当前阶段为主要阶段1或主要阶段2
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前阶段为主要阶段1或主要阶段2
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 过滤函数：判断是否为鱼族且可作为除外的费用
function s.costfilter(c)
	return c:IsRace(RACE_FISH) and c:IsAbleToRemoveAsCost()
end
-- 效果处理：选择2只鱼族怪兽除外作为费用
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否满足除外2只鱼族怪兽的条件
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,2,c) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的2张卡
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,2,2,c)
	-- 将选中的卡除外作为费用
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果处理：设置特殊召唤的目标
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否满足特殊召唤的条件
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果处理：将自身特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将自身特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 效果处理：选择一张表侧表示的卡除外
function s.flagtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsFaceup() end
	-- 检查是否满足选择一张表侧表示卡的条件
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择一张表侧表示的卡
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
end
-- 效果处理：设置选中卡的离开场时除外效果
function s.flagop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	-- 设置选中卡的离开场时除外效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,2))  --"「魊影的阴影 斯诺皮奥斯」效果适用中"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
	e1:SetValue(LOCATION_REMOVED)
	e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
	tc:RegisterEffect(e1)
end
-- 效果处理：选择1只鱼族怪兽除外作为费用
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足除外1只鱼族怪兽的条件
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的1张卡
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡除外作为费用
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果处理：设置加入手卡的目标
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	-- 设置加入手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
-- 效果处理：将自身加入手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将自身送入手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end

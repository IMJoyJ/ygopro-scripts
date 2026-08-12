--飛鯉
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从手卡丢弃1只水属性怪兽才能发动。这张卡的攻击力上升500。这个效果在对方回合也能发动。
-- ②：这张卡战斗破坏对方怪兽时，把这张卡解放才能发动。从手卡·卡组把1只鱼族·海龙族·水族怪兽特殊召唤。
function c33314479.initial_effect(c)
	-- ①：从手卡丢弃1只水属性怪兽才能发动。这张卡的攻击力上升500。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCountLimit(1,33314479)
	e1:SetRange(LOCATION_MZONE)
	-- 限制效果只能在伤害计算前的时机发动或适用
	e1:SetCondition(aux.dscon)
	e1:SetCost(c33314479.cost)
	e1:SetOperation(c33314479.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡战斗破坏对方怪兽时，把这张卡解放才能发动。从手卡·卡组把1只鱼族·海龙族·水族怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	-- 判断是否与对方怪兽战斗并被破坏
	e2:SetCondition(aux.bdocon)
	e2:SetCountLimit(1,33314480)
	e2:SetCost(c33314479.spcost)
	e2:SetTarget(c33314479.sptg)
	e2:SetOperation(c33314479.spop)
	c:RegisterEffect(e2)
end
-- 水属性怪兽的筛选条件
function c33314479.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsDiscardable()
end
-- 丢弃满足条件的1只水属性怪兽作为效果发动的代价
function c33314479.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足丢弃1只水属性怪兽的条件
	if chk==0 then return Duel.IsExistingMatchingCard(c33314479.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 执行丢弃1只水属性怪兽的操作
	Duel.DiscardHand(tp,c33314479.cfilter,1,1,REASON_COST+REASON_DISCARD,nil)
end
-- 使自身攻击力上升500点
function c33314479.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 使自身攻击力上升500点
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 解放自身作为效果发动的代价
function c33314479.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 执行解放自身的效果
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 用于筛选可特殊召唤的鱼族·海龙族·水族怪兽
function c33314479.spfilter(c,e,tp)
	return c:IsRace(RACE_FISH+RACE_AQUA+RACE_SEASERPENT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤效果的发动条件
function c33314479.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有可用怪兽区
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 检查手卡或卡组中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c33314479.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- 执行特殊召唤操作
function c33314479.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有可用怪兽区
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的1只怪兽
	local g=Duel.SelectMatchingCard(tp,c33314479.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

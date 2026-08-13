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
	-- 设置①效果的发动条件：在伤害步骤内且伤害计算前才能发动（不能在伤害计算后发动）。
	e1:SetCondition(aux.dscon)
	e1:SetCost(c33314479.cost)
	e1:SetOperation(c33314479.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡战斗破坏对方怪兽时，把这张卡解放才能发动。从手卡·卡组把1只鱼族·海龙族·水族怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	-- 设置②效果的发动条件：这张卡与对方怪兽战斗并把它破坏（这张卡仍与战斗相关）。
	e2:SetCondition(aux.bdocon)
	e2:SetCountLimit(1,33314480)
	e2:SetCost(c33314479.spcost)
	e2:SetTarget(c33314479.sptg)
	e2:SetOperation(c33314479.spop)
	c:RegisterEffect(e2)
end
-- 定义丢弃手牌的筛选条件：水属性怪兽且可以被丢弃。
function c33314479.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsDiscardable()
end
-- ①效果的发动代价：检查并从手卡丢弃1只水属性怪兽作为代价。chk==0时确认存在可丢弃对象，执行时丢弃。
function c33314479.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认手牌中是否存在至少1张满足条件（水属性且可丢弃）的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c33314479.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 执行代价：从手牌选择1张水属性怪兽，以代价+丢弃的理由送入墓地。
	Duel.DiscardHand(tp,c33314479.cfilter,1,1,REASON_COST+REASON_DISCARD,nil)
end
-- ①效果处理：若这张卡仍与效果相关且表侧表示，则给它注册一个攻击力上升500的持续效果。
function c33314479.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的攻击力上升500。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- ②效果的发动代价：解放这张卡。chk==0时确认这张卡可解放，执行时解放。
function c33314479.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 执行代价：将这张卡解放。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 定义特殊召唤对象的筛选条件：鱼族·海龙族·水族怪兽，且满足特殊召唤条件。
function c33314479.spfilter(c,e,tp)
	return c:IsRace(RACE_FISH+RACE_AQUA+RACE_SEASERPENT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动条件：解放后自己场上仍有可用怪兽区，且手卡·卡组存在可特殊召唤的符合条件的怪兽。
function c33314479.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余怪兽区（考虑这张卡解放后腾出的位置）。
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 检查手卡·卡组是否存在1只满足特殊召唤条件的鱼族·海龙族·水族怪兽。
		and Duel.IsExistingMatchingCard(c33314479.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：本效果将进行特殊召唤，从手卡·卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- ②效果处理：若仍有空余怪兽区，从手卡·卡组选择1只符合条件的怪兽以表侧表示特殊召唤。
function c33314479.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 二次确认自己场上还有空余怪兽区，否则效果处理不适用。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示选择提示，让玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·卡组选择1只满足spfilter条件的怪兽作为特殊召唤对象（不取对象，效果处理时选择）。
	local g=Duel.SelectMatchingCard(tp,c33314479.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

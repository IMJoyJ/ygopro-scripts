--デフコンバード
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：从手卡把这张卡以外的1只电子界族怪兽丢弃才能发动。这张卡从手卡特殊召唤。
-- ②：1回合1次，自己的电子界族怪兽被选择作为攻击对象时才能发动。那只怪兽的攻击力·守备力直到那次伤害步骤结束时变成原本攻击力的2倍。那只怪兽是攻击表示的场合，可以再把那个表示形式变成守备表示。
function c76353872.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：从手卡把这张卡以外的1只电子界族怪兽丢弃才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(76353872,0))  --"这张卡从手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,76353872)
	e1:SetCost(c76353872.spcost)
	e1:SetTarget(c76353872.sptg)
	e1:SetOperation(c76353872.spop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己的电子界族怪兽被选择作为攻击对象时才能发动。那只怪兽的攻击力·守备力直到那次伤害步骤结束时变成原本攻击力的2倍。那只怪兽是攻击表示的场合，可以再把那个表示形式变成守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(76353872,1))  --"攻击力翻倍"
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BE_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c76353872.condition)
	e2:SetTarget(c76353872.target)
	e2:SetOperation(c76353872.opetation)
	c:RegisterEffect(e2)
end
-- 过滤条件：手卡中除自身以外的电子界族怪兽
function c76353872.cfilter(c)
	return c:IsRace(RACE_CYBERSE) and c:IsDiscardable()
end
-- ①的效果发动代价：从手卡将这张卡以外的1只电子界族怪兽丢弃
function c76353872.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在除这张卡以外的电子界族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c76353872.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 从手卡选择1只除这张卡以外的电子界族怪兽丢弃
	Duel.DiscardHand(tp,c76353872.cfilter,1,1,REASON_COST+REASON_DISCARD,e:GetHandler())
end
-- ①的效果发动目标：检查怪兽区域空位并确认自身能否特殊召唤
function c76353872.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁信息：包含特殊召唤自身的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①的效果处理：将这张卡从手卡特殊召唤
function c76353872.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到自己场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- ②的效果发动条件：自己的表侧表示电子界族怪兽被选择作为攻击对象时
function c76353872.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的攻击对象（被攻击的怪兽）
	local at=Duel.GetAttackTarget()
	return at and at:IsControler(tp) and at:IsFaceup() and at:IsRace(RACE_CYBERSE)
end
-- ②的效果发动目标：使被攻击的怪兽与此效果建立关系
function c76353872.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将被攻击的怪兽与当前效果建立关系，以便在效果处理时确认其状态
	Duel.GetAttackTarget():CreateEffectRelation(e)
end
-- ②的效果处理：使被攻击怪兽的攻击力·守备力变成原本攻击力的2倍，并可选择将其变成守备表示
function c76353872.opetation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被攻击的怪兽
	local at=Duel.GetAttackTarget()
	if at:IsRelateToEffect(e) and at:IsFaceup() then
		-- 那只怪兽的攻击力·守备力直到那次伤害步骤结束时变成原本攻击力的2倍。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(at:GetBaseAttack()*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		at:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e2:SetValue(at:GetBaseAttack()*2)
		at:RegisterEffect(e2)
		-- 若该怪兽是攻击表示且可以改变表示形式，询问玩家是否将其变成守备表示
		if at:IsAttackPos() and at:IsCanChangePosition() and Duel.SelectYesNo(tp,aux.Stringid(76353872,2)) then  --"是否变成守备表示？"
			-- 中断当前效果处理，使后续的改变表示形式不与之前的数值变化视为同时处理
			Duel.BreakEffect()
			-- 将被攻击的怪兽变成表侧守备表示
			Duel.ChangePosition(at,POS_FACEUP_DEFENSE)
		end
	end
end

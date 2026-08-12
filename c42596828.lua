--龍狸燈
-- 效果：
-- ①：1回合1次，从手卡丢弃1只幻龙族怪兽才能发动。这张卡的守备力直到回合结束时上升1000。这个效果在对方回合也能发动。
-- ②：攻击表示的这张卡和攻击表示怪兽进行战斗的伤害计算时才能发动1次。那次战斗用双方怪兽的守备力当作攻击力使用进行伤害计算。
function c42596828.initial_effect(c)
	-- ①：1回合1次，从手卡丢弃1只幻龙族怪兽才能发动。这张卡的守备力直到回合结束时上升1000。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(42596828,0))  --"守备力上升"
	e1:SetCategory(CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMINGS_CHECK_MONSTER+TIMING_DAMAGE_STEP)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	-- 限制效果只能在伤害计算前的时机发动或适用
	e1:SetCondition(aux.dscon)
	e1:SetCost(c42596828.defcost)
	e1:SetOperation(c42596828.defop)
	c:RegisterEffect(e1)
	-- ②：攻击表示的这张卡和攻击表示怪兽进行战斗的伤害计算时才能发动1次。那次战斗用双方怪兽的守备力当作攻击力使用进行伤害计算。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(42596828,1))  --"使用守备力进行伤害计算"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetCondition(c42596828.atkcon)
	e2:SetCost(c42596828.atkcost)
	e2:SetOperation(c42596828.atkop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断手卡中是否存在可丢弃的幻龙族怪兽
function c42596828.defcostfilter(c)
	return c:IsDiscardable() and c:IsRace(RACE_WYRM)
end
-- 检查手卡中是否存在至少1张幻龙族怪兽并将其丢弃作为效果的代价
function c42596828.defcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在至少1张幻龙族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c42596828.defcostfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 从手卡丢弃1张幻龙族怪兽作为效果的代价
	Duel.DiscardHand(tp,c42596828.defcostfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 将此卡的守备力在回合结束前增加1000
function c42596828.defop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 将此卡的守备力增加1000
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_DEFENSE)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 判断战斗中的双方怪兽是否都处于攻击表示且守备力大于0
function c42596828.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前战斗中的攻击怪兽和防守怪兽
	local ac,bc=Duel.GetBattleMonster(tp)
	return bc and (ac==c or bc==c)
		and ac:IsPosition(POS_ATTACK) and ac:IsDefenseAbove(0)
		and bc:IsPosition(POS_ATTACK) and bc:IsDefenseAbove(0)
end
-- 检查此卡是否已使用过该效果，若未使用则注册标记
function c42596828.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetFlagEffect(42596828)==0 end
	c:RegisterFlagEffect(42596828,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL,0,1)
end
-- 将战斗中的攻击怪兽和防守怪兽的守备力设为战斗攻击力
function c42596828.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前战斗中的攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取当前战斗中的防守怪兽
	local d=Duel.GetAttackTarget()
	if a:IsRelateToBattle() and d and d:IsRelateToBattle() then
		-- 将攻击怪兽的守备力设为战斗攻击力
		local ea=Effect.CreateEffect(c)
		ea:SetType(EFFECT_TYPE_SINGLE)
		ea:SetCode(EFFECT_SET_BATTLE_ATTACK)
		ea:SetReset(RESET_PHASE+PHASE_DAMAGE)
		ea:SetValue(a:GetDefense())
		a:RegisterEffect(ea,true)
		-- 将防守怪兽的守备力设为战斗攻击力
		local ed=Effect.CreateEffect(c)
		ed:SetType(EFFECT_TYPE_SINGLE)
		ed:SetCode(EFFECT_SET_BATTLE_ATTACK)
		ed:SetReset(RESET_PHASE+PHASE_DAMAGE)
		ed:SetValue(d:GetDefense())
		d:RegisterEffect(ed,true)
	end
end

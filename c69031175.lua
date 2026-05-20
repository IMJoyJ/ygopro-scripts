--BF－アーマード・ウィング
-- 效果：
-- 「黑羽」调整＋调整以外的怪兽1只以上
-- ①：这张卡不会被战斗破坏，这张卡的战斗发生的对自己的战斗伤害变成0。
-- ②：这张卡向怪兽攻击的伤害步骤结束时才能发动。给那只怪兽放置1个楔指示物（最多1个）。
-- ③：把对方场上的楔指示物全部取除才能发动。有楔指示物放置过的全部怪兽的攻击力·守备力直到回合结束时变成0。
function c69031175.initial_effect(c)
	-- 添加同调召唤手续：「黑羽」调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x33),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 这张卡不会被战斗破坏
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 这张卡的战斗发生的对自己的战斗伤害变成0
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 这张卡向怪兽攻击的伤害步骤结束时才能发动。给那只怪兽放置1个楔指示物（最多1个）。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(69031175,0))  --"放置指示物"
	e3:SetCategory(CATEGORY_COUNTER)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DAMAGE_STEP_END)
	e3:SetCondition(c69031175.ctcon)
	e3:SetOperation(c69031175.ctop)
	c:RegisterEffect(e3)
	-- 把对方场上的楔指示物全部取除才能发动。有楔指示物放置过的全部怪兽的攻击力·守备力直到回合结束时变成0。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(69031175,1))  --"攻守变化"
	e4:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCost(c69031175.atkcost)
	e4:SetOperation(c69031175.atkop)
	c:RegisterEffect(e4)
end
-- 放置楔指示物效果的发动条件判断
function c69031175.ctcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗的攻击对象（被攻击的怪兽）
	local atg=Duel.GetAttackTarget()
	-- 判断是否在伤害步骤结束时且自身是攻击方
	return aux.dsercon(e,tp,eg,ep,ev,re,r,rp) and Duel.GetAttacker()==e:GetHandler()
		and atg and atg:IsRelateToBattle() and atg:GetCounter(0x1002)==0 and atg:IsCanAddCounter(0x1002,1)
end
-- 放置楔指示物效果的执行操作
function c69031175.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗的攻击对象
	local atg=Duel.GetAttackTarget()
	if atg:IsRelateToBattle() then
		atg:AddCounter(0x1002,1)
	end
end
-- 过滤场上放置有楔指示物的怪兽
function c69031175.filter(c)
	return c:GetCounter(0x1002)>0
end
-- 攻守变0效果的发动代价与目标确认
function c69031175.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在放置有楔指示物的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c69031175.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有放置有楔指示物的怪兽
	local g=Duel.GetMatchingGroup(c69031175.filter,tp,0,LOCATION_MZONE,nil)
	local t=g:GetFirst()
	while t do
		t:RemoveCounter(tp,0x1002,t:GetCounter(0x1002),REASON_COST)
		t=g:GetNext()
	end
	-- 将这些怪兽设为效果处理的对象
	Duel.SetTargetCard(g)
end
-- 攻守变0效果的执行操作
function c69031175.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被设为效果对象的怪兽组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local t=g:GetFirst()
	while t do
		if t:IsRelateToEffect(e) then
			-- 攻击力直到回合结束时变成0
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(0)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			t:RegisterEffect(e1)
			-- 守备力直到回合结束时变成0
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
			e2:SetValue(0)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			t:RegisterEffect(e2)
		end
		t=g:GetNext()
	end
end

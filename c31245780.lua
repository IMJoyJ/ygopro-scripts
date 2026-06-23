--バトルマニア
-- 效果：
-- 对方回合的准备阶段时才能发动。对方场上表侧表示存在的怪兽全部变成攻击表示，这个回合表示形式不能改变。此外，这个回合可以攻击的对方怪兽必须作出攻击。
function c31245780.initial_effect(c)
	-- 创建效果，设置为发动时点，发动时触发，设置提示时点为准备阶段，条件为对方回合准备阶段，目标为对方场上表侧表示怪兽，效果为改变表示形式
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE)
	e1:SetCondition(c31245780.condition)
	e1:SetTarget(c31245780.target)
	e1:SetOperation(c31245780.activate)
	c:RegisterEffect(e1)
end
-- 效果发动条件：对方回合的准备阶段
function c31245780.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 对方回合且当前阶段为准备阶段
	return Duel.GetTurnPlayer()~=tp and Duel.GetCurrentPhase()==PHASE_STANDBY
end
-- 效果发动时点，检查对方场上是否存在表侧表示怪兽，若存在则设置操作信息为改变表示形式
function c31245780.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1张表侧表示怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有表侧表示怪兽
	local sg=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	-- 设置操作信息为改变表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,sg,sg:GetCount(),0,0)
end
-- 效果发动处理，将对方场上所有表侧表示怪兽变为攻击表示，并设置必须攻击和不能改变表示形式效果
function c31245780.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方场上所有表侧表示怪兽
	local sg=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if sg:GetCount()>0 then
		-- 将对方场上所有表侧表示怪兽变为攻击表示
		Duel.ChangePosition(sg,POS_FACEUP_ATTACK,0,POS_FACEUP_ATTACK,0)
		local tc=sg:GetFirst()
		while tc do
			-- 这个回合可以攻击的对方怪兽必须作出攻击
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_MUST_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			-- 这个回合表示形式不能改变
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
			tc:RegisterFlagEffect(31245780,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
			tc=sg:GetNext()
		end
	end
end
-- 用于检测是否为被战斗狂影响的怪兽且可攻击
function c31245780.befilter(c)
	return c:GetFlagEffect(31245780)~=0 and c:IsAttackable()
end

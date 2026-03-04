--悪魔のサイコロ
-- 效果：
-- ①：掷1次骰子。对方场上的怪兽的攻击力·守备力直到回合结束时下降出现的数目×100。
function c126218.initial_effect(c)
	-- ①：掷1次骰子。对方场上的怪兽的攻击力·守备力直到回合结束时下降出现的数目×100。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DICE+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 限制效果只能在伤害计算前的时机发动或适用
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c126218.target)
	e1:SetOperation(c126218.activate)
	c:RegisterEffect(e1)
end
-- 效果处理时点
function c126218.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在表侧表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 设置连锁操作信息为投掷1次骰子
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
-- 效果处理时点
function c126218.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有表侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 投掷1次骰子并乘以100作为攻击力和守备力下降值
		local d=Duel.TossDice(tp,1)*100
		local sc=g:GetFirst()
		while sc do
			-- 将攻击力下降d数值
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e1:SetValue(-d)
			sc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_UPDATE_DEFENSE)
			sc:RegisterEffect(e2)
			sc=g:GetNext()
		end
	end
end

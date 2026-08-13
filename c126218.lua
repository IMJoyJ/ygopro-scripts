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
	-- 设置该效果只能在伤害步骤且伤害计算前发动（不能进入伤害计算后发动）。
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c126218.target)
	e1:SetOperation(c126218.activate)
	c:RegisterEffect(e1)
end
-- 效果发动时的合法性检查与操作信息登记：确认对方场上有表侧表示怪兽，并登记本次连锁将进行掷骰子处理。
function c126218.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性判定：若在检查阶段（chk==0），则要求对方场上有至少1只表侧表示怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 设置本次连锁的操作信息为掷骰子类别（CATEGORY_DICE），预计由玩家tp掷1次骰子。
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
-- 效果处理：获取对方场上全部表侧表示怪兽，若存在则掷1次骰子并将点数×100，使那些怪兽的攻击力·守备力直到回合结束时下降该数值。
function c126218.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有表侧表示怪兽的集合，作为下降攻击力·守备力的对象。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 由玩家tp掷1次骰子，将骰子点数乘以100，作为攻击力·守备力的下降量。
		local d=Duel.TossDice(tp,1)*100
		local sc=g:GetFirst()
		while sc do
			-- 对方场上的怪兽的攻击力直到回合结束时下降出现的数目×100。
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

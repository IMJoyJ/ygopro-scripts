--天使のサイコロ
-- 效果：
-- ①：掷1次骰子。自己场上的怪兽的攻击力·守备力直到回合结束时上升出现的数目×100。
function c74137509.initial_effect(c)
	-- ①：掷1次骰子。自己场上的怪兽的攻击力·守备力直到回合结束时上升出现的数目×100。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DICE+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置效果的发动条件为不在伤害计算后（限制在伤害步骤中的发动时机）
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c74137509.target)
	e1:SetOperation(c74137509.activate)
	c:RegisterEffect(e1)
end
-- 效果发动时的合法性检测与操作信息设置
function c74137509.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检测自己场上是否存在表侧表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	-- 设置操作信息，声明该效果包含掷1次骰子的处理
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
-- 效果处理的核心逻辑，执行掷骰子并对怪兽适用攻防上升效果
function c74137509.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前自己场上所有表侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
	if g:GetCount()>0 then
		-- 进行1次掷骰子，并记录掷出的结果
		local d=Duel.TossDice(tp,1)
		local sc=g:GetFirst()
		while sc do
			-- 自己场上的怪兽的攻击力...直到回合结束时上升出现的数目×100
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e1:SetValue(d*100)
			sc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_UPDATE_DEFENSE)
			sc:RegisterEffect(e2)
			sc=g:GetNext()
		end
	end
end

--パワー・インジェクター
-- 效果：
-- 支付600基本分发动。那个回合中场上表侧表示存在的全部念动力族怪兽的攻击力上升500。这个效果1回合只能使用1次。
function c89547299.initial_effect(c)
	-- 支付600基本分发动。那个回合中场上表侧表示存在的全部念动力族怪兽的攻击力上升500。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(89547299,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c89547299.atkcost)
	e1:SetTarget(c89547299.atktg)
	e1:SetOperation(c89547299.atkop)
	c:RegisterEffect(e1)
end
-- 发动成本（Cost）处理函数：检查并支付基本分
function c89547299.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查玩家是否能支付600点基本分
	if chk==0 then return Duel.CheckLPCost(tp,600) end
	-- 支付600点基本分
	Duel.PayLPCost(tp,600)
end
-- 过滤条件：场上表侧表示的念动力族怪兽
function c89547299.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_PSYCHO)
end
-- 发动条件与目标选择（Target）函数
function c89547299.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查双方场上是否存在至少1只表侧表示的念动力族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c89547299.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
end
-- 效果处理（Operation）函数：使场上所有表侧表示的念动力族怪兽攻击力上升
function c89547299.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方场上所有表侧表示的念动力族怪兽
	local g=Duel.GetMatchingGroup(c89547299.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		-- 那个回合中场上表侧表示存在的全部念动力族怪兽的攻击力上升500。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end

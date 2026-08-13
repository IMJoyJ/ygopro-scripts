--オーバー・コアリミット
-- 效果：
-- 只要这张卡在场上存在，自己场上表侧表示存在的名字带有「核成」的全部怪兽的攻击力上升500。此外，1回合1次，自己的主要阶段时可以从手卡丢弃1张「核成兽的钢核」，自己场上表侧表示存在的名字带有「核成」的全部怪兽的攻击力直到结束阶段时上升1000。
function c36560997.initial_effect(c)
	-- 将卡号36623431（核成兽的钢核）登记为这张卡记载的卡名，以便与「核成兽的钢核」相关的规则判定/检索能识别此卡。
	aux.AddCodeList(c,36623431)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上存在，自己场上表侧表示存在的名字带有「核成」的全部怪兽的攻击力上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	-- 设定该永续效果的作用对象为名字带有「核成」字段的怪兽（即只有这些怪兽会获得攻击力上升）。
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x1d))
	e2:SetValue(500)
	c:RegisterEffect(e2)
	-- 此外，1回合1次，自己的主要阶段时可以从手卡丢弃1张「核成兽的钢核」，自己场上表侧表示存在的名字带有「核成」的全部怪兽的攻击力直到结束阶段时上升1000。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(36560997,0))  --"攻击上升"
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCost(c36560997.atcost)
	e3:SetTarget(c36560997.attg)
	e3:SetOperation(c36560997.atop)
	c:RegisterEffect(e3)
end
-- 定义代价筛选函数：用于选择手卡中存在的「核成兽的钢核」（卡号36623431）且可以丢弃的卡。
function c36560997.cfilter(c)
	return c:IsCode(36623431) and c:IsDiscardable()
end
-- 定义发动代价函数：效果发动时从手卡丢弃1张「核成兽的钢核」作为代价；包含合法检查和实际丢弃处理。
function c36560997.atcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段（chk==0）：确认自己的手牌中是否存在至少1张可丢弃的「核成兽的钢核」，否则不能支付代价。
	if chk==0 then return Duel.IsExistingMatchingCard(c36560997.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 实际支付代价：从手卡选择1张「核成兽的钢核」丢弃（原因设为代价+丢弃）。
	Duel.DiscardHand(tp,c36560997.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 定义效果处理时的怪兽筛选函数：要求怪兽表侧表示且字段为「核成」（0x1d）。
function c36560997.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x1d)
end
-- 定义效果发动条件（目标检查）函数：发动时确认自己场上存在至少1只表侧表示的「核成」怪兽，否则不能发动。
function c36560997.attg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 目标检查阶段（chk==0）：确认自己的怪兽区存在至少1只表侧表示的「核成」怪兽，作为效果可发动的条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c36560997.filter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 定义效果处理函数：将自己场上所有表侧表示的「核成」怪兽的攻击力直到结束阶段上升1000。
function c36560997.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取己方场上所有满足条件的表侧表示「核成」怪兽，组成集合用于逐一附加攻击力上升效果。
	local g=Duel.GetMatchingGroup(c36560997.filter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 自己场上表侧表示存在的名字带有「核成」的全部怪兽的攻击力直到结束阶段时上升1000。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end

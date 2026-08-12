--オーバー・コアリミット
-- 效果：
-- 只要这张卡在场上存在，自己场上表侧表示存在的名字带有「核成」的全部怪兽的攻击力上升500。此外，1回合1次，自己的主要阶段时可以从手卡丢弃1张「核成兽的钢核」，自己场上表侧表示存在的名字带有「核成」的全部怪兽的攻击力直到结束阶段时上升1000。
function c36560997.initial_effect(c)
	-- 记录此卡与「核成兽的钢核」（卡号36623431）之间的关联
	aux.AddCodeList(c,36623431)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上存在，自己场上表侧表示存在的名字带有「核成」的全部怪兽的攻击力上升500
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	-- 设置效果目标为名字带有「核成」的怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x1d))
	e2:SetValue(500)
	c:RegisterEffect(e2)
	-- 1回合1次，自己的主要阶段时可以从手卡丢弃1张「核成兽的钢核」，自己场上表侧表示存在的名字带有「核成」的全部怪兽的攻击力直到结束阶段时上升1000
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
-- 过滤函数：判断手卡中是否存在可丢弃的「核成兽的钢核」
function c36560997.cfilter(c)
	return c:IsCode(36623431) and c:IsDiscardable()
end
-- 效果处理函数：检查是否满足丢弃条件并执行丢弃操作
function c36560997.atcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足丢弃条件
	if chk==0 then return Duel.IsExistingMatchingCard(c36560997.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 执行丢弃1张「核成兽的钢核」的操作
	Duel.DiscardHand(tp,c36560997.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤函数：判断场上是否存在表侧表示的「核成」怪兽
function c36560997.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x1d)
end
-- 效果处理函数：检查是否满足发动条件
function c36560997.attg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在表侧表示的「核成」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c36560997.filter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 效果处理函数：为符合条件的「核成」怪兽在结束阶段时增加1000攻击力
function c36560997.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取场上所有表侧表示的「核成」怪兽
	local g=Duel.GetMatchingGroup(c36560997.filter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 为怪兽增加1000攻击力并在结束阶段时重置
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end

--サンダー・ボトル
-- 效果：
-- 每次自己场上存在的怪兽攻击宣言，给这张卡放置1个雷指示物。可以把有雷指示物4个以上放置的这张卡送去墓地，对方场上存在的怪兽全部破坏。
function c11741041.initial_effect(c)
	c:EnableCounterPermit(0xc)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 创建效果e2，类型为字段永续效果，在攻击宣言时触发，调用c11741041.ctop函数。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(c11741041.ctop)
	c:RegisterEffect(e2)
	-- 创建效果e3，描述为“破坏”，类别为破坏效果，类型为快速响应效果，在自由连锁时可以发动，生效范围为魔陷区，条件是c11741041.descon函数返回真值，所需费用由c11741041.descost函数处理，目标卡由c11741041.destg函数确定，效果执行由c11741041.desop函数处理。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(11741041,0))  --"破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c11741041.descon)
	e3:SetCost(c11741041.descost)
	e3:SetTarget(c11741041.destg)
	e3:SetOperation(c11741041.desop)
	c:RegisterEffect(e3)
end
c11741041.mentioned_counter={
	[0xc]=true,
}
-- 该函数在攻击宣言时触发，如果攻击者是当前回合玩家则给这张卡增加一个雷指示物。
function c11741041.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查攻击者是否为当前回合的行动者（tp）。
	if Duel.GetAttacker():IsControler(tp) then
		e:GetHandler():AddCounter(0xc,1)
	end
end
-- 该函数判断是否满足发动效果的条件，即雷指示物的数量是否大于等于4。
function c11741041.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCounter(0xc)>=4
end
-- 该函数处理发动效果所需的费用，如果chk为0则返回卡片是否可以作为费用送去墓地，否则将这张卡送去墓地。
function c11741041.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将效果的发动者（c）以REASON_COST的原因送去墓地。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 该函数确定破坏效果的目标，如果chk为0则检查对方场上是否存在怪兽，否则获取所有对方场上的怪兽并设置操作信息。
function c11741041.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在确认目标前，检查对方怪兽区是否有卡片存在。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有的怪兽。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 设置当前处理的连锁的操作信息，类别为破坏效果，目标为所有对方场上的怪兽，数量为对方场上怪兽的数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 该函数执行破坏效果，获取所有对方场上的怪兽并进行破坏。
function c11741041.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有的怪兽。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 以REASON_EFFECT的原因破坏目标怪兽。
	Duel.Destroy(g,REASON_EFFECT)
end

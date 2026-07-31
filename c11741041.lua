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
	-- 每次自己场上存在的怪兽攻击宣言，给这张卡放置 1 个雷指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(c11741041.ctop)
	c:RegisterEffect(e2)
	-- 可以把有雷指示物 4 个以上放置的这张卡送去墓地，对方场上存在的怪兽全部破坏。
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
-- 效果 e2 的操作处理函数定义：当攻击宣言触发时执行的具体逻辑代码块，用于在满足条件时为怪兽添加指示物。
function c11741041.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查此次攻击怪兽是否由当前玩家控制。
	if Duel.GetAttacker():IsControler(tp) then
		e:GetHandler():AddCounter(0xc,1)
	end
end
-- 效果 e3 的发动条件函数定义：用于判断这张卡上的雷指示物数量是否满足发动要求（>=4）。
function c11741041.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCounter(0xc)>=4
end
-- 效果 e3 的代价函数定义：包含检查能否支付代价及执行将卡片送入墓地的逻辑。
function c11741041.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 以 REASON_COST 原因将这张卡从场上送入墓地，完成效果 e3 的发动代价支付。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 效果 e3 的目标函数定义：用于检查对方场上是否存在怪兽并设置操作信息以便后续破坏处理。
function c11741041.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 目标选择函数的条件判断部分，确认对方场上至少存在一张怪兽卡以作为破坏对象。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 检索对方场上的所有怪兽组，用于后续的目标处理或操作信息设置。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 为效果 e3 的后续处理设置操作信息，明确本次效果的分类及作用对象。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果 e3 的实际执行函数定义：在连锁处理后检索目标并执行破坏操作的逻辑块。
function c11741041.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 在执行操作时再次检索对方场上的所有怪兽组，确保处理的是当前状态下的有效对象。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 以 REASON_EFFECT 原因破坏检索到的怪兽组，完成效果 e3 的最终结算步骤。
	Duel.Destroy(g,REASON_EFFECT)
end

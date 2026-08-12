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
	-- 每次自己场上存在的怪兽攻击宣言，给这张卡放置1个雷指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(c11741041.ctop)
	c:RegisterEffect(e2)
	-- 可以把有雷指示物4个以上放置的这张卡送去墓地，对方场上存在的怪兽全部破坏。
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
-- 攻击宣言时触发的持续效果：若进行攻击的怪兽由自己控制，则给这张卡放置1个雷指示物
function c11741041.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断此次攻击宣言的怪兽是否由自己控制（即是否为自己场上的怪兽进行的攻击宣言）
	if Duel.GetAttacker():IsControler(tp) then
		e:GetHandler():AddCounter(0xc,1)
	end
end
-- 发动条件：检查这张卡上放置的雷指示物是否在4个以上
function c11741041.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCounter(0xc)>=4
end
-- 发动代价：确认这张卡能够送去墓地，然后将其送去墓地作为代价
function c11741041.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 把这张卡作为代价送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 目标设定：确认对方场上存在怪兽，把对方场上全部怪兽列入破坏的操作信息
function c11741041.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方主要怪兽区域是否存在至少1只怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方主要怪兽区域的全部怪兽，作为破坏的目标组
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 设置操作信息：宣告本次连锁将破坏对方场上的全部这些怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果处理：重新获取对方场上的全部怪兽，并将其全部破坏
function c11741041.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方主要怪兽区域当前存在的全部怪兽
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 将这组怪兽全部以效果破坏
	Duel.Destroy(g,REASON_EFFECT)
end

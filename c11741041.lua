--サンダー・ボトル
-- 效果：
-- 每次自己场上存在的怪兽攻击宣言，给这张卡放置1个雷指示物。可以把有雷指示物4个以上放置的这张卡送去墓地，对方场上存在的怪兽全部破坏。
function c11741041.initial_effect(c)
	c:EnableCounterPermit(0xc)
	-- 发动时点设置为自由时点，可以随时发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 每次自己场上存在的怪兽攻击宣言，给这张卡放置1个雷指示物
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(c11741041.ctop)
	c:RegisterEffect(e2)
	-- 可以把有雷指示物4个以上放置的这张卡送去墓地，对方场上存在的怪兽全部破坏
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
-- 攻击宣言时触发的效果处理函数
function c11741041.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断攻击怪兽是否为自己的怪兽
	if Duel.GetAttacker():IsControler(tp) then
		e:GetHandler():AddCounter(0xc,1)
	end
end
-- 破坏效果发动的条件判断函数
function c11741041.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetCounter(0xc)>=4
end
-- 破坏效果的费用支付函数
function c11741041.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将自身送去墓地作为破坏效果的费用
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 破坏效果的目标选择函数
function c11741041.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1只怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有怪兽作为破坏目标
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 设置连锁操作信息，确定破坏效果影响的怪兽数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏效果的执行函数
function c11741041.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有怪兽作为破坏目标
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	-- 将对方场上所有怪兽破坏
	Duel.Destroy(g,REASON_EFFECT)
end

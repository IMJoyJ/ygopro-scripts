--暴君の威圧
-- 效果：
-- 把自己场上存在的1只怪兽解放发动。只要这张卡在场上存在，场上表侧表示存在的原本持有者是自己的怪兽不受这张卡以外的陷阱卡的效果影响。
function c4638410.initial_effect(c)
	-- 把自己场上存在的1只怪兽解放发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c4638410.cost)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上存在，场上表侧表示存在的原本持有者是自己的怪兽不受这张卡以外的陷阱卡的效果影响
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c4638410.etarget)
	e2:SetValue(c4638410.efilter)
	c:RegisterEffect(e2)
end
-- 检查并选择1张满足条件的己方怪兽进行解放作为发动代价
function c4638410.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测是否满足解放条件
	if chk==0 then return Duel.CheckReleaseGroup(tp,nil,1,nil) end
	-- 选择1张符合条件的己方怪兽
	local rg=Duel.SelectReleaseGroup(tp,nil,1,1,nil)
	-- 将选中的怪兽以支付代价的方式进行解放
	Duel.Release(rg,REASON_COST)
end
-- 设定效果目标为原本持有者为自己场上的怪兽
function c4638410.etarget(e,c)
	return c:GetOwner()==e:GetHandlerPlayer()
end
-- 设定效果值为排除自身外的陷阱卡效果
function c4638410.efilter(e,te)
	return te:IsActiveType(TYPE_TRAP) and te:GetOwner()~=e:GetOwner()
end

--暴君の威圧
-- 效果：
-- 把自己场上存在的1只怪兽解放发动。只要这张卡在场上存在，场上表侧表示存在的原本持有者是自己的怪兽不受这张卡以外的陷阱卡的效果影响。
function c4638410.initial_effect(c)
	-- 把自己场上存在的1只怪兽解放发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c4638410.cost)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上存在，场上表侧表示存在的原本持有者是自己的怪兽不受这张卡以外的陷阱卡的效果影响。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c4638410.etarget)
	e2:SetValue(c4638410.efilter)
	c:RegisterEffect(e2)
end
-- 此函数的整体作用是处理发动代价：检查自己场上是否有可解放的怪兽，选择1只并将其解放作为发动代价。
function c4638410.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在代价确认阶段，检查自己场上是否存在至少1只可解放的怪兽，以满足解放1只怪兽的发动代价。
	if chk==0 then return Duel.CheckReleaseGroup(tp,nil,1,nil) end
	-- 从自己场上选择1只可解放的怪兽，用于解放作为发动代价。
	local rg=Duel.SelectReleaseGroup(tp,nil,1,1,nil)
	-- 将选择的怪兽解放，支付发动代价（REASON_COST）。
	Duel.Release(rg,REASON_COST)
end
-- 作为免疫效果的适用对象判定：仅当怪兽的原本持有者是这张卡的控制者（自己）时，该怪兽才享受免疫保护。
function c4638410.etarget(e,c)
	return c:GetOwner()==e:GetHandlerPlayer()
end
-- 作为免疫效果的判定条件：被检测的效果来源卡片不是本卡（暴君的威压）时，且该效果为陷阱卡效果，则使其免疫生效。
function c4638410.efilter(e,te)
	return te:IsActiveType(TYPE_TRAP) and te:GetOwner()~=e:GetOwner()
end

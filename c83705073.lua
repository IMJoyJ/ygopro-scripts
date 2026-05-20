--ワルキューレ・エルダ
-- 效果：
-- ①：「女武神·埃尔达」在自己场上只能有1只表侧表示存在。
-- ②：只要「女武神」卡的效果特殊召唤的这张卡在怪兽区域存在，对方场上的怪兽的攻击力下降1000。
-- ③：只要这张卡在怪兽区域存在，被战斗·效果破坏送去对方墓地的卡不去墓地而除外。
function c83705073.initial_effect(c)
	c:SetUniqueOnField(1,0,83705073)
	-- ②：只要「女武神」卡的效果特殊召唤的这张卡在怪兽区域存在，对方场上的怪兽的攻击力下降1000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c83705073.atkcon)
	e1:SetOperation(c83705073.atkop)
	c:RegisterEffect(e1)
	-- ③：只要这张卡在怪兽区域存在，被战斗·效果破坏送去对方墓地的卡不去墓地而除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(LOCATION_REMOVED)
	e2:SetTarget(c83705073.rmtg)
	c:RegisterEffect(e2)
end
-- 检查特殊召唤此卡的效果是否属于「女武神」卡片的效果
function c83705073.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return re and re:GetHandler():IsSetCard(0x122)
end
-- 在特殊召唤成功时，为自身注册使对方场上怪兽攻击力下降1000的永续效果
function c83705073.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 对方场上的怪兽的攻击力下降1000
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetDescription(aux.Stringid(83705073,0))  --"「女武神」卡的效果特殊召唤"
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetValue(-1000)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
end
-- 筛选因战斗或效果破坏而送去对方墓地的卡片
function c83705073.rmtg(e,c)
	return c:GetOwner()~=e:GetHandlerPlayer() and c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end

--闇よりの罠
-- 效果：
-- ①：自己基本分是3000以下时，支付1000基本分，以「黑暗中的陷阱」以外的自己墓地1张通常陷阱卡为对象才能发动。这张卡的效果变成和那张墓地的通常陷阱卡发动时的效果相同。那之后，那张墓地的通常陷阱卡除外。
function c79766336.initial_effect(c)
	-- ①：自己基本分是3000以下时，支付1000基本分，以「黑暗中的陷阱」以外的自己墓地1张通常陷阱卡为对象才能发动。这张卡的效果变成和那张墓地的通常陷阱卡发动时的效果相同。那之后，那张墓地的通常陷阱卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0x1e1,0x1e1)
	e1:SetCondition(c79766336.condition)
	e1:SetCost(c79766336.cost)
	e1:SetTarget(c79766336.target)
	e1:SetOperation(c79766336.operation)
	c:RegisterEffect(e1)
end
-- 发动条件判定
function c79766336.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己基本分是否在3000以下
	return Duel.GetLP(tp)<=3000
end
-- 发动代价（Cost）处理
function c79766336.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己是否能支付1000基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 支付1000基本分
	Duel.PayLPCost(tp,1000)
end
-- 过滤墓地中满足条件的通常陷阱卡（非同名卡、可除外、可发动其效果）
function c79766336.filter(c)
	return c:GetType()==0x4 and not c:IsCode(79766336,22628574,6351147) and c:IsAbleToRemove() and c:CheckActivateEffect(false,true,false)~=nil
end
-- 发动时的效果处理（Target）
function c79766336.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		local te=e:GetLabelObject()
		local tg=te:GetTarget()
		return tg and tg(e,tp,eg,ep,ev,re,r,rp,0,chkc)
	end
	-- 检查墓地是否存在符合条件的可选择对象
	if chk==0 then return Duel.IsExistingTarget(c79766336.filter,tp,LOCATION_GRAVE,0,1,nil) end
	e:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择墓地1张符合条件的通常陷阱卡作为对象
	local g=Duel.SelectTarget(tp,c79766336.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	local te,ceg,cep,cev,cre,cr,crp=g:GetFirst():CheckActivateEffect(false,true,true)
	-- 清除当前连锁的对象卡片（因为复制效果时，原卡片并不作为当前效果的直接对象，而是通过复制其效果来处理）
	Duel.ClearTargetCard()
	g:GetFirst():CreateEffectRelation(e)
	local tg=te:GetTarget()
	e:SetProperty(te:GetProperty())
	if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	-- 清除当前连锁的操作信息，防止被其他卡片直接响应
	Duel.ClearOperationInfo(0)
end
-- 效果处理（Operation）
function c79766336.operation(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te then return end
	local tc=te:GetHandler()
	if not (tc:IsRelateToEffect(e) and tc:GetType()==TYPE_TRAP) then return end
	e:SetLabelObject(te:GetLabelObject())
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
	if tc:IsRelateToEffect(e) and tc:GetType()==TYPE_TRAP then
		-- 中断当前效果处理，使后续的除外处理与前面的效果复制不视为同时处理
		Duel.BreakEffect()
		-- 将作为对象的墓地通常陷阱卡表侧表示除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end

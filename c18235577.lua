--寂々虫
-- 效果：
-- 把这张卡从手卡送去墓地发动。场上存在的1只怪兽的等级直到结束阶段时下降1星。
function c18235577.initial_effect(c)
	-- 效果原文内容：把这张卡从手卡送去墓地发动。场上存在的1只怪兽的等级直到结束阶段时下降1星。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(18235577,0))  --"等级下降"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c18235577.lvcost)
	e1:SetTarget(c18235577.lvtg)
	e1:SetOperation(c18235577.lvop)
	c:RegisterEffect(e1)
end
-- 规则层面操作：检查是否可以支付将此卡送去墓地的费用
function c18235577.lvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 规则层面操作：将此卡送去墓地作为费用
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 规则层面操作：定义可选择的目标怪兽必须表侧表示且等级至少为2
function c18235577.lvfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(2)
end
-- 规则层面操作：选择场上一只符合条件的怪兽作为目标
function c18235577.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c18235577.lvfilter(chkc) end
	-- 规则层面操作：判断是否存在符合条件的怪兽目标
	if chk==0 then return Duel.IsExistingTarget(c18235577.lvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 规则层面操作：提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 规则层面操作：选择一只表侧表示且等级至少为2的怪兽作为目标
	Duel.SelectTarget(tp,c18235577.lvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 规则层面操作：为选中的怪兽在结束阶段时降低1星等级
function c18235577.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 效果原文内容：场上存在的1只怪兽的等级直到结束阶段时下降1星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(-1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end

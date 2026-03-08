--騒々虫
-- 效果：
-- 把这张卡从手卡送去墓地发动。场上存在的1只怪兽的等级直到结束阶段时上升1星。
function c45620686.initial_effect(c)
	-- 把这张卡从手卡送去墓地发动。场上存在的1只怪兽的等级直到结束阶段时上升1星。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45620686,0))  --"等级上升"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c45620686.lvcost)
	e1:SetTarget(c45620686.lvtg)
	e1:SetOperation(c45620686.lvop)
	c:RegisterEffect(e1)
end
-- 检查自身是否可以作为cost送去墓地
function c45620686.lvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将自身送去墓地作为cost
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 筛选条件：怪兽必须表侧表示且等级大于等于0
function c45620686.lvfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(0)
end
-- 选择场上1只符合条件的怪兽作为效果对象
function c45620686.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c45620686.lvfilter(chkc) end
	-- 判断场上是否存在1只符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c45620686.lvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只符合条件的怪兽作为效果对象
	Duel.SelectTarget(tp,c45620686.lvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 将选择的怪兽等级上升1星直到结束阶段
function c45620686.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 等级上升1星
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end

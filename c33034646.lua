--機甲忍者フレイム
-- 效果：
-- 这张卡召唤·反转召唤·特殊召唤成功时，选择自己场上1只名字带有「忍者」的怪兽才能发动。选择的怪兽的等级上升1星。
function c33034646.initial_effect(c)
	-- 这张卡通常召唤成功时，选择自己场上1只名字带有「忍者」的怪兽才能发动。选择的怪兽的等级上升1星。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(33034646,0))  --"等级上升"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c33034646.target)
	e1:SetOperation(c33034646.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 筛选场上表侧表示且等级高于1的「忍者」怪兽
function c33034646.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(1) and c:IsSetCard(0x2b)
end
-- 选择满足条件的怪兽作为效果对象
function c33034646.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c33034646.filter(chkc) end
	-- 检查是否有满足条件的怪兽存在
	if chk==0 then return Duel.IsExistingTarget(c33034646.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择1只满足条件的怪兽作为效果对象
	Duel.SelectTarget(tp,c33034646.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 将选择的怪兽等级上升1星
function c33034646.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 使目标怪兽的等级上升1星
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(1)
		tc:RegisterEffect(e1)
	end
end

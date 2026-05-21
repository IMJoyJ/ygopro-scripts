--リビングデッドの呼び声
-- 效果：
-- ①：以自己墓地1只怪兽为对象才能把这张卡发动。那只怪兽攻击表示特殊召唤。这张卡从场上离开时那只怪兽破坏。那只怪兽破坏时这张卡破坏。
function c97077563.initial_effect(c)
	-- ①：以自己墓地1只怪兽为对象才能把这张卡发动。那只怪兽攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c97077563.target)
	e1:SetOperation(c97077563.operation)
	c:RegisterEffect(e1)
	-- 这张卡从场上离开时那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_LEAVE_FIELD_P)
	e2:SetOperation(c97077563.checkop)
	c:RegisterEffect(e2)
	-- 这张卡从场上离开时那只怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetOperation(c97077563.desop)
	e3:SetLabelObject(e2)
	c:RegisterEffect(e3)
	-- 那只怪兽破坏时这张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetCondition(c97077563.descon2)
	e4:SetOperation(c97077563.desop2)
	c:RegisterEffect(e4)
end
-- 过滤自己墓地可以表侧攻击表示特殊召唤的怪兽
function c97077563.filter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 效果处理时对已选择的对象进行合法性检查（是否仍在墓地且仍可特殊召唤）
function c97077563.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp)
		and chkc:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 检查发动时自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在符合条件的、可以作为效果对象的怪兽
		and Duel.IsExistingTarget(c97077563.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 给玩家发送提示信息，提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只符合条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c97077563.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置当前连锁的操作信息，表示该效果包含特殊召唤1张卡的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：将选择的墓地怪兽特殊召唤，并将该怪兽与这张卡建立对象关联
function c97077563.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选择为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e)
		-- 尝试将目标怪兽以表侧攻击表示特殊召唤（分解步骤）
		and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK) then
		c:SetCardTarget(tc)
	end
	-- 完成特殊召唤的处理
	Duel.SpecialSummonComplete()
end
-- 在卡片即将离场前，检查其效果是否被无效，并用Label记录状态
function c97077563.checkop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsDisabled() then
		e:SetLabel(1)
	else e:SetLabel(0) end
end
-- 当这张卡从场上离开时，如果未被无效，则破坏作为其对象的怪兽
function c97077563.desop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabelObject():GetLabel()~=0 then return end
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		-- 因效果破坏作为对象的怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 检查被破坏的卡中是否包含作为这张卡对象的怪兽，作为这张卡破坏效果的发动条件
function c97077563.descon2(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and eg:IsContains(tc) and tc:IsReason(REASON_DESTROY)
end
-- 当作为对象的怪兽被破坏时，执行破坏这张卡的操作
function c97077563.desop2(e,tp,eg,ep,ev,re,r,rp)
	-- 因效果破坏这张卡自身
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end

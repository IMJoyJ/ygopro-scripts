--ヴェノム・スプラッシュ
-- 效果：
-- 选择1只放置有毒指示物的怪兽发动。把那张卡的毒指示物取除，给与对方基本分取除的毒指示物数量×700的数值的伤害。
function c4466015.initial_effect(c)
	-- 选择1只放置有毒指示物的怪兽发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c4466015.target)
	e1:SetOperation(c4466015.activate)
	c:RegisterEffect(e1)
end
c4466015.mentioned_counter={
	[0x1009]=true,
}
-- 定义过滤器，用于判断目标怪兽是否具有毒指示物。
function c4466015.filter(c)
	return c:GetCounter(0x1009)>0
end
-- 设置效果的目标选择逻辑，确保选择的是场上的带有毒指示物的怪兽。
function c4466015.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c4466015.filter(chkc) end
	-- 检查是否有满足条件的目标怪兽存在。
	if chk==0 then return Duel.IsExistingTarget(c4466015.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家发送提示信息，要求选择表侧表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择符合条件的1只怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c4466015.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息，指定将对对方造成伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetFirst():GetCounter(0x1009)*700)
end
-- 把那张卡的毒指示物取除，给与对方基本分取除的毒指示物数量×700的数值的伤害。
function c4466015.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽。
	local tc=Duel.GetFirstTarget()
	local ct=tc:GetCounter(0x1009)
	if ct>0 then
		tc:RemoveCounter(tp,0x1009,ct,REASON_EFFECT)
		-- 对对方玩家造成与取除毒指示物数量相对应的伤害值。
		Duel.Damage(1-tp,ct*700,REASON_EFFECT)
	end
end

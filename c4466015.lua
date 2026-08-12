--ヴェノム・スプラッシュ
-- 效果：
-- 选择1只放置有毒指示物的怪兽发动。把那张卡的毒指示物取除，给与对方基本分取除的毒指示物数量×700的数值的伤害。
function c4466015.initial_effect(c)
	-- 选择1只放置有毒指示物的怪兽发动。把那张卡的毒指示物取除，给与对方基本分取除的毒指示物数量×700的数值的伤害。
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
-- 对象过滤器：判断该卡上是否放置有1个以上的毒指示物。
function c4466015.filter(c)
	return c:GetCounter(0x1009)>0
end
-- 目标函数：确认场上存在可成为对象的带毒指示物的怪兽，提示并选择1只作为效果对象，同时设置伤害分类的操作信息。
function c4466015.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c4466015.filter(chkc) end
	-- 发动条件检查：双方主要怪兽区是否存在至少1只放置有毒指示物、可成为此效果对象的怪兽。
	if chk==0 then return Duel.IsExistingTarget(c4466015.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向发动玩家发送选择提示：请选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让发动玩家选择1只放置有毒指示物的怪兽作为此效果的对象。
	local g=Duel.SelectTarget(tp,c4466015.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息：分类为伤害效果，预计给与对方的伤害数值为目标怪兽的毒指示物数量×700。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetFirst():GetCounter(0x1009)*700)
end
-- 效果处理函数：取得对象怪兽及其毒指示物数量，取除全部毒指示物，并按取除数量×700给与对方基本分伤害。
function c4466015.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的效果对象怪兽。
	local tc=Duel.GetFirstTarget()
	local ct=tc:GetCounter(0x1009)
	if ct>0 then
		tc:RemoveCounter(tp,0x1009,ct,REASON_EFFECT)
		-- 给与对方基本分取除的毒指示物数量×700的数值的伤害。
		Duel.Damage(1-tp,ct*700,REASON_EFFECT)
	end
end

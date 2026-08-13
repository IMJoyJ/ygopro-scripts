--墓守の暗殺者
-- 效果：
-- 「王家长眠之谷」在场上表侧表示存在时效果才能发动。这张卡攻击宣言时，可以变更对方场上存在的一只表侧表示怪兽的表示形式。
function c25262697.initial_effect(c)
	-- 「王家长眠之谷」在场上表侧表示存在时效果才能发动。这张卡攻击宣言时，可以变更对方场上存在的一只表侧表示怪兽的表示形式。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25262697,0))  --"改变表示形式"
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c25262697.poscon)
	e1:SetTarget(c25262697.postg)
	e1:SetOperation(c25262697.posop)
	c:RegisterEffect(e1)
end
-- 发动条件判定：检查当前场上是否存在表侧表示且效果适用的「王家长眠之谷」（卡号47355498）。
function c25262697.poscon(e,tp,eg,ep,ev,re,r,rp)
	-- 调用Duel.IsEnvironment检测场上是否有效果适用的「王家长眠之谷」，作为效果能否发动的条件。
	return Duel.IsEnvironment(47355498)
end
-- 选择对象的过滤函数：对象必须为表侧表示怪兽，且能够被效果改变表示形式。
function c25262697.filter(c)
	return c:IsFaceup() and c:IsCanChangePosition()
end
-- 效果发动时的目标选择处理：确认对象为对方场上表侧表示且可变更表示形式的怪兽，从对方怪兽区域选择1只作为效果对象，并设置操作信息。
function c25262697.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c25262697.filter(chkc) end
	-- 效果发动合法性检查：确认对方场上存在至少1只满足过滤条件且能成为效果对象的表侧表示怪兽。
	if chk==0 then return Duel.IsExistingTarget(c25262697.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向操作玩家显示选择提示消息，提示内容为“请选择要改变表示形式的怪兽”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 让玩家从对方场上的表侧表示怪兽中选择1只满足条件的怪兽作为效果对象，并自动登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c25262697.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置本次连锁的处理信息：本效果属于改变表示形式类效果，处理对象为已选择的怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 效果处理时的操作：取得效果对象，若对象仍表侧表示且与效果存在关联，则变更其表示形式（表侧攻击↔表侧守备）。
function c25262697.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中登记的第一张对象卡（即被选择变更表示形式的对方怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 将对象怪兽的表示形式在表侧攻击表示和表侧守备表示之间切换。注意：若原是表侧攻击则变为表侧守备；若原是表侧守备则变为表侧攻击。
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,0,POS_FACEUP_ATTACK,0)
	end
end

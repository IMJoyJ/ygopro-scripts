--ティンダングル・ハウンド
-- 效果：
-- ①：这张卡反转的场合，以这张卡以外的场上1只表侧表示怪兽为对象才能发动。这张卡的攻击力上升作为对象的怪兽的原本攻击力数值。那之后，作为对象的怪兽变成里侧守备表示。
-- ②：对方场上的怪兽的攻击力下降和那怪兽成为连接状态的怪兽数量×1000。
-- ③：这张卡被战斗·效果破坏送去墓地的场合，以场上1只里侧表示怪兽为对象才能发动。那只怪兽变成表侧守备表示。
function c31759689.initial_effect(c)
	-- ①：这张卡反转的场合，以这张卡以外的场上1只表侧表示怪兽为对象才能发动。这张卡的攻击力上升作为对象的怪兽的原本攻击力数值。那之后，作为对象的怪兽变成里侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31759689,0))
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_ATKCHANGE+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c31759689.target)
	e1:SetOperation(c31759689.operation)
	c:RegisterEffect(e1)
	-- ②：对方场上的怪兽的攻击力下降和那怪兽成为连接状态的怪兽数量×1000。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(c31759689.val)
	c:RegisterEffect(e2)
	-- ③：这张卡被战斗·效果破坏送去墓地的场合，以场上1只里侧表示怪兽为对象才能发动。那只怪兽变成表侧守备表示。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(31759689,1))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCategory(CATEGORY_POSITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c31759689.poscon)
	e3:SetTarget(c31759689.postg)
	e3:SetOperation(c31759689.posop)
	c:RegisterEffect(e3)
end
-- ①的取对象筛选：必须是场上表侧表示、可以变成里侧守备表示、且原本攻击力大于0的怪兽。
function c31759689.filter(c)
	return c:IsFaceup() and c:IsCanTurnSet() and c:GetBaseAttack()>0
end
-- ①的发动时点处理：从双方场上选择1只满足filter且不是发动者自身的表侧表示怪兽作为效果对象。
function c31759689.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c31759689.filter(chkc) end
	-- 发动合法性检查：确认场上是否存在满足filter且不是发动者自身的表侧表示怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c31759689.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
	-- 向操作者显示选择效果对象的消息提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让操作者从双方场上选择1只满足filter且不是发动者的怪兽，并记录为当前连锁的对象。
	Duel.SelectTarget(tp,c31759689.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetHandler())
end
-- ①效果处理：若本卡仍表侧且对象仍关联，先获取对象原本攻击力为本卡附加攻击力上升效果；然后中断处理，最后将对象变为里侧守备表示。
function c31759689.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得①效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and c:IsRelateToEffect(e) and c:IsFaceup() then
		local atk=tc:GetBaseAttack()
		-- 这张卡的攻击力上升作为对象的怪兽的原本攻击力数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
		-- 中断当前效果处理，使“攻击力上升”和“变成里侧守备表示”不在同一时点处理，以符合“那之后”的先后顺序。
		Duel.BreakEffect()
		-- 将作为对象的怪兽变成里侧守备表示。
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
-- 判断两张怪兽是否互为连接状态（一方在另一方的连接区中），用于②的数量计算。
function c31759689.atkfilter(c,ec)
	return (c:GetLinkedGroup() and c:GetLinkedGroup():IsContains(ec)) or (ec:GetLinkedGroup() and ec:GetLinkedGroup():IsContains(c))
end
-- ②的攻击力下降值计算：统计与当前对方怪兽存在连接状态的怪兽数量，乘以-1000作为下降值（返回负数）。
function c31759689.val(e,c)
	-- 统计场上与当前怪兽存在连接状态的怪兽总数量，乘以-1000作为攻击力下降值。
	return Duel.GetMatchingGroupCount(c31759689.atkfilter,0,LOCATION_MZONE,LOCATION_MZONE,c,c)*-1000
end
-- ③的发动条件：这张卡被战斗或效果破坏并被送去墓地。
function c31759689.poscon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- ③的取对象筛选：场上里侧表示且可以改变表示形式的怪兽。
function c31759689.posfilter(c)
	return c:IsFacedown() and c:IsCanChangePosition()
end
-- ③的发动时点处理：从双方场上选择1只里侧表示且可改变表示形式的怪兽作为效果对象。
function c31759689.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c31759689.posfilter(chkc) end
	-- 发动合法性检查：确认场上是否存在满足posfilter的里侧表示怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c31759689.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向操作者显示选择要改变表示形式的怪兽的消息提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 让操作者从双方场上选择1只里侧表示且可改变表示形式的怪兽，并记录为当前连锁的对象。
	Duel.SelectTarget(tp,c31759689.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- ③效果处理：若对象仍与效果关联且不是表侧守备表示，则将其变成表侧守备表示。
function c31759689.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得③效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and not tc:IsPosition(POS_FACEUP_DEFENSE) then
		-- 将对象怪兽变成表侧守备表示。
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)
	end
end

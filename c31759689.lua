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
-- 过滤函数，返回满足条件的怪兽：表侧表示、可以变为里侧表示、原本攻击力大于0
function c31759689.filter(c)
	return c:IsFaceup() and c:IsCanTurnSet() and c:GetBaseAttack()>0
end
-- 效果处理函数，设置效果目标为满足条件的怪兽
function c31759689.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c31759689.filter(chkc) end
	-- 判断是否满足发动条件：场上存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c31759689.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择满足条件的怪兽作为效果对象
	Duel.SelectTarget(tp,c31759689.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetHandler())
end
-- 效果处理函数，将目标怪兽的攻击力加到自身，并将目标怪兽变为里侧守备表示
function c31759689.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and c:IsRelateToEffect(e) and c:IsFaceup() then
		local atk=tc:GetBaseAttack()
		-- 创建一个攻击力变更效果，使自身攻击力增加目标怪兽的原本攻击力
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
		-- 中断当前效果，使后续处理不同时进行
		Duel.BreakEffect()
		-- 将目标怪兽变为里侧守备表示
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
-- 过滤函数，判断两个怪兽是否连接
function c31759689.atkfilter(c,ec)
	return (c:GetLinkedGroup() and c:GetLinkedGroup():IsContains(ec)) or (ec:GetLinkedGroup() and ec:GetLinkedGroup():IsContains(c))
end
-- 效果处理函数，计算对方场上连接怪兽数量并乘以-1000作为攻击力变更值
function c31759689.val(e,c)
	-- 获取对方场上连接怪兽数量并乘以-1000
	return Duel.GetMatchingGroupCount(c31759689.atkfilter,0,LOCATION_MZONE,LOCATION_MZONE,c,c)*-1000
end
-- 效果发动条件函数，判断此卡是否因战斗或效果破坏而送去墓地
function c31759689.poscon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- 过滤函数，返回满足条件的怪兽：里侧表示、可以改变表示形式
function c31759689.posfilter(c)
	return c:IsFacedown() and c:IsCanChangePosition()
end
-- 效果处理函数，设置效果目标为满足条件的怪兽
function c31759689.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c31759689.posfilter(chkc) end
	-- 判断是否满足发动条件：场上存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c31759689.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择满足条件的怪兽作为效果对象
	Duel.SelectTarget(tp,c31759689.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果处理函数，将目标怪兽变为表侧守备表示
function c31759689.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and not tc:IsPosition(POS_FACEUP_DEFENSE) then
		-- 将目标怪兽变为表侧守备表示
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)
	end
end

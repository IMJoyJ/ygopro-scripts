--No.102 光天使グローリアス・ヘイロー
-- 效果：
-- 光属性4星怪兽×3
-- ①：1回合1次，把这张卡1个超量素材取除，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力变成一半，效果无效化。
-- ②：场上的这张卡被战斗·效果破坏的场合，可以作为代替把这张卡的超量素材全部取除。这个效果适用的回合，自己受到的战斗伤害变成一半。
function c49678559.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续，素材要求为光属性4星怪兽3只。
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_LIGHT),4,3)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力变成一半，效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(49678559,0))  --"效果无效"
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c49678559.cost)
	e1:SetTarget(c49678559.target)
	e1:SetOperation(c49678559.operation)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡被战斗·效果破坏的场合，可以作为代替把这张卡的超量素材全部取除。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c49678559.reptg)
	c:RegisterEffect(e2)
end
-- 将这张卡的XYZ编号设定为102，用于与No.相关卡和效果的互动。
aux.xyz_number[49678559]=102
-- ①效果发动时，检查并执行从这张卡上取除1个超量素材作为发动代价。
function c49678559.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 定义效果对象的选择条件：对方场上的表侧表示怪兽。
function c49678559.filter(c)
	return c:IsFaceup()
end
-- ①效果发动时的取对象处理和操作信息设置：选择对方场上1只表侧表示怪兽为对象，并设置无效化效果的处理信息。
function c49678559.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c49678559.filter(chkc) end
	-- 发动合法性检查：对方场上是否存在1只表侧表示怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c49678559.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家展示选择提示，要求选择表侧表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 玩家选择对方场上1只表侧表示怪兽作为①效果的对象。
	local g=Duel.SelectTarget(tp,c49678559.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置本次连锁的操作信息为“无效化”，对象为刚选择的怪兽，供其他卡/效果检测。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- ①效果处理时，若对象怪兽仍在场上且与效果关联，则使其攻击力变成一半，并将其效果无效化。
function c49678559.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取①效果的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽的攻击力变成一半。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(math.ceil(tc:GetAttack()/2))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- 效果无效化。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetValue(RESET_TURN_SET)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e3)
	end
end
-- ②代替破坏的触发条件检查：这张卡因战斗或效果即将被破坏（且不是被代替破坏），并且可以取除超量素材，才可发动代替破坏。
function c49678559.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE) end
	-- 询问控制者是否发动②效果，用取除全部超量素材来代替这张卡的破坏。
	if Duel.SelectEffectYesNo(tp,c,96) then
		local g=c:GetOverlayGroup()
		-- 将这张卡的全部超量素材送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
		-- 这个效果适用的回合，自己受到的战斗伤害变成一半。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetValue(HALF_DAMAGE)
		e1:SetReset(RESET_PHASE+PHASE_END,1)
		-- 将“自己受到的战斗伤害减半”的效果注册到当前回合的玩家，持续到回合结束。
		Duel.RegisterEffect(e1,tp)
		return true
	else return false end
end

--グリッド・ロッド
-- 效果：
-- 自己场上的电子界族怪兽才能装备。
-- ①：装备怪兽的攻击力上升300，不受对方的效果影响，1回合只有1次不会被战斗破坏。
-- ②：场上的表侧表示的这张卡被破坏送去墓地的场合才能发动。自己场上的全部电子界族怪兽直到回合结束时不会被战斗·效果破坏。
function c30552375.initial_effect(c)
	-- ①：装备怪兽的攻击力上升300，不受对方的效果影响，1回合只有1次不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c30552375.target)
	e1:SetOperation(c30552375.operation)
	c:RegisterEffect(e1)
	-- 自己场上的电子界族怪兽才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetValue(c30552375.eqlimit)
	c:RegisterEffect(e2)
	-- 装备怪兽的攻击力上升300。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(300)
	c:RegisterEffect(e3)
	-- 装备怪兽不受对方的效果影响。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetValue(c30552375.efilter)
	c:RegisterEffect(e4)
	-- 1回合只有1次不会被战斗破坏。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_EQUIP)
	e5:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e5:SetValue(c30552375.valcon)
	e5:SetCountLimit(1)
	c:RegisterEffect(e5)
	-- 场上的表侧表示的这张卡被破坏送去墓地的场合才能发动。自己场上的全部电子界族怪兽直到回合结束时不会被战斗·效果破坏。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(30552375,0))  --"全部电子界族怪兽不会被破坏"
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_TO_GRAVE)
	e6:SetProperty(EFFECT_FLAG_DELAY)
	e6:SetCondition(c30552375.indcon)
	e6:SetTarget(c30552375.indtg)
	e6:SetOperation(c30552375.indop)
	c:RegisterEffect(e6)
end
-- 过滤函数，用于判断是否为表侧表示的电子界族怪兽。
function c30552375.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_CYBERSE)
end
-- 设置装备效果的目标为己方场上的电子界族怪兽。
function c30552375.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c30552375.filter(chkc) end
	-- 检查己方场上是否存在满足条件的电子界族怪兽。
	if chk==0 then return Duel.IsExistingTarget(c30552375.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择一个己方场上的电子界族怪兽作为装备对象。
	Duel.SelectTarget(tp,c30552375.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置装备效果的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 执行装备操作，将装备卡装备给目标怪兽。
function c30552375.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 执行装备操作，将装备卡装备给目标怪兽。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 限制装备对象必须为己方的电子界族怪兽。
function c30552375.eqlimit(e,c)
	return c:IsRace(RACE_CYBERSE) and c:GetControler()==e:GetHandler():GetControler()
end
-- 使装备怪兽不受对方的效果影响。
function c30552375.efilter(e,re)
	return e:GetHandlerPlayer()~=re:GetOwnerPlayer()
end
-- 限制装备怪兽只有在战斗破坏时才不会被破坏。
function c30552375.valcon(e,re,r,rp)
	return r==REASON_BATTLE
end
-- 判断装备卡是否因破坏而进入墓地。
function c30552375.indcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP) and c:IsReason(REASON_DESTROY)
end
-- 设置诱发效果的目标为己方场上的电子界族怪兽。
function c30552375.indtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方场上是否存在电子界族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c30552375.filter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 为己方所有电子界族怪兽添加不会被战斗和效果破坏的效果。
function c30552375.indop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方场上的所有电子界族怪兽。
	local g=Duel.GetMatchingGroup(c30552375.filter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 为装备怪兽添加不会被战斗破坏的效果。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetDescription(aux.Stringid(30552375,1))  --"「网格杖」效果适用中"
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
end

--D・ステープラン
-- 效果：
-- 这张卡得到这张卡的表示形式的以下效果。
-- ●攻击表示：只要这张卡在场上表侧表示存在，对方不能选择其他怪兽作为攻击对象。这张卡被战斗破坏的场合，把让这张卡破坏的怪兽的攻击力下降300。
-- ●守备表示：这张卡不会被战斗破坏。这张卡被攻击的场合，那次伤害计算后选择对方场上表侧攻击表示存在的1只怪兽变成守备表示，这张卡的表示形式变成攻击表示。
function c2250266.initial_effect(c)
	-- 攻击表示：只要这张卡在场上表侧表示存在，对方不能选择其他怪兽作为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_LEAVE_FIELD_P)
	e1:SetOperation(c2250266.check)
	c:RegisterEffect(e1)
	-- 这张卡被战斗破坏的场合，把让这张卡破坏的怪兽的攻击力下降300。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(2250266,0))  --"攻击下降"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetCondition(c2250266.cona)
	e2:SetOperation(c2250266.opa)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	-- 只要这张卡在场上表侧表示存在，对方不能选择其他怪兽作为攻击对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e3:SetCondition(c2250266.cona2)
	e3:SetValue(c2250266.atlimit)
	c:RegisterEffect(e3)
	-- 这张卡不会被战斗破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e4:SetCondition(c2250266.cond)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	-- 这张卡被攻击的场合，那次伤害计算后选择对方场上表侧攻击表示存在的1只怪兽变成守备表示，这张卡的表示形式变成攻击表示。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(2250266,1))  --"变成攻击表示"
	e5:SetCategory(CATEGORY_POSITION)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_BATTLED)
	e5:SetCondition(c2250266.cond)
	e5:SetTarget(c2250266.tgd2)
	e5:SetOperation(c2250266.opd2)
	c:RegisterEffect(e5)
end
-- 记录当前卡片是否处于攻击表示状态
function c2250266.check(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsDisabled() and c:IsAttackPos() then e:SetLabel(1)
	else e:SetLabel(0) end
end
-- 判断是否为攻击表示状态以触发效果
function c2250266.cona(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetLabel()==1
end
-- 将破坏此卡的怪兽的攻击力下降300
function c2250266.opa(e,tp,eg,ep,ev,re,r,rp)
	local rc=e:GetHandler():GetReasonCard()
	if rc:IsRelateToBattle() then
		-- 为破坏此卡的怪兽添加攻击力下降效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-300)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e1)
	end
end
-- 判断当前卡片是否处于攻击表示状态
function c2250266.cona2(e)
	return e:GetHandler():IsAttackPos()
end
-- 限制对方不能选择此卡为攻击对象
function c2250266.atlimit(e,c)
	return c~=e:GetHandler()
end
-- 判断当前卡片是否处于守备表示状态
function c2250266.cond(e)
	return not e:GetHandler():IsDisabled() and e:GetHandler():IsDefensePos()
end
-- 筛选对方场上表侧攻击表示的怪兽
function c2250266.filter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsCanChangePosition()
end
-- 选择对方场上表侧攻击表示的怪兽并设置操作信息
function c2250266.tgd2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c2250266.filter(chkc) end
	if chk==0 then return true end
	-- 提示玩家选择攻击表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACK)  --"请选择攻击表示的怪兽"
	-- 选择对方场上表侧攻击表示的怪兽
	local g=Duel.SelectTarget(tp,c2250266.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息为改变表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 执行守备表示效果：将对方怪兽变为守备表示并改变自身为攻击表示
function c2250266.opd2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsAttackPos()
		-- 将目标怪兽变为守备表示并确认自身参与战斗
		and Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)~=0 and c:IsRelateToBattle() then
		-- 将自身变为攻击表示
		Duel.ChangePosition(e:GetHandler(),POS_FACEUP_ATTACK,0,POS_FACEUP_ATTACK,0)
	end
end

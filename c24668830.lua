--細菌感染
-- 效果：
-- 机械族以外的怪兽装备可能。装备怪兽的攻击力在每次的自己的准备阶段攻击力下降300。
function c24668830.initial_effect(c)
	-- 装备怪兽的攻击力在每次的自己的准备阶段攻击力下降300。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c24668830.target)
	e1:SetOperation(c24668830.operation)
	c:RegisterEffect(e1)
	-- 机械族以外的怪兽装备可能。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c24668830.atkcon)
	e2:SetOperation(c24668830.atkop)
	c:RegisterEffect(e2)
	-- 装备怪兽的攻击力在每次的自己的准备阶段攻击力下降300。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c24668830.eqlimit)
	c:RegisterEffect(e3)
end
-- 效果作用：限制装备对象不能为机械族怪兽
function c24668830.eqlimit(e,c)
	return not c:IsRace(RACE_MACHINE)
end
-- 效果作用：筛选场上正面表示的非机械族怪兽
function c24668830.filter(c)
	return c:IsFaceup() and not c:IsRace(RACE_MACHINE)
end
-- 效果作用：选择场上正面表示的非机械族怪兽作为装备对象
function c24668830.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c24668830.filter(chkc) end
	-- 效果作用：判断是否满足选择装备对象的条件
	if chk==0 then return Duel.IsExistingTarget(c24668830.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 效果作用：提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 效果作用：选择场上正面表示的非机械族怪兽作为装备对象
	Duel.SelectTarget(tp,c24668830.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 效果作用：设置连锁操作信息，表明将要进行装备处理
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果作用：执行装备操作，将装备卡装备给目标怪兽
function c24668830.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前连锁中被选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 效果作用：将装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 效果作用：判断是否为自己的准备阶段
function c24668830.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：判断当前回合玩家是否为效果持有者
	return Duel.GetTurnPlayer()==tp
end
-- 效果作用：在准备阶段时，使装备怪兽的攻击力下降300
function c24668830.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	-- 效果作用：使装备怪兽的攻击力下降300
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(-300)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	ec:RegisterEffect(e1)
end

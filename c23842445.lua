--ニトロユニット
-- 效果：
-- 对方场上的怪兽才能装备。装备怪兽被战斗破坏送去墓地时，给与对方基本分装备怪兽攻击力数值的伤害。
function c23842445.initial_effect(c)
	-- 对方场上的怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c23842445.target)
	e1:SetOperation(c23842445.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽被战斗破坏送去墓地时，给与对方基本分装备怪兽攻击力数值的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c23842445.eqlimit)
	c:RegisterEffect(e2)
	-- 效果作用
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(23842445,0))  --"LP伤害"
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(c23842445.damcon)
	e3:SetTarget(c23842445.damtg)
	e3:SetOperation(c23842445.damop)
	c:RegisterEffect(e3)
end
-- 限制装备对象为对方控制的怪兽
function c23842445.eqlimit(e,c)
	return c:IsControler(1-e:GetHandlerPlayer())
end
-- 选择装备目标怪兽
function c23842445.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 判断是否有符合条件的装备目标
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择装备目标
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择装备目标怪兽
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置装备效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法卡生效
function c23842445.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的装备目标
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 执行装备操作
		Duel.Equip(tp,c,tc)
	end
end
-- 判断是否因战斗破坏离场
function c23842445.damcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetPreviousEquipTarget()
	return c:IsReason(REASON_LOST_TARGET) and ec:IsLocation(LOCATION_GRAVE) and ec:IsReason(REASON_BATTLE)
end
-- 设置伤害效果的处理信息
function c23842445.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local dam=e:GetHandler():GetPreviousEquipTarget():GetAttack()
	-- 设置伤害对象为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置伤害值为装备怪兽的攻击力
	Duel.SetTargetParam(dam)
	-- 设置伤害效果的处理信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 执行伤害效果
function c23842445.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的伤害对象和伤害值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对对方玩家造成指定伤害
	Duel.Damage(p,d,REASON_EFFECT)
end

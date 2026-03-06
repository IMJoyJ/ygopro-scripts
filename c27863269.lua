--ロケット・パイルダー
-- 效果：
-- 装备怪兽攻击的场合，装备怪兽不会被战斗破坏。装备怪兽进行攻击的伤害步骤结束时，受到装备怪兽的攻击的怪兽的攻击力直到结束阶段时下降装备怪兽的攻击力数值。
function c27863269.initial_effect(c)
	-- 装备怪兽攻击的场合，装备怪兽不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c27863269.target)
	e1:SetOperation(c27863269.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽进行攻击的伤害步骤结束时，受到装备怪兽的攻击的怪兽的攻击力直到结束阶段时下降装备怪兽的攻击力数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetCondition(c27863269.indcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 效果作用
	local e3=Effect.CreateEffect(c)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- 效果原文内容
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(27863269,0))  --"攻击下降"
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_DAMAGE_STEP_END)
	e4:SetCondition(c27863269.atkcon)
	e4:SetOperation(c27863269.atkop)
	c:RegisterEffect(e4)
end
-- 选择装备怪兽
function c27863269.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 判断是否满足装备条件
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择装备对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择一个正面表示的怪兽作为装备对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，准备将装备卡装备给目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备卡效果处理
function c27863269.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的装备对象
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 装备怪兽攻击时的条件判断
function c27863269.indcon(e)
	-- 判断当前攻击怪兽是否为装备怪兽
	return Duel.GetAttacker()==e:GetHandler():GetEquipTarget()
end
-- 攻击后攻击力变化的条件判断
function c27863269.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击时的目标怪兽
	local at=Duel.GetAttackTarget()
	-- 判断攻击目标是否存在于战斗中且正面表示
	return at and at:IsRelateToBattle() and at:IsFaceup() and Duel.GetAttacker()==e:GetHandler():GetEquipTarget()
end
-- 攻击力变化效果处理
function c27863269.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取攻击时的目标怪兽
	local at=Duel.GetAttackTarget()
	if not c:IsRelateToEffect(e) or not at:IsRelateToBattle() or at:IsFacedown() then return end
	local atk=c:GetEquipTarget():GetAttack()
	-- 将装备怪兽的攻击力数值从目标怪兽的攻击力中扣除
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(-atk)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	at:RegisterEffect(e1)
end

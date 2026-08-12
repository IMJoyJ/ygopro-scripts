--EMラクダウン
-- 效果：
-- ←2 【灵摆】 2→
-- ①：1回合1次，以自己场上1只表侧表示怪兽为对象才能发动。对方场上的全部怪兽的守备力直到回合结束时下降800，这个回合作为对象的怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
-- 【怪兽效果】
-- ①：这张卡被战斗破坏的场合才能发动。让把这张卡破坏的怪兽的攻击力下降800。
function c44481227.initial_effect(c)
	-- 为灵摆怪兽添加灵摆怪兽属性，使其可以进行灵摆召唤和灵摆卡的发动
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，以自己场上1只表侧表示怪兽为对象才能发动。对方场上的全部怪兽的守备力直到回合结束时下降800，这个回合作为对象的怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetCondition(c44481227.condition)
	e2:SetTarget(c44481227.target)
	e2:SetOperation(c44481227.operation)
	c:RegisterEffect(e2)
	-- ①：这张卡被战斗破坏的场合才能发动。让把这张卡破坏的怪兽的攻击力下降800。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(c44481227.atkcon)
	e3:SetOperation(c44481227.atkop)
	c:RegisterEffect(e3)
end
-- 判断是否能进入战斗阶段
function c44481227.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否能进入战斗阶段
	return Duel.IsAbleToEnterBP()
end
-- 过滤函数，返回场上正面表示且未具有贯穿效果的怪兽
function c44481227.filter(c)
	return c:IsFaceup() and not c:IsHasEffect(EFFECT_PIERCE)
end
-- 设置效果目标，选择自己场上的正面表示怪兽作为对象
function c44481227.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c44481227.filter(chkc) end
	-- 检查自己场上是否存在正面表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(c44481227.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否存在正面表示的怪兽
		and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择目标怪兽
	Duel.SelectTarget(tp,c44481227.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理函数，使对方场上所有正面表示怪兽守备力下降800，并给与对方战斗伤害
function c44481227.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 获取对方场上所有正面表示怪兽的集合
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()==0 then return end
	local gc=g:GetFirst()
	while gc do
		-- 为对方场上所有正面表示怪兽的守备力下降800
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_DEFENSE)
		e1:SetValue(-800)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		gc:RegisterEffect(e1)
		gc=g:GetNext()
	end
	if tc:IsRelateToEffect(e) then
		-- 使目标怪兽获得贯穿效果
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_PIERCE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
-- 判断被战斗破坏的怪兽是否参与了战斗
function c44481227.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=e:GetHandler():GetReasonCard()
	return rc:IsRelateToBattle()
end
-- 效果处理函数，使将这张卡破坏的怪兽攻击力下降800
function c44481227.atkop(e,tp,eg,ep,ev,re,r,rp)
	local rc=e:GetHandler():GetReasonCard()
	if rc:IsRelateToBattle() then
		-- 使将这张卡破坏的怪兽攻击力下降800
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-800)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e1)
	end
end

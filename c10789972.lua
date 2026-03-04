--覚醒戦士 クーフーリン
-- 效果：
-- 「觉醒之证」降临。1回合1次，选择自己墓地存在的1只通常怪兽才能发动。选择的怪兽从游戏中除外，直到下次的自己回合的准备阶段时这张卡的攻击力上升除外的那只通常怪兽的攻击力数值。
function c10789972.initial_effect(c)
	c:EnableReviveLimit()
	-- 效果原文内容：「觉醒之证」降临。1回合1次，选择自己墓地存在的1只通常怪兽才能发动。选择的怪兽从游戏中除外，直到下次的自己回合的准备阶段时这张卡的攻击力上升除外的那只通常怪兽的攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10789972,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c10789972.target)
	e1:SetOperation(c10789972.operation)
	c:RegisterEffect(e1)
end
-- 检索满足条件的墓地通常怪兽
function c10789972.filter(c)
	return c:IsType(TYPE_NORMAL) and c:IsAbleToRemove()
end
-- 效果处理时的选卡阶段，用于设置目标怪兽
function c10789972.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c10789972.filter(chkc) end
	-- 判断是否满足发动条件，即自己墓地是否存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c10789972.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家提示选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	-- 选择1只符合条件的墓地怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c10789972.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息，表明将要除外1只墓地怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,tp,LOCATION_GRAVE)
end
-- 效果处理时的执行阶段，用于处理效果的发动
function c10789972.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否仍然在场且满足除外条件，同时确认自身怪兽处于正面表示状态
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 and c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 效果原文内容：直到下次的自己回合的准备阶段时这张卡的攻击力上升除外的那只通常怪兽的攻击力数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(tc:GetBaseAttack())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_STANDBY,2)
		c:RegisterEffect(e1)
	end
end

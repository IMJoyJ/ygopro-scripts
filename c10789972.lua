--覚醒戦士 クーフーリン
-- 效果：
-- 「觉醒之证」降临。1回合1次，选择自己墓地存在的1只通常怪兽才能发动。选择的怪兽从游戏中除外，直到下次的自己回合的准备阶段时这张卡的攻击力上升除外的那只通常怪兽的攻击力数值。
function c10789972.initial_effect(c)
	-- 在卡片中记录关联卡片「觉醒之证」（卡号9845733）
	aux.AddCodeList(c,9845733)
	c:EnableReviveLimit()
	-- 1回合1次，选择自己墓地存在的1只通常怪兽才能发动。选择的怪兽从游戏中除外，直到下次的自己回合的准备阶段时这张卡的攻击力上升除外的那只通常怪兽的攻击力数值。
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
-- 过滤条件：自己墓地存在的通常怪兽，且可以被除外
function c10789972.filter(c)
	return c:IsType(TYPE_NORMAL) and c:IsAbleToRemove()
end
-- 起动效果的发动目标（检查并选择墓地中的通常怪兽作为效果的对象）
function c10789972.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c10789972.filter(chkc) end
	-- 在进行合法性检测时，确认自己墓地中是否存在至少1只通常怪兽
	if chk==0 then return Duel.IsExistingTarget(c10789972.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择一张需要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择自己墓地的一只通常怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c10789972.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁处理信息：将选中的墓地怪兽除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,tp,LOCATION_GRAVE)
end
-- 起动效果的效果处理（将目标通常怪兽除外，并在规定时间内使自身攻击力上升被除外怪兽的攻击力）
function c10789972.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取在效果发动时选择的目标通常怪兽
	local tc=Duel.GetFirstTarget()
	-- 确认目标怪兽与该效果关联，将其成功除外，并且自身表侧表示存在于场上
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 and c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 直到下次的自己回合的准备阶段时这张卡的攻击力上升除外的那只通常怪兽的攻击力数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(tc:GetBaseAttack())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_STANDBY,2)
		c:RegisterEffect(e1)
	end
end

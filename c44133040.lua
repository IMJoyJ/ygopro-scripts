--セレンの呪眼
-- 效果：
-- 「咒眼」怪兽才能装备。这个卡名的③的效果1回合只能使用1次。
-- ①：装备怪兽不会被战斗以及对方的效果破坏，不会成为对方的效果的对象。
-- ②：每次自己把装备怪兽的效果或者这张卡以外的「咒眼」魔法·陷阱卡发动才发动。装备怪兽的攻击力上升500，自己失去500基本分。
-- ③：支付1000基本分，从自己墓地把「太阴之咒眼」以外的1张「咒眼」魔法·陷阱卡除外才能发动。墓地的这张卡在自己场上盖放。
function c44133040.initial_effect(c)
	-- ①：装备怪兽不会被战斗以及对方的效果破坏，不会成为对方的效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c44133040.target)
	e1:SetOperation(c44133040.operation)
	c:RegisterEffect(e1)
	-- 「咒眼」怪兽才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetValue(c44133040.eqlimit)
	c:RegisterEffect(e2)
	-- 装备怪兽不会被战斗破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	-- 装备怪兽不会被对方的效果破坏。
	e4:SetValue(aux.indoval)
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e5:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	-- 装备怪兽不会成为对方的效果的对象。
	e5:SetValue(aux.tgoval)
	c:RegisterEffect(e5)
	-- ②：每次自己把装备怪兽的效果或者这张卡以外的「咒眼」魔法·陷阱卡发动才发动。装备怪兽的攻击力上升500，自己失去500基本分。
	local e7=Effect.CreateEffect(c)
	e7:SetDescription(aux.Stringid(44133040,0))  --"攻击力上升并失去基本分"
	e7:SetCategory(CATEGORY_ATKCHANGE)
	e7:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e7:SetCode(EVENT_CHAINING)
	e7:SetRange(LOCATION_SZONE)
	e7:SetCondition(c44133040.atkcon)
	e7:SetOperation(c44133040.atkop)
	c:RegisterEffect(e7)
	-- ③：支付1000基本分，从自己墓地把「太阴之咒眼」以外的1张「咒眼」魔法·陷阱卡除外才能发动。墓地的这张卡在自己场上盖放。
	local e8=Effect.CreateEffect(c)
	e8:SetDescription(aux.Stringid(44133040,1))  --"这张卡在自己场上盖放"
	e8:SetCategory(CATEGORY_SSET)
	e8:SetType(EFFECT_TYPE_IGNITION)
	e8:SetRange(LOCATION_GRAVE)
	e8:SetCountLimit(1,52840268)
	e8:SetCost(c44133040.setcost)
	e8:SetTarget(c44133040.settg)
	e8:SetOperation(c44133040.setop)
	c:RegisterEffect(e8)
end
-- 过滤函数，用于筛选场上正面表示的「咒眼」怪兽。
function c44133040.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x129)
end
-- 设置装备卡的发动目标为场上正面表示的「咒眼」怪兽。
function c44133040.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c44133040.filter(chkc) end
	-- 检查场上是否存在满足条件的装备目标。
	if chk==0 then return Duel.IsExistingTarget(c44133040.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上正面表示的「咒眼」怪兽作为装备目标。
	Duel.SelectTarget(tp,c44133040.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置装备效果的处理信息。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 执行装备操作，将装备卡装备给目标怪兽。
function c44133040.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的装备目标怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将装备卡装备给目标怪兽。
		Duel.Equip(tp,c,tc)
	end
end
-- 装备对象限制函数，仅允许「咒眼」怪兽装备。
function c44133040.eqlimit(e,c)
	return c:IsSetCard(0x129)
end
-- 判断是否触发攻击力上升效果的条件。
function c44133040.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	return rp==tp
		and ((re:IsActiveType(TYPE_MONSTER) and c:GetEquipTarget()==rc)
			or (re:IsHasType(EFFECT_TYPE_ACTIVATE) and rc:IsSetCard(0x129) and rc~=c))
end
-- 执行攻击力上升和失去基本分的效果。
function c44133040.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if ec and c:IsRelateToEffect(e) then
		-- 为装备怪兽增加500点攻击力。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		ec:RegisterEffect(e1)
		-- 使自己失去500基本分。
		Duel.SetLP(tp,Duel.GetLP(tp)-500)
	end
end
-- 过滤函数，用于筛选墓地中可除外的「咒眼」魔法·陷阱卡。
function c44133040.costfilter(c)
	return c:IsSetCard(0x129) and c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsCode(44133040) and c:IsAbleToRemoveAsCost()
end
-- 设置发动③效果的费用，支付1000基本分并除外一张墓地的「咒眼」魔法·陷阱卡。
function c44133040.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否能支付1000基本分并找到可除外的卡。
	if chk==0 then return Duel.CheckLPCost(tp,1000) and Duel.IsExistingMatchingCard(c44133040.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 支付1000基本分。
	Duel.PayLPCost(tp,1000)
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择一张墓地的「咒眼」魔法·陷阱卡除外。
	local g=Duel.SelectMatchingCard(tp,c44133040.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡从墓地除外。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 设置③效果的发动目标，确认该卡可以盖放。
function c44133040.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	-- 设置操作信息，表示将该卡从墓地离开。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 执行③效果的处理，将该卡在自己场上盖放。
function c44133040.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将该卡在自己场上盖放。
		Duel.SSet(tp,c)
	end
end

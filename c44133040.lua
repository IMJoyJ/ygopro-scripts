--セレンの呪眼
-- 效果：
-- 「咒眼」怪兽才能装备。这个卡名的③的效果1回合只能使用1次。
-- ①：装备怪兽不会被战斗以及对方的效果破坏，不会成为对方的效果的对象。
-- ②：每次自己把装备怪兽的效果或者这张卡以外的「咒眼」魔法·陷阱卡发动才发动。装备怪兽的攻击力上升500，自己失去500基本分。
-- ③：支付1000基本分，从自己墓地把「太阴之咒眼」以外的1张「咒眼」魔法·陷阱卡除外才能发动。墓地的这张卡在自己场上盖放。
function c44133040.initial_effect(c)
	-- 「咒眼」怪兽才能装备。
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
	-- ①：装备怪兽不会被战斗以及对方的效果破坏（不会被战斗破坏的部分）。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	-- 设置不会被对方的效果破坏的判定条件：对方发动的效果不能破坏装备怪兽。
	e4:SetValue(aux.indoval)
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e5:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	-- 设置不会成为对方效果对象的判定条件：对方的效果不能以装备怪兽为对象。
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
	-- ③：支付1000基本分，从自己墓地把「太阴之咒眼」以外的1张「咒眼」魔法·陷阱卡除外才能发动。墓地的这张卡在自己场上盖放。这个卡名的③的效果1回合只能使用1次。
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
-- 定义装备对象过滤器：必须是表侧表示且属于「咒眼」怪兽。
function c44133040.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x129)
end
-- 装备魔法的发动时点处理：检查并选择场上1只表侧表示「咒眼」怪兽作为装备对象。
function c44133040.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c44133040.filter(chkc) end
	-- 发动合法性检查：场上是否存在至少1只表侧表示「咒眼」怪兽可作为装备对象。
	if chk==0 then return Duel.IsExistingTarget(c44133040.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 显示选择提示信息“请选择要装备的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从双方怪兽区选择1只表侧表示「咒眼」怪兽，并将其登记为效果对象。
	Duel.SelectTarget(tp,c44133040.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：本次连锁处理为装备分类，目标为这张装备卡，数量1。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备处理：若这张卡和目标怪兽仍与效果关联且目标表侧表示，将这张卡装备给目标怪兽。
function c44133040.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取出效果处理时选择的装备目标怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡作为装备卡装备到目标怪兽身上。
		Duel.Equip(tp,c,tc)
	end
end
-- 定义装备限制：只有「咒眼」怪兽才能装备这张卡。
function c44133040.eqlimit(e,c)
	return c:IsSetCard(0x129)
end
-- ②效果的发动条件：自己发动了装备怪兽的效果，或发动了这张卡以外的「咒眼」魔法·陷阱卡时满足条件（由rp==tp确保是自己发动）。
function c44133040.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	return rp==tp
		and ((re:IsActiveType(TYPE_MONSTER) and c:GetEquipTarget()==rc)
			or (re:IsHasType(EFFECT_TYPE_ACTIVATE) and rc:IsSetCard(0x129) and rc~=c))
end
-- ②效果处理：装备怪兽攻击力上升500，且自己失去500基本分。
function c44133040.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if ec and c:IsRelateToEffect(e) then
		-- 装备怪兽的攻击力上升500。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		ec:RegisterEffect(e1)
		-- 自己失去500基本分。
		Duel.SetLP(tp,Duel.GetLP(tp)-500)
	end
end
-- 定义③效果除外代价的过滤器：自己墓地的「咒眼」魔法·陷阱卡，且不是「太阴之咒眼」，并可以作为除外代价。
function c44133040.costfilter(c)
	return c:IsSetCard(0x129) and c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsCode(44133040) and c:IsAbleToRemoveAsCost()
end
-- ③效果的发动代价：支付1000基本分，从自己墓地选择并除外1张符合条件的「咒眼」魔法·陷阱卡。
function c44133040.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：能否支付1000基本分且墓地存在符合条件的可除外卡片。
	if chk==0 then return Duel.CheckLPCost(tp,1000) and Duel.IsExistingMatchingCard(c44133040.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 实际支付1000基本分作为发动代价。
	Duel.PayLPCost(tp,1000)
	-- 显示选择提示信息“请选择要除外的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地选择1张符合条件的「咒眼」魔法·陷阱卡作为除外代价。
	local g=Duel.SelectMatchingCard(tp,c44133040.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的卡片表侧表示除外，作为发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ③效果的发动目标检查：确认这张卡在墓地且可以盖放，并设置操作信息。
function c44133040.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	-- 设置操作信息：本效果涉及这张卡从墓地离开（盖放到场上）。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- ③效果处理：将墓地中的这张卡在自己场上盖放。
function c44133040.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以里侧表示盖放到自己魔法与陷阱区域。
		Duel.SSet(tp,c)
	end
end

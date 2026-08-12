--破壊剣－ウィザードバスターブレード
-- 效果：
-- ①：自己主要阶段以自己场上1只「破坏之剑士」为对象才能发动。从自己的手卡·场上把这只怪兽当作装备卡使用给那只自己怪兽装备。
-- ②：这张卡装备中的场合，对方不能把墓地的怪兽的效果发动。
-- ③：把装备的这张卡送去墓地，以「破坏剑-魔法破坏之剑」以外的自己墓地1只「破坏剑」怪兽为对象才能发动。那只怪兽加入手卡。
function c2602411.initial_effect(c)
	-- ①：自己主要阶段以自己场上1只「破坏之剑士」为对象才能发动。从自己的手卡·场上把这只怪兽当作装备卡使用给那只自己怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetTarget(c2602411.eqtg)
	e1:SetOperation(c2602411.eqop)
	c:RegisterEffect(e1)
	-- ②：这张卡装备中的场合，对方不能把墓地的怪兽的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,1)
	e2:SetCondition(c2602411.condition)
	e2:SetValue(c2602411.aclimit)
	c:RegisterEffect(e2)
	-- ③：把装备的这张卡送去墓地，以「破坏剑-魔法破坏之剑」以外的自己墓地1只「破坏剑」怪兽为对象才能发动。那只怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c2602411.condition)
	e3:SetCost(c2602411.thcost)
	e3:SetTarget(c2602411.thtg)
	e3:SetOperation(c2602411.thop)
	c:RegisterEffect(e3)
end
-- 筛选场上正面表示的「破坏之剑士」怪兽
function c2602411.filter(c)
	return c:IsFaceup() and c:IsCode(78193831)
end
-- 检查是否满足装备条件
function c2602411.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c2602411.filter(chkc) end
	-- 检查装备区域是否还有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查场上是否存在符合条件的「破坏之剑士」怪兽
		and Duel.IsExistingTarget(c2602411.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择目标怪兽
	Duel.SelectTarget(tp,c2602411.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 装备效果处理函数
function c2602411.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if c:IsLocation(LOCATION_MZONE) and c:IsFacedown() then return end
	-- 获取选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断装备条件是否满足
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsControler(1-tp) or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		-- 将装备卡送入墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 执行装备操作
	Duel.Equip(tp,c,tc)
	-- 设置装备限制效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c2602411.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
end
-- 限制只能装备给指定怪兽
function c2602411.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 判断是否已装备怪兽
function c2602411.condition(e)
	return e:GetHandler():GetEquipTarget()
end
-- 限制对方从墓地发动怪兽效果
function c2602411.aclimit(e,re,tp)
	local loc=re:GetActivateLocation()
	return loc==LOCATION_GRAVE and re:IsActiveType(TYPE_MONSTER)
end
-- 支付装备效果的墓地代价
function c2602411.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将装备卡送入墓地作为代价
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 筛选墓地符合条件的「破坏剑」怪兽
function c2602411.thfilter(c)
	return c:IsSetCard(0xd6) and c:IsType(TYPE_MONSTER) and not c:IsCode(2602411) and c:IsAbleToHand()
end
-- 设置手牌加入手牌的效果处理信息
function c2602411.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c2602411.thfilter(chkc) end
	-- 检查墓地是否存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c2602411.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,c2602411.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 手牌加入手牌效果处理函数
function c2602411.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end

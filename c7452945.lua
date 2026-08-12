--天命の聖剣
-- 效果：
-- 战士族怪兽才能装备。这个卡名的③的效果1回合只能使用1次。
-- ①：「天命之圣剑」在自己场上只能有1张表侧表示存在。
-- ②：装备怪兽1回合只有1次不会被战斗·效果破坏。
-- ③：场上的表侧表示的这张卡被破坏送去墓地的场合，以自己场上1只战士族「圣骑士」怪兽为对象才能发动。那只自己的战士族「圣骑士」怪兽把这张卡装备。
function c7452945.initial_effect(c)
	c:SetUniqueOnField(1,0,7452945)
	-- 战士族怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c7452945.target)
	e1:SetOperation(c7452945.operation)
	c:RegisterEffect(e1)
	-- ②：装备怪兽1回合只有1次不会被战斗·效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetValue(c7452945.valcon)
	e2:SetCountLimit(1)
	c:RegisterEffect(e2)
	-- 战士族怪兽才能装备。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c7452945.eqlimit)
	c:RegisterEffect(e3)
	-- ③：场上的表侧表示的这张卡被破坏送去墓地的场合，以自己场上1只战士族「圣骑士」怪兽为对象才能发动。那只自己的战士族「圣骑士」怪兽把这张卡装备。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(7452945,0))  --"装备"
	e4:SetCategory(CATEGORY_EQUIP)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCountLimit(1,7452945)
	e4:SetCondition(c7452945.eqcon)
	e4:SetTarget(c7452945.eqtg)
	e4:SetOperation(c7452945.operation2)
	c:RegisterEffect(e4)
end
-- 限制装备对象只能是战士族怪兽
function c7452945.eqlimit(e,c)
	return c:IsRace(RACE_WARRIOR)
end
-- 过滤场上表侧表示的战士族怪兽
function c7452945.eqfilter1(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR)
end
-- 装备魔法卡发动时的对象选择与效果处理
function c7452945.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c7452945.eqfilter1(chkc) end
	-- 在发动时，检查场上是否存在可装备的表侧表示战士族怪兽
	if chk==0 then return Duel.IsExistingTarget(c7452945.eqfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只表侧表示的战士族怪兽作为装备对象
	Duel.SelectTarget(tp,c7452945.eqfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息为装备这张卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法卡发动时的效果处理
function c7452945.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的装备对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc and c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() and c:CheckUniqueOnField(tp) then
		-- 将这张卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
	end
end
-- 判断破坏原因是否为战斗或效果破坏
function c7452945.valcon(e,re,r,rp)
	return bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0
end
-- 判断此卡是否从场上表侧表示被破坏送去墓地，且满足同名卡唯一存在限制
function c7452945.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP) and c:IsReason(REASON_DESTROY) and c:CheckUniqueOnField(tp)
end
-- 过滤自己场上表侧表示的战士族「圣骑士」怪兽
function c7452945.eqfilter2(c)
	return c:IsFaceup() and c:IsSetCard(0x107a) and c:IsRace(RACE_WARRIOR)
end
-- 效果③的发动准备与对象选择
function c7452945.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c7452945.eqfilter2(chkc) end
	-- 在发动时，检查此卡是否仍在墓地且自己魔法与陷阱区域有空位
	if chk==0 then return e:GetHandler():IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己场上是否存在可作为对象的表侧表示战士族「圣骑士」怪兽
		and Duel.IsExistingTarget(c7452945.eqfilter2,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只表侧表示的战士族「圣骑士」怪兽作为对象
	Duel.SelectTarget(tp,c7452945.eqfilter2,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果处理信息为装备这张卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
	-- 设置效果处理信息为这张卡从墓地离开
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 效果③的效果处理
function c7452945.operation2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果③选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup()
		and tc:IsControler(tp) and tc:IsSetCard(0x107a) and c7452945.eqlimit(nil,tc) and c:CheckUniqueOnField(tp) then
		-- 将这张卡从墓地装备给目标怪兽
		Duel.Equip(tp,c,tc)
	end
end

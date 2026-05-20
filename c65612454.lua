--エレキューブ
-- 效果：
-- 雷族怪兽才能装备。装备怪兽的攻击力上升自己墓地存在的雷族怪兽数量×100的数值。此外，可以把场上表侧表示存在的这张卡送去墓地，自己场上表侧表示存在的1只雷族怪兽的攻击力上升1000。
function c65612454.initial_effect(c)
	-- 雷族怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c65612454.target)
	e1:SetOperation(c65612454.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽的攻击力上升自己墓地存在的雷族怪兽数量×100的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(c65612454.val)
	c:RegisterEffect(e2)
	-- 雷族怪兽才能装备。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c65612454.eqlimit)
	c:RegisterEffect(e3)
	-- 此外，可以把场上表侧表示存在的这张卡送去墓地，自己场上表侧表示存在的1只雷族怪兽的攻击力上升1000。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(65612454,0))  --"攻击上升"
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_SZONE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCost(c65612454.atkcost)
	e4:SetTarget(c65612454.atktg)
	e4:SetOperation(c65612454.atkop)
	c:RegisterEffect(e4)
end
-- 装备限制：只能装备给雷族怪兽
function c65612454.eqlimit(e,c)
	return c:IsRace(RACE_THUNDER)
end
-- 过滤条件：场上表侧表示的雷族怪兽
function c65612454.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_THUNDER)
end
-- 装备魔法卡发动时的效果目标选择与操作信息设置
function c65612454.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c65612454.filter(chkc) end
	-- 步骤1：检查场上是否存在可以装备的表侧表示雷族怪兽
	if chk==0 then return Duel.IsExistingTarget(c65612454.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只表侧表示的雷族怪兽作为装备对象
	Duel.SelectTarget(tp,c65612454.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息为装备此卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法卡发动后的效果处理（执行装备）
function c65612454.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的装备对象怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 起动效果的代价检查与支付
function c65612454.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将这张卡送去墓地作为发动的代价
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 计算装备怪兽攻击力上升数值的函数
function c65612454.val(e,c)
	-- 返回自己墓地存在的雷族怪兽数量×100的数值
	return Duel.GetMatchingGroupCount(Card.IsRace,c:GetControler(),LOCATION_GRAVE,0,nil,RACE_THUNDER)*100
end
-- 起动效果的目标选择
function c65612454.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c65612454.filter(chkc) end
	-- 步骤1：检查自己场上是否存在表侧表示的雷族怪兽
	if chk==0 then return Duel.IsExistingTarget(c65612454.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的雷族怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c65612454.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 起动效果的效果处理（增加攻击力）
function c65612454.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and c65612454.filter(tc) then
		-- 自己场上表侧表示存在的1只雷族怪兽的攻击力上升1000。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(1000)
		tc:RegisterEffect(e1)
	end
end

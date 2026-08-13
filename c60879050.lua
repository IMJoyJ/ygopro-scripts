--機関連結
-- 效果：
-- 把自己墓地2只10星以上的机械族怪兽除外发动的场合才能给机械族·地属性怪兽装备。
-- ①：装备怪兽的攻击力变成原本攻击力的2倍，装备怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
-- ②：只要这张卡在魔法与陷阱区域存在，装备怪兽以外的自己怪兽不能攻击。
function c60879050.initial_effect(c)
	-- 把自己墓地2只10星以上的机械族怪兽除外发动的场合才能给机械族·地属性怪兽装备。（e1定义发动效果，包含代价、目标和处理）
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetCost(c60879050.cost)
	e1:SetTarget(c60879050.target)
	e1:SetOperation(c60879050.operation)
	c:RegisterEffect(e1)
	-- 才能给机械族·地属性怪兽装备。（装备对象限制为机械族·地属性怪兽）
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c60879050.eqlimit)
	c:RegisterEffect(e2)
	-- 装备怪兽的攻击力变成原本攻击力的2倍。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_SET_ATTACK)
	e3:SetValue(c60879050.value)
	c:RegisterEffect(e3)
	-- 装备怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e4)
	-- 只要这张卡在魔法与陷阱区域存在，装备怪兽以外的自己怪兽不能攻击。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_ATTACK)
	e5:SetRange(LOCATION_SZONE)
	e5:SetTargetRange(LOCATION_MZONE,0)
	e5:SetTarget(c60879050.ftarget)
	c:RegisterEffect(e5)
end
-- 装备限制判定：仅当该怪兽为这张装备卡的装备对象，且种族为机械族、属性为地属性时才允许装备。
function c60879050.eqlimit(e,c)
	return e:GetHandler():GetEquipTarget()==c and c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH)
end
-- 目标过滤：表侧表示且机械族·地属性的怪兽。
function c60879050.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH)
end
-- 代价过滤：墓地中机械族、10星以上且可作为代价除外的怪兽。
function c60879050.rmfilter(c)
	return c:IsRace(RACE_MACHINE) and c:IsLevelAbove(10) and c:IsAbleToRemoveAsCost()
end
-- 发动代价：从自己墓地选择2只机械族·10星以上的怪兽正面表示除外，作为发动这张卡的条件。
function c60879050.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时点检查：自己墓地是否存在至少2张满足rmfilter条件的卡，以判断能否支付代价。
	if chk==0 then return Duel.IsExistingMatchingCard(c60879050.rmfilter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 提示玩家选择要除外的卡片，显示“请选择要除外的卡”消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地选择2张满足rmfilter条件的怪兽卡作为代价。
	local g=Duel.SelectMatchingCard(tp,c60879050.rmfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 将选择的2张怪兽卡以正面表示除外，作为发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果目标：选择自己或对方场上1只表侧表示且机械族·地属性的怪兽作为装备对象，并设为取对象效果的对象。
function c60879050.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c60879050.filter(chkc) end
	-- 发动时点检查：场上是否存在至少1只满足filter条件的怪兽可作为装备对象。
	if chk==0 then return Duel.IsExistingTarget(c60879050.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽，显示“请选择要装备的卡”消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只满足filter的怪兽，并将其设置为当前效果的对象。
	Duel.SelectTarget(tp,c60879050.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果处理：若这张卡和目标怪兽仍与效果相关且目标表侧表示，则将这张卡装备给目标怪兽。
function c60879050.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡装备给目标怪兽，使其成为装备魔法卡并装备在怪兽上。
		Duel.Equip(tp,c,tc)
	end
end
-- 攻击力设定：返回装备怪兽的原本攻击力×2，使其攻击力变成原本攻击力的2倍。
function c60879050.value(e,c)
	return c:GetBaseAttack()*2
end
-- 不能攻击的限制判定：当怪兽不是这张装备卡的装备对象时，该怪兽不能攻击。
function c60879050.ftarget(e,c)
	return e:GetHandler():GetEquipTarget()~=c
end

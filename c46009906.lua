--猛獣の歯
-- 效果：
-- 兽族才能装备。1只装备怪兽的攻击力和守备力上升300。
function c46009906.initial_effect(c)
	-- 兽族才能装备（作为装备魔法发动时，选择符合条件的兽族怪兽进行装备）
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c46009906.target)
	e1:SetOperation(c46009906.operation)
	c:RegisterEffect(e1)
	-- 1只装备怪兽的攻击力上升300
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(300)
	c:RegisterEffect(e2)
	-- 1只装备怪兽的守备力上升300
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	e3:SetValue(300)
	c:RegisterEffect(e3)
	-- 兽族才能装备
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EQUIP_LIMIT)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetValue(c46009906.eqlimit)
	c:RegisterEffect(e4)
end
-- 装备限制条件：只有兽族怪兽才能装备这张卡
function c46009906.eqlimit(e,c)
	return c:IsRace(RACE_BEAST)
end
-- 过滤条件：表侧表示且种族为兽族的怪兽，用于选择装备对象
function c46009906.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_BEAST)
end
-- 发动时的目标选择流程：检查指定对象是否合法，确认存在符合条件的兽族怪兽后，提示玩家选择1只并设置装备操作信息
function c46009906.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c46009906.filter(chkc) end
	-- 发动时检查场上是否存在至少1只符合条件的表侧表示兽族怪兽，若不存在则不能发动
	if chk==0 then return Duel.IsExistingTarget(c46009906.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 显示选择提示，让玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从双方主要怪兽区选择1只表侧表示兽族怪兽作为装备对象
	Duel.SelectTarget(tp,c46009906.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置本次操作信息为装备自己这张卡，数量1，供后续连锁检测使用
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理时：若这张卡和目标怪兽都仍与效果关联且目标为表侧表示，则将其装备给目标怪兽
function c46009906.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的装备对象
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡作为装备卡装备给选择的对象
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end

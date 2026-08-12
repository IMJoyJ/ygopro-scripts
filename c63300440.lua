--ドラゴン・シールド
-- 效果：
-- 龙族怪兽才能装备。
-- ①：装备怪兽不会被战斗·效果破坏。装备怪兽的战斗发生的对双方玩家的战斗伤害变成0。
function c63300440.initial_effect(c)
	-- 龙族怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c63300440.target)
	e1:SetOperation(c63300440.operation)
	c:RegisterEffect(e1)
	-- 龙族怪兽才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c63300440.eqlimit)
	c:RegisterEffect(e2)
	-- ①：装备怪兽不会被战斗·效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetCode(EFFECT_NO_BATTLE_DAMAGE)
	e5:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	c:RegisterEffect(e5)
	local e6=e3:Clone()
	e6:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e6:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	c:RegisterEffect(e6)
end
-- 定义装备限制：只能装备给龙族怪兽
function c63300440.eqlimit(e,c)
	return c:IsRace(RACE_DRAGON)
end
-- 过滤场上表侧表示的龙族怪兽
function c63300440.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON)
end
-- 效果发动的对象选择与操作准备
function c63300440.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c63300440.filter(chkc) end
	-- 检查场上是否存在至少1只符合条件的表侧表示龙族怪兽
	if chk==0 then return Duel.IsExistingTarget(c63300440.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 给玩家发送提示信息，提示选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只表侧表示的龙族怪兽作为效果的对象
	Duel.SelectTarget(tp,c63300440.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，表示该效果是装备这张卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理：将这张卡装备给选择的目标怪兽
function c63300440.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动的目标怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡作为装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end

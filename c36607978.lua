--魔性の月
-- 效果：
-- 兽战士族怪兽才能装备。装备怪兽的攻击力·守备力上升300。
function c36607978.initial_effect(c)
	-- 兽战士族怪兽才能装备（发动时选择符合条件的兽战士族怪兽作为装备对象）
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c36607978.target)
	e1:SetOperation(c36607978.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽的攻击力上升300
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(300)
	c:RegisterEffect(e2)
	-- 装备怪兽的守备力上升300
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	e3:SetValue(300)
	c:RegisterEffect(e3)
	-- 兽战士族怪兽才能装备（装备对象限制）
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EQUIP_LIMIT)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetValue(c36607978.eqlimit)
	c:RegisterEffect(e4)
end
-- 装备限制判定：只有兽战士族怪兽才能装备此卡
function c36607978.eqlimit(e,c)
	return c:IsRace(RACE_BEASTWARRIOR)
end
-- 选择条件：场上表侧表示的兽战士族怪兽
function c36607978.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_BEASTWARRIOR)
end
-- 发动效果的选择处理：确认是否存在符合条件的装备对象，若存在则选择1只表侧表示兽战士族怪兽作为装备对象，并设定将该卡装备给对方怪兽的处理信息
function c36607978.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c36607978.filter(chkc) end
	-- 判定场上是否存在至少1只表侧表示兽战士族怪兽可作为装备对象
	if chk==0 then return Duel.IsExistingTarget(c36607978.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 显示选择提示：请选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择1只自己或对方场上表侧表示兽战士族怪兽作为装备对象
	Duel.SelectTarget(tp,c36607978.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设定操作信息：将这张卡装备（CATEGORY_EQUIP），对象为这张卡自身
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理：取得选择的装备对象，若这张卡和对象均与效果相关且对象仍表侧表示，则将这张卡装备给对象
function c36607978.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的装备对象
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡装备给选择的怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end

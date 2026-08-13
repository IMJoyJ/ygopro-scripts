--銀の弓矢
-- 效果：
-- 天使族才能装备。1只装备怪兽的攻击力·守备力上升300。
function c1557499.initial_effect(c)
	-- 天使族才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c1557499.target)
	e1:SetOperation(c1557499.operation)
	c:RegisterEffect(e1)
	-- 攻击力上升300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(300)
	c:RegisterEffect(e2)
	-- 守备力上升300。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	e3:SetValue(300)
	c:RegisterEffect(e3)
	-- 天使族才能装备。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EQUIP_LIMIT)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetValue(c1557499.eqlimit)
	c:RegisterEffect(e4)
end
-- 装备限制判定：仅允许天使族怪兽装备此卡。
function c1557499.eqlimit(e,c)
	return c:IsRace(RACE_FAIRY)
end
-- 筛选条件：场上表侧表示的天使族怪兽。
function c1557499.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_FAIRY)
end
-- 发动时的目标选择处理：选择场上1只表侧表示的天使族怪兽作为装备对象，并设置装备操作信息。
function c1557499.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c1557499.filter(chkc) end
	-- 发动合法性检查：确认场上存在至少1只可选择的表侧表示天使族怪兽。
	if chk==0 then return Duel.IsExistingTarget(c1557499.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从双方场上选择1只表侧表示的天使族怪兽作为装备对象。
	Duel.SelectTarget(tp,c1557499.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息，宣告本次连锁将进行装备卡装备。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理：若此卡和目标仍与效果关联且目标表侧表示，则将这张卡装备给目标怪兽。
function c1557499.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的装备目标怪兽。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将此卡作为装备卡装备给目标怪兽。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end

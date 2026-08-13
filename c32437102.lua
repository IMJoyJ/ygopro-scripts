--竜魂の力
-- 效果：
-- 只有战士族可以装备。装备怪兽的种族变龙族，攻击力守备力上升500。
function c32437102.initial_effect(c)
	-- 只有战士族可以装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c32437102.target)
	e1:SetOperation(c32437102.operation)
	c:RegisterEffect(e1)
	-- 攻击力上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(500)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- 装备怪兽的种族变龙族。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_CHANGE_RACE)
	e4:SetValue(RACE_DRAGON)
	c:RegisterEffect(e4)
	-- 只有战士族可以装备。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_EQUIP_LIMIT)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetValue(c32437102.eqlimit)
	c:RegisterEffect(e5)
end
-- 作为装备限制的判定函数：检查怪兽卡面记载的原始种族是否为战士族，满足时才允许这张卡装备。
function c32437102.eqlimit(e,c)
	return c:GetOriginalRace()==RACE_WARRIOR
end
-- 装备对象过滤函数：筛选表侧表示且当前种族为战士族的怪兽，作为这张装备魔法卡可以选择的目标。
function c32437102.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR)
end
-- 发动时的目标选择处理：确认场上存在符合条件的战士族怪兽后，选择1只表侧表示战士族怪兽作为装备对象，并登记装备操作信息。
function c32437102.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c32437102.filter(chkc) end
	-- 发动条件检查：场上是否存在1只表侧表示且种族为战士族的怪兽可以成为效果对象，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c32437102.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向操作玩家显示“请选择要装备的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从双方怪兽区域选择1只表侧表示且种族为战士族的怪兽，并将其设为本效果的对象。
	Duel.SelectTarget(tp,c32437102.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息：分类为装备，关联卡为这张装备魔法卡自身，数量为1，用于后续规则判定。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理时的实际装备操作：若这张卡与对象怪兽仍与本效果相关且对象表侧表示，则将这张卡装备给对象怪兽。
function c32437102.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得发动时选择的那只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张装备魔法卡作为装备卡装备给对象怪兽，完成装备。
		Duel.Equip(tp,c,tc)
	end
end

--闇・エネルギー
-- 效果：
-- 恶魔族怪兽才能装备。
-- ①：装备怪兽的攻击力·守备力上升300。
function c4614116.initial_effect(c)
	-- 恶魔族怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c4614116.target)
	e1:SetOperation(c4614116.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽的攻击力上升300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(300)
	c:RegisterEffect(e2)
	-- 装备怪兽的守备力上升300。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	e3:SetValue(300)
	c:RegisterEffect(e3)
	-- 恶魔族怪兽才能装备。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EQUIP_LIMIT)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetValue(c4614116.eqlimit)
	c:RegisterEffect(e4)
end
-- 装备限制判定：仅当目标怪兽种族为恶魔族（RACE_FIEND）时，这张卡才能装备。
function c4614116.eqlimit(e,c)
	return c:IsRace(RACE_FIEND)
end
-- 对象筛选条件：选择场上表侧表示且种族为恶魔族的怪兽。
function c4614116.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_FIEND)
end
-- 发动时的目标处理：确认场上存在可装备对象后，提示玩家选择1只表侧表示恶魔族怪兽作为装备对象，并设置装备效果的操作信息。
function c4614116.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c4614116.filter(chkc) end
	-- 发动条件检查：场上是否存在至少1只满足条件的表侧恶魔族怪兽，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c4614116.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家展示“请选择要装备的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只表侧表示恶魔族怪兽作为装备对象，并将其登记为当前连锁的对象。
	Duel.SelectTarget(tp,c4614116.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息，声明本次操作是将这张装备卡装备给对象怪兽（CATEGORY_EQUIP），数量为1。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理：若装备卡与对象怪兽仍与效果相关联且对象保持表侧表示，则将这张卡装备给对象怪兽。
function c4614116.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张装备卡装备给对象怪兽（成功则作为装备魔法装备）。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end

--融合武器ムラサメブレード
-- 效果：
-- 战士族怪兽才能装备。
-- ①：装备怪兽的攻击力上升800。
-- ②：给怪兽装备的这张卡不会被效果破坏。
function c37684215.initial_effect(c)
	-- 战士族怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c37684215.target)
	e1:SetOperation(c37684215.operation)
	c:RegisterEffect(e1)
	-- ①：装备怪兽的攻击力上升800。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(800)
	c:RegisterEffect(e2)
	-- 战士族怪兽才能装备。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c37684215.eqlimit)
	c:RegisterEffect(e3)
	-- ②：给怪兽装备的这张卡不会被效果破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(c37684215.indcon)
	e4:SetValue(1)
	c:RegisterEffect(e4)
end
-- 装备限制判定：该卡仅允许装备给战士族怪兽。
function c37684215.eqlimit(e,c)
	return c:IsRace(RACE_WARRIOR)
end
-- 筛选场上表侧表示且种族为战士族的怪兽，作为装备对象候补。
function c37684215.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR)
end
-- 发动时处理：确认场上存在符合条件的表侧表示战士族怪兽，选择其中1只作为对象，并宣告进行装备。
function c37684215.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c37684215.filter(chkc) end
	-- 发动条件检查：若场上不存在任何符合条件的表侧表示战士族怪兽，则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c37684215.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家显示“请选择要装备的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从双方场上选择1只表侧表示的战士族怪兽作为此卡的装备对象。
	Duel.SelectTarget(tp,c37684215.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息，声明此卡将进行装备（对象为此卡自身）。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理时：若此卡与对象均未离场且对象仍表侧表示，则把此卡装备给对象怪兽。
function c37684215.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的装备对象怪兽。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将此卡作为装备卡装备到对象怪兽身上。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 因装备条件判定：此卡处于魔陷区且正装备着怪兽时，才适用“不会被效果破坏”的效果。
function c37684215.indcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetEquipTarget()
end

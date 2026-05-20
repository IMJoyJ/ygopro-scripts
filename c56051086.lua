--No.43 魂魄傀儡鬼ソウル・マリオネッター
-- 效果：
-- 暗属性2星怪兽×3
-- ①：1回合1次，把这张卡1个超量素材取除，以自己墓地1只「No.」怪兽为对象才能发动。那只怪兽当作装备卡使用给这张卡装备。
-- ②：有「No.」卡装备的这张卡不会被战斗·效果破坏。
-- ③：1回合1次，自己基本分回复时才能发动。这张卡的攻击力上升那个数值，给与对方那个数值的伤害。
function c56051086.initial_effect(c)
	-- 添加XYZ召唤手续：暗属性2星怪兽×3。
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),2,3)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除，以自己墓地1只「No.」怪兽为对象才能发动。那只怪兽当作装备卡使用给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(56051086,0))  --"装备"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c56051086.eqcost)
	e1:SetTarget(c56051086.eqtg)
	e1:SetOperation(c56051086.eqop)
	c:RegisterEffect(e1)
	-- ②：有「No.」卡装备的这张卡不会被战斗·效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetCondition(c56051086.indcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e3)
	-- ③：1回合1次，自己基本分回复时才能发动。这张卡的攻击力上升那个数值，给与对方那个数值的伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(56051086,1))  --"攻击上升"
	e4:SetCategory(CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_RECOVER)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c56051086.damcon)
	e4:SetTarget(c56051086.damtg)
	e4:SetOperation(c56051086.damop)
	c:RegisterEffect(e4)
end
-- 设定该卡片的「No.」编号为43。
aux.xyz_number[56051086]=43
-- 装备效果的Cost：检查并取除这张卡的1个超量素材。
function c56051086.eqcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤条件：自己墓地中可以被装备的「No.」怪兽。
function c56051086.filter(c)
	return c:IsSetCard(0x48) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
-- 装备效果的Target：检查魔法与陷阱区域是否有空位，并选择自己墓地1只「No.」怪兽作为效果对象。
function c56051086.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c56051086.filter(chkc) end
	-- 检查发动时自己场上的魔法与陷阱区域是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己墓地是否存在满足条件的「No.」怪兽。
		and Duel.IsExistingTarget(c56051086.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要装备的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己墓地1只满足条件的「No.」怪兽作为效果对象并进行取对象确认。
	local g=Duel.SelectTarget(tp,c56051086.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：包含1张离开墓地的卡。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 装备效果的Operation：将选择的墓地怪兽作为装备卡装备给这张卡，并添加装备限制。
function c56051086.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果处理时作为对象的怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽作为装备卡装备给这张卡，若装备失败则结束处理。
		if not Duel.Equip(tp,tc,c,false) then return end
		-- 那只怪兽当作装备卡使用给这张卡装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c56051086.eqlimit)
		tc:RegisterEffect(e1)
	end
end
-- 装备限制：只能装备给该效果的拥有者（即这张卡）。
function c56051086.eqlimit(e,c)
	return c==e:GetOwner()
end
-- 破坏抗性的适用条件：这张卡装备有「No.」卡。
function c56051086.indcon(e)
	return e:GetHandler():GetEquipGroup():IsExists(Card.IsSetCard,1,nil,0x48)
end
-- 攻击力上升与伤害效果的发动条件：自己基本分回复时。
function c56051086.damcon(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
-- 攻击力上升与伤害效果的Target：设置给与对方伤害的操作信息。
function c56051086.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：给与对方玩家等同于回复数值的伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ev)
end
-- 攻击力上升与伤害效果的Operation：使这张卡的攻击力上升回复的数值，并给与对方该数值的伤害。
function c56051086.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 这张卡的攻击力上升那个数值
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(ev)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
	-- 给与对方等同于回复数值的效果伤害。
	Duel.Damage(1-tp,ev,REASON_EFFECT)
end

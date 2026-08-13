--破壊剣－アームズバスターブレード
-- 效果：
-- ①：自己主要阶段以自己场上1只「破坏之剑士」为对象才能发动。从自己的手卡·场上把这只怪兽当作装备卡使用给那只自己怪兽装备。
-- ②：这张卡装备中的场合，对方场上的已是表侧表示存在的魔法·陷阱卡不能把效果发动。
-- ③：把装备的这张卡送去墓地才能发动。这张卡装备过的怪兽的攻击力直到回合结束时上升1000。
function c38601126.initial_effect(c)
	-- ①：自己主要阶段以自己场上1只「破坏之剑士」为对象才能发动。从自己的手卡·场上把这只怪兽当作装备卡使用给那只自己怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetTarget(c38601126.eqtg)
	e1:SetOperation(c38601126.eqop)
	c:RegisterEffect(e1)
	-- ②：这张卡装备中的场合，对方场上的已是表侧表示存在的魔法·陷阱卡不能把效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,1)
	e2:SetCondition(c38601126.condition)
	e2:SetValue(c38601126.aclimit)
	c:RegisterEffect(e2)
	-- ③：把装备的这张卡送去墓地才能发动。这张卡装备过的怪兽的攻击力直到回合结束时上升1000。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c38601126.condition)
	e3:SetCost(c38601126.dacost)
	e3:SetOperation(c38601126.daop)
	c:RegisterEffect(e3)
end
-- 过滤条件：卡为表侧表示且卡号是78193831（「破坏之剑士」）。
function c38601126.filter(c)
	return c:IsFaceup() and c:IsCode(78193831)
end
-- ①效果的发动条件与取对象：确认自己场上有表侧表示的「破坏之剑士」可作为对象，且自己魔陷区有空位；若检查对象时，仅允许选择自己场上表侧表示的「破坏之剑士」。
function c38601126.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c38601126.filter(chkc) end
	-- 检查自己魔陷区是否有可用空格（用于放置装备卡）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己场上是否存在表侧表示且卡号为78193831（「破坏之剑士」）的怪兽，可以作为装备对象。
		and Duel.IsExistingTarget(c38601126.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 显示“请选择要装备的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从自己场上表侧表示的「破坏之剑士」中选择1只作为效果对象，并设为连锁对象。
	Duel.SelectTarget(tp,c38601126.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ①效果处理：确认自身仍与效果相关且不是里侧表示；若对象仍合法，则把这张卡装备给对象怪兽，并附加仅能装备给该对象的装备限制；若对象不合法则这张卡以效果原因送墓。
function c38601126.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if c:IsLocation(LOCATION_MZONE) and c:IsFacedown() then return end
	-- 取得发动时选择的装备对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 若自己魔陷区无空位、对象怪兽已失控、变为里侧表示或不再与效果相关，则装备处理失败。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsControler(1-tp) or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		-- 因无法装备，将这张卡以效果原因送去墓地。
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 将这张卡作为装备卡装备给对象怪兽。
	Duel.Equip(tp,c,tc)
	-- 从自己的手卡·场上把这只怪兽当作装备卡使用给那只自己怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c38601126.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
end
-- 装备限制判定：仅允许装备给效果发动时选择的「破坏之剑士」（记录在LabelObject中）。
function c38601126.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 判断这张卡是否处于装备状态（存在装备对象）。
function c38601126.condition(e)
	return e:GetHandler():GetEquipTarget()
end
-- ②效果的禁止发动判定：对方在魔法与陷阱区域发动的非卡发动的效果（即已是表侧表示的魔法·陷阱卡发动效果）被禁止。
function c38601126.aclimit(e,re,tp)
	local loc=re:GetActivateLocation()
	return loc==LOCATION_SZONE and not re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- ③效果的发动代价：检查装备中的这张卡能否作为代价送去墓地，并将装备对象怪兽设为连锁对象，然后送墓。
function c38601126.dacost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	local tc=e:GetHandler():GetEquipTarget()
	-- 将这张卡装备过的怪兽设为连锁对象，以便效果处理时取得该怪兽。
	Duel.SetTargetCard(tc)
	-- 将这张装备卡作为代价送去墓地。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- ③效果处理：这张卡装备过的怪兽攻击力直到回合结束时上升1000。
function c38601126.daop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得通过代价记录的装备对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 这张卡装备过的怪兽的攻击力直到回合结束时上升1000。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end

--超重武者装留グレート・ウォール
-- 效果：
-- ①：自己主要阶段以自己场上1只「超重武者」怪兽为对象才能发动。从自己的手卡·场上把这只怪兽当作守备力上升1200的装备卡使用给那只自己怪兽装备。
-- ②：用这张卡的效果把这张卡装备的怪兽被选择作为攻击对象时，把装备的这张卡送去墓地才能发动。那次攻击无效，装备怪兽的守备力变成0。
function c31181711.initial_effect(c)
	-- ①：自己主要阶段以自己场上1只「超重武者」怪兽为对象才能发动。从自己的手卡·场上把这只怪兽当作守备力上升1200的装备卡使用给那只自己怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31181711,0))  --"装备"
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetTarget(c31181711.eqtg)
	e1:SetOperation(c31181711.eqop)
	c:RegisterEffect(e1)
end
-- 筛选条件：对象必须是表侧表示且字段为「超重武者」的怪兽。
function c31181711.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x9a)
end
-- 目标选择条件：己方魔陷区有空位，且存在至少1只表侧表示「超重武者」怪兽可以成为对象（不能选择发动效果的这张卡自身）。
function c31181711.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c31181711.filter(chkc) end
	-- 发动条件检查：己方魔陷区存在可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 发动条件检查：场上存在符合条件的「超重武者」怪兽可以作为装备对象，且不包含这张卡自身。
		and Duel.IsExistingTarget(c31181711.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 向玩家显示选择提示：请选择要装备的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从自己场上选择1只表侧表示「超重武者」怪兽作为装备对象。
	Duel.SelectTarget(tp,c31181711.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
end
-- 效果处理：确认这张卡仍与效果关联且不在里侧表示后，获取对象；若魔陷区空位或对象不满足条件，则这张卡送去墓地；否则将这张卡装备给对象，并依次注册装备限制、守备力上升1200、②攻击无效效果。
function c31181711.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if c:IsLocation(LOCATION_MZONE) and c:IsFacedown() then return end
	-- 获取被选择为装备对象的怪兽。
	local tc=Duel.GetFirstTarget()
	-- 装备前检查：魔陷区没有空位、对象不再是己方控制、对象变成里侧表示或已与效果失去关联时，装备处理失败。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsControler(1-tp) or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		-- 装备失败时，将这张卡以效果原因送去墓地。
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 将这张卡作为装备卡装备给对象怪兽。
	Duel.Equip(tp,c,tc)
	-- ①：自己主要阶段以自己场上1只「超重武者」怪兽为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c31181711.eqlimit)
	c:RegisterEffect(e1)
	-- 从自己的手卡·场上把这只怪兽当作守备力上升1200的装备卡使用给那只自己怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetValue(1200)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
	-- ②：用这张卡的效果把这张卡装备的怪兽被选择作为攻击对象时，把装备的这张卡送去墓地才能发动。那次攻击无效，装备怪兽的守备力变成0。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BE_BATTLE_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c31181711.btcon)
	e3:SetCost(c31181711.btcost)
	e3:SetOperation(c31181711.btop)
	e3:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e3)
end
-- 装备限制：这张卡作为装备卡时，只能装备给「超重武者」怪兽。
function c31181711.eqlimit(e,c)
	return c:IsSetCard(0x9a)
end
-- 效果条件：被选择为攻击对象的怪兽必须是这张卡当前装备的怪兽。
function c31181711.btcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetFirst()==e:GetHandler():GetEquipTarget()
end
-- ②效果的发动条件与代价：装备怪兽被选择为攻击对象时，可作为代价把装备的这张卡送去墓地；代价检查时确认此卡能被送去墓地，支付时先记录装备对象再送去墓地。
function c31181711.btcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	e:SetLabelObject(e:GetHandler():GetEquipTarget())
	-- 支付代价：将装备中的这张卡作为代价送去墓地。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- ②效果处理：无效那次攻击，若无效成功且装备怪兽仍表侧表示，则将其守备力变为0。
function c31181711.btop(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetLabelObject()
	-- 判断攻击无效成功且装备怪兽未离场/仍表侧，才继续执行守备力变更。
	if Duel.NegateAttack() and ec:IsFaceup() then
		-- 装备怪兽的守备力变成0。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		ec:RegisterEffect(e1)
	end
end

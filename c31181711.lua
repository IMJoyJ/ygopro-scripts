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
-- 筛选场上正面表示的「超重武者」怪兽
function c31181711.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x9a)
end
-- 效果处理时选择目标怪兽，检查是否满足条件
function c31181711.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c31181711.filter(chkc) end
	-- 判断玩家场上是否有足够的魔法陷阱区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断玩家场上是否有符合条件的「超重武者」怪兽
		and Duel.IsExistingTarget(c31181711.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择目标怪兽
	Duel.SelectTarget(tp,c31181711.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
end
-- 装备效果处理
function c31181711.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if c:IsLocation(LOCATION_MZONE) and c:IsFacedown() then return end
	-- 获取选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断是否满足装备条件
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsControler(1-tp) or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		-- 将装备卡送入墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 将装备卡装备给目标怪兽
	Duel.Equip(tp,c,tc)
	-- 装备对象限制，只能是「超重武者」怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c31181711.eqlimit)
	c:RegisterEffect(e1)
	-- 装备卡效果，使装备怪兽守备力上升1200
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
-- 装备对象限制函数，只能是「超重武者」怪兽
function c31181711.eqlimit(e,c)
	return c:IsSetCard(0x9a)
end
-- 判断是否为装备怪兽被选为攻击对象
function c31181711.btcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetFirst()==e:GetHandler():GetEquipTarget()
end
-- 支付装备卡作为代价，将装备卡送入墓地
function c31181711.btcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	e:SetLabelObject(e:GetHandler():GetEquipTarget())
	-- 将装备卡送入墓地作为代价
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 处理攻击无效和守备力归零效果
function c31181711.btop(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetLabelObject()
	-- 无效攻击并判断装备怪兽是否正面表示
	if Duel.NegateAttack() and ec:IsFaceup() then
		-- 将装备怪兽的守备力变为0
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_DEFENSE_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		ec:RegisterEffect(e1)
	end
end

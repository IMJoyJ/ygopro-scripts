--破壊剣－ウィザードバスターブレード
-- 效果：
-- ①：自己主要阶段以自己场上1只「破坏之剑士」为对象才能发动。从自己的手卡·场上把这只怪兽当作装备卡使用给那只自己怪兽装备。
-- ②：这张卡装备中的场合，对方不能把墓地的怪兽的效果发动。
-- ③：把装备的这张卡送去墓地，以「破坏剑-魔法破坏之剑」以外的自己墓地1只「破坏剑」怪兽为对象才能发动。那只怪兽加入手卡。
function c2602411.initial_effect(c)
	-- ①：自己主要阶段以自己场上1只「破坏之剑士」为对象才能发动。从自己的手卡·场上把这只怪兽当作装备卡使用给那只自己怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetTarget(c2602411.eqtg)
	e1:SetOperation(c2602411.eqop)
	c:RegisterEffect(e1)
	-- ②：这张卡装备中的场合，对方不能把墓地的怪兽的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,1)
	e2:SetCondition(c2602411.condition)
	e2:SetValue(c2602411.aclimit)
	c:RegisterEffect(e2)
	-- ③：把装备的这张卡送去墓地，以「破坏剑-魔法破坏之剑」以外的自己墓地1只「破坏剑」怪兽为对象才能发动。那只怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c2602411.condition)
	e3:SetCost(c2602411.thcost)
	e3:SetTarget(c2602411.thtg)
	e3:SetOperation(c2602411.thop)
	c:RegisterEffect(e3)
end
-- 过滤函数：判断怪兽必须是表侧表示且卡名是「破坏之剑士」(78193831)。
function c2602411.filter(c)
	return c:IsFaceup() and c:IsCode(78193831)
end
-- 发动时的取对象处理：若在连锁中指定对象则检查对象是否符合条件；在发动确认阶段检查己方魔陷区有空位且场上存在可选取的表侧表示「破坏之剑士」。
function c2602411.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c2602411.filter(chkc) end
	-- 检查自己魔陷区是否有空位，以保证这张卡能作为装备卡装备到场上。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己场上是否存在至少1只表侧表示且卡名为「破坏之剑士」的怪兽可作为装备对象。
		and Duel.IsExistingTarget(c2602411.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家显示“请选择要装备的卡”的提示信息，用于装备对象的选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只符合条件的表侧表示「破坏之剑士」作为这张卡的装备对象。
	Duel.SelectTarget(tp,c2602411.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果①的装备处理：确认这张卡和对象合法后将其装备给对象；若无法正常装备则这张卡送去墓地。
function c2602411.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if c:IsLocation(LOCATION_MZONE) and c:IsFacedown() then return end
	-- 获取被选择为装备对象的「破坏之剑士」。
	local tc=Duel.GetFirstTarget()
	-- 判断是否因魔陷区无空位、对象控制权变更、对象变为里侧或与效果失去关联而导致装备处理不能进行。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsControler(1-tp) or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		-- 装备条件不满足时，将这张卡以效果原因送去墓地。
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 将这张卡作为装备卡装备给对象怪兽「破坏之剑士」。
	Duel.Equip(tp,c,tc)
	-- ①：从自己的手卡·场上把这只怪兽当作装备卡使用给那只自己怪兽装备（为这张卡设置装备对象限制）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c2602411.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
end
-- 装备限制函数：只有与效果记录的LabelObject相同的怪兽（即当初选择的「破坏之剑士」）才能装备这张卡。
function c2602411.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 条件函数：这张卡存在装备对象，即处于装备魔法卡状态时条件成立（用于②③）。
function c2602411.condition(e)
	return e:GetHandler():GetEquipTarget()
end
-- 限制条件：对方发动的效果必须是发动区域为墓地且类型为怪兽效果时，才会被禁止。
function c2602411.aclimit(e,re,tp)
	local loc=re:GetActivateLocation()
	return loc==LOCATION_GRAVE and re:IsActiveType(TYPE_MONSTER)
end
-- ③的代价处理：检查这张装备卡能否作为代价送去墓地；可以则将其送去墓地作为发动代价。
function c2602411.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将这张装备中的卡作为COST送去墓地。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 检索/选择条件：自己墓地中属于「破坏剑」(0xd6)系列怪兽、不是「破坏剑-魔法破坏之剑」自身、并且能加入手卡的卡。
function c2602411.thfilter(c)
	return c:IsSetCard(0xd6) and c:IsType(TYPE_MONSTER) and not c:IsCode(2602411) and c:IsAbleToHand()
end
-- ③的取对象处理：选择自己墓地1只符合条件的「破坏剑」怪兽，并设置回手效果的操作信息。
function c2602411.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c2602411.thfilter(chkc) end
	-- 发动时检查自己墓地是否存在至少1只符合条件的「破坏剑」怪兽作为对象。
	if chk==0 then return Duel.IsExistingTarget(c2602411.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家显示“请选择要加入手牌的卡”的提示信息，用于对象选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只符合条件的「破坏剑」怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c2602411.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置当前连锁的操作信息为“将对象卡加入手卡”，供相关卡进行效果检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ③的结算处理：将选择的对象怪兽加入手卡。
function c2602411.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取③选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以效果原因送回持有者手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end

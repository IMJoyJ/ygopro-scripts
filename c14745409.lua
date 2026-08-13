--聖剣ガラティーン
-- 效果：
-- 战士族怪兽才能装备。这个卡名的③的效果1回合只能使用1次。
-- ①：「圣剑 加拉廷」在自己场上只能有1张表侧表示存在。
-- ②：装备怪兽的攻击力上升1000，每次自己准备阶段下降200。
-- ③：场上的表侧表示的这张卡被破坏送去墓地的场合，以自己场上1只战士族「圣骑士」怪兽为对象才能发动。那只自己的战士族「圣骑士」怪兽把这张卡装备。
function c14745409.initial_effect(c)
	c:SetUniqueOnField(1,0,14745409)
	-- 战士族怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c14745409.target)
	e1:SetOperation(c14745409.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽的攻击力上升1000
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(1000)
	c:RegisterEffect(e2)
	-- 战士族怪兽才能装备。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c14745409.eqlimit)
	c:RegisterEffect(e3)
	-- 每次自己准备阶段下降200
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c14745409.atkcon)
	e4:SetOperation(c14745409.atkop)
	c:RegisterEffect(e4)
	-- 这个卡名的③的效果1回合只能使用1次。③：场上的表侧表示的这张卡被破坏送去墓地的场合，以自己场上1只战士族「圣骑士」怪兽为对象才能发动。那只自己的战士族「圣骑士」怪兽把这张卡装备。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(14745409,0))  --"装备"
	e5:SetCategory(CATEGORY_EQUIP)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetCountLimit(1,14745409)
	e5:SetCondition(c14745409.eqcon)
	e5:SetTarget(c14745409.eqtg)
	e5:SetOperation(c14745409.operation2)
	c:RegisterEffect(e5)
end
-- 装备限制判定：要求装备对象为战士族怪兽。
function c14745409.eqlimit(e,c)
	return c:IsRace(RACE_WARRIOR)
end
-- 过滤器：选择场上表侧表示且种族为战士族的怪兽作为装备对象候选。
function c14745409.eqfilter1(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR)
end
-- 这张卡发动时的对象处理：从场上选择1只表侧表示战士族怪兽作为装备对象，并设置装备操作信息。
function c14745409.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c14745409.eqfilter1(chkc) end
	-- 发动合法性检查：场上是否存在至少1只表侧表示战士族怪兽可作为装备对象。
	if chk==0 then return Duel.IsExistingTarget(c14745409.eqfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家发出选择提示，提示内容为“请选择要装备的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从场上表侧表示战士族怪兽中选择1只，并设为这张卡发动效果的对象。
	Duel.SelectTarget(tp,c14745409.eqfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息，标明该效果涉及装备操作，对象为这张卡自身。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理时，若这张卡和对象怪兽仍与效果关联、对象仍表侧表示且不违反同名卡限制，则将这张卡装备给该怪兽。
function c14745409.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取出发动时选择的装备对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() and c:CheckUniqueOnField(tp) then
		-- 将装备卡c装备给对象怪兽tc，完成装备动作。
		Duel.Equip(tp,c,tc)
	end
end
-- 准备阶段攻击力下降效果的触发条件：当前回合玩家为这张卡的控制者，即自己的准备阶段。
function c14745409.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为这张卡的控制者，仅在自己的准备阶段返回真。
	return Duel.GetTurnPlayer()==tp
end
-- 准备阶段时处理攻击力下降：首次创建-200攻击力效果并注册，后续每次将效果数值再减少200。
function c14745409.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetFlagEffect(14745409)==0 then
		-- 每次自己准备阶段下降200。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_EQUIP)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-200)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		c:RegisterFlagEffect(14745409,RESET_EVENT+RESETS_STANDARD,0,0)
		e:SetLabelObject(e1)
		e:SetLabel(2)
	else
		local pe=e:GetLabelObject()
		local ct=e:GetLabel()
		e:SetLabel(ct+1)
		pe:SetValue(ct*-200)
	end
end
-- ③效果的发动条件：这张卡在被破坏送去墓地前位于场上且表侧表示，破坏是送去墓地的原因，同时满足同名卡只能有1张表侧表示的限制。
function c14745409.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP) and c:IsReason(REASON_DESTROY) and c:CheckUniqueOnField(tp)
end
-- 过滤器：选择自己场上表侧表示、属于「圣骑士」字段且种族为战士族的怪兽作为装备对象候选。
function c14745409.eqfilter2(c)
	return c:IsFaceup() and c:IsSetCard(0x107a) and c:IsRace(RACE_WARRIOR)
end
-- ③效果发动时的对象处理：检查自身是否仍与效果关联、自己魔陷区是否有空位，并从自己场上选择1只战士族「圣骑士」怪兽作为装备对象。
function c14745409.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c14745409.eqfilter2(chkc) end
	-- 合法条件检查：此卡仍与效果关联且未离开墓地，以及自己魔陷区有空位可以装备。
	if chk==0 then return e:GetHandler():IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 合法条件检查：自己场上是否存在表侧表示的战士族「圣骑士」怪兽可以作为装备对象。
		and Duel.IsExistingTarget(c14745409.eqfilter2,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家发出选择提示，提示内容为“请选择要装备的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从自己场上的表侧表示战士族「圣骑士」怪兽中选择1只，并设为③效果的对象。
	Duel.SelectTarget(tp,c14745409.eqfilter2,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置当前连锁的操作信息，标明该效果涉及装备操作，对象为这张卡自身。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
	-- 设置当前连锁的操作信息，标明这张卡将从墓地离开（因装备而离开墓地）。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- ③效果处理时：若这张卡和对象怪兽仍与效果关联、对象怪兽仍表侧表示且由自己控制，并是战士族「圣骑士」，则将这张卡从墓地装备给该怪兽。
function c14745409.operation2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取出③效果发动时选择的装备对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc and c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup()
		and tc:IsControler(tp) and tc:IsSetCard(0x107a) and c14745409.eqlimit(nil,tc) and c:CheckUniqueOnField(tp) then
		-- 将装备卡c从墓地装备给对象怪兽tc，完成③效果的装备动作。
		Duel.Equip(tp,c,tc)
	end
end

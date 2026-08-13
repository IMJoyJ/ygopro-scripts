--バク団
-- 效果：
-- 自己的主要阶段时，手卡或者自己场上的这只怪兽可以当作装备卡使用给对方场上1只超量怪兽装备。用这个效果把这张卡装备的怪兽没有超量素材的场合，那只怪兽破坏。此外，这张卡当作装备卡使用而装备中的场合，每次对方的准备阶段把装备怪兽1个超量素材取除。
function c38210374.initial_effect(c)
	-- 自己的主要阶段时，手卡或者自己场上的这只怪兽可以当作装备卡使用给对方场上1只超量怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(38210374,0))  --"装备"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetTarget(c38210374.eqtg)
	e1:SetOperation(c38210374.eqop)
	c:RegisterEffect(e1)
	-- 此外，这张卡当作装备卡使用而装备中的场合，每次对方的准备阶段把装备怪兽1个超量素材取除。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(38210374,1))  --"取除素材"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c38210374.rmcon)
	e2:SetTarget(c38210374.rmtg)
	e2:SetOperation(c38210374.rmop)
	c:RegisterEffect(e2)
end
-- 装备对象的选择条件：怪兽必须是表侧表示且为超量怪兽。
function c38210374.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- 装备效果发动时的目标处理：检查自己魔陷区有空位且对方场上有满足条件的超量怪兽，然后选择对方场上1只超量怪兽作为装备对象。
function c38210374.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c38210374.filter(chkc) end
	-- 发动条件：自己魔陷区存在空位（放置作为装备卡的本卡）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 发动条件：对方场上存在至少1只表侧表示的超量怪兽可以作为装备对象。
		and Duel.IsExistingTarget(c38210374.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 给出选择装备对象的提示文字，让玩家选择要装备的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择对方场上1只满足条件的超量怪兽，并将其登记为本次效果的取对象目标。
	Duel.SelectTarget(tp,c38210374.filter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 装备效果的解决处理：检查本卡和目标是否仍合法，合法则将本卡装备给目标，并给本卡追加装备限制和自毁效果；不合法则本卡送去墓地。
function c38210374.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if c:IsLocation(LOCATION_MZONE) and c:IsFacedown() then return end
	-- 取得效果发动时选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	-- 判断是否仍满足装备条件：魔陷区有空位、目标表侧存在且与效果关联，否则处理失败。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		-- 装备处理失败时，将这张卡以效果原因送去墓地。
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 将这张卡作为装备卡装备到目标超量怪兽上。
	Duel.Equip(tp,c,tc)
	-- 给对方场上1只超量怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c38210374.eqlimit)
	c:RegisterEffect(e1)
	-- 用这个效果把这张卡装备的怪兽没有超量素材的场合，那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_SELF_DESTROY)
	e2:SetCondition(c38210374.descon)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
end
-- 装备限制判定：只有超量怪兽才能被这张卡装备。
function c38210374.eqlimit(e,c)
	return c:IsType(TYPE_XYZ)
end
-- 自毁效果的触发条件：装备对象没有超量素材。
function c38210374.descon(e)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and ec:GetOverlayCount()==0
end
-- 取除素材效果的触发条件：当前阶段为准备阶段且是对方回合。
function c38210374.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家不是这张卡的控制者，即对方回合。
	return Duel.GetTurnPlayer()~=tp
end
-- 取除素材效果发动前的合法性检查：装备对象存在且可以取除1个超量素材。
function c38210374.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ec=e:GetHandler():GetEquipTarget()
		return ec and ec:CheckRemoveOverlayCard(tp,1,REASON_EFFECT)
	end
end
-- 效果处理：将装备怪兽的1个超量素材取除（送去墓地，原因为效果）。
function c38210374.rmop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local ec=e:GetHandler():GetEquipTarget()
	if ec then
		ec:RemoveOverlayCard(tp,1,1,REASON_EFFECT)
	end
end

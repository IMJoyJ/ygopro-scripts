--ヴァイロン・テトラ
-- 效果：
-- 这张卡从怪兽卡区域上送去墓地的场合，可以支付500基本分，把这张卡当作装备卡使用给自己场上表侧表示存在的1只怪兽装备。这张卡的装备怪兽被破坏的场合，可以作为代替把这张卡破坏。
function c1281505.initial_effect(c)
	-- 这张卡从怪兽卡区域上送去墓地的场合，可以支付500基本分，把这张卡当作装备卡使用给自己场上表侧表示存在的1只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(1281505,0))  --"当作装备卡装备"
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c1281505.eqcon)
	e1:SetCost(c1281505.eqcost)
	e1:SetTarget(c1281505.eqtg)
	e1:SetOperation(c1281505.eqop)
	c:RegisterEffect(e1)
	-- 这张卡的装备怪兽被破坏的场合，可以作为代替把这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetTarget(c1281505.reptg)
	e3:SetOperation(c1281505.repop)
	c:RegisterEffect(e3)
end
-- 检查这张卡被送去墓地前是否位于怪兽卡区域，以判定是否满足“从怪兽卡区域上送去墓地”的诱发条件。
function c1281505.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE)
end
-- 设置发动代价：需要支付500基本分，包含支付检查和实际支付。
function c1281505.eqcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动合法性检查时，确认玩家能够支付500基本分作为代价。
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 实际支付500基本分作为发动效果的代价。
	Duel.PayLPCost(tp,500)
end
-- 设置效果发动目标：选择自己场上表侧表示存在的1只怪兽，且需要魔陷区有空位容纳装备卡。
function c1281505.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 确认自己魔陷区存在空位，以能放置作为装备卡的这张卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 确认自己场上有表侧表示怪兽存在，可以作为装备对象。
		and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	-- 显示选择提示“请选择要装备的卡”，引导玩家进行装备对象的选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从自己场上表侧表示怪兽中选择1只，并将其登记为当前连锁的取对象目标。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：这张卡与目标怪兽均有效时，将这张卡装备给目标怪兽，并追加装备对象限制。
function c1281505.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得发动时选择的装备对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 将这张卡作为装备卡装备给目标怪兽，完成“当作装备卡使用”的装备操作。
		Duel.Equip(tp,c,tc)
		-- 把这张卡当作装备卡使用给自己场上表侧表示存在的1只怪兽装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(c1281505.eqlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
-- 规定这张卡作为装备卡时，仅可装备给自己控制的怪兽，以实现装备对象限制。
function c1281505.eqlimit(e,c)
	local tp=e:GetHandlerPlayer()
	return c:IsControler(tp)
end
-- 代替破坏效果的触发判定：装备怪兽将要被破坏时，检查这张卡是否可被破坏、非预定破坏、且装备怪兽不是被代替原因破坏。
function c1281505.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
		and not c:GetEquipTarget():IsReason(REASON_REPLACE) end
	-- 询问玩家是否发动代替破坏效果，选择“是”则用这张卡代替装备怪兽破坏。
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- 代替破坏效果处理：将这张卡破坏，以代替装备怪兽被破坏。
function c1281505.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果和代替破坏的原因破坏这张卡，完成代替装备怪兽破坏的处理。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT+REASON_REPLACE)
end

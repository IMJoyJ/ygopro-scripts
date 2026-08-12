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
-- 效果发动条件：这张卡从怪兽区域送去墓地
function c1281505.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE)
end
-- 效果发动费用：支付500基本分
function c1281505.eqcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否能支付500基本分
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 支付500基本分
	Duel.PayLPCost(tp,500)
end
-- 效果发动选择目标：选择1只自己场上的表侧表示怪兽
function c1281505.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 检查场上是否有足够的魔法卡区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己场上是否存在1只表侧表示怪兽
		and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	-- 选择1只自己场上的表侧表示怪兽作为装备对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果发动处理：将装备卡装备给选择的怪兽
function c1281505.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取选择的装备对象怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 将装备卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
		-- 装备对象限制：只能装备给自己场上的怪兽
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(c1281505.eqlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
-- 装备对象限制判定函数：只能装备给自己控制的怪兽
function c1281505.eqlimit(e,c)
	local tp=e:GetHandlerPlayer()
	return c:IsControler(tp)
end
-- 代替破坏效果判定函数：是否选择发动代替破坏效果
function c1281505.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
		and not c:GetEquipTarget():IsReason(REASON_REPLACE) end
	-- 选择是否发动代替破坏效果
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- 代替破坏效果处理函数：将装备卡破坏
function c1281505.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将装备卡破坏
	Duel.Destroy(e:GetHandler(),REASON_EFFECT+REASON_REPLACE)
end

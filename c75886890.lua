--ヴァイロン・スフィア
-- 效果：
-- ①：这张卡从怪兽区域送去墓地的场合，支付500基本分，以自己场上1只表侧表示怪兽为对象才能发动。这张卡当作装备卡使用给那只自己怪兽装备。
-- ②：把当作装备卡使用的这张卡送去墓地，以这张卡装备过的怪兽可以装备的自己墓地1张装备魔法卡为对象才能发动。这张卡装备过的怪兽把作为对象的卡装备。
function c75886890.initial_effect(c)
	-- ①：这张卡从怪兽区域送去墓地的场合，支付500基本分，以自己场上1只表侧表示怪兽为对象才能发动。这张卡当作装备卡使用给那只自己怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(75886890,0))  --"当成装备卡装备"
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c75886890.eqcon)
	e1:SetCost(c75886890.eqcost)
	e1:SetTarget(c75886890.eqtg)
	e1:SetOperation(c75886890.eqop)
	c:RegisterEffect(e1)
	-- ②：把当作装备卡使用的这张卡送去墓地，以这张卡装备过的怪兽可以装备的自己墓地1张装备魔法卡为对象才能发动。这张卡装备过的怪兽把作为对象的卡装备。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(75886890,1))  --"选择一张装备魔法卡装备"
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCost(c75886890.eqcost2)
	e2:SetTarget(c75886890.eqtg2)
	e2:SetOperation(c75886890.eqop2)
	c:RegisterEffect(e2)
end
-- 判断这张卡是否从怪兽区域送去墓地
function c75886890.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE)
end
-- 检查并支付500基本分
function c75886890.eqcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查玩家是否能支付500基本分
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 支付500基本分
	Duel.PayLPCost(tp,500)
end
-- 检查魔法与陷阱区域是否有空位，以及自己场上是否存在可以成为效果对象的表侧表示怪兽
function c75886890.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 在发动准备阶段，检查自己的魔法与陷阱区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 并且检查自己场上是否存在可以成为效果对象的表侧表示怪兽
		and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只表侧表示怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 将这张卡作为装备卡装备给作为对象的怪兽，并设置装备限制
function c75886890.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 将这张卡作为装备卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
		-- 这张卡当作装备卡使用给那只自己怪兽装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(c75886890.eqlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
-- 限制这张卡只能装备给自己的怪兽
function c75886890.eqlimit(e,c)
	local tp=e:GetHandlerPlayer()
	return c:IsControler(tp)
end
-- 将当作装备卡使用的这张卡送去墓地作为发动的代价，并记录原本装备的怪兽
function c75886890.eqcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	e:SetLabelObject(e:GetHandler():GetEquipTarget())
	-- 将作为代价的这张卡送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤出自己墓地中可以装备给指定怪兽的装备魔法卡
function c75886890.filter2(c,ec)
	return c:IsType(TYPE_EQUIP) and c:CheckEquipTarget(ec)
end
-- 选择自己墓地1张可以装备给原本装备怪兽的装备魔法卡作为效果对象
function c75886890.eqtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ec=e:GetHandler():GetEquipTarget()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c75886890.filter2(chkc,ec) end
	-- 在发动准备阶段，检查是否存在原本装备的怪兽，以及自己墓地中是否存在可以装备给该怪兽的装备魔法卡
	if chk==0 then return ec and Duel.IsExistingTarget(c75886890.filter2,tp,LOCATION_GRAVE,0,1,nil,ec) end
	-- 提示玩家选择一张装备魔法卡
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(75886890,2))  --"请选择一张装备魔法卡"
	-- 选择自己墓地1张符合条件的装备魔法卡作为效果对象
	Duel.SelectTarget(tp,c75886890.filter2,tp,LOCATION_GRAVE,0,1,1,nil,e:GetLabelObject())
	e:GetLabelObject():CreateEffectRelation(e)
end
-- 将作为对象的装备魔法卡装备给原本装备的怪兽
function c75886890.eqop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的装备魔法卡
	local tc=Duel.GetFirstTarget()
	local ec=e:GetLabelObject()
	if tc:IsRelateToEffect(e) then
		-- 将作为对象的装备魔法卡装备给原本装备的怪兽
		Duel.Equip(tp,tc,ec)
	end
end

--No.55 ゴゴゴゴライアス
-- 效果：
-- 4星怪兽×2
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，自己场上的怪兽的守备力上升800。
-- ②：把这张卡1个超量素材取除，以自己墓地1只岩石族·地属性·4星怪兽为对象才能发动。那只岩石族·地属性怪兽加入手卡。
function c46871387.initial_effect(c)
	-- 为卡片添加XYZ召唤手续，使用满足条件的4星怪兽叠放，最少需要2只
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- ②：把这张卡1个超量素材取除，以自己墓地1只岩石族·地属性·4星怪兽为对象才能发动。那只岩石族·地属性怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(46871387,0))  --"加入手卡"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,46871387)
	e1:SetCost(c46871387.thcost)
	e1:SetTarget(c46871387.thtg)
	e1:SetOperation(c46871387.thop)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在怪兽区域存在，自己场上的怪兽的守备力上升800。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetValue(800)
	c:RegisterEffect(e2)
end
-- 设置该卡的XYZ编号为55
aux.xyz_number[46871387]=55
-- 效果发动时支付1个超量素材作为代价
function c46871387.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 定义过滤函数，筛选墓地中的岩石族·地属性·4星怪兽
function c46871387.filter(c)
	return c:IsRace(RACE_ROCK) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsLevel(4) and c:IsAbleToHand()
end
-- 设置效果的目标选择逻辑，从己方墓地选择符合条件的怪兽
function c46871387.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c46871387.filter(chkc) end
	-- 检查是否场上存在满足条件的墓地目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c46871387.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的墓地目标怪兽
	local g=Duel.SelectTarget(tp,c46871387.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息，确定将目标怪兽送入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 执行效果处理，将目标怪兽送入手牌并确认对方查看
function c46871387.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsRace(RACE_ROCK) and tc:IsAttribute(ATTRIBUTE_EARTH) then
		-- 将目标怪兽以效果原因送入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家确认查看该怪兽
		Duel.ConfirmCards(1-tp,tc)
	end
end

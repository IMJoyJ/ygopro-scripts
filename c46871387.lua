--No.55 ゴゴゴゴライアス
-- 效果：
-- 4星怪兽×2
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，自己场上的怪兽的守备力上升800。
-- ②：把这张卡1个超量素材取除，以自己墓地1只岩石族·地属性·4星怪兽为对象才能发动。那只岩石族·地属性怪兽加入手卡。
function c46871387.initial_effect(c)
	-- 为这张卡添加超量召唤手续：可用任意2只等级4的怪兽作为素材叠放进行超量召唤。
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- “这个卡名的②的效果1回合只能使用1次。②：把这张卡1个超量素材取除，以自己墓地1只岩石族·地属性·4星怪兽为对象才能发动。那只岩石族·地属性怪兽加入手卡。”
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
	-- “①：只要这张卡在怪兽区域存在，自己场上的怪兽的守备力上升800。”
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetValue(800)
	c:RegisterEffect(e2)
end
-- 将这张卡的卡号登记为No.55（XYZ编号），用于相关规则的识别与No.卡相关效果处理。
aux.xyz_number[46871387]=55
-- ②效果的发动代价：检查能否取除这张卡的1个超量素材；可以则实际取除1个超量素材作为代价。
function c46871387.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 定义②效果的对象筛选条件：自己墓地的岩石族·地属性·4星怪兽，且能够加入手卡。
function c46871387.filter(c)
	return c:IsRace(RACE_ROCK) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsLevel(4) and c:IsAbleToHand()
end
-- ②效果发动时的目标处理：确认对象为合法墓地岩石族·地属性·4星怪兽后，玩家选择1张符合条件的墓地怪兽作为对象，并注册将该卡加入手卡的操作信息。
function c46871387.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c46871387.filter(chkc) end
	-- 在发动时检查自己墓地是否存在至少1张满足条件的岩石族·地属性·4星怪兽。
	if chk==0 then return Duel.IsExistingTarget(c46871387.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向操作玩家显示“请选择要加入手牌的卡”的选卡提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1张符合条件的岩石族·地属性·4星怪兽，将其设为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,c46871387.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置当前连锁的操作信息：将选中的对象卡加入手卡（1张，来自墓地）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果处理：取得效果对象，确认其仍与效果相关且仍是岩石族·地属性怪兽后，将其加入持有者手卡，并向对方展示。
function c46871387.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中登记的唯一效果对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsRace(RACE_ROCK) and tc:IsAttribute(ATTRIBUTE_EARTH) then
		-- 将该对象怪兽送入其持有者的手卡（原因记为效果）。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 让对方玩家确认这张加入手卡的怪兽。
		Duel.ConfirmCards(1-tp,tc)
	end
end

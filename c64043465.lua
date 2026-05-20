--魔神火炎砲
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：以场上1只怪兽为对象才能发动。从手卡·卡组把1只「被封印」怪兽或1张「艾克佐迪亚」卡送去墓地，作为对象的怪兽回到手卡。
-- ②：这张卡从魔法与陷阱区域送去墓地的场合，以自己墓地1只「被封印」怪兽或1张「艾克佐迪亚」卡为对象才能发动。那张卡加入手卡。
function c64043465.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：以场上1只怪兽为对象才能发动。从手卡·卡组把1只「被封印」怪兽或1张「艾克佐帝亚」卡送去墓地，作为对象的怪兽回到手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(64043465,0))  --"场上怪兽回到手卡"
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,64043465)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetTarget(c64043465.target)
	e2:SetOperation(c64043465.operation)
	c:RegisterEffect(e2)
	-- ②：这张卡从魔法与陷阱区域送去墓地的场合，以自己墓地1只「被封印」怪兽或1张「艾克佐帝亚」卡为对象才能发动。那张卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(64043465,1))  --"墓地的卡回到手卡"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,64043465)
	e3:SetCondition(c64043465.thcon)
	e3:SetTarget(c64043465.thtg)
	e3:SetOperation(c64043465.thop)
	c:RegisterEffect(e3)
end
-- 过滤手卡或卡组中可以送去墓地的「被封印」怪兽或「艾克佐帝亚」卡
function c64043465.tgfilter(c)
	return ((c:IsSetCard(0x40) and c:IsType(TYPE_MONSTER)) or c:IsSetCard(0xde)) and c:IsAbleToGrave()
end
-- ①效果的发动准备与目标选择
function c64043465.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToHand() end
	-- 检查自己手卡或卡组是否存在至少1张可以送去墓地的「被封印」怪兽或「艾克佐帝亚」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c64043465.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil)
		-- 检查场上是否存在至少1只可以回到手牌的怪兽
		and Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择场上1只可以回到手牌的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁信息，表示该效果包含将自己手卡或卡组的1张卡送去墓地的操作
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
	-- 设置连锁信息，表示该效果包含将选中的对象怪兽送回手牌的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ①效果的处理逻辑
function c64043465.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家从手卡或卡组选择1张满足条件的「被封印」怪兽或「艾克佐帝亚」卡
	local g=Duel.SelectMatchingCard(tp,c64043465.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
	-- 将选中的卡送去墓地，并确认其已成功送去墓地
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_GRAVE) then
		-- 获取作为效果对象的怪兽
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			-- 将作为对象的怪兽送回持有者手牌
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	end
end
-- 检查此卡是否是从魔法与陷阱区域送去墓地
function c64043465.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_SZONE)
end
-- 过滤自己墓地中可以加入手牌的「被封印」怪兽或「艾克佐帝亚」卡
function c64043465.thfilter(c)
	return ((c:IsSetCard(0x40) and c:IsType(TYPE_MONSTER)) or c:IsSetCard(0xde)) and c:IsAbleToHand()
end
-- ②效果的发动准备与目标选择
function c64043465.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c64043465.thfilter(chkc) end
	-- 检查自己墓地是否存在至少1张可以加入手牌的「被封印」怪兽或「艾克佐帝亚」卡
	if chk==0 then return Duel.IsExistingTarget(c64043465.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1张满足条件的「被封印」怪兽或「艾克佐帝亚」卡作为效果对象
	local g=Duel.SelectTarget(tp,c64043465.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁信息，表示该效果包含将选中的对象卡加入手牌的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果的处理逻辑
function c64043465.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的墓地卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将作为对象的卡片加入玩家手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end

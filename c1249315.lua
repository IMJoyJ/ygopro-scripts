--聖光の宣告者
-- 效果：
-- 2星怪兽×2
-- 这个卡名的效果1回合只能使用1次。
-- ①：把这张卡1个超量素材取除，以自己墓地1只怪兽为对象才能发动。那只怪兽加入手卡。那之后，选1张手卡回到卡组。
function c1249315.initial_effect(c)
	-- 为卡片添加等级为2、需要2只怪兽进行XYZ召唤的手续
	aux.AddXyzProcedure(c,nil,2,2)
	c:EnableReviveLimit()
	-- ①：把这张卡1个超量素材取除，以自己墓地1只怪兽为对象才能发动。那只怪兽加入手卡。那之后，选1张手卡回到卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1249315,0))  --"加入手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,1249315)
	e2:SetCost(c1249315.thcost)
	e2:SetTarget(c1249315.thtg)
	e2:SetOperation(c1249315.thop)
	c:RegisterEffect(e2)
end
-- 效果的费用支付函数，检查并移除1个超量素材作为代价
function c1249315.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 用于筛选墓地中的怪兽是否可以加入手卡的过滤函数
function c1249315.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果的发动时选择目标函数，用于选择墓地中的怪兽作为对象
function c1249315.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c1249315.thfilter(chkc) end
	-- 判断是否满足选择目标的条件，即墓地是否存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c1249315.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家发送提示信息，提示选择要加入手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	-- 选择目标怪兽，从玩家墓地中选择1只符合条件的怪兽
	local g=Duel.SelectTarget(tp,c1249315.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理时的操作信息，指定将目标怪兽加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果的处理函数，执行将目标怪兽加入手卡并返回手卡的处理
function c1249315.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否仍然有效，并将其加入手卡，若成功则继续处理
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND) then
		-- 向玩家发送提示信息，提示选择要返回卡组的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		-- 从玩家手牌中选择1张卡作为返回卡组的对象
		local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0):Select(tp,1,1,nil)
		if g:GetCount()>0 then
			-- 中断当前效果处理，使后续处理视为错时点
			Duel.BreakEffect()
			-- 将选中的手卡返回卡组并洗牌
			Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end

--聖光の宣告者
-- 效果：
-- 2星怪兽×2
-- 这个卡名的效果1回合只能使用1次。
-- ①：把这张卡1个超量素材取除，以自己墓地1只怪兽为对象才能发动。那只怪兽加入手卡。那之后，选1张手卡回到卡组。
function c1249315.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：用任意2只2星怪兽作为超量素材进行XYZ召唤。
	aux.AddXyzProcedure(c,nil,2,2)
	c:EnableReviveLimit()
	-- 这个卡名的效果1回合只能使用1次。①：把这张卡1个超量素材取除，以自己墓地1只怪兽为对象才能发动。那只怪兽加入手卡。那之后，选1张手卡回到卡组。
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
-- 支付代价：发动前检查能否移除这张卡的1个超量素材；可以则把这张卡的1个超量素材移除作为发动代价。
function c1249315.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 墓地怪兽的筛选函数：对象必须是怪兽且能够加入手卡。
function c1249315.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 发动时的目标选择处理：检查自己墓地是否存在符合条件的怪兽；存在则让玩家选择1只墓地怪兽作为对象，并设定“加入手卡”的操作信息。
function c1249315.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c1249315.thfilter(chkc) end
	-- 发动条件判定：自己墓地是否存在至少1只满足条件的怪兽，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c1249315.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 给玩家显示“请选择要返回手牌的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 从自己墓地选择1只满足条件的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c1249315.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将本次操作信息登记为“把1张卡加入手卡”，供后续时点或连锁检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理：取回那名对象怪兽；若成功加入手卡，则再选1张手卡洗回卡组。
function c1249315.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的那只对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象仍与效果关联且已成功加入手卡并处于手牌区域，才继续执行“选1张手卡回卡组”的处理。
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND) then
		-- 给玩家显示“请选择要返回卡组的卡”的选择提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 从自己手牌选择1张卡（用于返回卡组）。
		local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0):Select(tp,1,1,nil)
		if g:GetCount()>0 then
			-- 中断当前效果连锁的处理，使前面的回手牌和此后的回卡组不在同一时点被处理（避免误判同时处理）。
			Duel.BreakEffect()
			-- 将选择的那张手牌洗回持有者卡组（以效果为原因，并触发洗牌）。
			Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end

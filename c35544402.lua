--ティンクル・セイクリッド
-- 效果：
-- 「闪烁星圣」的②的效果1回合只能使用1次。
-- ①：以自己场上1只「星圣」怪兽为对象才能发动。那只怪兽的等级上升1星或者2星。
-- ②：这张卡在墓地存在的场合，把自己墓地1只「星圣」怪兽除外才能发动。墓地的这张卡加入手卡。
function c35544402.initial_effect(c)
	-- ①：以自己场上1只「星圣」怪兽为对象才能发动。那只怪兽的等级上升1星或者2星。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(35544402,0))  --"等级上升"
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c35544402.target)
	e1:SetOperation(c35544402.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，把自己墓地1只「星圣」怪兽除外才能发动。墓地的这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(35544402,1))  --"加入手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,35544402)
	e2:SetCost(c35544402.thcost)
	e2:SetTarget(c35544402.thtg)
	e2:SetOperation(c35544402.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断目标怪兽是否为表侧表示的「星圣」怪兽且等级大于0
function c35544402.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x53) and c:GetLevel()>0
end
-- 设置效果目标，选择自己场上满足条件的1只怪兽作为对象
function c35544402.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c35544402.filter(chkc) end
	-- 检查是否满足发动条件，即自己场上是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c35544402.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要发动效果的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足条件的1只怪兽作为效果对象
	Duel.SelectTarget(tp,c35544402.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理函数，使目标怪兽的等级上升1星或2星
function c35544402.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 创建一个改变目标怪兽等级的效果，根据玩家选择使等级上升1星或2星
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		-- 让玩家选择使目标怪兽等级上升1星或2星
		if Duel.SelectOption(tp,aux.Stringid(35544402,2),aux.Stringid(35544402,3))==0 then  --"等级上升1星/等级上升2星"
			e1:SetValue(1)
		else e1:SetValue(2) end
		tc:RegisterEffect(e1)
	end
end
-- 过滤函数，用于判断墓地中的卡是否为「星圣」怪兽且可以作为除外的代价
function c35544402.thfilter(c)
	return c:IsSetCard(0x53) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 设置效果发动的代价，从墓地选择1只「星圣」怪兽除外
function c35544402.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件，即自己墓地是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c35544402.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择1只满足条件的卡作为除外的代价
	local g=Duel.SelectMatchingCard(tp,c35544402.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的卡除外作为发动效果的代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 设置效果的处理目标，将此卡加入手牌
function c35544402.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置效果处理信息，表示此卡将被加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果处理函数，将此卡加入手牌并确认对方查看
function c35544402.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡送入手牌
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 向对方确认查看此卡
		Duel.ConfirmCards(1-tp,c)
	end
end

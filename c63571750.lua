--王家の財宝
-- 效果：
-- 发动后，这张卡表面向上混到自己的卡组。抽回那张卡的时候送到墓地，从自己的墓地选择这张卡以外的1张其他的卡加入手卡。
function c63571750.initial_effect(c)
	-- 开启全局标记，用于检测卡组中是否存在正面朝上的卡片（卡组翻转检查）
	Duel.EnableGlobalFlag(GLOBALFLAG_DECK_REVERSE_CHECK)
	-- 发动后，这张卡表面向上混到自己的卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c63571750.target)
	e1:SetOperation(c63571750.activate)
	c:RegisterEffect(e1)
end
-- 魔法卡发动时的效果处理分支（Target），检查自身是否能返回卡组，并设置操作信息
function c63571750.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeck() end
	-- 设置操作信息，表示此效果的处理包含将自身送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- 魔法卡发动时的效果处理（Operation），将自身洗入卡组并翻转为正面朝上，同时注册抽到该卡时触发的效果
function c63571750.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	c:CancelToGrave()
	-- 将这张卡送回玩家卡组并洗牌
	Duel.SendtoDeck(c,tp,SEQ_DECKSHUFFLE,REASON_EFFECT)
	if not c:IsLocation(LOCATION_DECK) then return end
	-- 洗切玩家的卡组
	Duel.ShuffleDeck(tp)
	c:ReverseInDeck()
	-- 抽回那张卡的时候送到墓地，从自己的墓地选择这张卡以外的1张其他的卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(63571750,0))  --"回收"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_DRAW)
	e1:SetTarget(c63571750.thtg)
	e1:SetOperation(c63571750.thop)
	e1:SetReset(RESET_EVENT+0x1de0000)
	c:RegisterEffect(e1)
end
-- 抽到此卡时触发效果的Target函数，用于选择墓地中的一张卡作为对象
function c63571750.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and chkc:IsAbleToHand() end
	if chk==0 then return e:GetHandler():IsRelateToEffect(e) end
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地中1张可以加入手牌的卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息，表示此效果的处理包含将选中的卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 抽到此卡时触发效果的Operation函数，将自身送去墓地，并将选中的对象卡加入手牌
function c63571750.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否与效果相关，并成功将自身送去墓地
	if c:IsRelateToEffect(e) and Duel.SendtoGrave(c,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_GRAVE) then
		-- 获取之前选择的墓地卡片对象
		local tc=Duel.GetFirstTarget()
		if tc and tc:IsRelateToEffect(e) then
			-- 将目标卡片加入持有者的手牌
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
		end
	end
end

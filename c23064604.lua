--冥帝エレボス
-- 效果：
-- 这张卡可以把1只上级召唤的怪兽解放作上级召唤。
-- ①：这张卡上级召唤的场合才能发动。从手卡·卡组把「帝王」魔法·陷阱卡2种类各1张送去墓地，从对方的手卡·场上·墓地让1张卡回到卡组（从手卡是随机选）。
-- ②：这张卡在墓地存在的场合，1回合1次，自己·对方的主要阶段，从手卡丢弃1张「帝王」魔法·陷阱卡，以自己墓地1只攻击力2400以上而守备力1000的怪兽为对象才能发动。那只怪兽加入手卡。
function c23064604.initial_effect(c)
	-- 效果原文：把1只上级召唤的怪兽解放作上级召唤
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(23064604,0))  --"把1只上级召唤的怪兽解放作上级召唤"
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(c23064604.otcon)
	e1:SetOperation(c23064604.otop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_PROC)
	c:RegisterEffect(e2)
	-- 效果原文：从手卡·卡组把「帝王」魔法·陷阱卡2种类送去墓地，从对方的手卡·场上·墓地之中选1张卡回到卡组
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(23064604,1))  --"从手卡·卡组把「帝王」魔法·陷阱卡2种类送去墓地，从对方的手卡·场上·墓地之中选1张卡回到卡组"
	e3:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(c23064604.tdcon)
	e3:SetTarget(c23064604.tdtg)
	e3:SetOperation(c23064604.tdop)
	c:RegisterEffect(e3)
	-- 效果原文：以自己墓地1只攻击力2400以上而守备力1000的怪兽为对象才能发动。那只怪兽加入手卡
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(23064604,2))  --"以自己墓地1只攻击力2400以上而守备力1000的怪兽为对象才能发动。那只怪兽加入手卡"
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetCountLimit(1)
	e4:SetCondition(c23064604.thcon)
	e4:SetCost(c23064604.thcost)
	e4:SetTarget(c23064604.thtg)
	e4:SetOperation(c23064604.thop)
	c:RegisterEffect(e4)
end
-- 过滤函数：判断怪兽是否为上级召唤
function c23064604.otfilter(c)
	return c:IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 上级召唤条件判断：检查卡片等级是否不低于7且祭品数量是否不超过1，并验证是否存在满足条件的祭品
function c23064604.otcon(e,c,minc)
	if c==nil then return true end
	-- 获取场上所有上级召唤的怪兽作为祭品候选
	local mg=Duel.GetMatchingGroup(c23064604.otfilter,0,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 判断是否满足上级召唤条件
	return c:IsLevelAbove(7) and minc<=1 and Duel.CheckTribute(c,1,1,mg)
end
-- 上级召唤操作：选择并解放1只上级召唤的怪兽作为祭品
function c23064604.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取场上所有上级召唤的怪兽作为祭品候选
	local mg=Duel.GetMatchingGroup(c23064604.otfilter,0,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 从候选中选择1只怪兽作为祭品
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 将选中的祭品怪兽解放
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 上级召唤成功时的触发条件：判断该卡是否为上级召唤
function c23064604.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 过滤函数：判断是否为「帝王」魔法·陷阱卡且可送去墓地
function c23064604.tgfilter(c)
	return c:IsSetCard(0xbe) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGrave()
end
-- 上级召唤效果的发动条件与目标设置：检查手卡和卡组中是否存在至少2种不同的「帝王」魔法·陷阱卡，并确认对方场上有可返回卡组的卡
function c23064604.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取手卡和卡组中所有「帝王」魔法·陷阱卡
		local g=Duel.GetMatchingGroup(c23064604.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil)
		return g:GetClassCount(Card.GetCode)>1
			-- 检查对方手卡、场上或墓地是否存在可返回卡组的卡
			and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,1,nil)
	end
	-- 设置操作信息：将2张「帝王」魔法·陷阱卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,2,tp,LOCATION_DECK)
	-- 设置操作信息：将对方1张卡返回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,1-tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE)
end
-- 上级召唤效果的处理：选择2种不同种类的「帝王」魔法·陷阱卡送去墓地，然后从对方手卡、场上或墓地中选择1张卡返回卡组
function c23064604.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取手卡和卡组中所有「帝王」魔法·陷阱卡
	local g=Duel.GetMatchingGroup(c23064604.tgfilter,tp,LOCATION_HAND+LOCATION_DECK,0,nil)
	if g:GetClassCount(Card.GetCode)<2 then return end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从符合条件的卡中选择2张不同种类的卡
	local tg1=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
	-- 将选中的卡送去墓地并确认是否全部进入墓地
	if Duel.SendtoGrave(tg1,REASON_EFFECT)~=0 and tg1:IsExists(Card.IsLocation,2,nil,LOCATION_GRAVE) then
		local sg=nil
		-- 获取对方手卡中可返回卡组的卡
		local hg=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_HAND,nil)
		-- 检查对方手卡中是否存在可返回卡组的卡
		local b1=Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_HAND,1,nil)
		-- 检查对方场上是否存在可返回卡组的卡
		local b2=Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,nil)
		-- 检查对方墓地中是否存在可返回卡组的卡
		local b3=Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_GRAVE,1,nil)
		local op=0
		if not b1 and not b2 and not b3 then return end
		if b1 then
			if b2 and b3 then
				-- 提示玩家选择从对方手卡、场上或墓地中返回卡组的卡
				op=Duel.SelectOption(tp,aux.Stringid(23064604,3),aux.Stringid(23064604,4),aux.Stringid(23064604,5))  --"选对方的1张手卡回到卡组/选对方场上的1张卡回到卡组/选对方墓地的1张卡回到卡组"
			elseif b2 and not b3 then
				-- 提示玩家选择从对方手卡或场上返回卡组的卡
				op=Duel.SelectOption(tp,aux.Stringid(23064604,3),aux.Stringid(23064604,4))  --"选对方的1张手卡回到卡组/选对方场上的1张卡回到卡组"
			elseif not b2 and b3 then
				-- 提示玩家选择从对方手卡或墓地返回卡组的卡
				op=Duel.SelectOption(tp,aux.Stringid(23064604,3),aux.Stringid(23064604,5))  --"选对方的1张手卡回到卡组/选对方墓地的1张卡回到卡组"
				if op==1 then op=2 end
			else
				op=0
			end
		else
			if b2 and b3 then
				-- 提示玩家选择从对方场上或墓地返回卡组的卡
				op=Duel.SelectOption(tp,aux.Stringid(23064604,4),aux.Stringid(23064604,5))+1  --"选对方场上的1张卡回到卡组/选对方墓地的1张卡回到卡组"
			elseif b2 and not b3 then
				op=1
			else
				op=2
			end
		end
		if op==0 then
			sg=hg:RandomSelect(tp,1)
		elseif op==1 then
			-- 提示玩家选择要返回卡组的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
			-- 从对方场上选择1张卡返回卡组
			sg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,0,LOCATION_ONFIELD,1,1,nil)
			-- 显示选中卡作为对象的动画
			Duel.HintSelection(sg)
		else
			-- 提示玩家选择要返回卡组的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
			-- 从对方墓地中选择1张卡返回卡组
			sg=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,0,LOCATION_GRAVE,1,1,nil)
			-- 显示选中卡作为对象的动画
			Duel.HintSelection(sg)
		end
		-- 将选中的卡返回卡组
		Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 效果发动条件：判断当前阶段是否为主阶段1或主阶段2
function c23064604.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end
-- 过滤函数：判断是否为「帝王」魔法·陷阱卡且可丢弃
function c23064604.cfilter(c)
	return c:IsSetCard(0xbe) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsDiscardable()
end
-- 效果发动费用：丢弃1张「帝王」魔法·陷阱卡
function c23064604.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在可丢弃的「帝王」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c23064604.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 丢弃1张「帝王」魔法·陷阱卡
	Duel.DiscardHand(tp,c23064604.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤函数：判断是否为攻击力2400以上且守备力1000的怪兽且可加入手牌
function c23064604.thfilter(c)
	return c:IsAttackAbove(2400) and c:IsDefense(1000) and c:IsAbleToHand()
end
-- 效果发动目标设置：选择自己墓地中符合条件的1只怪兽
function c23064604.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c23064604.thfilter(chkc) end
	-- 检查是否存在符合条件的墓地怪兽
	if chk==0 then return Duel.IsExistingTarget(c23064604.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择1只符合条件的墓地怪兽作为目标
	local g=Duel.SelectTarget(tp,c23064604.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：将目标怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理：将目标怪兽加入手牌
function c23064604.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end

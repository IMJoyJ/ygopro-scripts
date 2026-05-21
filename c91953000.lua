--海晶乙女ブルータン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把「海晶少女 蓝倒吊」以外的1只「海晶少女」怪兽送去墓地。
-- ②：这张卡作为水属性连接怪兽的连接素材送去墓地的场合才能发动。从自己卡组上面把3张卡翻开。可以从那之中选1张「海晶少女」卡加入手卡。剩下的卡回到卡组。
function c91953000.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把「海晶少女 蓝倒吊」以外的1只「海晶少女」怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(91953000,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,91953000)
	e1:SetTarget(c91953000.tgtg)
	e1:SetOperation(c91953000.tgop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡作为水属性连接怪兽的连接素材送去墓地的场合才能发动。从自己卡组上面把3张卡翻开。可以从那之中选1张「海晶少女」卡加入手卡。剩下的卡回到卡组。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(91953000,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCountLimit(1,91953001)
	e3:SetCondition(c91953000.thcon)
	e3:SetTarget(c91953000.thtg)
	e3:SetOperation(c91953000.thop)
	c:RegisterEffect(e3)
end
-- 过滤卡组中「海晶少女 蓝倒吊」以外的「海晶少女」怪兽
function c91953000.tgfilter(c)
	return c:IsSetCard(0x12b) and c:IsType(TYPE_MONSTER) and not c:IsCode(91953000) and c:IsAbleToGrave()
end
-- 效果①的发动准备，检查卡组中是否存在符合条件的怪兽并设置送去墓地的操作信息
function c91953000.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只「海晶少女 蓝倒吊」以外的「海晶少女」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c91953000.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置将卡组中的1张卡送去墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理，从卡组选择1只符合条件的怪兽送去墓地
function c91953000.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1只符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c91953000.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽因效果送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 效果②的发动条件，检查这张卡是否作为水属性连接怪兽的连接素材送去墓地
function c91953000.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and r==REASON_LINK and c:GetReasonCard():IsAttribute(ATTRIBUTE_WATER)
end
-- 效果②的发动准备，检查卡组数量是否在3张以上并设置加入手卡的操作信息
function c91953000.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组上方是否有至少3张卡
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=3 end
	-- 设置将卡组中的1张卡加入手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
-- 过滤可以加入手卡的「海晶少女」卡
function c91953000.thfilter(c)
	return c:IsSetCard(0x12b) and c:IsAbleToHand()
end
-- 效果②的效果处理，翻开卡组上方3张卡，可选择其中1张「海晶少女」卡加入手卡，其余卡回到卡组
function c91953000.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 确认自己卡组最上方的3张卡
	Duel.ConfirmDecktop(tp,3)
	-- 获取自己卡组最上方的3张卡
	local g=Duel.GetDecktopGroup(tp,3)
	if g:GetCount()>0 then
		-- 检查翻开的卡中是否存在「海晶少女」卡，并询问玩家是否选择加入手卡
		if g:IsExists(c91953000.thfilter,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(91953000,2)) then  --"是否选卡加入手卡？"
			-- 提示玩家选择要加入手牌的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			local sg=g:FilterSelect(tp,c91953000.thfilter,1,1,nil)
			-- 将选择的卡因效果加入手卡
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			-- 给对方玩家确认加入手卡的卡
			Duel.ConfirmCards(1-tp,sg)
			-- 洗切玩家的手卡
			Duel.ShuffleHand(tp)
		end
		-- 洗切玩家的卡组
		Duel.ShuffleDeck(tp)
	end
end

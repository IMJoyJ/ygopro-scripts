--黒衣竜アルビオン
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡的卡名只要在场上·墓地存在当作「阿不思的落胤」使用。
-- ②：这张卡在手卡·墓地存在的场合，把1只「阿不思的落胤」或1张「烙印」魔法·陷阱卡从手卡·卡组送去墓地才能发动。以那张卡从哪里送去墓地来对应的以下效果适用。
-- ●手卡：这张卡特殊召唤。
-- ●卡组：这张卡回到卡组最下面。从手卡回去的场合，再让自己抽1张。
function c25451383.initial_effect(c)
	-- 使该卡在场上或墓地时视为「阿不思的落胤」使用
	aux.EnableChangeCode(c,68468459,LOCATION_MZONE+LOCATION_GRAVE)
	-- ②：这张卡在手卡·墓地存在的场合，把1只「阿不思的落胤」或1张「烙印」魔法·陷阱卡从手卡·卡组送去墓地才能发动。以那张卡从哪里送去墓地来对应的以下效果适用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25451383,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,25451383)
	e1:SetTarget(c25451383.target)
	e1:SetOperation(c25451383.operation)
	c:RegisterEffect(e1)
end
-- 定义费用过滤器，用于判断是否为「阿不思的落胤」或「烙印」魔法·陷阱卡且可作为墓地代价
function c25451383.costfilter(c)
	return (c:IsCode(68468459) or c:IsSetCard(0x15d) and c:IsType(TYPE_SPELL+TYPE_TRAP)) and c:IsAbleToGraveAsCost()
end
-- 设置效果的发动条件，检查手卡或卡组是否存在满足条件的卡，并判断是否可以特殊召唤或送回卡组
function c25451383.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查手卡是否存在满足条件的卡
	local b1=Duel.IsExistingMatchingCard(c25451383.costfilter,tp,LOCATION_HAND,0,1,c)
		-- 检查是否有足够的怪兽区域并判断该卡是否可以特殊召唤
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	-- 检查卡组是否存在满足条件的卡
	local b2=Duel.IsExistingMatchingCard(c25451383.costfilter,tp,LOCATION_DECK,0,1,nil)
		-- 检查该卡是否可以送回卡组且满足抽卡条件
		and c:IsAbleToDeck() and (c:IsLocation(LOCATION_GRAVE) or Duel.IsPlayerCanDraw(tp,1))
	if chk==0 then return b1 or b2 end
	local g=Group.CreateGroup()
	-- 获取手卡中满足条件的卡组
	local g1=Duel.GetMatchingGroup(c25451383.costfilter,tp,LOCATION_HAND,0,c)
	-- 获取卡组中满足条件的卡组
	local g2=Duel.GetMatchingGroup(c25451383.costfilter,tp,LOCATION_DECK,0,nil)
	if b1 then
		g:Merge(g1)
	end
	if b2 then
		g:Merge(g2)
	end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local tc=g:Select(tp,1,1,nil):GetFirst()
	if tc:IsLocation(LOCATION_HAND) then
		e:SetLabel(1)
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		-- 设置操作信息为特殊召唤
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	end
	if tc:IsLocation(LOCATION_DECK) and c:IsLocation(LOCATION_HAND) then
		e:SetLabel(2)
		e:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
		-- 设置操作信息为送回卡组
		Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,0,0)
		-- 设置操作信息为抽卡
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	end
	if tc:IsLocation(LOCATION_DECK) and c:IsLocation(LOCATION_GRAVE) then
		e:SetLabel(3)
		e:SetCategory(CATEGORY_TODECK)
		-- 设置操作信息为送回卡组
		Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,0,0)
	end
	-- 将选中的卡送去墓地作为发动代价
	Duel.SendtoGrave(tc,REASON_COST)
end
-- 处理效果发动后的操作，根据选择的卡来源执行不同效果
function c25451383.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local label=e:GetLabel()
	if label==1 then
		-- 将该卡特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	if label==2 then
		-- 将该卡送回卡组底端并判断是否成功
		if Duel.SendtoDeck(c,nil,SEQ_DECKBOTTOM,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_DECK) then
			-- 中断当前效果，使后续处理视为错时点
			Duel.BreakEffect()
			-- 让玩家抽1张卡
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
	if label==3 then
		-- 将该卡送回卡组底端
		Duel.SendtoDeck(c,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end

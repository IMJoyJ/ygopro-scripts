--十二獣の方合
-- 效果：
-- ①：以自己场上1只「十二兽」超量怪兽为对象才能发动。从卡组选1只「十二兽」怪兽在那只超量怪兽下面重叠作为超量素材。
-- ②：把墓地的这张卡除外，以自己墓地5张「十二兽」卡为对象才能发动（同名卡最多1张）。那5张卡加入卡组洗切。那之后，自己从卡组抽1张。这个效果在这张卡送去墓地的回合不能发动。
function c73881652.initial_effect(c)
	-- ①：以自己场上1只「十二兽」超量怪兽为对象才能发动。从卡组选1只「十二兽」怪兽在那只超量怪兽下面重叠作为超量素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c73881652.target)
	e1:SetOperation(c73881652.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己墓地5张「十二兽」卡为对象才能发动（同名卡最多1张）。那5张卡加入卡组洗切。那之后，自己从卡组抽1张。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(73881652,0))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_FREE_CHAIN)
	-- 设置该效果在送去墓地的回合不能发动的限制条件
	e2:SetCondition(aux.exccon)
	-- 设置发动代价为将墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c73881652.drtg)
	e2:SetOperation(c73881652.drop)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示的「十二兽」超量怪兽
function c73881652.tgfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(0xf1)
end
-- 过滤条件：卡组中可以作为超量素材的「十二兽」怪兽
function c73881652.matfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xf1) and c:IsCanOverlay()
end
-- 效果①的发动准备：检查场上是否有合法的超量怪兽以及卡组中是否有合法的素材怪兽，并选择对象
function c73881652.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c73881652.tgfilter(chkc) end
	-- 检查自己场上是否存在可以作为对象的「十二兽」超量怪兽
	if chk==0 then return Duel.IsExistingTarget(c73881652.tgfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 并且检查自己卡组是否存在可以作为超量素材的「十二兽」怪兽
		and Duel.IsExistingMatchingCard(c73881652.matfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只「十二兽」超量怪兽作为效果对象
	Duel.SelectTarget(tp,c73881652.tgfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果①的处理：将卡组选出的「十二兽」怪兽作为对象超量怪兽的超量素材
function c73881652.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的超量怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and not tc:IsImmuneToEffect(e) then
		-- 提示玩家选择要作为超量素材的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
		-- 从卡组选择1只「十二兽」怪兽
		local g=Duel.SelectMatchingCard(tp,c73881652.matfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选出的怪兽重叠在对象超量怪兽下面作为超量素材
			Duel.Overlay(tc,g)
		end
	end
end
-- 过滤条件：墓地中可以返回卡组的「十二兽」卡
function c73881652.drfilter(c,e)
	return c:IsSetCard(0xf1) and c:IsAbleToDeck() and c:IsCanBeEffectTarget(e)
end
-- 效果②的发动准备：检查墓地中是否有5张不同名的「十二兽」卡、玩家是否能抽卡，并选择对象
function c73881652.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取自己墓地中（除这张卡以外）所有满足条件的「十二兽」卡
	local g=Duel.GetMatchingGroup(c73881652.drfilter,tp,LOCATION_GRAVE,0,e:GetHandler(),e)
	-- 检查玩家当前是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		and g:GetClassCount(Card.GetCode)>4 end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 设置辅助检查条件，确保后续选出的卡片组内没有同名卡
	aux.GCheckAdditional=aux.dncheck
	-- 让玩家从满足条件的卡中选择5张
	local sg=g:SelectSubGroup(tp,aux.TRUE,false,5,5)
	-- 重置辅助检查条件
	aux.GCheckAdditional=nil
	-- 将选出的5张卡设为效果对象
	Duel.SetTargetCard(sg)
	-- 设置连锁操作信息：将5张卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,5,0,0)
	-- 设置连锁操作信息：玩家抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果②的处理：将5张对象卡洗回卡组，之后抽1张卡
function c73881652.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的5张卡
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not tg or tg:FilterCount(Card.IsRelateToEffect,nil,e)~=5 then return end
	-- 将对象卡片送回持有者卡组并洗卡
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 获取实际被操作（送回卡组）的卡片组
	local g=Duel.GetOperatedGroup()
	-- 如果实际有卡片回到了主卡组，则洗切卡组
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then Duel.ShuffleDeck(tp) end
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
	if ct==5 then
		-- 中断当前效果，使之后的效果处理（抽卡）视为不同时处理
		Duel.BreakEffect()
		-- 玩家从卡组抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end

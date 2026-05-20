--森羅の霊峰
-- 效果：
-- 自己的主要阶段时把手卡或者自己场上表侧表示存在的1只植物族怪兽送去墓地才能发动。从卡组选1张名字带有「森罗」的卡在卡组最上面放置。「森罗的灵峰」的这个效果1回合只能使用1次。此外，对方的结束阶段时只有1次，可以把自己卡组最上面的卡翻开。翻开的卡是植物族怪兽的场合，那张卡送去墓地。不是的场合，那张卡回到卡组最上面或者最下面。
function c70222318.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 自己的主要阶段时把手卡或者自己场上表侧表示存在的1只植物族怪兽送去墓地才能发动。从卡组选1张名字带有「森罗」的卡在卡组最上面放置。「森罗的灵峰」的这个效果1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,70222318)
	e2:SetCost(c70222318.cost)
	e2:SetTarget(c70222318.target)
	e2:SetOperation(c70222318.operation)
	c:RegisterEffect(e2)
	-- 此外，对方的结束阶段时只有1次，可以把自己卡组最上面的卡翻开。翻开的卡是植物族怪兽的场合，那张卡送去墓地。不是的场合，那张卡回到卡组最上面或者最下面。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(70222318,3))  --"检索"
	e3:SetCategory(CATEGORY_DECKDES)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetCountLimit(1)
	e3:SetCondition(c70222318.tgcon)
	e3:SetTarget(c70222318.tgtg)
	e3:SetOperation(c70222318.tgop)
	c:RegisterEffect(e3)
end
-- 过滤条件：手卡或场上表侧表示存在、且能作为代价送去墓地的植物族怪兽
function c70222318.cfilter(c)
	return c:IsRace(RACE_PLANT) and (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsAbleToGraveAsCost()
end
-- 效果发动的代价：将手卡或场上表侧表示的1只植物族怪兽送去墓地
function c70222318.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡或场上是否存在满足送去墓地条件的植物族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c70222318.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家选择1张手卡或场上表侧表示的植物族怪兽
	local g=Duel.SelectMatchingCard(tp,c70222318.cfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	-- 将选中的怪兽作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果发动的靶向/检查：确认卡组中是否存在名字带有「森罗」的卡
function c70222318.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在名字带有「森罗」的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_DECK,0,1,nil,0x90) end
end
-- 效果处理：从卡组选1张名字带有「森罗」的卡放置在卡组最上面
function c70222318.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择一张名字带有「森罗」的卡
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(70222318,0))  --"选择一张名字带有「森罗」的卡"
	-- 从卡组中选择1张名字带有「森罗」的卡
	local g=Duel.SelectMatchingCard(tp,Card.IsSetCard,tp,LOCATION_DECK,0,1,1,nil,0x90)
	local tc=g:GetFirst()
	if tc then
		-- 洗切自身卡组
		Duel.ShuffleDeck(tp)
		-- 将选中的「森罗」卡移动到卡组最上面
		Duel.MoveSequence(tc,SEQ_DECKTOP)
		-- 确认卡组最上方的一张卡（向双方展示）
		Duel.ConfirmDecktop(tp,1)
	end
end
-- 效果发动条件：对方的结束阶段
function c70222318.tgcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为对方玩家
	return tp~=Duel.GetTurnPlayer()
end
-- 效果发动靶向/检查：确认玩家是否能将卡组顶端的卡送去墓地
function c70222318.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以把卡组顶端1张卡送去墓地
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
end
-- 效果处理：翻开卡组最上面的卡，根据种族进行送墓或放回卡组顶端/底端的操作
function c70222318.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 再次检查玩家是否可以把卡组顶端1张卡送去墓地，若不能则不处理
	if not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
	-- 翻开（确认）卡组最上面的一张卡
	Duel.ConfirmDecktop(tp,1)
	-- 获取卡组最上方的一张卡
	local g=Duel.GetDecktopGroup(tp,1)
	local tc=g:GetFirst()
	if tc:IsRace(RACE_PLANT) then
		-- 禁用接下来的洗卡检测，防止因卡片离开卡组而自动洗牌
		Duel.DisableShuffleCheck()
		-- 将翻开的卡作为效果和翻开原因送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_REVEAL)
	else
		-- 让玩家选择将卡片放置在卡组最上面还是最下面
		local opt=Duel.SelectOption(tp,aux.Stringid(70222318,1),aux.Stringid(70222318,2))  --"放置卡组最上面/放置卡组最下面"
		if opt==1 then
			-- 若玩家选择放置在卡组最下面，则将该卡移动到卡组最下面
			Duel.MoveSequence(tc,opt)
		end
	end
end

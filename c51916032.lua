--人造人間－サイコ・ジャッカー
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡的卡名只要在场上·墓地存在当作「人造人-念力震慑者」使用。
-- ②：把这张卡解放才能发动。从卡组把「人造人-念力插孔者」以外的1只「人造人」怪兽加入手卡。那之后，对方的魔法与陷阱区域有盖放的卡的场合，那些全部确认。可以把最多有那之中的陷阱卡数量的「人造人」怪兽从手卡特殊召唤。
function c51916032.initial_effect(c)
	-- 使该卡在场上和墓地时视为「人造人-念力震慑者」使用
	aux.EnableChangeCode(c,77585513,LOCATION_MZONE+LOCATION_GRAVE)
	-- ②：把这张卡解放才能发动。从卡组把「人造人-念力插孔者」以外的1只「人造人」怪兽加入手卡。那之后，对方的魔法与陷阱区域有盖放的卡的场合，那些全部确认。可以把最多有那之中的陷阱卡数量的「人造人」怪兽从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(51916032,0))  --"加入手卡"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,51916032)
	e2:SetCost(c51916032.cost)
	e2:SetTarget(c51916032.target)
	e2:SetOperation(c51916032.operation)
	c:RegisterEffect(e2)
end
-- 支付效果代价，解放自身
function c51916032.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将自身解放作为效果的代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤函数，用于筛选满足条件的「人造人」怪兽（非本卡）并可加入手牌
function c51916032.filter(c)
	return c:IsSetCard(0xbc) and not c:IsCode(51916032) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 设置连锁处理信息，表示将从卡组检索一张「人造人」怪兽加入手牌
function c51916032.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c51916032.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理时要操作的卡组信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 过滤函数，用于筛选对方魔法与陷阱区域盖放的卡
function c51916032.cffilter(c)
	return c:IsFacedown() and c:GetSequence()<5
end
-- 过滤函数，用于筛选可特殊召唤的「人造人」怪兽
function c51916032.spfilter(c,e,tp)
	return c:IsSetCard(0xbc) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 执行效果的主要流程：检索卡牌、确认对方盖放卡、判断是否特殊召唤
function c51916032.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择一张符合条件的卡加入手牌
	local g=Duel.SelectMatchingCard(tp,c51916032.filter,tp,LOCATION_DECK,0,1,1,nil)
	-- 若未选到卡或未能成功送入手牌则结束效果
	if g:GetCount()==0 or Duel.SendtoHand(g,nil,REASON_EFFECT)==0 then return end
	-- 向对方确认其盖放的卡
	Duel.ConfirmCards(1-tp,g)
	-- 洗切自己的手牌
	Duel.ShuffleHand(tp)
	-- 获取对方魔法与陷阱区域盖放的卡组
	local cg=Duel.GetMatchingGroup(c51916032.cffilter,tp,0,LOCATION_SZONE,nil)
	if cg:GetCount()>0 then
		-- 中断当前连锁处理，使后续效果视为错时处理
		Duel.BreakEffect()
		-- 确认自己所盖放的卡
		Duel.ConfirmCards(tp,cg)
		-- 获取自己场上可用的怪兽区域数量
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if ft<=0 then return end
		local ct=cg:FilterCount(Card.IsType,nil,TYPE_TRAP)
		if ct>ft then ct=ft end
		-- 获取自己手牌中符合条件的「人造人」怪兽
		local sg=Duel.GetMatchingGroup(c51916032.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
		-- 判断是否满足特殊召唤条件并询问玩家选择
		if ct>0 and sg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(51916032,1)) then  --"是否特殊召唤「人造人」怪兽？"
			-- 提示玩家选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local tg=sg:Select(tp,1,ct,nil)
			-- 将选中的卡特殊召唤到场上
			Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end

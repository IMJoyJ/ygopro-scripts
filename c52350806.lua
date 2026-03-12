--未界域のモスマン
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：把手卡的这张卡给对方观看才能发动。从自己的全部手卡之中由对方随机选1张，自己把那张卡丢弃。那是「未界域的天蛾人」以外的场合，再从手卡把1只「未界域的天蛾人」特殊召唤，自己从卡组抽1张。
-- ②：这张卡从手卡丢弃的场合才能发动。双方各自从卡组抽1张。那之后，抽卡的玩家选自身1张手卡丢弃。
function c52350806.initial_effect(c)
	-- ①：把手卡的这张卡给对方观看才能发动。从自己的全部手卡之中由对方随机选1张，自己把那张卡丢弃。那是「未界域的天蛾人」以外的场合，再从手卡把1只「未界域的天蛾人」特殊召唤，自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(52350806,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_HANDES+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c52350806.spcost)
	e1:SetTarget(c52350806.sptg)
	e1:SetOperation(c52350806.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡从手卡丢弃的场合才能发动。双方各自从卡组抽1张。那之后，抽卡的玩家选自身1张手卡丢弃。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(52350806,1))
	e2:SetCategory(CATEGORY_HANDES+CATEGORY_DRAW)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DISCARD)
	e2:SetCountLimit(1,52350806)
	e2:SetTarget(c52350806.drtg)
	e2:SetOperation(c52350806.drop)
	c:RegisterEffect(e2)
end
-- 效果发动时检查是否公开手牌，未公开则不能发动。
function c52350806.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 过滤函数，用于筛选手牌中可以特殊召唤的「未界域的天蛾人」。
function c52350806.spfilter(c,e,tp)
	return c:IsCode(52350806) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置连锁处理信息，表示将要丢弃1张手牌。
function c52350806.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件：手牌中有可丢弃的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil,REASON_EFFECT) end
	-- 设置连锁处理信息，表示将要丢弃1张手牌。
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
-- 效果处理函数，执行①效果的主要逻辑。
function c52350806.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家所有手牌组成一个组。
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	if #g<1 then return end
	local tc=g:RandomSelect(1-tp,1):GetFirst()
	-- 判断是否成功将对方选中的卡送入墓地且不是「未界域的天蛾人」。
	if tc and Duel.SendtoGrave(tc,REASON_DISCARD+REASON_EFFECT)~=0 and not tc:IsCode(52350806)
		-- 判断场上是否有空位可以特殊召唤怪兽。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 获取满足条件的「未界域的天蛾人」手牌组。
		local spg=Duel.GetMatchingGroup(c52350806.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
		if spg:GetCount()<=0 then return end
		local sg=spg
		if spg:GetCount()~=1 then
			-- 提示玩家选择要特殊召唤的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			sg=spg:Select(tp,1,1,nil)
		end
		-- 中断当前效果处理，使后续效果视为错时处理。
		Duel.BreakEffect()
		-- 执行特殊召唤操作。
		if Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)~=0 then
			-- 从卡组抽一张卡。
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end
-- 设置连锁处理信息，表示将要丢弃和抽卡。
function c52350806.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件：双方都可以抽卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.IsPlayerCanDraw(1-tp,1) end
	-- 设置连锁处理信息，表示将要丢弃1张手牌。
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,PLAYER_ALL,1)
	-- 设置连锁处理信息，表示将要从卡组抽1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,1)
end
-- 效果处理函数，执行②效果的主要逻辑。
function c52350806.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 玩家tp从卡组抽一张卡。
	local h1=Duel.Draw(tp,1,REASON_EFFECT)
	-- 对方玩家从卡组抽一张卡。
	local h2=Duel.Draw(1-tp,1,REASON_EFFECT)
	-- 如果任意一方成功抽卡，则中断当前效果处理。
	if h1>0 or h2>0 then Duel.BreakEffect() end
	if h1>0 then
		-- 将玩家tp的手牌洗切。
		Duel.ShuffleHand(tp)
		-- 玩家tp丢弃1张手牌。
		Duel.DiscardHand(tp,aux.TRUE,1,1,REASON_EFFECT+REASON_DISCARD)
	end
	if h2>0 then
		-- 将对方玩家的手牌洗切。
		Duel.ShuffleHand(1-tp)
		-- 对方玩家丢弃1张手牌。
		Duel.DiscardHand(1-tp,aux.TRUE,1,1,REASON_EFFECT+REASON_DISCARD)
	end
end

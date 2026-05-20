--ワルキューレ・フィアット
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。把这张卡以外的自己场上的「女武神」怪兽数量的卡从自己卡组上面翻开。那之中有通常魔法·通常陷阱卡的场合，选那之内的1张加入手卡，剩下的卡全部送去墓地。没有的场合，翻开的卡全部回到卡组。
-- ②：这张卡被战斗破坏送去墓地时才能发动。从卡组把1只「女武神」怪兽特殊召唤。
function c81558967.initial_effect(c)
	-- ①：自己主要阶段才能发动。把这张卡以外的自己场上的「女武神」怪兽数量的卡从自己卡组上面翻开。那之中有通常魔法·通常陷阱卡的场合，选那之内的1张加入手卡，剩下的卡全部送去墓地。没有的场合，翻开的卡全部回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(81558967,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,81558967)
	e1:SetTarget(c81558967.target)
	e1:SetOperation(c81558967.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡被战斗破坏送去墓地时才能发动。从卡组把1只「女武神」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(81558967,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetCountLimit(1,81558968)
	e2:SetCondition(c81558967.spcon)
	e2:SetTarget(c81558967.sptg)
	e2:SetOperation(c81558967.spop)
	c:RegisterEffect(e2)
end
-- 过滤条件：表侧表示的「女武神」怪兽
function c81558967.ctfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x122)
end
-- 效果①的发动准备与合法性检测
function c81558967.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取自己场上除这张卡以外的「女武神」怪兽的数量
		local ct=Duel.GetMatchingGroupCount(c81558967.ctfilter,tp,LOCATION_MZONE,0,e:GetHandler())
		-- 若数量为0，或卡组剩余卡片数量小于该数量，则不能发动
		if ct==0 or Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<ct then return false end
		-- 获取卡组最上方的对应数量的卡片组
		local g=Duel.GetDecktopGroup(tp,ct)
		return g:FilterCount(Card.IsAbleToHand,nil)>0
	end
	-- 设置连锁信息：包含从卡组将1张卡加入手卡的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
-- 过滤条件：通常魔法卡或通常陷阱卡
function c81558967.thfilter(c)
	return c:GetType()==TYPE_SPELL or c:GetType()==TYPE_TRAP
end
-- 效果①的处理逻辑
function c81558967.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 重新获取自己场上除这张卡以外的「女武神」怪兽的数量
	local ct=Duel.GetMatchingGroupCount(c81558967.ctfilter,tp,LOCATION_MZONE,0,e:GetHandler())
	if ct==0 then return end
	-- 获取卡组最上方的对应数量的卡片组
	local g=Duel.GetDecktopGroup(tp,ct)
	-- 确认（翻开）卡组最上方的对应数量的卡
	Duel.ConfirmDecktop(tp,ct)
	local tg=g:Filter(c81558967.thfilter,nil)
	if tg:GetCount()>0 then
		-- 使接下来的操作不触发系统自动洗牌检测
		Duel.DisableShuffleCheck()
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local tc=tg:Select(tp,1,1,nil):GetFirst()
		if tc:IsAbleToHand() then
			-- 将选中的卡加入手牌
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 给对方玩家确认加入手牌的卡
			Duel.ConfirmCards(1-tp,tc)
			-- 洗切手牌
			Duel.ShuffleHand(tp)
		else
			-- 若无法加入手牌，则因规则送去墓地
			Duel.SendtoGrave(tc,REASON_RULE)
		end
		g:RemoveCard(tc)
		-- 将翻开的其余卡片全部送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_REVEAL)
	else
		-- 若没有通常魔法·通常陷阱卡，则将翻开的卡全部回到卡组并洗牌
		Duel.ShuffleDeck(tp)
	end
end
-- 过滤条件：可以特殊召唤的「女武神」怪兽
function c81558967.spfilter(c,e,tp)
	return c:IsSetCard(0x122) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动条件：自身被战斗破坏并送去墓地
function c81558967.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE)
end
-- 效果②的发动准备与合法性检测
function c81558967.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若为检测阶段，首先确认自己场上有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且卡组中存在至少1只可以特殊召唤的「女武神」怪兽
		and Duel.IsExistingMatchingCard(c81558967.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁信息：包含从卡组特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果②的处理逻辑
function c81558967.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若此时自己场上没有可用的怪兽区域，则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只满足条件的「女武神」怪兽
	local g=Duel.SelectMatchingCard(tp,c81558967.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

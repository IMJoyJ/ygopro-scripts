--白銀の城の召使い アリアーヌ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从手卡以及自己场上盖放的卡之中把1张通常陷阱卡送去墓地才能发动。从卡组把「白银之城的召使 阿里亚娜」以外的1只4星以下的恶魔族怪兽守备表示特殊召唤。
-- ②：自己的通常陷阱卡的效果让怪兽从场上离开的场合才能发动。自己从卡组抽1张。那之后，以下效果可以适用。
-- ●从手卡把1只恶魔族怪兽特殊召唤或把1张魔法·陷阱卡盖放。
function c75730490.initial_effect(c)
	-- ①：从手卡以及自己场上盖放的卡之中把1张通常陷阱卡送去墓地才能发动。从卡组把「白银之城的召使 阿里亚娜」以外的1只4星以下的恶魔族怪兽守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(75730490,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,75730490)
	e1:SetCost(c75730490.spcost)
	e1:SetTarget(c75730490.sptg)
	e1:SetOperation(c75730490.spop)
	c:RegisterEffect(e1)
	-- ②：自己的通常陷阱卡的效果让怪兽从场上离开的场合才能发动。自己从卡组抽1张。那之后，以下效果可以适用。●从手卡把1只恶魔族怪兽特殊召唤或把1张魔法·陷阱卡盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(75730490,1))  --"抽卡"
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_SPECIAL_SUMMON+CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,75730491)
	e2:SetCondition(c75730490.drcon)
	e2:SetTarget(c75730490.drtg)
	e2:SetOperation(c75730490.drop)
	c:RegisterEffect(e2)
end
-- 过滤手卡或场上盖放的通常陷阱卡作为发动Cost
function c75730490.costfilter(c)
	return (c:IsLocation(LOCATION_HAND) or c:IsFacedown()) and c:GetType()==TYPE_TRAP and c:IsAbleToGraveAsCost()
end
-- 效果①的发动Cost：将手卡或场上盖放的一张通常陷阱卡送去墓地
function c75730490.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- Cost检查：检查手卡或场上是否存在可以送去墓地的通常陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c75730490.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家选择1张手卡或场上盖放的通常陷阱卡
	local g=Duel.SelectMatchingCard(tp,c75730490.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil)
	-- 将选中的卡作为Cost送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤卡组中除「白银之城的召使 阿里亚娜」以外的4星以下恶魔族怪兽
function c75730490.spfilter(c,e,tp)
	return not c:IsCode(75730490) and c:IsRace(RACE_FIEND) and c:IsLevelBelow(4)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果①的发动准备与检查（Target）
function c75730490.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足特殊召唤条件的怪兽
		and Duel.IsExistingMatchingCard(c75730490.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁信息：包含从卡组特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理（Operation）：从卡组守备表示特殊召唤怪兽
function c75730490.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否仍有空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择1只满足条件的恶魔族怪兽
	local g=Duel.SelectMatchingCard(tp,c75730490.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧守备表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 过滤因效果离开场上的怪兽
function c75730490.cfilter(c)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsReason(REASON_EFFECT)
end
-- 效果②的发动条件：自己的通常陷阱卡的效果让怪兽从场上离开的场合
function c75730490.drcon(e,tp,eg,ep,ev,re,r,rp)
	return re and rp==tp and re:IsActiveType(TYPE_TRAP) and re:GetHandler():GetOriginalType()==TYPE_TRAP
		and eg:IsExists(c75730490.cfilter,1,nil)
end
-- 效果②的发动准备与检查（Target）
function c75730490.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家当前是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置抽卡效果的目标玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置抽卡数量为1张
	Duel.SetTargetParam(1)
	-- 设置连锁信息：包含自己抽1张卡的操作
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 过滤手卡中可以特殊召唤的恶魔族怪兽
function c75730490.spfilter2(c,e,tp)
	return c:IsRace(RACE_FIEND) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的效果处理（Operation）：抽卡，并可选择适用后续的特殊召唤或盖放效果
function c75730490.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取抽卡的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡，若成功抽卡则进行后续处理
	if Duel.Draw(p,d,REASON_EFFECT)>0 then
		local off=1
		local ops={}
		local opval={}
		-- 获取手卡中满足特殊召唤条件的恶魔族怪兽组
		local spg=Duel.GetMatchingGroup(c75730490.spfilter2,tp,LOCATION_HAND,0,nil,e,tp)
		-- 获取手卡中可以盖放的魔法·陷阱卡组
		local stg=Duel.GetMatchingGroup(Card.IsSSetable,tp,LOCATION_HAND,0,nil)
		-- 检查手卡中是否有可特召的恶魔族怪兽且自己场上有空余怪兽区域
		if #spg>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
			ops[off]=aux.Stringid(75730490,2)  --"从手卡特殊召唤"
			opval[off-1]=1
			off=off+1
		end
		if #stg>0 then
			ops[off]=aux.Stringid(75730490,3)  --"从手卡盖放"
			opval[off-1]=2
			off=off+1
		end
		ops[off]=aux.Stringid(75730490,4)  --"什么都不做"
		opval[off-1]=0
		-- 让玩家选择适用的后续效果（特召、盖放或不适用）
		local op=Duel.SelectOption(tp,table.unpack(ops))
		if opval[op]==1 then
			-- 中断当前效果处理，使后续的特殊召唤不与抽卡同时处理
			Duel.BreakEffect()
			-- 提示玩家选择要特殊召唤的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local sg=spg:Select(tp,1,1,nil)
			-- 将选中的恶魔族怪兽从手卡表侧表示特殊召唤
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
		if opval[op]==2 then
			-- 中断当前效果处理，使后续的盖放不与抽卡同时处理
			Duel.BreakEffect()
			-- 提示玩家选择要盖放的魔法·陷阱卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
			local sg=stg:Select(tp,1,1,nil)
			-- 将选中的魔法·陷阱卡在自己场上盖放
			Duel.SSet(tp,sg,tp,false)
		end
	end
end

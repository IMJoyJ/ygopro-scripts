--アルカナスプレッド
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：进行1次投掷硬币，那个里表的以下效果适用。自己的场地区域有「光之结界」存在的场合，不进行投掷硬币而选里表的其中1个适用。
-- ●表：从卡组把1只4星以下的「秘仪之力」怪兽特殊召唤。
-- ●里：把持有进行投掷硬币效果的1只怪兽从自己墓地特殊召唤。
-- ②：把墓地的这张卡除外才能发动。把持有进行投掷硬币效果的1张卡从自己墓地加入手卡。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果（发动时进行投硬币或选择效果并特殊召唤怪兽）和②效果（墓地除外自身回收墓地有投硬币效果的卡）。
function s.initial_effect(c)
	-- 注册卡片关联卡名「光之结界」（卡号73206827）。
	aux.AddCodeList(c,73206827)
	-- ①：进行1次投掷硬币，那个里表的以下效果适用。自己的场地区域有「光之结界」存在的场合，不进行投掷硬币而选里表的其中1个适用。●表：从卡组把1只4星以下的「秘仪之力」怪兽特殊召唤。●里：把持有进行投掷硬币效果的1只怪兽从自己墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_COIN+CATEGORY_GRAVE_SPSUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。把持有进行投掷硬币效果的1张卡从自己墓地加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"墓地加入手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	-- 设置发动代价为将墓地的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 过滤条件：4星以下的「秘仪之力」怪兽，且能被特殊召唤。
function s.spfilter1(c,e,tp)
	return c:IsSetCard(0x5) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤条件：持有进行投掷硬币效果的怪兽，且能被特殊召唤。
function s.spfilter2(c,e,tp)
	-- 检查卡片是否具有投硬币效果属性，且能被特殊召唤。
	return c:IsEffectProperty(aux.EffectPropertyFilter(EFFECT_FLAG_COIN)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动准备（Target），检查怪兽区域是否有空位，以及卡组或墓地是否存在可特殊召唤的对应怪兽。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用于特殊召唤的怪兽区域空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足条件的「秘仪之力」怪兽。
		and (Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_DECK,0,1,nil,e,tp)
		-- 或者检查墓地中是否存在满足条件的持有投硬币效果的怪兽。
		or Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_GRAVE,0,1,nil,e,tp)) end
	-- 设置连锁信息，表明该效果包含投掷1次硬币的操作。
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
-- ①效果的处理（Operation），根据场上是否存在「光之结界」来决定是直接选择效果还是通过投硬币决定效果，并执行相应的特殊召唤。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local res=-1
	-- 检查自己的场地区域是否存在「光之结界」。
	if Duel.IsEnvironment(73206827,tp,LOCATION_FZONE) then
		-- 若怪兽区域没有空位，则不处理效果。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 检查卡组中是否存在可特殊召唤的「秘仪之力」怪兽。
		local b1=Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_DECK,0,1,nil,e,tp)
		-- 检查墓地中是否存在不受「王家长眠之谷」影响且可特殊召唤的持有投硬币效果的怪兽。
		local b2=Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter2),tp,LOCATION_GRAVE,0,1,nil,e,tp)
		if b1 and not b2 then
			-- 向对方玩家提示：自己选择了适用表侧（正面）的效果。
			Duel.Hint(HINT_OPSELECTED,1-tp,60)
			res=1
		end
		if b2 and not b1 then
			-- 向对方玩家提示：自己选择了适用里侧（反面）的效果。
			Duel.Hint(HINT_OPSELECTED,1-tp,61)
			res=0
		end
		if b1 and b2 then
			-- 让玩家在表侧（正面）和里侧（反面）效果中选择一个适用。
			res=aux.SelectFromOptions(tp,
				{b1,60,1},
				{b2,61,0})
		end
	else
		-- 进行1次投掷硬币。
		res=Duel.TossCoin(tp,1)
	end
	if res==1 then
		-- 再次检查怪兽区域是否有空位，若无则不处理。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 提示玩家选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组选择1只满足条件的「秘仪之力」怪兽。
		local g=Duel.SelectMatchingCard(tp,s.spfilter1,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	elseif res==0 then
		-- 再次检查怪兽区域是否有空位，若无则不处理。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 提示玩家选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从墓地选择1只不受「王家长眠之谷」影响且满足条件的持有投硬币效果的怪兽。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter2),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 过滤条件：持有进行投掷硬币效果且能加入手卡的卡片。
function s.thfilter(c)
	-- 检查卡片是否具有投硬币效果属性，且能加入手卡。
	return c:IsEffectProperty(aux.EffectPropertyFilter(EFFECT_FLAG_COIN)) and c:IsAbleToHand()
end
-- ②效果的发动准备（Target），检查墓地是否存在可回收的持有投硬币效果的卡，并设置回收的连锁信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在（除这张卡以外的）满足条件的持有投硬币效果的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 设置连锁信息，表明该效果包含从墓地将1张卡加入手卡的操作。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- ②效果的处理（Operation），从墓地选择1张持有投硬币效果的卡加入手卡并给对方确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手卡的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从墓地选择1张不受「王家长眠之谷」影响且满足条件的持有投硬币效果的卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end

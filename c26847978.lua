--鉄獣戦線 徒花のフェリジット
-- 效果：
-- 兽族·兽战士族·鸟兽族怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。从手卡把1只4星以下的兽族·兽战士族·鸟兽族怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是兽族·兽战士族·鸟兽族怪兽不能作为连接素材。
-- ②：这张卡被送去墓地的场合才能发动。自己抽1张。那之后，选1张自己的手卡回到卡组最下面。
function c26847978.initial_effect(c)
	-- 为卡片添加连接召唤手续，要求使用2只满足种族为兽族·兽战士族·鸟兽族的怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST),2,2)
	c:EnableReviveLimit()
	-- ①：自己主要阶段才能发动。从手卡把1只4星以下的兽族·兽战士族·鸟兽族怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是兽族·兽战士族·鸟兽族怪兽不能作为连接素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(26847978,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,26847978)
	e1:SetTarget(c26847978.sptg)
	e1:SetOperation(c26847978.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡被送去墓地的场合才能发动。自己抽1张。那之后，选1张自己的手卡回到卡组最下面。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(26847978,1))
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,26847979)
	e2:SetTarget(c26847978.drtg)
	e2:SetOperation(c26847978.drop)
	c:RegisterEffect(e2)
end
-- 定义特殊召唤的过滤条件，即满足种族为兽族·兽战士族·鸟兽族且等级不超过4星，并且可以被特殊召唤
function c26847978.spfilter(c,e,tp)
	return c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足特殊召唤的条件，包括场上是否有空位以及手牌中是否存在符合条件的怪兽
function c26847978.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空位用于特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c26847978.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息，表示将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 处理特殊召唤效果，选择并特殊召唤符合条件的怪兽，并设置后续效果限制
function c26847978.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 再次检查场上是否有空位用于特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手牌中选择满足条件的怪兽
		local g=Duel.SelectMatchingCard(tp,c26847978.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽特殊召唤到场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 创建一个场上的效果，禁止非兽族·兽战士族·鸟兽族怪兽作为连接素材
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(0xff,0xff)
	-- 设置该效果的目标为非指定种族的怪兽
	e1:SetTarget(aux.NOT(aux.TargetBoolFunction(Card.IsRace,RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST)))
	e1:SetValue(c26847978.sumlimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将该效果注册到场上
	Duel.RegisterEffect(e1,tp)
end
-- 定义该效果的限制函数，用于判断是否禁止某怪兽作为连接素材
function c26847978.sumlimit(e,c)
	if not c then return false end
	return c:IsControler(e:GetHandlerPlayer())
end
-- 设置抽卡和回卡组的效果目标
function c26847978.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置效果的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果的目标参数为1
	Duel.SetTargetParam(1)
	-- 设置操作信息，表示将要抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	-- 设置操作信息，表示将要将1张手卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,0,tp,1)
end
-- 处理抽卡和回卡组的效果，先抽卡再选择一张手卡送回卡组
function c26847978.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡操作，若无法抽卡则返回
	if Duel.Draw(p,d,REASON_EFFECT)==0 then return end
	-- 提示玩家选择要送回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从手牌中选择一张可以送回卡组的卡
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil)
	if g:GetCount()>0 then
		-- 中断当前效果处理，使后续效果视为不同时处理
		Duel.BreakEffect()
		-- 将选中的卡送回卡组底部
		Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end

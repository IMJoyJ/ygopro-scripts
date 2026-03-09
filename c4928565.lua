--ティアラメンツ・クシャトリラ
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段才能发动。这张卡从手卡特殊召唤，从自己的手卡·墓地选1张「俱舍怒威族」卡或者「珠泪哀歌族」卡除外。
-- ②：这张卡召唤·特殊召唤成功的场合才能发动。从自己或者对方的卡组上面把3张卡送去墓地。
-- ③：这张卡被效果送去墓地的场合才能发动。从自己卡组上面把2张卡送去墓地。
local s,id,o=GetID()
-- 创建卡片的初始效果，包括①②③三个效果的注册
function s.initial_effect(c)
	-- ①：自己·对方的主要阶段才能发动。这张卡从手卡特殊召唤，从自己的手卡·墓地选1张「俱舍怒威族」卡或者「珠泪哀歌族」卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤成功的场合才能发动。从自己或者对方的卡组上面把3张卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.ddtg)
	e2:SetOperation(s.ddop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③：这张卡被效果送去墓地的场合才能发动。从自己卡组上面把2张卡送去墓地。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_DECKDES)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,id+o*2)
	e4:SetCondition(s.discon)
	e4:SetTarget(s.distg)
	e4:SetOperation(s.disop)
	c:RegisterEffect(e4)
end
-- 判断当前是否为主阶段1或主阶段2
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end
-- 过滤函数，用于筛选「俱舍怒威族」或「珠泪哀歌族」且可除外的卡
function s.rmfilter(c)
	return c:IsSetCard(0x189,0x181) and c:IsAbleToRemove()
end
-- ①效果的发动条件检查，判断是否满足特殊召唤和除外条件
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断场上是否有足够的怪兽区域进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 判断手牌或墓地是否存在符合条件的「俱舍怒威族」或「珠泪哀歌族」卡
		and Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,c) end
	-- 设置操作信息：将此卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	-- 设置操作信息：将1张符合条件的卡除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- ①效果的处理函数，执行特殊召唤和除外操作
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e)
		-- 判断此卡是否能成功特殊召唤
		and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 选择满足条件的1张卡进行除外
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.rmfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
		if #g>0 then
			-- 执行除外操作
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	end
end
-- ②效果的目标设定函数，判断是否可以将卡组顶部3张卡送去墓地
function s.ddtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己是否可以将卡组顶部3张卡送去墓地
	local b1=Duel.IsPlayerCanDiscardDeck(tp,3)
	-- 判断对方是否可以将卡组顶部3张卡送去墓地
	local b2=Duel.IsPlayerCanDiscardDeck(1-tp,3)
	if chk==0 then return b1 or b2 end
	-- 设置操作信息：将卡组顶部3张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,PLAYER_ALL,3)
end
-- ②效果的处理函数，根据选择决定从谁的卡组送去墓地
function s.ddop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己是否可以将卡组顶部3张卡送去墓地
	local b1=Duel.IsPlayerCanDiscardDeck(tp,3)
	-- 判断对方是否可以将卡组顶部3张卡送去墓地
	local b2=Duel.IsPlayerCanDiscardDeck(1-tp,3)
	if not b1 and not b2 then return end
	local opt=0
	if b1 and not b2 then
		-- 选择从自己卡组送去墓地的选项
		opt=Duel.SelectOption(tp,aux.Stringid(id,1))  --"从自己卡组上面把3张卡送去墓地"
	end
	if not b1 and b2 then
		-- 选择从对方卡组送去墓地的选项
		opt=Duel.SelectOption(tp,aux.Stringid(id,2))+1  --"从对方卡组上面把3张卡送去墓地"
	end
	if b1 and b2 then
		-- 选择从谁的卡组送去墓地的选项
		opt=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))  --"从自己卡组上面把3张卡送去墓地/从对方卡组上面把3张卡送去墓地"
	end
	if opt==0 then
		-- 执行从自己卡组送去墓地的操作
		Duel.DiscardDeck(tp,3,REASON_EFFECT)
	else
		-- 执行从对方卡组送去墓地的操作
		Duel.DiscardDeck(1-tp,3,REASON_EFFECT)
	end
end
-- ③效果的发动条件，判断此卡是否因效果被送去墓地
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- ③效果的目标设定函数，判断是否可以将卡组顶部2张卡送去墓地
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己是否可以将卡组顶部2张卡送去墓地
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,2) end
	-- 设置操作对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置操作参数为2
	Duel.SetTargetParam(2)
	-- 设置操作信息：将卡组顶部2张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,2)
end
-- ③效果的处理函数，执行将卡组顶部2张卡送去墓地的操作
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行将指定玩家卡组顶部d张卡送去墓地的操作
	Duel.DiscardDeck(p,d,REASON_EFFECT)
end

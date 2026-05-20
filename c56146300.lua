--B・F－猛撃のレイピア
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上的表侧表示怪兽不存在的场合或者只有昆虫族怪兽的场合，从手卡丢弃1只其他的昆虫族怪兽才能发动。从卡组把1张「蜂军风」在自己的魔法与陷阱区域表侧表示放置。那之后，这张卡从手卡特殊召唤。这个回合，自己不是昆虫族怪兽不能从额外卡组特殊召唤。
-- ②：把墓地的这张卡除外才能发动。自己场上1只昆虫族怪兽的等级下降1星。
local s,id,o=GetID()
-- 初始化函数，注册卡片的两个起动效果
function s.initial_effect(c)
	-- 记录该卡效果中记载了「蜂军风」的卡名
	aux.AddCodeList(c,67441879)
	-- ①：自己场上的表侧表示怪兽不存在的场合或者只有昆虫族怪兽的场合，从手卡丢弃1只其他的昆虫族怪兽才能发动。从卡组把1张「蜂军风」在自己的魔法与陷阱区域表侧表示放置。那之后，这张卡从手卡特殊召唤。这个回合，自己不是昆虫族怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。自己场上1只昆虫族怪兽的等级下降1星。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"等级下降"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 设置发动代价为将墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.lvtg)
	e2:SetOperation(s.lvop)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示的非昆虫族怪兽
function s.cfilter(c)
	return c:IsFaceup() and not c:IsRace(RACE_INSECT)
end
-- ①效果的发动条件：自己场上不存在表侧表示的非昆虫族怪兽
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否不存在表侧表示的非昆虫族怪兽
	return not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：手卡中可丢弃的昆虫族怪兽
function s.costfilter(c)
	return c:IsRace(RACE_INSECT) and c:IsDiscardable()
end
-- ①效果的发动代价：从手卡丢弃1只其他的昆虫族怪兽
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在除这张卡以外的昆虫族怪兽可以丢弃
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 丢弃手卡中1只除这张卡以外的昆虫族怪兽作为发动代价
	Duel.DiscardHand(tp,s.costfilter,1,1,REASON_COST+REASON_DISCARD,e:GetHandler())
end
-- 过滤条件：卡组中可以表侧表示放置到魔陷区的「蜂军风」
function s.acfilter(c,tp)
	return c:IsCode(67441879) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- ①效果的靶向/可行性检查：检查魔陷区和怪兽区是否有空位，卡组中是否有「蜂军风」，且自身能否特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的魔法与陷阱区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己场上是否有可用的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在可以放置的「蜂军风」
		and Duel.IsExistingMatchingCard(s.acfilter,tp,LOCATION_DECK,0,1,nil,tp)
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
end
-- ①效果的处理：从卡组将「蜂军风」表侧表示放置，那之后将这张卡特殊召唤，并适用额外卡组特殊召唤限制
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自己场上是否有可用的魔法与陷阱区域
	if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		-- 提示玩家选择要放置到场上的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
		-- 从卡组选择1张「蜂军风」
		local tc=Duel.SelectMatchingCard(tp,s.acfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
		-- 将选中的卡在自己的魔法与陷阱区域表侧表示放置，并检查是否成功
		if tc and Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)~=0
			and c:IsRelateToEffect(e) then
			-- 中断当前效果，使后续的特殊召唤处理不与放置卡片视为同时进行
			Duel.BreakEffect()
			-- 将这张卡从手卡表侧表示特殊召唤
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 这个回合，自己不是昆虫族怪兽不能从额外卡组特殊召唤。/自己场上1只昆虫族怪兽的等级下降1星。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该回合内限制玩家从额外卡组特殊召唤非昆虫族怪兽的效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制不能从额外卡组特殊召唤非昆虫族怪兽
function s.splimit(e,c)
	return not c:IsRace(RACE_INSECT) and c:IsLocation(LOCATION_EXTRA)
end
-- 过滤条件：自己场上表侧表示且等级在2星以上的昆虫族怪兽
function s.lvfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(2) and c:IsRace(RACE_INSECT)
end
-- ②效果的靶向/可行性检查：检查自己场上是否存在符合条件的昆虫族怪兽
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查自己场上是否存在等级在2星以上的表侧表示昆虫族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.lvfilter,tp,LOCATION_MZONE,0,1,nil) end
end
-- ②效果的处理：选择自己场上1只昆虫族怪兽，使其等级下降1星
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要适用的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 玩家选择自己场上1只符合条件的昆虫族怪兽
	local g=Duel.SelectMatchingCard(tp,s.lvfilter,tp,LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 选中目标怪兽并显示选择动画
		Duel.HintSelection(g)
		-- 等级下降1星
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(-1)
		tc:RegisterEffect(e1)
	end
end

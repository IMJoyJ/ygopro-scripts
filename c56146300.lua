--B・F－猛撃のレイピア
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上的表侧表示怪兽不存在的场合或者只有昆虫族怪兽的场合，从手卡丢弃1只其他的昆虫族怪兽才能发动。从卡组把1张「蜂军风」在自己的魔法与陷阱区域表侧表示放置。那之后，这张卡从手卡特殊召唤。这个回合，自己不是昆虫族怪兽不能从额外卡组特殊召唤。
-- ②：把墓地的这张卡除外才能发动。自己场上1只昆虫族怪兽的等级下降1星。
local s,id,o=GetID()
-- 初始化卡片效果，在卡片关系列表中添加「蜂军风」，并注册手卡特殊召唤以及墓地除外下降等级的两个起动效果。
function s.initial_effect(c)
	-- 在卡片关系列表中添加「蜂军风」的卡片密码，表示该卡记载了此卡名。
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
	-- 设置效果的发动代价为将墓地的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.lvtg)
	e2:SetOperation(s.lvop)
	c:RegisterEffect(e2)
end
-- 过滤条件：筛选自己场上表侧表示的非昆虫族怪兽。
function s.cfilter(c)
	return c:IsFaceup() and not c:IsRace(RACE_INSECT)
end
-- 检查自己场上是否不存在表侧表示的非昆虫族怪兽，作为效果①的发动条件。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上是否存在至少1张表侧表示的非昆虫族怪兽并取反，即要求场上没有非昆虫族怪兽。
	return not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：筛选手卡中可以被丢弃的昆虫族怪兽。
function s.costfilter(c)
	return c:IsRace(RACE_INSECT) and c:IsDiscardable()
end
-- 检查并执行丢弃手卡中1只除这张卡以外的昆虫族怪兽的效果发动代价。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果①发动阶段检查手卡中是否存在除这张卡以外的可以丢弃的昆虫族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 从手卡丢弃1只除这张卡以外的昆虫族怪兽。
	Duel.DiscardHand(tp,s.costfilter,1,1,REASON_COST+REASON_DISCARD,e:GetHandler())
end
-- 过滤条件：筛选卡组中卡名为「蜂军风」、未被禁止且可放置在自己场上的卡片。
function s.acfilter(c,tp)
	return c:IsCode(67441879) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- 检查自己场上魔法与陷阱区域、怪兽区域是否存在空位，卡组中是否存在可放置的「蜂军风」，且这张卡能特殊召唤，作为效果①的靶向检查。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上魔法与陷阱区域是否存在可用空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己场上怪兽区域是否存在可用空位。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己卡组中是否存在可以放置的「蜂军风」。
		and Duel.IsExistingMatchingCard(s.acfilter,tp,LOCATION_DECK,0,1,nil,tp)
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
end
-- 从卡组把1张「蜂军风」在魔法与陷阱区域表侧表示放置，那之后将这张卡从手卡特殊召唤，并限制本回合只能特殊召唤昆虫族怪兽。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断自己场上魔法与陷阱区域是否仍有可用空位。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		-- 提示玩家选择要放置到场上的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
		-- 让玩家从卡组选择1张符合条件的「蜂军风」。
		local tc=Duel.SelectMatchingCard(tp,s.acfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
		-- 将选择的卡片在自己的魔法与陷阱区域表侧表示放置。
		if tc and Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			and c:IsRelateToEffect(e) then
			-- 中断当前效果的处理，使后面的特殊召唤和前面的放置不视为同时处理。
			Duel.BreakEffect()
			-- 将这张卡从手卡表侧表示特殊召唤。
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 这个回合，自己不是昆虫族怪兽不能从额外卡组特殊召唤。自己场上1只昆虫族怪兽的等级下降1星。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册对玩家生效的自肃效果，本回合自己不是昆虫族怪兽不能从额外卡组特殊召唤。
	Duel.RegisterEffect(e1,tp)
end
-- 特殊召唤限制条件：限制从额外卡组特殊召唤非昆虫族怪兽。
function s.splimit(e,c)
	return not c:IsRace(RACE_INSECT) and c:IsLocation(LOCATION_EXTRA)
end
-- 过滤条件：筛选自己场上表侧表示、等级在2星以上且是昆虫族的怪兽。
function s.lvfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(2) and c:IsRace(RACE_INSECT)
end
-- 检查自己场上是否存在符合降低等级条件的昆虫族怪兽。
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查自己场上是否存在至少1只表侧表示且等级在2星以上的昆虫族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.lvfilter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 选择自己场上1只符合条件的昆虫族怪兽，让其等级下降1星。
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择作为效果对象的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从自己场上选择1只符合条件的昆虫族怪兽。
	local g=Duel.SelectMatchingCard(tp,s.lvfilter,tp,LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 对选择的卡片显示提示标记或动画以指示目标。
		Duel.HintSelection(g)
		-- 自己场上1只昆虫族怪兽的等级下降1星。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(-1)
		tc:RegisterEffect(e1)
	end
end

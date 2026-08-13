--B・F－猛撃のレイピア
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上的表侧表示怪兽不存在的场合或者只有昆虫族怪兽的场合，从手卡丢弃1只其他的昆虫族怪兽才能发动。从卡组把1张「蜂军风」在自己的魔法与陷阱区域表侧表示放置。那之后，这张卡从手卡特殊召唤。这个回合，自己不是昆虫族怪兽不能从额外卡组特殊召唤。
-- ②：把墓地的这张卡除外才能发动。自己场上1只昆虫族怪兽的等级下降1星。
local s,id,o=GetID()
-- 初始化卡片效果：记录卡上记载的「蜂军风」卡名，注册手卡发动的①效果（特殊召唤，含放置「蜂军风」与特殊召唤自身）和墓地发动的②效果（除外自身让昆虫族怪兽等级下降1星），两个效果均设置同名卡1回合1次的次数限制
function s.initial_effect(c)
	-- 记录这张卡上记载了「蜂军风」（卡号67441879）的卡名
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
	-- 设置②效果的发动代价：把墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.lvtg)
	e2:SetOperation(s.lvop)
	c:RegisterEffect(e2)
end
-- 过滤函数：找出自己场上表侧表示且不是昆虫族的怪兽
function s.cfilter(c)
	return c:IsFaceup() and not c:IsRace(RACE_INSECT)
end
-- ①效果的发动条件：自己场上不存在表侧表示的非昆虫族怪兽（即场上没有怪兽或只有昆虫族怪兽）
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己主要怪兽区不存在表侧表示的非昆虫族怪兽，满足时才能发动①效果
	return not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 代价过滤函数：找出手卡中可以丢弃的昆虫族怪兽
function s.costfilter(c)
	return c:IsRace(RACE_INSECT) and c:IsDiscardable()
end
-- ①效果的发动代价：从手卡丢弃1只其他的昆虫族怪兽（不含这张卡自身）
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在这张卡以外可以丢弃的昆虫族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 让玩家选择手卡中这张卡以外的1只昆虫族怪兽，作为代价丢弃
	Duel.DiscardHand(tp,s.costfilter,1,1,REASON_COST+REASON_DISCARD,e:GetHandler())
end
-- 过滤函数：找出卡组中卡名为「蜂军风」、未被禁止且满足场上同名卡数量限制、可以放置的卡
function s.acfilter(c,tp)
	return c:IsCode(67441879) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- ①效果的目标检查：自己的魔法与陷阱区和主要怪兽区均有空格、卡组存在可放置的「蜂军风」、且这张卡可以从手卡特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的魔法与陷阱区是否有可用空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 并且检查自己的主要怪兽区是否有可用空格
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查卡组中是否存在可以放置到场上的「蜂军风」
		and Duel.IsExistingMatchingCard(s.acfilter,tp,LOCATION_DECK,0,1,nil,tp)
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
end
-- ①效果的处理：从卡组选1张「蜂军风」在自己的魔法与陷阱区域表侧表示放置，那之后把这张卡从手卡特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认自己的魔法与陷阱区仍有可用空格才进行放置处理
	if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		-- 向玩家显示「请选择要放置到场上的卡」的选卡提示
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
		-- 让玩家从卡组选择1张可以放置的「蜂军风」
		local tc=Duel.SelectMatchingCard(tp,s.acfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
		-- 若选卡成功且成功把「蜂军风」移动到自己的魔法与陷阱区表侧表示放置，且这张卡仍与效果关联
		if tc and Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
			and c:IsRelateToEffect(e) then
			-- 中断当前效果处理，使放置与之后的特殊召唤视为不同时处理（避免错时点问题）
			Duel.BreakEffect()
			-- 把这张卡从手卡以表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 这个回合，自己不是昆虫族怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 把「不能特殊召唤非昆虫族的额外卡组怪兽」的限制效果注册给自己，直到回合结束
	Duel.RegisterEffect(e1,tp)
end
-- 限制过滤：额外卡组的非昆虫族怪兽不能特殊召唤
function s.splimit(e,c)
	return not c:IsRace(RACE_INSECT) and c:IsLocation(LOCATION_EXTRA)
end
-- 过滤函数：找出自己场上表侧表示、等级2以上的昆虫族怪兽
function s.lvfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(2) and c:IsRace(RACE_INSECT)
end
-- ②效果的目标检查：自己场上存在表侧表示且等级2以上的昆虫族怪兽
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查自己主要怪兽区是否存在表侧表示、等级2以上的昆虫族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.lvfilter,tp,LOCATION_MZONE,0,1,nil) end
end
-- ②效果的处理：选择自己场上1只表侧表示、等级2以上的昆虫族怪兽，使其等级下降1星
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 向玩家显示「请选择效果的对象」的选卡提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从自己主要怪兽区选择1只表侧表示、等级2以上的昆虫族怪兽
	local g=Duel.SelectMatchingCard(tp,s.lvfilter,tp,LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 为选中的怪兽显示被选为对象的动画，并记录其被选为对象
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

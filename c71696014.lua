--マジシャンズ・ローブ
-- 效果：
-- 「魔术师之袍」的①②的效果1回合各能使用1次。
-- ①：对方回合从手卡丢弃1张魔法·陷阱卡才能发动。从卡组把1只「黑魔术师」特殊召唤。
-- ②：这张卡在墓地存在的状态，对方回合自己把魔法·陷阱卡的效果发动的场合才能发动。这张卡从墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c71696014.initial_effect(c)
	-- 注册卡片关联密码，表示这张卡的效果中记载了「黑魔术师」的卡名
	aux.AddCodeList(c,46986414)
	-- ①：对方回合从手卡丢弃1张魔法·陷阱卡才能发动。从卡组把1只「黑魔术师」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(71696014,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,71696014)
	e1:SetCondition(c71696014.condition1)
	e1:SetCost(c71696014.cost)
	e1:SetTarget(c71696014.target1)
	e1:SetOperation(c71696014.operation1)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，对方回合自己把魔法·陷阱卡的效果发动的场合才能发动。这张卡从墓地特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(71696014,1))  --"这张卡特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,71696015)
	e3:SetCondition(c71696014.condition2)
	e3:SetTarget(c71696014.target2)
	e3:SetOperation(c71696014.operation2)
	c:RegisterEffect(e3)
end
-- 效果①的发动条件：必须在对方回合
function c71696014.condition1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否不是自己（即对方回合）
	return Duel.GetTurnPlayer()~=tp
end
-- 过滤手牌中可丢弃的魔法·陷阱卡
function c71696014.cfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsDiscardable()
end
-- 效果①的发动代价：从手卡丢弃1张魔法·陷阱卡
function c71696014.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在至少1张可丢弃的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c71696014.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家选择并丢弃1张手牌中的魔法·陷阱卡作为发动代价
	Duel.DiscardHand(tp,c71696014.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤卡组中可以特殊召唤的「黑魔术师」
function c71696014.filter(c,e,tp)
	return c:IsCode(46986414) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备与合法性检查（检查怪兽区域空位和卡组中是否存在「黑魔术师」）
function c71696014.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在可以特殊召唤的「黑魔术师」
		and Duel.IsExistingMatchingCard(c71696014.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息，表示该效果会从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理：从卡组把1只「黑魔术师」特殊召唤
function c71696014.operation1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否仍有可用的怪兽区域空格，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只满足条件的「黑魔术师」
	local g=Duel.SelectMatchingCard(tp,c71696014.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的「黑魔术师」以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②的发动条件：对方回合自己把魔法·陷阱卡的效果发动
function c71696014.condition2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为对方回合，且发动效果的玩家是自己，且该效果属于魔法或陷阱卡
	return Duel.GetTurnPlayer()~=tp and rp==tp and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果②的发动准备与合法性检查（检查怪兽区域空位和自身是否能特殊召唤）
function c71696014.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理的操作信息，表示该效果会特殊召唤这张卡自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果②的效果处理：将这张卡从墓地特殊召唤，并添加离场时除外的限制
function c71696014.operation2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自己场上是否有可用怪兽区域空格，且这张卡是否仍与效果相关联，若不满足则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<1 or not c:IsRelateToEffect(e) then return end
	-- 尝试将这张卡以表侧表示特殊召唤，若特殊召唤成功则进行后续处理
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end

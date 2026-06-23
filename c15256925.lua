--滅びの呪文－デス・アルテマ
-- 效果：
-- ①：自己场上有8星以上的魔法师族怪兽存在的场合才能发动。选场上1张卡里侧表示除外。
-- ②：魔法与陷阱区域的这张卡被对方的效果破坏的场合才能发动。从卡组把1只「黑混沌之魔术师」或者「混沌之黑魔术师」无视召唤条件特殊召唤。
function c15256925.initial_effect(c)
	-- ①：自己场上有8星以上的魔法师族怪兽存在的场合才能发动。选场上1张卡里侧表示除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCondition(c15256925.condition)
	e1:SetTarget(c15256925.target)
	e1:SetOperation(c15256925.activate)
	c:RegisterEffect(e1)
	-- ②：魔法与陷阱区域的这张卡被对方的效果破坏的场合才能发动。从卡组把1只「黑混沌之魔术师」或者「混沌之黑魔术师」无视召唤条件特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(15256925,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(c15256925.spcon)
	e2:SetTarget(c15256925.sptg)
	e2:SetOperation(c15256925.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于检查场上是否存在8星以上的魔法师族怪兽
function c15256925.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER) and c:IsLevelAbove(8)
end
-- 效果条件函数，判断自己场上是否存在8星以上的魔法师族怪兽
function c15256925.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只8星以上的魔法师族怪兽
	return Duel.IsExistingMatchingCard(c15256925.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果目标函数，设置效果处理时要除外的卡片组
function c15256925.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少1张可以除外的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler(),tp,POS_FACEDOWN) end
	-- 获取场上所有可以除外的卡的集合
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler(),tp,POS_FACEDOWN)
	-- 设置效果处理时要除外的卡的数量为1
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果处理函数，执行除外操作
function c15256925.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	-- 选择场上1张可以除外的卡
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,aux.ExceptThisCard(e),tp,POS_FACEDOWN)
	if g:GetCount()>0 then
		-- 显示选中的卡被选为对象的动画
		Duel.HintSelection(g)
		-- 将选中的卡以里侧表示的方式除外
		Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
	end
end
-- 特殊召唤发动条件函数，判断此卡是否因对方效果被破坏且处于魔法与陷阱区域
function c15256925.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_SZONE) and rp==1-tp
end
-- 过滤函数，用于筛选卡组中「黑混沌之魔术师」或「混沌之黑魔术师」
function c15256925.spfilter(c,e,tp)
	return c:IsCode(30208479,40737112) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 特殊召唤效果目标函数，设置效果处理时要特殊召唤的卡片
function c15256925.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有足够的特殊召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只「黑混沌之魔术师」或「混沌之黑魔术师」
		and Duel.IsExistingMatchingCard(c15256925.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理时要特殊召唤的卡的数量为1
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 特殊召唤效果处理函数，执行特殊召唤操作
function c15256925.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 从卡组中选择1只「黑混沌之魔术师」或「混沌之黑魔术师」
	local g=Duel.SelectMatchingCard(tp,c15256925.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的卡无视召唤条件特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end

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
-- 过滤条件：判定怪兽是否为表侧表示、魔法师族且等级在8以上。
function c15256925.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER) and c:IsLevelAbove(8)
end
-- 效果①的发动条件：确认自己场上存在至少1只满足cfilter条件的怪兽。
function c15256925.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 具体检索：以我方场上怪兽区域为范围，检查是否存在1只表侧表示·魔法师族·8星以上的怪兽。
	return Duel.IsExistingMatchingCard(c15256925.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果①的发动目标阶段：确认场上存在可被里侧除外的卡，并设置处理时除外1张卡的操作信息。
function c15256925.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 合法性检查：场上存在至少1张能被除外的卡，且不能选择效果发动者自身。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler(),tp,POS_FACEDOWN) end
	-- 取得场上所有可被除外的卡（排除效果发动者自身），用于操作信息的目标集合。
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,e:GetHandler(),tp,POS_FACEDOWN)
	-- 设置操作信息：本次连锁处理将进行除外，对象卡组为g，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果①的解决处理：实际选择场上1张卡以里侧表示除外。
function c15256925.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要除外的卡，显示“请选择要除外的卡”的选择消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家从场上选择1张可被除外的卡（排除效果发动者自身）作为本次除外对象。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,aux.ExceptThisCard(e),tp,POS_FACEDOWN)
	if g:GetCount()>0 then
		-- 显示被选中卡的对象动画，并记录这些卡被选为对象。
		Duel.HintSelection(g)
		-- 将选择的卡以里侧表示除外，原因为效果。
		Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
	end
end
-- 效果②的发动条件：这张卡被对方的效果破坏，且破坏前位于魔法与陷阱区域。
function c15256925.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_SZONE) and rp==1-tp
end
-- 特殊召唤对象的过滤条件：卡名是「黑混沌之魔术师」或「混沌之黑魔术师」，且可以被无视召唤条件特殊召唤。
function c15256925.spfilter(c,e,tp)
	return c:IsCode(30208479,40737112) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 效果②的发动目标阶段：确认己方主怪兽区有空位，且卡组中存在符合条件的特殊召唤对象。
function c15256925.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 合法性检查之一：己方场上主怪兽区存在可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 合法性检查之二：卡组中存在满足spfilter条件的怪兽。
		and Duel.IsExistingMatchingCard(c15256925.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：本次处理将从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果②的解决处理：实际从卡组选择1只符合条件的怪兽进行特殊召唤。
function c15256925.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的卡，显示“请选择要特殊召唤的卡”的选择消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从卡组选择1只满足spfilter条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c15256925.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽无视召唤条件以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end

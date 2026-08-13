--おろかな墓荒らし
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：除「愚蠢的盗墓者」外的1张有「时间黑魔术师」的卡名记述的卡从卡组送去墓地。那之后，可以把自己或对方的墓地1只怪兽在自己场上特殊召唤。
-- ②：把墓地的这张卡除外才能发动。以下其中1张卡在自己场上盖放。
-- ●除「愚蠢的盗墓者」外的有「时间黑魔术师」的卡名记述的自己墓地的魔法·陷阱卡
-- ●对方墓地的魔法·陷阱卡
local s,id,o=GetID()
-- 初始化函数：注册卡名记载关系，并注册效果①（发动型：卡组送墓+墓地特殊召唤）和效果②（墓地发动的诱发即时效果：盖放魔陷）
function s.initial_effect(c)
	-- 在这张卡上登记其效果文本记载了「时间黑魔术师」（卡号40235813）这一卡名
	aux.AddCodeList(c,40235813)
	-- 这个卡名的①②的效果1回合各能使用1次。①：除「愚蠢的盗墓者」外的1张有「时间黑魔术师」的卡名记述的卡从卡组送去墓地。那之后，可以把自己或对方的墓地1只怪兽在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"送去墓地"
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。以下其中1张卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"盖放"
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	-- 设置发动代价：把墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
-- 送去墓地的候选卡过滤器：判断卡是否可作为①效果从卡组送去墓地的对象
function s.tgfilter(c)
	-- 该卡不是「愚蠢的盗墓者」本身、效果文本记载了「时间黑魔术师」且能够被送去墓地
	return not c:IsCode(id) and aux.IsCodeListed(c,40235813) and c:IsAbleToGrave()
end
-- ①效果的目标函数：检查卡组是否存在可送墓的卡，并设置操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：卡组中至少存在1张满足送墓过滤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：将把卡组1张卡送去墓地（用于王家长眠之谷等效果的检测）
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 特殊召唤候选过滤器：判断该怪兽是否满足可以被特殊召唤的条件
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的处理：从卡组选卡送墓，之后可将自己或对方墓地1只怪兽特殊召唤到自己场上
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家：请选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1张满足送墓条件的卡
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 把选中的卡以效果原因送去墓地，并确认其确实进入了墓地
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)~=0 and g:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE)
		-- 且自己场上主要怪兽区还有可用的空格
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且自己或对方墓地存在可以被特殊召唤的怪兽（同时不受王家长眠之谷影响）
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp)
		-- 并询问玩家是否要进行特殊召唤，玩家选择是则继续处理
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否特殊召唤？"
		-- 中断当前效果处理，使特殊召唤不与送墓同时处理（对应「那之后」）
		Duel.BreakEffect()
		-- 提示玩家：请选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从自己或对方墓地选择1只可以被特殊召唤的怪兽
		local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
		-- 为选中的怪兽显示被选为对象的动画并记录
		Duel.HintSelection(sg)
		-- 把选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 盖放候选过滤器：可盖放的魔法·陷阱卡，且为场地魔法或魔法陷阱区有空位，并且是对方墓地的卡或自己墓地记载了「时间黑魔术师」的非本卡卡
function s.stfilter(c,tp)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable(true)
		-- 且该卡是场地魔法卡，或者自己的魔法陷阱区还有可用空格
		and (c:IsType(TYPE_FIELD) or Duel.GetLocationCount(tp,LOCATION_SZONE)>0)
		-- 且该卡由对方控制（对方墓地的卡），或是记载了「时间黑魔术师」且不是「愚蠢的盗墓者」的卡
		and (c:IsControler(1-tp) or aux.IsCodeListed(c,40235813) and not c:IsCode(id))
end
-- ②效果的目标函数：检查双方墓地是否存在可盖放的卡
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：双方墓地至少存在1张满足盖放条件的卡（除外这张卡自身）
	if chk==0 then return Duel.IsExistingMatchingCard(s.stfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,e:GetHandler(),tp) end
end
-- ②效果的处理：从双方墓地选择1张魔法·陷阱卡在自己场上盖放
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家：请选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从自己或对方墓地选择1张满足盖放条件的魔法·陷阱卡（不受王家长眠之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.stfilter),tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,tp)
	if #g>0 then
		-- 为选中的卡显示被选为对象的动画并记录
		Duel.HintSelection(g)
		-- 把选中的卡在自己场上盖放
		Duel.SSet(tp,g)
	end
end

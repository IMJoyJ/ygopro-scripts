--フルール・シンクロン
-- 效果：
-- ①：这张卡作为同调素材送去墓地的场合才能发动。从手卡把1只2星以下的怪兽特殊召唤。
function c19642774.initial_effect(c)
	-- ①：这张卡作为同调素材送去墓地的场合才能发动。从手卡把1只2星以下的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19642774,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetCondition(c19642774.con)
	e1:SetTarget(c19642774.tg)
	e1:SetOperation(c19642774.op)
	c:RegisterEffect(e1)
end
-- 判定效果发动条件：此卡当前在墓地，且其作为同调素材被送去墓地（因为同调召唤）。
function c19642774.con(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- 筛选可特殊召唤的怪兽：等级为2星以下，且能被当前效果特殊召唤（不无视召唤条件和苏生限制）。
function c19642774.filter(c,e,tp)
	return c:IsLevelBelow(2) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动合法性检查：自己场上存在可用的主要怪兽区空格，且手牌中有1张满足筛选条件的怪兽才能发动。
function c19642774.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有足够的怪兽区空格可用（主要怪兽区空格数>0）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在至少1张满足c19642774.filter条件的卡（2星以下且可特殊召唤的怪兽）。
		and Duel.IsExistingMatchingCard(c19642774.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：本效果处理时将进行特殊召唤，处理对象来自手牌（用于给时点/连锁响应提供信息）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：选择手卡中1只2星以下且可特殊召唤的怪兽，将其表侧攻击表示特殊召唤到自己场上。
function c19642774.op(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己场上是否有可用怪兽区空格，若无则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向操作玩家发送选择提示，提示内容为‘请选择要特殊召唤的卡’。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手牌中筛选并选择1张满足条件的怪兽（2星以下且可特殊召唤）作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c19642774.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上（不无视特殊召唤条件和苏生限制）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

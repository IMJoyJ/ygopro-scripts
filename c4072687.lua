--受け入れがたい結果
-- 效果：
-- ①：自己场上有魔法师族怪兽存在的场合才能发动。从手卡把1只「占卜魔女」怪兽特殊召唤。
function c4072687.initial_effect(c)
	-- ①：自己场上有魔法师族怪兽存在的场合才能发动。从手卡把1只「占卜魔女」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c4072687.condition)
	e1:SetTarget(c4072687.target)
	e1:SetOperation(c4072687.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：卡为表侧表示且种族为魔法师族怪兽，用于检查自己场上是否存在满足发动条件的魔法师族怪兽。
function c4072687.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER)
end
-- 发动条件判定：自己场上存在至少1张表侧表示的魔法师族怪兽时才能发动。
function c4072687.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己主要怪兽区是否存在1张以上表侧表示且种族为魔法师族的怪兽。
	return Duel.IsExistingMatchingCard(c4072687.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：手牌中属于「占卜魔女」（0x12e）系列且能够被玩家tp以效果e特殊召唤的怪兽。
function c4072687.filter(c,e,tp)
	return c:IsSetCard(0x12e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时合法判定：chk==0时，要求自己主要怪兽区有空位，且手牌存在可特殊召唤的「占卜魔女」怪兽；满足则发动有效。
function c4072687.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时检查自己主要怪兽区是否还有空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 且手牌中存在至少1只符合特殊召唤条件的「占卜魔女」怪兽。
		and Duel.IsExistingMatchingCard(c4072687.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 登记本次效果将进行从手牌特殊召唤1只怪兽的操作信息，供后续连锁/时点判断使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：若自己主要怪兽区仍有空位，则从手牌选择1只「占卜魔女」怪兽，以表侧表示特殊召唤到自己场上。
function c4072687.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 处理前再次确认自己主要怪兽区有空位，防止处理时无空位而失败。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示“请选择要特殊召唤的卡”的选择提示，引导玩家选择手牌中的「占卜魔女」怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌中选出1只满足特殊召唤条件的「占卜魔女」怪兽。
	local g=Duel.SelectMatchingCard(tp,c4072687.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

--神星なる波動
-- 效果：
-- ①：1回合1次，自己主要阶段以及对方战斗阶段才能把这个效果发动。从手卡把1只「星骑士」怪兽特殊召唤。
function c5026221.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，自己主要阶段以及对方战斗阶段才能把这个效果发动。从手卡把1只「星骑士」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(5026221,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c5026221.condition)
	e2:SetTarget(c5026221.target2)
	e2:SetOperation(c5026221.operation)
	c:RegisterEffect(e2)
end
-- 发动条件判定：若当前为自己回合，则仅限主要阶段1或2；若为对方回合，则仅限战斗阶段（从战斗阶段开始到战斗阶段结束）。
function c5026221.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前所处阶段，用于判断是否符合发动时机。
	local ph=Duel.GetCurrentPhase()
	-- 判断当前回合玩家是否为自己，以区分按照自己回合还是对方回合的发动时机进行限制。
	if Duel.GetTurnPlayer()==tp then
		return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
	else
		return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
	end
end
-- 筛选条件：手牌中属于「星骑士」字段，且当前能够被该效果合法特殊召唤的怪兽（正常检查召唤条件与苏生限制）。
function c5026221.filter(c,e,tp)
	return c:IsSetCard(0x9c) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时的合法性检测：确认自己主要怪兽区有空位，且手牌中存在至少1只满足筛选条件的「星骑士」怪兽；同时登记特殊召唤的操作信息。
function c5026221.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动前检测条件之一：自己场上主要怪兽区存在可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动前检测条件之二：手牌中存在至少1只符合筛选条件的「星骑士」怪兽。
		and Duel.IsExistingMatchingCard(c5026221.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 登记操作信息：本次效果将把1只来自手牌的怪兽特殊召唤，用于连锁响应及发动时点的判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：先确认怪兽区仍有空格，然后选择1只手牌中符合条件的「星骑士」怪兽，以表侧表示特殊召唤到自己场上。
function c5026221.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理前再次确认场上是否有可用怪兽区空格，若没有则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出选择提示“请选择要特殊召唤的卡”，引导玩家选择特殊召唤对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌中选择1只满足筛选条件的「星骑士」怪兽作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c5026221.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上（按正常规则检查召唤条件与苏生限制）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

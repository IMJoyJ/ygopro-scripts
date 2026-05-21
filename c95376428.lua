--召喚制限－エクストラネット
-- 效果：
-- ①：自己或者对方从额外卡组把怪兽特殊召唤的场合把这个效果发动。从把那些怪兽特殊召唤的玩家来看的对方可以让以下效果适用。
-- ●从卡组抽1张。
function c95376428.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己或者对方从额外卡组把怪兽特殊召唤的场合把这个效果发动。从把那些怪兽特殊召唤的玩家来看的对方可以让以下效果适用。●从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(95376428,0))  --"抽卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCondition(c95376428.condition)
	e2:SetTarget(c95376428.target)
	e2:SetOperation(c95376428.operation)
	c:RegisterEffect(e2)
end
-- 检查特殊召唤的怪兽中是否存在原本在额外卡组的怪兽，作为效果发动的条件
function c95376428.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsPreviousLocation,1,nil,LOCATION_EXTRA)
end
-- 效果发动时的目标处理，因为是诱发必发效果，直接返回true
function c95376428.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
end
-- 过滤函数，用于检查怪兽是否由指定玩家特殊召唤
function c95376428.filter(c,tp)
	return c:IsSummonPlayer(tp)
end
-- 效果处理，分别判断双方玩家是否有从额外卡组特殊召唤怪兽，并让其对手选择是否抽1张卡
function c95376428.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 如果当前回合玩家特殊召唤了怪兽，且其对手可以抽卡，则询问对手是否选择抽卡
	if eg:IsExists(c95376428.filter,1,nil,tp) and Duel.IsPlayerCanDraw(1-tp,1) and Duel.SelectYesNo(1-tp,aux.Stringid(95376428,1)) then  --"是否抽1张卡？"
		-- 让当前回合玩家的对手从卡组抽1张卡
		Duel.Draw(1-tp,1,REASON_EFFECT)
	end
	-- 如果当前回合玩家的对手特殊召唤了怪兽，且当前回合玩家可以抽卡，则询问当前回合玩家是否选择抽卡
	if eg:IsExists(c95376428.filter,1,nil,1-tp) and Duel.IsPlayerCanDraw(tp,1) and Duel.SelectYesNo(tp,aux.Stringid(95376428,1)) then  --"是否抽1张卡？"
		-- 让当前回合玩家从卡组抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end

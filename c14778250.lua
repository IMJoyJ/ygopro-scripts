--THE トリッキー
-- 效果：
-- ①：这张卡可以丢弃1张手卡，从手卡特殊召唤。
function c14778250.initial_effect(c)
	-- ①：这张卡可以丢弃1张手卡，从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c14778250.spcon)
	e1:SetTarget(c14778250.sptg)
	e1:SetOperation(c14778250.spop)
	c:RegisterEffect(e1)
end
-- 特殊召唤规则的召唤条件判断：当c为nil时视为规则询问，返回真表示可以尝试进行特殊召唤；否则需要确认自己主要怪兽区有空位，且手牌中存在除自身外的可丢弃手牌。
function c14778250.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 确认自己场上主要怪兽区存在可用空格，保证特殊召唤有格子可用。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己手牌中是否存在至少1张除诡术师自身以外的、可以丢弃的手牌，以满足召唤代价。
		and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,c)
end
-- 特殊召唤规则的目标处理：让玩家从手牌中选择1张可丢弃的卡作为丢弃代价；若没有选择则不能进行特殊召唤。
function c14778250.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己手牌中所有可丢弃的卡，并排除诡术师自身（不能丢弃自己来支付这个召唤代价）。
	local g=Duel.GetMatchingGroup(Card.IsDiscardable,tp,LOCATION_HAND,0,c)
	-- 显示“请选择要丢弃的手牌”的选择提示，引导玩家选择要丢弃的手牌。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则的效果处理：从效果对象中取出之前选择存储的那张手牌，并将其送入墓地，完成丢弃手牌的召唤手续。
function c14778250.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选定的手牌送去墓地，丢弃原因包含特殊召唤和丢弃（REASON_SPSUMMON+REASON_DISCARD）。
	Duel.SendtoGrave(g,REASON_SPSUMMON+REASON_DISCARD)
end

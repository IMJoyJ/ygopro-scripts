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
-- 检查特殊召唤的条件是否满足
function c14778250.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判断玩家场上是否有怪兽区域空位
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断玩家手牌中是否存在可丢弃的卡片
		and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,c)
end
-- 设置特殊召唤的目标选择函数
function c14778250.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家手牌中所有可丢弃的卡片
	local g=Duel.GetMatchingGroup(Card.IsDiscardable,tp,LOCATION_HAND,0,c)
	-- 向玩家提示选择要丢弃的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 设置特殊召唤的效果发动函数
function c14778250.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的卡片送去墓地，视为因特殊召唤和丢弃而离开
	Duel.SendtoGrave(g,REASON_SPSUMMON+REASON_DISCARD)
end

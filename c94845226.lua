--魔轟神獣ルビィラーダ
-- 效果：
-- 自己场上表侧表示存在的这张卡被选择作为攻击对象时，可以从手卡丢弃1只名字带有「魔轰神」的怪兽让那次攻击无效。
function c94845226.initial_effect(c)
	-- 自己场上表侧表示存在的这张卡被选择作为攻击对象时，可以从手卡丢弃1只名字带有「魔轰神」的怪兽让那次攻击无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(94845226,0))  --"攻击无效"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetCost(c94845226.cost)
	e1:SetOperation(c94845226.op)
	c:RegisterEffect(e1)
end
-- 过滤手牌中可以被丢弃的名字带有「魔轰神」的怪兽
function c94845226.cfilter(c)
	return c:IsSetCard(0x35) and c:IsType(TYPE_MONSTER) and c:IsDiscardable()
end
-- 发动代价：从手卡丢弃1只名字带有「魔轰神」的怪兽
function c94845226.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在至少1只满足过滤条件的名字带有「魔轰神」的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c94845226.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家选择并以丢弃和代价为原因将1张手牌中满足过滤条件的名字带有「魔轰神」的怪兽送去墓地
	Duel.DiscardHand(tp,c94845226.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 效果处理：使那次攻击无效
function c94845226.op(e,tp,eg,ep,ev,re,r,rp)
	-- 无效当前的攻击
	Duel.NegateAttack()
end

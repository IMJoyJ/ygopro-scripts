--王家の生け贄
-- 效果：
-- 当自己场上有「王家长眠之谷」存在时才能发动。双方玩家把手卡中的怪兽卡全部丢弃去墓地。
function c72405967.initial_effect(c)
	-- 当自己场上有「王家长眠之谷」存在时才能发动。双方玩家把手卡中的怪兽卡全部丢弃去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_HANDES_SELF+CATEGORY_HANDES_OPPO+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c72405967.condition)
	e1:SetTarget(c72405967.target)
	e1:SetOperation(c72405967.activate)
	c:RegisterEffect(e1)
end
-- 发动条件：检查场上是否存在「王家长眠之谷」
function c72405967.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前生效的场地是否是自己控制的「王家长眠之谷」
	return Duel.IsEnvironment(47355498,tp)
end
-- 发动时的目标确认与操作信息设置
function c72405967.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查双方手牌中是否存在至少1张卡（排除此卡自身）
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_HAND,LOCATION_HAND,1,e:GetHandler()) end
	Duel.SetOperationInfo(0,CATEGORY_HANDES_SELF,nil,0,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_HANDES_OPPO,nil,0,1-tp,0)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,PLAYER_ALL,LOCATION_HAND)
end
-- 效果处理：将双方手牌中的怪兽卡全部丢弃去墓地
function c72405967.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方手牌中所有的怪兽卡
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_HAND,LOCATION_HAND,nil,TYPE_MONSTER)
	if g:GetCount()>0 then
		-- 将这些怪兽卡因效果丢弃送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)
	end
end

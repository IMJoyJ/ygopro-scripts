--古代の採掘機
-- 效果：
-- ①：自己场上有「古代的机械」怪兽存在的场合，丢弃1张手卡才能发动。从卡组选1张魔法卡在自己场上盖放。这个效果盖放的卡在这个回合不能发动。
function c67829249.initial_effect(c)
	-- ①：自己场上有「古代的机械」怪兽存在的场合，丢弃1张手卡才能发动。从卡组选1张魔法卡在自己场上盖放。这个效果盖放的卡在这个回合不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_SSET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c67829249.condition)
	e1:SetCost(c67829249.cost)
	e1:SetTarget(c67829249.target)
	e1:SetOperation(c67829249.operation)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的「古代的机械」怪兽
function c67829249.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x7)
end
-- 发动条件：检查自己场上是否存在表侧表示的「古代的机械」怪兽
function c67829249.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只表侧表示的「古代的机械」怪兽
	return Duel.IsExistingMatchingCard(c67829249.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 发动代价：丢弃1张手卡
function c67829249.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查手卡中是否存在可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 让玩家选择并丢弃1张手卡作为发动代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤条件：卡组中可以盖放的魔法卡
function c67829249.filter(c)
	return c:IsType(TYPE_SPELL) and c:IsSSetable()
end
-- 发动目标：检查卡组中是否存在可以盖放的魔法卡
function c67829249.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查卡组中是否存在至少1张可以盖放的魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c67829249.filter,tp,LOCATION_DECK,0,1,nil) end
end
-- 效果处理：从卡组选择1张魔法卡在自己场上盖放，并限制该卡在本回合不能发动
function c67829249.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从卡组中选择1张满足条件的魔法卡
	local g=Duel.SelectMatchingCard(tp,c67829249.filter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	-- 如果成功将选中的魔法卡在自己场上盖放
	if tc and Duel.SSet(tp,tc)~=0 then
		-- 这个效果盖放的卡在这个回合不能发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+0x17a0000+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1,true)
	end
end

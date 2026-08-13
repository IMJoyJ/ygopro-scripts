--N・アクア・ドルフィン
-- 效果：
-- ①：1回合1次，丢弃1张手卡才能发动。把对方手卡确认，从那之中选1只怪兽。持有选的怪兽的攻击力以上的攻击力的怪兽在自己场上存在的场合，选的怪兽破坏，给与对方500伤害。那以外的场合，自己受到500伤害。
function c17955766.initial_effect(c)
	-- 效果：①：1回合1次，丢弃1张手卡才能发动。把对方手卡确认，选那之内的1只怪兽。持有选的怪兽的攻击力以上的攻击力的怪兽在自己场上存在的场合，选的怪兽破坏，给与对方500伤害。那以外的场合，自己受到500伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(17955766,0))  --"确认手卡"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c17955766.cost)
	e1:SetTarget(c17955766.target)
	e1:SetOperation(c17955766.activate)
	c:RegisterEffect(e1)
end
-- 效果发动代价函数：在判定阶段确认自己手牌中有无可丢弃的卡；在发动时选择并丢弃1张手卡作为发动代价。
function c17955766.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段（chk==0）：确认自己手牌中存在至少1张可以丢弃的卡，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 实际执行代价：从自己手牌选择1张可丢弃的卡丢弃，原因标记为REASON_COST+REASON_DISCARD。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 效果发动的目标/合法性检查函数：由于效果处理时需要确认对方手牌并选择其中1只怪兽，因此发动时需确认对方手牌中存在至少1张卡。
function c17955766.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 目标检查阶段（chk==0）：确认对方手牌卡数大于0，否则无法发动。
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
end
-- 过滤函数：筛选自己场上表侧表示且当前攻击力不低于指定攻击力(atk)的怪兽，用于判断场上是否存在攻击力高于等于所选怪兽的怪兽。
function c17955766.filter(c,atk)
	return c:IsFaceup() and c:IsAttackAbove(atk)
end
-- 效果处理主函数：确认对方手牌，从中选择1只怪兽，根据自己场上是否有表侧表示且攻击力不低于该怪兽的怪兽来决定是破坏所选怪兽并给对方500伤害，还是自己受到500伤害；最后洗切对方手牌。
function c17955766.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方手牌的所有卡，存入组对象g。
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if g:GetCount()>0 then
		-- 向发动玩家tp公开确认对方的手牌。
		Duel.ConfirmCards(tp,g)
		-- 显示选择提示“请选择一张怪兽卡”，引导玩家从对方手牌中选择1只怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(17955766,1))  --"请选择一张怪兽卡"
		local tg=g:FilterSelect(tp,Card.IsType,1,1,nil,TYPE_MONSTER)
		local tc=tg:GetFirst()
		if tc then
			-- 判断所选怪兽的攻击力不低于0，且自己场上存在表侧表示且攻击力不低于所选怪兽当前攻击力的怪兽。
			if tc:IsAttackAbove(0) and Duel.IsExistingMatchingCard(c17955766.filter,tp,LOCATION_MZONE,0,1,nil,tc:GetAttack()) then
				-- 以效果原因将选中的对方怪兽破坏。
				Duel.Destroy(tc,REASON_EFFECT)
				-- 给与对方（1-tp）500点效果伤害。
				Duel.Damage(1-tp,500,REASON_EFFECT)
			else
				-- 自己（tp）受到500点效果伤害。
				Duel.Damage(tp,500,REASON_EFFECT)
			end
		end
		-- 因对方手牌被公开确认过，效果处理结束后将对方手牌洗切。
		Duel.ShuffleHand(1-tp)
	end
end

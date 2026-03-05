--N・アクア・ドルフィン
-- 效果：
-- ①：1回合1次，丢弃1张手卡才能发动。把对方手卡确认，从那之中选1只怪兽。持有选的怪兽的攻击力以上的攻击力的怪兽在自己场上存在的场合，选的怪兽破坏，给与对方500伤害。那以外的场合，自己受到500伤害。
function c17955766.initial_effect(c)
	-- 效果原文内容：①：1回合1次，丢弃1张手卡才能发动。把对方手卡确认，从那之中选1只怪兽。持有选的怪兽的攻击力以上的攻击力的怪兽在自己场上存在的场合，选的怪兽破坏，给与对方500伤害。那以外的场合，自己受到500伤害。
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
-- 规则层面操作：检查是否满足丢弃手卡的代价条件
function c17955766.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：判断玩家手牌是否存在
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 规则层面操作：执行丢弃1张手卡的操作
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 规则层面操作：检查是否满足选择目标的条件
function c17955766.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：判断对方手牌是否存在
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0 end
end
-- 规则层面操作：定义过滤函数，用于筛选场上攻击力满足条件的怪兽
function c17955766.filter(c,atk)
	return c:IsFaceup() and c:IsAttackAbove(atk)
end
-- 规则层面操作：主效果执行流程，包括确认对方手牌、选择目标怪兽、判断是否满足破坏条件并执行相应效果
function c17955766.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：获取对方手牌组
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if g:GetCount()>0 then
		-- 规则层面操作：确认对方手牌内容
		Duel.ConfirmCards(tp,g)
		-- 规则层面操作：提示玩家选择一张怪兽卡
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(17955766,1))  --"请选择一张怪兽卡"
		local tg=g:FilterSelect(tp,Card.IsType,1,1,nil,TYPE_MONSTER)
		local tc=tg:GetFirst()
		if tc then
			-- 规则层面操作：判断己方场上是否存在攻击力大于等于选中怪兽攻击力的怪兽
			if tc:IsAttackAbove(0) and Duel.IsExistingMatchingCard(c17955766.filter,tp,LOCATION_MZONE,0,1,nil,tc:GetAttack()) then
				-- 规则层面操作：破坏选中的怪兽
				Duel.Destroy(tc,REASON_EFFECT)
				-- 规则层面操作：给与对方500伤害
				Duel.Damage(1-tp,500,REASON_EFFECT)
			else
				-- 规则层面操作：自己受到500伤害
				Duel.Damage(tp,500,REASON_EFFECT)
			end
		end
		-- 规则层面操作：洗切对方手牌
		Duel.ShuffleHand(1-tp)
	end
end

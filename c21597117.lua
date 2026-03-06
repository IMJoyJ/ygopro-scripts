--ヒーロー見参
-- 效果：
-- ①：对方怪兽的攻击宣言时才能发动。自己1张手卡由对方随机选。那是怪兽的场合，在自己场上特殊召唤，不是的场合送去墓地。
function c21597117.initial_effect(c)
	-- 效果初始化，设置效果类型为发动时效果，触发条件为攻击宣言时，关联条件、目标和发动函数
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c21597117.condition)
	e1:SetTarget(c21597117.target)
	e1:SetOperation(c21597117.activate)
	c:RegisterEffect(e1)
end
-- 效果发动条件：只有在对方回合才能发动
function c21597117.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 对方回合才能发动
	return tp~=Duel.GetTurnPlayer()
end
-- 过滤函数，用于判断手牌中是否有可以特殊召唤的怪兽
function c21597117.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标确认函数，检查是否有满足条件的怪兽可以特殊召唤
function c21597117.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空位可以特殊召唤怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己手牌中是否存在至少一张可以特殊召唤的怪兽
		and Duel.IsExistingMatchingCard(c21597117.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
end
-- 效果发动时的处理函数，执行具体效果
function c21597117.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否还有空位以及是否可以特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not Duel.IsPlayerCanSpecialSummon(tp) then return end
	-- 获取自己手牌的全部卡片组
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	local sg=g:RandomSelect(1-tp,1)
	local tc=sg:GetFirst()
	if tc then
		-- 向对方确认所选的卡片
		Duel.ConfirmCards(1-tp,tc)
		if tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then
			-- 将选中的卡片特殊召唤到自己场上
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		else
			-- 将选中的卡片送去墓地
			Duel.SendtoGrave(tc,REASON_EFFECT)
		end
	end
end

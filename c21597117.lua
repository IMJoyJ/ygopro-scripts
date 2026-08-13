--ヒーロー見参
-- 效果：
-- ①：对方怪兽的攻击宣言时才能发动。自己1张手卡由对方随机选。那是怪兽的场合，在自己场上特殊召唤，不是的场合送去墓地。
function c21597117.initial_effect(c)
	-- ①：对方怪兽的攻击宣言时才能发动。自己1张手卡由对方随机选。那是怪兽的场合，在自己场上特殊召唤，不是的场合送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c21597117.condition)
	e1:SetTarget(c21597117.target)
	e1:SetOperation(c21597117.activate)
	c:RegisterEffect(e1)
end
-- 效果发动条件函数：判断是否满足“对方怪兽的攻击宣言时”这一发动时机，即当前回合玩家不是效果发动者。
function c21597117.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回 tp 不等于当前回合玩家，确保是对方的回合、对方怪兽进行攻击宣言。
	return tp~=Duel.GetTurnPlayer()
end
-- 手牌怪兽特殊召唤过滤器：判断手牌中的怪兽是否能够被效果 e 特殊召唤到 tp 场上。
function c21597117.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时点合法性检测：确认 tp 的主要怪兽区有空位，并且手牌中存在至少 1 只可被特殊召唤的怪兽候选，否则不能发动。
function c21597117.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查 tp 的主要怪兽区是否有空余格子可供后续特殊召唤使用。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查 tp 手牌中是否存在至少 1 张满足特殊召唤条件的怪兽卡。
		and Duel.IsExistingMatchingCard(c21597117.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
end
-- 效果处理函数：在满足发动条件后，从自己手牌中随机选择 1 张卡给对方确认，若是怪兽则可特殊召唤则特殊召唤，否则送去墓地。
function c21597117.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若主要怪兽区没有空位或 tp 当前不能进行特殊召唤，则效果不处理，直接结束。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or not Duel.IsPlayerCanSpecialSummon(tp) then return end
	-- 获取 tp 手牌中的全部卡片，作为对方随机选择的候选集合。
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	local sg=g:RandomSelect(1-tp,1)
	local tc=sg:GetFirst()
	if tc then
		-- 将随机选出的那张手牌展示给对方玩家确认，对应“由对方随机选”的确认过程。
		Duel.ConfirmCards(1-tp,tc)
		if tc:IsCanBeSpecialSummoned(e,0,tp,false,false) then
			-- 当随机选出的卡是怪兽且满足特殊召唤条件时，将其以表侧攻击表示特殊召唤到 tp 的场上。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		else
			-- 当随机选出的卡不是怪兽或无法特殊召唤时，将其因效果送去墓地。
			Duel.SendtoGrave(tc,REASON_EFFECT)
		end
	end
end

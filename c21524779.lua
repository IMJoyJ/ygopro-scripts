--OKaサンダー
-- 效果：
-- 1回合1次，自己的主要阶段时才能发动。从手卡把「雷电妈妈」以外的1只雷族·光属性·4星的怪兽召唤。
function c21524779.initial_effect(c)
	-- 效果原文内容：1回合1次，自己的主要阶段时才能发动。从手卡把「雷电妈妈」以外的1只雷族·光属性·4星的怪兽召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21524779,0))  --"召唤"
	e1:SetCategory(CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c21524779.target)
	e1:SetOperation(c21524779.operation)
	c:RegisterEffect(e1)
end
-- 检索满足条件的卡片组：雷族、光属性、4星、不是雷电妈妈、可以通常召唤的怪兽
function c21524779.filter(c)
	return c:IsRace(RACE_THUNDER) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLevel(4)
		and not c:IsCode(21524779) and c:IsSummonable(true,nil)
end
-- 效果作用：检查是否满足发动条件并设置连锁操作信息
function c21524779.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：检查手牌中是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c21524779.filter,tp,LOCATION_HAND,0,1,nil) end
	-- 规则层面操作：设置连锁操作信息为召唤类别
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 效果作用：处理效果发动后的操作
function c21524779.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：提示玩家选择要召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 规则层面操作：从手牌中选择满足条件的1张怪兽卡
	local g=Duel.SelectMatchingCard(tp,c21524779.filter,tp,LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 规则层面操作：将选中的怪兽通常召唤
		Duel.Summon(tp,tc,true,nil)
	end
end

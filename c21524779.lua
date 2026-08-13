--OKaサンダー
-- 效果：
-- 1回合1次，自己的主要阶段时才能发动。从手卡把「雷电妈妈」以外的1只雷族·光属性·4星的怪兽召唤。
function c21524779.initial_effect(c)
	-- 对应效果原文：1回合1次，自己的主要阶段时才能发动。从手卡把「雷电妈妈」以外的1只雷族·光属性·4星的怪兽召唤。
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
-- 筛选手卡中满足雷族·光属性·4星、卡名不是「雷电妈妈」且可进行通常召唤的怪兽。
function c21524779.filter(c)
	return c:IsRace(RACE_THUNDER) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLevel(4)
		and not c:IsCode(21524779) and c:IsSummonable(true,nil)
end
-- 效果发动的目标判定：确认手牌存在符合条件的怪兽，并设置“召唤”的操作信息。
function c21524779.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认手牌存在至少1张满足条件的“雷族·光属性·4星”且非「雷电妈妈」的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c21524779.filter,tp,LOCATION_HAND,0,1,nil) end
	-- 设置操作信息：将本效果标记为包含1次“召唤”处理（用于后续连锁判定等）。
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 效果处理：从手牌选择1只符合条件的怪兽进行通常召唤（不占用通常召唤次数）。
function c21524779.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 向操作玩家显示“请选择要召唤的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 从手卡中选择1只满足条件的雷族·光属性·4星且非「雷电妈妈」的怪兽。
	local g=Duel.SelectMatchingCard(tp,c21524779.filter,tp,LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的怪兽进行通常召唤（本次召唤不计入每回合的通常召唤次数限制）。
		Duel.Summon(tp,tc,true,nil)
	end
end

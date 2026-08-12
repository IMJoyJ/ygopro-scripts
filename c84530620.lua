--OToサンダー
-- 效果：
-- 1回合1次，自己的主要阶段时才能发动。从手卡把「雷电爸爸」以外的1只雷族·光属性·4星的怪兽召唤。
function c84530620.initial_effect(c)
	-- 1回合1次，自己的主要阶段时才能发动。从手卡把「雷电爸爸」以外的1只雷族·光属性·4星的怪兽召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(84530620,0))  --"召唤"
	e1:SetCategory(CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c84530620.target)
	e1:SetOperation(c84530620.operation)
	c:RegisterEffect(e1)
end
-- 过滤手牌中除「雷电爸爸」以外的4星、光属性、雷族且可以进行通常召唤的怪兽
function c84530620.filter(c)
	return c:IsRace(RACE_THUNDER) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsLevel(4)
		and not c:IsCode(84530620) and c:IsSummonable(true,nil)
end
-- 效果发动的目标检查与操作信息设置：检查手牌中是否存在满足条件的怪兽，并设置召唤的操作信息
function c84530620.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查手牌中是否存在至少1只满足过滤条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c84530620.filter,tp,LOCATION_HAND,0,1,nil) end
	-- 设置连锁处理的操作信息，表示该效果包含召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 效果处理：让玩家从手牌选择1只满足条件的怪兽并进行通常召唤
function c84530620.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 在客户端显示提示信息，要求玩家选择要召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 让玩家从手牌中选择1只满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c84530620.filter,tp,LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 让玩家对选中的怪兽进行通常召唤，且忽略每回合的通常召唤次数限制
		Duel.Summon(tp,tc,true,nil)
	end
end

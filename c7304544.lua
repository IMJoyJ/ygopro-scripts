--ナチュル・パイナポー
-- 效果：
-- 在自己场上表侧表示存在的怪兽作为植物族。自己的准备阶段这张卡在墓地存在，自己场上不存在魔法·陷阱卡的场合，这张卡可以在自己场上特殊召唤。这个效果在自己场上不存在表侧表示的「自然菠萝」，自己墓地只存在植物族·兽族怪兽的场合才能发动。
function c7304544.initial_effect(c)
	-- 在自己场上表侧表示存在的怪兽作为植物族。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_RACE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetValue(RACE_PLANT)
	c:RegisterEffect(e1)
	-- 自己的准备阶段这张卡在墓地存在，自己场上不存在魔法·陷阱卡的场合，这张卡可以在自己场上特殊召唤。这个效果在自己场上不存在表侧表示的「自然菠萝」，自己墓地只存在植物族·兽族怪兽的场合才能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(7304544,0))  --"特殊召唤"
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1)
	e2:SetCondition(c7304544.condition)
	e2:SetTarget(c7304544.target)
	e2:SetOperation(c7304544.operation)
	c:RegisterEffect(e2)
end
-- 过滤场上表侧表示的卡名为「自然菠萝」的卡片
function c7304544.filter(c)
	return c:IsCode(7304544) and c:IsFaceup()
end
-- 过滤墓地中不是植物族且不是兽族的怪兽卡
function c7304544.filter2(c)
	return c:IsType(TYPE_MONSTER) and not c:IsRace(RACE_PLANT+RACE_BEAST)
end
-- 判断是否满足发动条件：当前为自己的准备阶段，自己场上没有魔陷，且场上没有表侧表示的「自然菠萝」，且墓地仅有植物族·兽族怪兽
function c7304544.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为自己的回合，且自己场上不存在魔法·陷阱卡
	return tp==Duel.GetTurnPlayer() and not Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_ONFIELD,0,1,nil,TYPE_SPELL+TYPE_TRAP)
		-- 检查自己场上是否不存在表侧表示的「自然菠萝」
		and not Duel.IsExistingMatchingCard(c7304544.filter,tp,LOCATION_ONFIELD,0,1,nil)
		-- 检查自己墓地是否只存在植物族·兽族怪兽（即不存在非植物族且非兽族的怪兽）
		and not Duel.IsExistingMatchingCard(c7304544.filter2,tp,LOCATION_GRAVE,0,1,nil)
end
-- 特殊召唤效果的发动准备，检查怪兽区域空位及自身是否能特殊召唤
function c7304544.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查时，确认自己场上的主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，将自身作为特殊召唤的对象
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理，若自身仍存在且场上仍无魔陷，则将自身特殊召唤
function c7304544.operation(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e)
		-- 在效果处理时，再次确认自己场上不存在魔法·陷阱卡
		and not Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_ONFIELD,0,1,nil,TYPE_SPELL+TYPE_TRAP) then
		-- 将此卡以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end

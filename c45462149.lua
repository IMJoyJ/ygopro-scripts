--コード・トーカー・インヴァート
-- 效果：
-- 电子界族怪兽2只
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡连接召唤成功的场合才能发动。从手卡把1只电子界族怪兽在作为这张卡所连接区的自己场上特殊召唤。
function c45462149.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加连接召唤手续，要求使用2只电子界族怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_CYBERSE),2,2)
	-- ①：这张卡连接召唤成功的场合才能发动。从手卡把1只电子界族怪兽在作为这张卡所连接区的自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45462149,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,45462149)
	e1:SetCondition(c45462149.condition)
	e1:SetTarget(c45462149.target)
	e1:SetOperation(c45462149.operation)
	c:RegisterEffect(e1)
end
-- 判断发动效果的怪兽是否为连接召唤方式特殊召唤
function c45462149.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 过滤满足条件的电子界族怪兽，且该怪兽可以被特殊召唤
function c45462149.filter(c,e,tp,zone)
	return c:IsRace(RACE_CYBERSE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
-- 设置连锁处理的目标为从手牌特殊召唤1只电子界族怪兽
function c45462149.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local zone=e:GetHandler():GetLinkedZone(tp)
		-- 检查手牌中是否存在满足条件的电子界族怪兽
		return Duel.IsExistingMatchingCard(c45462149.filter,tp,LOCATION_HAND,0,1,nil,e,tp,zone)
	end
	-- 设置连锁操作信息为特殊召唤1只电子界族怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 执行特殊召唤操作，选择手牌中的电子界族怪兽进行特殊召唤
function c45462149.operation(e,tp,eg,ep,ev,re,r,rp)
	local zone=e:GetHandler():GetLinkedZone(tp)
	-- 判断目标区域是否有足够的空位用于特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手牌中选择满足条件的电子界族怪兽
		local g=Duel.SelectMatchingCard(tp,c45462149.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp,zone)
		if g:GetCount()>0 then
			-- 将选中的怪兽特殊召唤到场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP,zone)
		end
	end
end

--コード・トーカー・インヴァート
-- 效果：
-- 电子界族怪兽2只
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡连接召唤成功的场合才能发动。从手卡把1只电子界族怪兽在作为这张卡所连接区的自己场上特殊召唤。
function c45462149.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续：需要2只电子界族怪兽作为连接素材。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_CYBERSE),2,2)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡连接召唤成功的场合才能发动。从手卡把1只电子界族怪兽在作为这张卡所连接区的自己场上特殊召唤。
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
-- 效果发动条件：判定这张卡是否为连接召唤成功。
function c45462149.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 过滤函数：选择手卡中种族为电子界且能被当前效果特殊召唤到这张卡连接区的怪兽。
function c45462149.filter(c,e,tp,zone)
	return c:IsRace(RACE_CYBERSE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
-- 效果发动时的目标处理：检查这张卡的连接区是否存在，且手卡中有1只符合条件的电子界族怪兽；然后登记特殊召唤的操作信息。
function c45462149.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local zone=e:GetHandler():GetLinkedZone(tp)
		-- 检查手卡是否存在至少1只满足过滤条件的电子界族怪兽，可作为特殊召唤对象。
		return Duel.IsExistingMatchingCard(c45462149.filter,tp,LOCATION_HAND,0,1,nil,e,tp,zone)
	end
	-- 登记操作信息：本次效果处理将进行1只怪兽从手卡的特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：从手卡选择1只电子界族怪兽，特殊召唤到这张卡的连接区域。
function c45462149.operation(e,tp,eg,ep,ev,re,r,rp)
	local zone=e:GetHandler():GetLinkedZone(tp)
	-- 检查这张卡的连接区域是否仍有空格可进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)>0 then
		-- 提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 玩家从手卡选择1只满足条件的电子界族怪兽。
		local g=Duel.SelectMatchingCard(tp,c45462149.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp,zone)
		if g:GetCount()>0 then
			-- 将选择的怪兽以表侧表示特殊召唤到这张卡的连接区域。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP,zone)
		end
	end
end

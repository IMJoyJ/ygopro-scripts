--アンブラル・ゴースト
-- 效果：
-- 自己的主要阶段时才能发动。这张卡和1只4星以下的恶魔族怪兽从手卡特殊召唤。这个效果发动的回合，自己不能通常召唤。「阴影幽鬼」的效果1回合只能使用1次。
function c59708927.initial_effect(c)
	-- 自己的主要阶段时才能发动。这张卡和1只4星以下的恶魔族怪兽从手卡特殊召唤。这个效果发动的回合，自己不能通常召唤。「阴影幽鬼」的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(59708927,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,59708927)
	e1:SetCost(c59708927.spcost)
	e1:SetTarget(c59708927.sptg)
	e1:SetOperation(c59708927.spop)
	c:RegisterEffect(e1)
end
-- 过滤手卡中等级4以下且可以特殊召唤的恶魔族怪兽。
function c59708927.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_FIEND) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的Cost：检查本回合是否进行过通常召唤，并给玩家注册本回合不能通常召唤/盖放怪兽的效果。
function c59708927.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本回合玩家是否进行过通常召唤（包括放置）。
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_NORMALSUMMON)==0 end
	-- 这个效果发动的回合，自己不能通常召唤。这张卡和1只4星以下的恶魔族怪兽从手卡特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	-- 给玩家注册不能通常召唤的效果。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_MSET)
	-- 给玩家注册不能通常召唤的放置（盖放）的效果。
	Duel.RegisterEffect(e2,tp)
end
-- 效果发动的Target：检查自身和手卡中符合条件的怪兽是否能特殊召唤，且场上有2个以上空位。
function c59708927.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查玩家场上的怪兽区域是否有2个以上的空位。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查手卡中是否存在除这张卡以外的1只4星以下的恶魔族怪兽。
		and Duel.IsExistingMatchingCard(c59708927.filter,tp,LOCATION_HAND,0,1,e:GetHandler(),e,tp) end
	-- 设置特殊召唤的操作信息，表示将从手卡特殊召唤2只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND)
end
-- 效果处理的Operation：将这张卡和手卡中选择的1只4星以下恶魔族怪兽特殊召唤。
function c59708927.spop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 检查怪兽区域空位是否不足2个，若不足则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 提示玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只除自身以外的4星以下恶魔族怪兽。
	local g=Duel.SelectMatchingCard(tp,c59708927.filter,tp,LOCATION_HAND,0,1,1,e:GetHandler(),e,tp)
	if g:GetCount()>0 then
		g:AddCard(e:GetHandler())
		-- 将选中的怪兽和这张卡以表侧表示特殊召唤。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

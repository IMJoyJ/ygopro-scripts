--煉獄の狂宴
-- 效果：
-- ①：把自己的手卡·场上（表侧表示）1张「炼狱」魔法·陷阱卡送去墓地才能发动。等级合计直到变成8星为止，从卡组把最多3只「狱火机」怪兽无视召唤条件特殊召唤。
function c31548814.initial_effect(c)
	-- ①：把自己的手卡·场上（表侧表示）1张「炼狱」魔法·陷阱卡送去墓地才能发动。等级合计直到变成8星为止，从卡组把最多3只「狱火机」怪兽无视召唤条件特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c31548814.cost)
	e1:SetTarget(c31548814.target)
	e1:SetOperation(c31548814.activate)
	c:RegisterEffect(e1)
end
-- 定义代价过滤条件：卡必须是「炼狱」魔法·陷阱卡，且处于表侧表示或手牌，并且可以作为代价送去墓地。
function c31548814.costfilter(c)
	return c:IsSetCard(0xc5) and c:IsType(TYPE_SPELL+TYPE_TRAP) and (c:IsFaceup() or c:IsLocation(LOCATION_HAND)) and c:IsAbleToGraveAsCost()
end
-- 代价处理函数：发动前检查是否存在满足条件的卡，然后提示玩家选择1张「炼狱」魔法·陷阱卡并送去墓地，作为发动效果的代价。
function c31548814.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在代价确认阶段（chk==0），检查场上或手牌是否存在至少1张满足代价过滤条件的卡，以决定效果是否可以发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c31548814.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,e:GetHandler()) end
	-- 向操作玩家显示选择提示，内容为“请选择要送去墓地的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从手牌或场上选择1张满足条件的「炼狱」魔法·陷阱卡作为代价，且不能选择发动效果的这张卡本身。
	local g=Duel.SelectMatchingCard(tp,c31548814.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,e:GetHandler())
	-- 将选择的卡以代价形式送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 定义特殊召唤过滤条件：卡必须是「狱火机」怪兽，并且可以无视召唤条件被特殊召唤。
function c31548814.spfilter(c,e,tp)
	return c:IsSetCard(0xbb) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
-- 目标函数：在发动时确认可用怪兽区数量、是否受青眼精灵龙限制，以及卡组中存在等级合计为8的「狱火机」怪兽组合；登记特殊召唤操作信息。
function c31548814.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 计算当前可用的主怪兽区数量，最多允许特殊召唤3只怪兽。
		local ft=math.min((Duel.GetLocationCount(tp,LOCATION_MZONE)),3)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if ft>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
		-- 获取卡组中所有满足特殊召唤条件的「狱火机」怪兽。
		local g=Duel.GetMatchingGroup(c31548814.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
		return ft>0 and g:CheckWithSumEqual(Card.GetLevel,8,1,ft)
	end
	-- 登记本次连锁的操作信息，标明将从卡组进行特殊召唤，供其他卡效果（如星尘龙等）进行发动检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数：再次确认可用怪兽区数量和青眼精灵龙限制，从卡组选择等级合计为8、数量不超过可用区的「狱火机」怪兽，并全部无视召唤条件正面表示特殊召唤。
function c31548814.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 计算当前可用的主怪兽区数量，最多允许特殊召唤3只怪兽。
	local ft=math.min((Duel.GetLocationCount(tp,LOCATION_MZONE)),3)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if ft>1 and Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 获取卡组中所有满足特殊召唤条件的「狱火机」怪兽。
	local g=Duel.GetMatchingGroup(c31548814.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	if ft<=0 or g:GetCount()==0 then return end
	-- 向操作玩家显示选择提示，内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=g:SelectWithSumEqual(tp,Card.GetLevel,8,1,ft)
	-- 将选中的怪兽无视召唤条件、以表侧表示特殊召唤到自己的怪兽区域。
	Duel.SpecialSummon(sg,0,tp,tp,true,false,POS_FACEUP)
end

--ミノケンサテュロス
-- 效果：
-- 这张卡不能特殊召唤。可以把这张卡解放，从自己卡组把2只兽战士族·4星的通常怪兽特殊召唤。
function c43708640.initial_effect(c)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 可以把这张卡解放，从自己卡组把2只兽战士族·4星的通常怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(43708640,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c43708640.spcost)
	e2:SetTarget(c43708640.sptg)
	e2:SetOperation(c43708640.spop)
	c:RegisterEffect(e2)
end
-- 代价判定函数：检查这张卡是否可被解放，以此作为发动效果的代价；若可以则继续发动，并在正式发动时解放自身。
function c43708640.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将这张卡解放并送去墓地，作为效果发动所需的代价（REASON_COST）。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 特殊召唤的筛选条件：从自己卡组选择等级4、兽战士族、通常怪兽，且该怪兽能够被当前效果特殊召唤（同时满足召唤条件和苏生限制）。
function c43708640.filter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsLevel(4) and c:IsRace(RACE_BEASTWARRIOR)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动目标的合法性检查：确认我方不受青眼精灵龙效果影响、场上拥有可用的怪兽区域，且卡组中存在至少2只符合条件的怪兽。
function c43708640.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检查自己场上是否有可用的怪兽区域（因为需要解放自身，解放后空位会增加，所以此处要求至少1个空格即可）。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己卡组中是否存在至少2张满足筛选条件的兽战士族·4星通常怪兽。
		and Duel.IsExistingMatchingCard(c43708640.filter,tp,LOCATION_DECK,0,2,nil,e,tp) end
	-- 登记本次效果的操作信息：分类为特殊召唤，预计从卡组特殊召唤2只怪兽，用于连锁处理、时点提示和相关效果判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- 效果处理函数：再次确认青眼精灵龙效果未生效且自己场上至少有2个可用怪兽区域，然后从卡组选出2只符合条件的兽战士族通常怪兽进行特殊召唤。
function c43708640.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 检查自己场上可用怪兽区域是否达到2个，不足则效果处理中止（因为需要特殊召唤2只怪兽）。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 获取卡组中所有符合特殊召唤条件的怪兽集合，作为待选择列表。
	local g=Duel.GetMatchingGroup(c43708640.filter,tp,LOCATION_DECK,0,nil,e,tp)
	if g:GetCount()>=2 then
		-- 向操作者显示“请选择要特殊召唤的卡”的选择提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,2,2,nil)
		-- 将选中的2只怪兽以表侧表示特殊召唤到自己场上，同时遵守怪兽的召唤条件与苏生限制。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end

--喚忌の呪眼
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己的手卡·墓地选1只「咒眼」怪兽特殊召唤。自己的魔法与陷阱区域有「太阴之咒眼」存在的场合，也能作为代替从卡组把1只「咒眼」怪兽特殊召唤。
function c17616743.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从自己的手卡·墓地选1只「咒眼」怪兽特殊召唤。自己的魔法与陷阱区域有「太阴之咒眼」存在的场合，也能作为代替从卡组把1只「咒眼」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,17616743+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c17616743.sptg)
	e1:SetOperation(c17616743.spop)
	c:RegisterEffect(e1)
end
-- 该过滤函数用于判定候选怪兽：必须是「咒眼」怪兽，且能被玩家tp以当前效果特殊召唤（需满足通常的特殊召唤条件与苏生限制）。
function c17616743.spfilter(c,e,tp)
	return c:IsSetCard(0x129) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 该过滤函数用于判定己方魔法与陷阱区是否存在表侧表示的「太阴之咒眼」。
function c17616743.filter(c)
	return c:IsCode(44133040) and c:IsFaceup()
end
-- 发动条件与目标范围的判定：先确认主要怪兽区有空位；默认可选范围为手卡·墓地，若存在表侧「太阴之咒眼」则将卡组也加入可选位置；只要上述范围内存在1只满足条件的「咒眼」怪兽即可发动，并写入特殊召唤1只怪兽的操作信息。
function c17616743.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 检查己方主要怪兽区域是否有空位，若无空格则不能发动效果。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
		local loc=LOCATION_HAND+LOCATION_GRAVE
		-- 检查己方魔法与陷阱区域是否存在表侧表示的「太阴之咒眼」，以决定是否将卡组加入可选特殊召唤范围。
		if Duel.IsExistingMatchingCard(c17616743.filter,tp,LOCATION_SZONE,0,1,nil) then
			loc=loc+LOCATION_DECK
		end
		-- 确认在当前可选范围内（手卡·墓地，或包含卡组）是否存在至少1只符合特殊召唤条件的「咒眼」怪兽，作为发动的前提。
		return Duel.IsExistingMatchingCard(c17616743.spfilter,tp,loc,0,1,nil,e,tp)
	end
	-- 设置操作信息：宣告本次效果的类别为特殊召唤（CATEGORY_SPECIAL_SUMMON），预定处理1只怪兽，来源范围为手卡·墓地·卡组；由于实际对象在效果处理时选择，此处targets传nil。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK)
end
-- 效果处理时的整体逻辑：若主要怪兽区域有空位，则按「太阴之咒眼」是否在场确定可选范围，由玩家选择1只符合条件的「咒眼」怪兽，并特殊召唤到己方场上。
function c17616743.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若效果处理时主要怪兽区域已没有空位，则终止处理，不进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local loc=LOCATION_HAND+LOCATION_GRAVE
	-- 效果处理时再次确认己方魔法与陷阱区域是否有表侧表示的「太阴之咒眼」，有则允许从卡组选择特殊召唤对象。
	if Duel.IsExistingMatchingCard(c17616743.filter,tp,LOCATION_SZONE,0,1,nil) then
		loc=loc+LOCATION_DECK
	end
	-- 向当前玩家显示选择提示，指定提示类型为选择卡片消息，内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从确定的范围内选择1张满足条件的「咒眼」怪兽；使用NecroValleyFilter过滤，使受『王家长眠之谷』影响的墓地候选不会被选中。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c17616743.spfilter),tp,loc,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到己方场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

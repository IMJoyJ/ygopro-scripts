--希望の天啓
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把自己场上1只表侧表示的龙族·8星怪兽送去墓地才能发动。把1只龙族·8阶的超量怪兽当作超量召唤从额外卡组特殊召唤。
local s,id,o=GetID()
-- 创建效果，设置效果描述、分类、类型、时点、发动次数限制、费用、效果处理函数
function s.initial_effect(c)
	-- ①：把自己场上1只表侧表示的龙族·8星怪兽送去墓地才能发动。把1只龙族·8阶的超量怪兽当作超量召唤从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选满足条件的超量怪兽（龙族、8阶、可特殊召唤、有召唤空位）
function s.spfilter(c,e,tp,lc)
	return c:IsType(TYPE_XYZ) and c:IsRace(RACE_DRAGON)
		-- 满足超量怪兽的种族、阶数、可特殊召唤、额外卡组召唤空位条件
		and c:IsRank(8) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,lc,c)>0
end
-- 过滤函数，用于筛选满足条件的场上的龙族8星怪兽（可送入墓地、有对应的超量怪兽）
function s.costfilter(c,e,tp)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsLevel(8)
		and c:IsAbleToGraveAsCost()
		-- 检查额外卡组是否存在满足条件的超量怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
end
-- 发动费用处理函数，选择1只场上的龙族8星怪兽送入墓地作为费用
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动费用条件（场上存在符合条件的龙族8星怪兽）
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择要送入墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择符合条件的场上的龙族8星怪兽
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 将选中的怪兽送入墓地作为费用
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果处理目标函数，检查是否满足超量素材条件或额外卡组是否存在满足条件的怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足超量素材条件
	if chk==0 then return aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_XMATERIAL)
		-- 检查额外卡组是否存在满足条件的超量怪兽
		and (e:IsCostChecked() or Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,nil)) end
	-- 设置效果处理信息，表示将从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理函数，选择并特殊召唤1只满足条件的龙族8阶超量怪兽
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 再次检查是否满足超量素材条件
	if not aux.MustMaterialCheck(nil,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只满足条件的超量怪兽
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,nil):GetFirst()
	if not tc then return end
	tc:SetMaterial(nil)
	-- 将选中的超量怪兽特殊召唤到场上
	if Duel.SpecialSummon(tc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP) then
		tc:CompleteProcedure()
	end
end

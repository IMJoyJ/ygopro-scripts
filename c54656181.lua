--C戦場の指揮官 コロネル
-- 效果：
-- ①：这张卡召唤成功时才能发动。从手卡把2只4星以下的战士族怪兽守备表示特殊召唤（同名卡最多1张）。
local s,id,o=GetID()
-- 注册该卡召唤成功时发动的效果：从手卡守备表示特殊召唤2只4星以下的战士族怪兽（同名卡最多1张）。
function s.initial_effect(c)
	-- ①：这张卡召唤成功时才能发动。从手卡把2只4星以下的战士族怪兽守备表示特殊召唤（同名卡最多1张）。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
-- 过滤手卡中可以被特殊召唤的4星以下的战士族怪兽。
function s.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_WARRIOR)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果发动的可行性检测与操作信息设置：检查怪兽区域空位数是否大于1、是否未受到青眼精灵龙等限制同时特召的效果影响，且手卡中存在2张卡名不同的符合条件的怪兽。
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取手卡中所有符合过滤条件的怪兽卡组。
		local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_HAND,0,nil,e,tp)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>1 and not Duel.IsPlayerAffectedByEffect(tp,59822133)
			-- 检查手卡中是否存在2张卡名不同的符合条件的怪兽。
			and g:CheckSubGroup(aux.dncheck,2,2) end
	-- 设置连锁信息，表明该效果的处理为从手卡特殊召唤2只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND)
end
-- 效果处理：在满足特召空间且未受特召限制影响时，从手卡选择2张卡名不同的符合条件的怪兽守备表示特殊召唤。
function s.op(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 or Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 重新获取手卡中符合过滤条件的怪兽卡组。
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_HAND,0,nil,e,tp)
	-- 提示玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从符合条件的卡组中选择2张卡名不同的怪兽。
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,2,2)
	if sg then
		-- 将选中的怪兽以表侧守备表示特殊召唤到自己场上。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end

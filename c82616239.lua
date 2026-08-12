--ライトウォーター・ドラゴン
-- 效果：
-- 这个卡名在规则上当作「水龙」使用。这个卡名的效果1回合只能使用1次。
-- ①：把场上的这张卡除外才能发动。从卡组把3只5星以下而水·风属性的恐龙族怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。这个效果的发动后，直到回合结束时自己不是恐龙族·海龙族怪兽不能从额外卡组特殊召唤。
local s,id,o=GetID()
-- 注册卡片的效果①：起动效果，在自己主要阶段发动，同名卡1回合只能使用1次，包含特殊召唤的效果分类。
function s.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：把场上的这张卡除外才能发动。从卡组把3只5星以下而水·风属性的恐龙族怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。这个效果的发动后，直到回合结束时自己不是恐龙族·海龙族怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
-- 发动代价与条件检查：检查自身是否可以作为代价除外，以及自身离场后是否有3个以上的空余怪兽区域。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost()
		-- 检查自身离场后，自己场上可用于特殊召唤的怪兽区域是否在3个以上。
		and Duel.GetMZoneCount(tp,e:GetHandler())>2 end
	-- 执行发动代价：将场上的这张卡表侧表示除外。
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
-- 过滤条件：卡组中5星以下、水或风属性的恐龙族怪兽，且可以守备表示特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_DINOSAUR) and c:IsAttribute(ATTRIBUTE_WIND+ATTRIBUTE_WATER) and c:IsLevelBelow(5)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 发动准备（Target）：检查卡组中是否存在至少3只满足条件的怪兽，检查怪兽区域数量，并设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取自己卡组中所有满足特殊召唤条件的怪兽组。
		local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		return not Duel.IsPlayerAffectedByEffect(tp,59822133)
			-- 检查怪兽区域数量（若已支付代价则不需再计算自身占用的格子，否则需要有3个以上的空余怪兽区域）。
			and (e:IsCostChecked() or Duel.GetLocationCount(tp,LOCATION_MZONE)>2)
			and g:GetCount()>=3 end
	-- 设置操作信息：从卡组特殊召唤3只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择3只满足条件的怪兽守备表示特殊召唤，并使它们的效果无效化。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果处理时，再次获取卡组中满足特殊召唤条件的怪兽组。
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 效果处理时，检查自己场上的空余怪兽区域是否在3个以上。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>2
		and g:GetCount()>=3 then
		-- 提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg1=g:Select(tp,3,3,nil)
		local tc=sg1:GetFirst()
		while tc do
			-- 逐步将选中的怪兽以表侧守备表示特殊召唤。
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
			-- 这个效果特殊召唤的怪兽的效果无效化。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1,true)
			-- 这个效果特殊召唤的怪兽的效果无效化。这个效果的发动后，直到回合结束时自己不是恐龙族·海龙族怪兽不能从额外卡组特殊召唤。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2,true)
			tc=sg1:GetNext()
		end
		-- 完成特殊召唤的流程。
		Duel.SpecialSummonComplete()
	end
	-- 这个效果的发动后，直到回合结束时自己不是恐龙族·海龙族怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 给玩家注册限制额外卡组特殊召唤的约束效果。
	Duel.RegisterEffect(e1,tp)
end
-- 限制条件：不能从额外卡组特殊召唤恐龙族·海龙族以外的怪兽。
function s.splimit(e,c)
	return not c:IsRace(RACE_DINOSAUR+RACE_SEASERPENT) and c:IsLocation(LOCATION_EXTRA)
end

--フューリー・オブ・ファイア
-- 效果：
-- 这个卡名在规则上也当作「转生炎兽」卡使用。这个卡名的卡在1回合只能发动1张。
-- ①：从自己的手卡·墓地选最多2只「转生炎兽」怪兽守备表示特殊召唤（同名卡最多1张）。这个效果特殊召唤的怪兽的效果无效化。这张卡的发动后，直到回合结束时自己只能有1次从额外卡组把怪兽特殊召唤。
function c92345028.initial_effect(c)
	-- 启用额外卡组特殊召唤次数限制的全局计数机制。
	aux.EnableExtraDeckSummonCountLimit()
	-- 这个卡名的卡在1回合只能发动1张。①：从自己的手卡·墓地选最多2只「转生炎兽」怪兽守备表示特殊召唤（同名卡最多1张）。这个效果特殊召唤的怪兽的效果无效化。这张卡的发动后，直到回合结束时自己只能有1次从额外卡组把怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,92345028+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c92345028.target)
	e1:SetOperation(c92345028.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：手卡·墓地的「转生炎兽」怪兽，且能以守备表示特殊召唤。
function c92345028.filter(c,e,tp)
	return c:IsSetCard(0x119) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果发动的目标选择与合法性检测。
function c92345028.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的手卡或墓地是否存在至少1只满足条件的「转生炎兽」怪兽。
		and Duel.IsExistingMatchingCard(c92345028.filter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置当前处理的连锁的操作信息，表示此效果会从手卡或墓地特殊召唤怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果处理的执行函数。
function c92345028.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己场上可用的怪兽区域数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取自己手卡·墓地中满足特殊召唤条件且不受「王家长眠之谷」影响的「转生炎兽」怪兽组。
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c92345028.filter),tp,LOCATION_HAND+LOCATION_GRAVE,0,nil,e,tp)
	if g:GetCount()>0 and ft>0 then
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
		local ct=math.min(ft,2)
		-- 提示玩家选择要特殊召唤的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选出最多2只卡名不同的怪兽（数量不超过可用怪兽区域数）。
		local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,ct)
		local tc=sg:GetFirst()
		while tc do
			-- 尝试将选中的怪兽以表侧守备表示特殊召唤。
			if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
				-- 这个效果特殊召唤的怪兽的效果无效化。
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1,true)
				-- 这个效果特殊召唤的怪兽的效果无效化。
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetValue(RESET_TURN_SET)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e2,true)
			end
			tc=sg:GetNext()
		end
		-- 完成特殊召唤的最终处理。
		Duel.SpecialSummonComplete()
	end
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	-- 这张卡的发动后，直到回合结束时自己只能有1次从额外卡组把怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c92345028.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册限制玩家从额外卡组特殊召唤次数的效果。
	Duel.RegisterEffect(e1,tp)
	-- 这张卡的发动后，直到回合结束时自己只能有1次从额外卡组把怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetOperation(c92345028.checkop)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 注册用于监测并扣减额外卡组特殊召唤次数的全局事件效果。
	Duel.RegisterEffect(e2,tp)
	-- 这张卡的发动后，直到回合结束时自己只能有1次从额外卡组把怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(92345028)
	e3:SetTargetRange(1,0)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 注册表示本回合已发动过此卡的标记效果。
	Duel.RegisterEffect(e3,tp)
end
-- 限制从额外卡组特殊召唤的过滤函数。
function c92345028.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	-- 检查特殊召唤的怪兽是否来自额外卡组，且该玩家的额外卡组特殊召唤剩余次数是否已归零。
	return c:IsLocation(LOCATION_EXTRA) and aux.ExtraDeckSummonCountLimit[sump]<=0
end
-- 过滤条件：由指定玩家从额外卡组特殊召唤的怪兽。
function c92345028.cfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsPreviousLocation(LOCATION_EXTRA)
end
-- 监测特殊召唤成功事件，并扣减对应玩家的额外卡组特殊召唤剩余次数。
function c92345028.checkop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(c92345028.cfilter,1,nil,tp) then
		-- 扣减自己本回合从额外卡组特殊召唤的剩余次数。
		aux.ExtraDeckSummonCountLimit[tp]=aux.ExtraDeckSummonCountLimit[tp]-1
	end
	if eg:IsExists(c92345028.cfilter,1,nil,1-tp) then
		-- 扣减对方本回合从额外卡组特殊召唤的剩余次数。
		aux.ExtraDeckSummonCountLimit[1-tp]=aux.ExtraDeckSummonCountLimit[1-tp]-1
	end
end

--顕現する紋章
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把自己场上1只怪兽解放才能发动。从卡组把2只「纹章兽」怪兽守备表示特殊召唤。这张卡的发动后，直到回合结束时自己不是念动力族怪兽以及机械族怪兽不能从额外卡组特殊召唤。
function c84482694.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：把自己场上1只怪兽解放才能发动。从卡组把2只「纹章兽」怪兽守备表示特殊召唤。这张卡的发动后，直到回合结束时自己不是念动力族怪兽以及机械族怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,84482694+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c84482694.cost)
	e1:SetTarget(c84482694.target)
	e1:SetOperation(c84482694.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：解放该怪兽后，自己场上可用的怪兽区域数量是否大于1
function c84482694.costfilter(c,tp)
	-- 判断解放该怪兽后，自己场上可用的怪兽区域数量是否大于1
	return Duel.GetMZoneCount(tp,c)>1
end
-- 发动代价（Cost）处理函数：解放自己场上1只怪兽
function c84482694.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	-- 在发动契机（chk==0）时，检查自己场上是否存在至少1只满足解放后能空出2个以上怪兽区域的可解放怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c84482694.costfilter,1,nil,tp) end
	-- 选择自己场上1只满足解放后能空出2个以上怪兽区域的可解放怪兽
	local g=Duel.SelectReleaseGroup(tp,c84482694.costfilter,1,1,nil,tp)
	-- 将选择的怪兽作为发动代价解放
	Duel.Release(g,REASON_COST)
end
-- 过滤条件：卡组中可以守备表示特殊召唤的「纹章兽」怪兽
function c84482694.spfilter(c,e,tp)
	return c:IsSetCard(0x76) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 发动目标（Target）处理函数：检查卡组中是否存在2只可特召的「纹章兽」怪兽并设置特殊召唤的操作信息
function c84482694.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否已支付解放代价（Label为1）或者当前自己场上的空怪兽区域是否大于1
	local res=e:GetLabel()==1 or Duel.GetLocationCount(tp,LOCATION_MZONE)>1
	if chk==0 then
		e:SetLabel(0)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		return res and not Duel.IsPlayerAffectedByEffect(tp,59822133)
			-- 检查卡组中是否存在至少2只满足特殊召唤条件的「纹章兽」怪兽
			and Duel.IsExistingMatchingCard(c84482694.spfilter,tp,LOCATION_DECK,0,2,nil,e,tp)
	end
	-- 设置当前连锁的操作信息为：从卡组特殊召唤2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- 效果处理（Operation）函数：从卡组特殊召唤2只「纹章兽」怪兽，并适用额外卡组特殊召唤限制的誓约效果
function c84482694.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if not Duel.IsPlayerAffectedByEffect(tp,59822133) and Duel.GetLocationCount(tp,LOCATION_MZONE)>1 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组中选择2只满足特殊召唤条件的「纹章兽」怪兽
		local g=Duel.SelectMatchingCard(tp,c84482694.spfilter,tp,LOCATION_DECK,0,2,2,nil,e,tp)
		if g:GetCount()==2 then
			-- 将选择的2只怪兽以表侧守备表示特殊召唤
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	end
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	-- 这张卡的发动后，直到回合结束时自己不是念动力族怪兽以及机械族怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c84482694.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将限制额外卡组特殊召唤的效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制效果的过滤函数：限制从额外卡组特殊召唤非念动力族且非机械族的怪兽
function c84482694.splimit(e,c)
	return not c:IsRace(RACE_PSYCHO+RACE_MACHINE) and c:IsLocation(LOCATION_EXTRA)
end

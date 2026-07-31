--バリアンズ・シール
local s,id,o=GetID()
-- 此函数用于注册卡片的两个效果，第一个是发动时可以无效连锁的魔法效果，第二个是墓地发动的诱发即时效果。
function s.initial_effect(c)
	-- 此效果为发动时可以无效连锁的魔法效果，当对方发动怪兽或魔法陷阱效果时可发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 此效果为墓地发动的诱发即时效果，可在自由时点发动，将2只「青眼」怪兽特殊召唤到场上。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	-- 此效果的发动需要把自身从游戏中除外作为费用。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 此过滤函数用于检测场上是否有满足条件的超量怪兽（编号101-107且为「变异族」或「精灵族」）。
function s.cfilter(c)
	-- 获取目标怪兽的No.编号，用于判断是否为特定编号的超量怪兽。
	local no=aux.GetXyzNumber(c)
	return c:IsFaceup() and (no and no>=101 and no<=107 and c:IsSetCard(0x1048)
		or c:IsSetCard(0x1073))
end
-- 此条件函数用于判断是否可以发动第一个效果，即场上存在满足条件的超量怪兽、对方发动的是怪兽或魔法陷阱效果且该连锁可被无效，并且是对方的连锁。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检测场上是否存在至少1张满足cfilter条件的卡。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 判断对方发动的效果为怪兽或魔法陷阱类型，且该连锁可以被无效，同时是对方的连锁。
		and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev) and rp==1-tp
end
-- 此函数用于设置第一个效果的目标信息，即无效对方的连锁效果。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为无效对方的连锁效果。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 此过滤函数用于检测场上是否存在满足条件的超量怪兽，且该超量怪兽可以作为超量素材。
function s.xyzfilter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
		-- 检测场上或墓地是否存在至少1张满足mtfilter条件的卡，用于作为超量素材。
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.mtfilter),tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,c,e)
end
-- 此过滤函数用于检测是否为可叠放的怪兽（即满足类型为怪兽、可叠放且不受效果影响）。
function s.mtfilter(c,e)
	return c:IsType(TYPE_MONSTER)
		and c:IsCanOverlay() and not (e and c:IsImmuneToEffect(e))
end
-- 此函数用于处理第一个效果的发动，当无效对方连锁后，若场上存在满足条件的超量怪兽，则可以选择是否进行超量操作。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试使对方的连锁无效。
	if Duel.NegateActivation(ev)
		-- 检测场上是否存在至少1张满足xyzfilter条件的卡。
		and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil,e,tp)
		-- 询问玩家是否选择进行超量操作。
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		-- 中断当前效果处理，使后续效果视为不同时处理。
		Duel.BreakEffect()
		-- 提示玩家选择要作为超量素材的卡。
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))
		-- 从场上或墓地选择1张满足xyzfilter条件的超量怪兽。
		local g=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
		local xc=g:GetFirst()
		-- 提示玩家选择要作为超量素材的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
		-- 优先从场上选择满足条件的卡作为超量素材，若场上无卡则从墓地选择。
		local mg=aux.SelectCardFromFieldFirst(tp,aux.NecroValleyFilter(s.mtfilter),tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,1,1,xc,e)
		if mg:GetCount()>0 then
			-- 为选中的卡显示被选为对象的动画效果。
			Duel.HintSelection(mg)
			local og=mg:GetFirst():GetOverlayGroup()
			if og:GetCount()>0 then
				-- 将选中卡的叠放区内的卡送去墓地。
				Duel.SendtoGrave(og,REASON_RULE)
			end
			-- 将选中的卡叠放到目标超量怪兽上。
			Duel.Overlay(xc,mg)
		end
	end
end
-- 此过滤函数用于检测是否为可特殊召唤的「青眼」怪兽。
function s.ffilter(c,e,tp)
	return c:IsSetCard(0x87) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 此函数用于设置第二个效果的目标信息，即从墓地特殊召唤2只「青眼」怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断玩家场上是否有至少2个空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检测墓地中是否存在至少2张满足ffilter条件的卡。
		and Duel.IsExistingMatchingCard(s.ffilter,tp,LOCATION_GRAVE,0,2,nil,e,tp) end
	-- 设置操作信息为从墓地特殊召唤2只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_GRAVE)
end
-- 此函数用于处理第二个效果的发动，当满足条件时，选择并特殊召唤2只「青眼」怪兽。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 or Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检测是否满足特殊召唤的条件，包括场上空位不足、受「青眼精灵龙」影响或墓地满足条件的卡不足2张。
		or Duel.GetMatchingGroupCount(aux.NecroValleyFilter(s.ffilter),tp,LOCATION_GRAVE,0,nil,e,tp)<2 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从墓地中选择2张满足ffilter条件的卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.ffilter),tp,LOCATION_GRAVE,0,2,2,nil,e,tp)
	-- 将选中的卡以特殊召唤方式送至场上。
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
end

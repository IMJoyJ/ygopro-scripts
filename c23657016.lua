--幻禄の天盃龍
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡用抽卡以外的方法加入手卡的场合才能发动。这张卡当作调整使用特殊召唤。那之后，可以让这张卡的等级上升1星。
-- ②：自己·对方回合，把这张卡解放才能发动。从卡组把「幻禄之天杯龙」以外的1只「天杯龙」怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是龙族怪兽不能特殊召唤。
local s,id,o=GetID()
-- 初始化效果：创建并注册两个效果，①为诱发选发效果（加入手卡时可特殊召唤自身并可选升星），②为诱发即时效果（解放自身从卡组特召天杯龙并附加自肃）；同时通过SetCountLimit实现同名卡①②效果1回合各1次。
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡用抽卡以外的方法加入手卡的场合才能发动。这张卡当作调整使用特殊召唤。那之后，可以让这张卡的等级上升1星。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤&等级上升"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。②：自己·对方回合，把这张卡解放才能发动。从卡组把「幻禄之天杯龙」以外的1只「天杯龙」怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是龙族怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件判定：这张卡加入手卡的原因不是抽卡（即通过抽卡以外的方法加入手卡）时才满足发动条件。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsReason(REASON_DRAW)
end
-- ①效果发动时的合法检查：取得效果处理卡，若chk==0则判断自己场上是否有可用怪兽区，以及这张卡自身是否可以被特殊召唤（满足召唤条件/苏生限制）。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在效果发动时（chk==0）检查自己主要怪兽区是否存在可用空格，必须有空格才能发动特殊召唤效果。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记本次操作信息：将效果类别设为特殊召唤，对象为这张卡自身，数量为1，用于其他卡牌对特殊召唤类效果的连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果处理：若这张卡仍与效果关联，则将其以表侧表示特殊召唤；特殊召唤成功后立即赋予其调整（Tuner）类型；随后询问玩家是否让其等级上升1星，若选择是则中断效果处理并使其等级提升1星。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡在效果处理时仍与当前效果保持关联（未被无效、离场或转移），且能够执行特殊召唤步骤；满足则开始特殊召唤该卡。
	if c:IsRelateToEffect(e) and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		-- 这张卡当作调整使用特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(TYPE_TUNER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 完成特殊召唤处理（与Duel.SpecialSummonStep配套使用），确认特殊召唤成功并结算相关时点。
		Duel.SpecialSummonComplete()
		-- 若这张卡拥有等级（等级在1以上），则询问玩家是否发动追加效果使其等级上升1星；玩家选择“是”才继续执行升星处理。
		if c:IsLevelAbove(1) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否上升等级？"
			-- 中断当前效果处理，使后续升星处理与之前的特殊召唤视为不同时点，避免相关玩家错失时点。
			Duel.BreakEffect()
			-- 那之后，可以让这张卡的等级上升1星。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_UPDATE_LEVEL)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			e2:SetValue(1)
			c:RegisterEffect(e2)
		end
	end
end
-- ②效果的发动代价：检查这张卡是否可以被解放；可以则将其解放送入墓地，作为发动②效果的COST。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放这张卡作为发动②效果的COST（REASON_COST），该解放不受效果无效等影响，且不触发被解放时发动的效果。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 定义从卡组检索并特殊召唤的候选卡条件：卡名不是「幻禄之天杯龙」自身、属于「天杯龙」系列、是怪兽，并且可以被当前效果特殊召唤。
function s.spfilter(c,e,tp)
	return not c:IsCode(id) and c:IsSetCard(0x1aa) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果发动时的合法检查：计算解放这张卡后自己场上可用的怪兽区数量大于0，且卡组中存在符合条件的「天杯龙」怪兽；满足才能发动。
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时（chk==0）检查解放这张卡后自己场上是否有可用的怪兽区空格，必须有空格才能发动特殊召唤效果。
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 同时检查卡组中是否存在至少1张满足s.spfilter筛选条件的「天杯龙」怪兽，确保有效果可处理。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 登记本次操作信息：效果类别为特殊召唤，处理时从卡组特殊召唤1只怪兽（数量1，持有者为操作者tp），供需要检查特殊召唤动作的效果进行判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：若仍有可用怪兽区，则让玩家从卡组选择1只符合条件的「天杯龙」怪兽并特殊召唤；随后给效果发动者附加自肃效果，直到回合结束时不能特殊召唤龙族以外的怪兽。
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己场上是否有可用怪兽区空位，因处理时场地可能已变化，需要避免无法特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 向玩家显示选择提示消息，指示其从卡组中选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从卡组中选出1张满足s.spfilter条件的「天杯龙」怪兽（排除「幻禄之天杯龙」且能特殊召唤）。
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽以表侧表示特殊召唤到己方场上（不检查苏生限制和召唤条件，因为是效果特殊召唤）。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	local c=e:GetHandler()
	-- 这个效果的发动后，直到回合结束时自己不是龙族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果注册到场上并作用于该效果发动者，使该玩家在回合结束前不能特殊召唤非龙族怪兽。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃限制的具体判定：若被特殊召唤的怪兽种族不是龙族则不允许特殊召唤，即只能特殊召唤龙族怪兽。
function s.splimit(e,c)
	return not c:IsRace(RACE_DRAGON)
end

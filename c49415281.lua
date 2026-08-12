--シンクロ・エマージェンシー
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。只有对方场上才有怪兽存在的场合，这张卡的发动从手卡也能用。
-- ①：从手卡把1只怪兽效果无效特殊召唤。从额外卡组特殊召唤的怪兽在对方场上存在的场合，可以再从卡组把1只「同调士」怪兽特殊召唤。这张卡的发动后，直到下个回合的结束时自己不是同调怪兽不能从额外卡组特殊召唤。
-- ②：把墓地的这张卡除外才能发动。进行1只同调怪兽的同调召唤。
local s,id,o=GetID()
-- 初始化卡片效果，注册3个效果：手卡发动/特殊召唤效果、墓地除外同调召唤效果、手卡发动陷阱卡的条件。
function s.initial_effect(c)
	-- ①：从手卡把1只怪兽效果无效特殊召唤。从额外卡组特殊召唤的怪兽在对方场上存在的场合，可以再从卡组把1只「同调士」怪兽特殊召唤。这张卡的发动后，直到下个回合的结束时自己不是同调怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。进行1只同调怪兽的同调召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"同调召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END+TIMING_END_PHASE)
	-- 检查自身是否能够作为cost除外，并将其除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sctg)
	e2:SetOperation(s.scop)
	c:RegisterEffect(e2)
	-- 只有对方场上才有怪兽存在的场合，这张卡的发动从手卡也能用。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))  --"适用「同调紧急」的效果来发动"
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e3:SetCondition(s.handcon)
	c:RegisterEffect(e3)
end
-- 过滤函数：判断手牌中的怪兽是否可以特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 卡片发动效果（效果①）的靶向检测函数：检查己方主要怪兽区域是否有空位，以及手牌中是否存在可以被特殊召唤的怪兽。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断己方主要怪兽区域是否有可用的空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手牌中是否存在可被特殊召唤的怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置特殊召唤效果的操作信息，预计从手牌特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 过滤函数：判断怪兽是否是从额外卡组特殊召唤的。
function s.cfilter(c)
	return c:IsSummonLocation(LOCATION_EXTRA)
end
-- 过滤函数：判断卡片是否为「同调士」怪兽，且可以特殊召唤。
function s.spfilter2(c,e,tp)
	return c:IsSetCard(0x1017) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 卡片发动效果（效果①）的实际处理函数：尝试特殊召唤手牌中的怪兽并无效其效果，若满足额外条件，可选择再从卡组特殊召唤1只「同调士」怪兽，并施加不是同调怪兽不能从额外卡组特殊召唤的限制。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断己方主要怪兽区域是否有可用的空位。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家选择手牌中1只满足特殊召唤条件的怪兽。
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		local tc=g:GetFirst()
		-- 若玩家成功选择卡片，则将其以表侧表示特殊召唤（非完整处理）。
		if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			-- 效果无效
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 效果无效
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
			-- 完成剩余部分的特殊召唤处理。
			Duel.SpecialSummonComplete()
			-- 判断己方主要怪兽区域是否有可用的空位。
			if Duel.GetLocationCount(tp,LOCATION_MZONE)>0
				-- 检查对方场上是否存在从额外卡组特殊召唤的怪兽。
				and Duel.IsExistingMatchingCard(s.cfilter,tp,0,LOCATION_MZONE,1,nil)
				-- 检查己方卡组中是否存在可特殊召唤的「同调士」怪兽。
				and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_DECK,0,1,nil,e,tp)
				-- 询问玩家是否追加从卡组特殊召唤「同调士」怪兽。
				and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否再特殊召唤？"
				-- 中断当前效果，使之后的追加特殊召唤处理与之前的召唤不视为同时处理。
				Duel.BreakEffect()
				-- 提示玩家选择要特殊召唤的卡片。
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				-- 让玩家从卡组选择1只满足条件的「同调士」怪兽。
				local sg=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_DECK,0,1,1,nil,e,tp)
				-- 将选择的「同调士」怪兽特殊召唤。
				Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
	-- 这张卡的发动后，直到下个回合的结束时自己不是同调怪兽不能从额外卡组特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,4))  --"「同调紧急」效果适用中"
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e3:SetTargetRange(1,0)
	e3:SetTarget(s.splimit)
	e3:SetReset(RESET_PHASE+PHASE_END,2)
	-- 将“直到下个回合的结束时自己不是同调怪兽不能从额外卡组特殊召唤”的限制效果注册给发动效果的玩家。
	Duel.RegisterEffect(e3,tp)
end
-- 限制条件过滤函数：限制非同调怪兽从额外卡组特殊召唤。
function s.splimit(e,c)
	return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA)
end
-- 墓地效果（效果②）的靶向检测函数：检查额外卡组中是否存在此时可以同调召唤的怪兽。
function s.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组中是否存在此时可以进行同调召唤的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,nil) end
	-- 设置特殊召唤的操作信息，预计从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 墓地效果（效果②）的实际处理函数：获取额外卡组中所有当前可以同调召唤的怪兽，让玩家选择其中1只并进行同调召唤。
function s.scop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取额外卡组中所有当前可以同调召唤的怪兽。
	local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,nil)
	if g:GetCount()>0 then
		-- 提示玩家选择进行同调召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 让玩家以选择的怪兽为对象进行同调召唤手续。
		Duel.SynchroSummon(tp,sg:GetFirst(),nil)
	end
end
-- 过滤条件：判断是否满足“只有对方场上才有怪兽存在”的手卡发动条件。
function s.handcon(e)
	-- 判断自己场上的怪兽数量是否为0。
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_MZONE,0)==0
		-- 判断对方场上的怪兽数量是否大于0。
		and Duel.GetFieldGroupCount(e:GetHandlerPlayer(),0,LOCATION_MZONE)>0
end

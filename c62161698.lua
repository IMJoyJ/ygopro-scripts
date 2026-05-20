--イリュージョン・バルーン
-- 效果：
-- ①：自己场上的怪兽被破坏的回合才能发动。从自己卡组上面把5张卡翻开。可以从那之中选1只「娱乐伙伴」怪兽特殊召唤。剩下的卡回到卡组洗切。
function c62161698.initial_effect(c)
	-- ①：自己场上的怪兽被破坏的回合才能发动。从自己卡组上面把5张卡翻开。可以从那之中选1只「娱乐伙伴」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(62161698,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCondition(c62161698.condition)
	e1:SetTarget(c62161698.target)
	e1:SetOperation(c62161698.operation)
	c:RegisterEffect(e1)
	if not c62161698.global_check then
		c62161698.global_check=true
		-- ①：自己场上的怪兽被破坏的回合才能发动。从自己卡组上面把5张卡翻开。可以从那之中选1只「娱乐伙伴」怪兽特殊召唤。剩下的卡回到卡组洗切。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetOperation(c62161698.checkop)
		-- 注册全局效果，用于监测场上怪兽被破坏的事件。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 监测怪兽被破坏事件的函数，若有玩家场上的怪兽被破坏，则为该玩家注册对应的回合标志。
function c62161698.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	local p1=false
	local p2=false
	while tc do
		if tc:IsPreviousLocation(LOCATION_MZONE) then
			if tc:IsPreviousControler(0) then p1=true else p2=true end
		end
		tc=eg:GetNext()
	end
	-- 若自己场上的怪兽被破坏，则为自己注册一个持续到回合结束的标志。
	if p1 then Duel.RegisterFlagEffect(0,62161698,RESET_PHASE+PHASE_END,0,1) end
	-- 若对方场上的怪兽被破坏，则为对方注册一个持续到回合结束的标志。
	if p2 then Duel.RegisterFlagEffect(1,62161698,RESET_PHASE+PHASE_END,0,1) end
end
-- 发动条件：检查当前回合是否有自己场上的怪兽被破坏。
function c62161698.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前玩家是否拥有怪兽被破坏的标志。
	return Duel.GetFlagEffect(tp,62161698)~=0
end
-- 效果发动时的合法性检查（检查是否能特殊召唤以及卡组卡片数量是否足够）。
function c62161698.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家当前是否能够进行特殊召唤。
	if chk==0 then return Duel.IsPlayerCanSpecialSummon(tp)
		-- 检查自己卡组上方的卡片数量是否大于4张。
		and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>4 end
end
-- 过滤条件：属于「娱乐伙伴」且可以被特殊召唤的怪兽。
function c62161698.filter(c,e,tp)
	return c:IsSetCard(0x9f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理：翻开卡组上方5张卡，并可选择其中1只「娱乐伙伴」怪兽特殊召唤。
function c62161698.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 若卡组没有卡，则不进行处理。
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 then return end
	-- 确认（翻开）自己卡组最上方的5张卡。
	Duel.ConfirmDecktop(tp,5)
	-- 获取卡组最上方的5张卡，并筛选出其中符合条件的「娱乐伙伴」怪兽。
	local g=Duel.GetDecktopGroup(tp,5):Filter(c62161698.filter,nil,e,tp)
	if g:GetCount()>0
		-- 检查自己场上是否有空余的怪兽区域。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 询问玩家是否选择进行特殊召唤。
		and Duel.SelectYesNo(tp,aux.Stringid(62161698,1)) then  --"是否特殊召唤「娱乐伙伴」怪兽？"
		-- 提示玩家选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 将卡组洗切。
	Duel.ShuffleDeck(tp)
end

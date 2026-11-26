--イリュージョン・バルーン
-- 效果：
-- ①：自己场上的怪兽被破坏的回合才能发动。从自己卡组上面把5张卡翻开。可以从那之中选1只「娱乐伙伴」怪兽特殊召唤。剩下的卡回到卡组洗切。
function c62161698.initial_effect(c)
	-- ①：自己场上的怪兽被破坏的回合才能发动。从自己卡组上面把5张卡翻开。可以从那之中选1只「娱乐伙伴」怪兽特殊召唤。剩下的卡回到卡组洗切。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(62161698,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCondition(c62161698.condition)
	e1:SetTarget(c62161698.target)
	e1:SetOperation(c62161698.operation)
	c:RegisterEffect(e1)
	if not c62161698.global_check then
		c62161698.global_check=true
		-- ①：自己场上的怪兽被破坏的回合才能发动。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetOperation(c62161698.checkop)
		-- 注册全局永续效果，持续记录每回合是否有玩家的场上怪兽被破坏
		Duel.RegisterEffect(ge1,0)
	end
end
-- 全局破坏事件回调，检查被破坏的卡之前是否位于怪兽区并为其控制者注册本回合标识
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
	-- 若玩家0场上的怪兽被破坏，为其注册持续至回合结束的发动条件标识
	if p1 then Duel.RegisterFlagEffect(0,62161698,RESET_PHASE+PHASE_END,0,1) end
	-- 若玩家1场上的怪兽被破坏，为其注册持续至回合结束的发动条件标识
	if p2 then Duel.RegisterFlagEffect(1,62161698,RESET_PHASE+PHASE_END,0,1) end
end
-- 发动条件检查，确认本回合自己场上的怪兽曾经被破坏
function c62161698.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断控制者本回合是否拥有场上怪兽被破坏的标识
	return Duel.GetFlagEffect(tp,62161698)~=0
end
-- 发动条件检查，确认控制者允许特殊召唤且自己卡组数量至少为5张
function c62161698.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查控制者当前是否允许进行特殊召唤
	if chk==0 then return Duel.IsPlayerCanSpecialSummon(tp)
		-- 检查自己卡组剩余卡片数量是否至少有5张
		and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>4 end
end
-- 过滤函数，检查是否为可特殊召唤的「娱乐伙伴」怪兽
function c62161698.filter(c,e,tp)
	return c:IsSetCard(0x9f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理，翻开自己卡组上方5张卡，从中可选择1只「娱乐伙伴」怪兽特殊召唤，最后洗切卡组
function c62161698.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己卡组已无卡片则直接结束处理
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 then return end
	-- 翻开并向双方确认自己卡组最上方的5张卡
	Duel.ConfirmDecktop(tp,5)
	-- 从翻开的卡组最上方5张卡中筛选可特殊召唤的「娱乐伙伴」怪兽
	local g=Duel.GetDecktopGroup(tp,5):Filter(c62161698.filter,nil,e,tp)
	if g:GetCount()>0
		-- 检查自己主要怪兽区是否至少有1个空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 询问控制者是否从翻开的卡中特殊召唤1只「娱乐伙伴」怪兽
		and Duel.SelectYesNo(tp,aux.Stringid(62161698,1)) then  --"是否特殊召唤「娱乐伙伴」怪兽？"
		-- 提示控制者从翻开的卡中选择要特殊召唤的「娱乐伙伴」怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的「娱乐伙伴」怪兽表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 将剩下的卡放回卡组并洗切
	Duel.ShuffleDeck(tp)
end

--ウォークライ・ジェネレート
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：对方场上的怪兽数量比自己场上的怪兽多的场合，自己·对方的战斗阶段才能发动。从卡组把1只「战吼」怪兽特殊召唤。这张卡在对方回合发动的场合，这个回合只要这个效果特殊召唤的怪兽在自己场上表侧表示存在，对方只能向那只怪兽攻击。
function c19275188.initial_effect(c)
	-- 效果原文内容：①：对方场上的怪兽数量比自己场上的怪兽多的场合，自己·对方的战斗阶段才能发动。从卡组把1只「战吼」怪兽特殊召唤。这张卡在对方回合发动的场合，这个回合只要这个效果特殊召唤的怪兽在自己场上表侧表示存在，对方只能向那只怪兽攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,19275188+EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMING_BATTLE_START)
	e1:SetCondition(c19275188.condition)
	e1:SetTarget(c19275188.target)
	e1:SetOperation(c19275188.operation)
	c:RegisterEffect(e1)
end
-- 规则层面操作：判断当前是否处于战斗阶段，并且对方场上的怪兽数量大于自己场上的怪兽数量。
function c19275188.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：获取当前游戏阶段。
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
		-- 规则层面操作：比较对方场上怪兽数量是否大于自己场上怪兽数量。
		and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
end
-- 规则层面操作：定义过滤函数，用于筛选满足条件的「战吼」怪兽。
function c19275188.filter(c,e,tp)
	return c:IsSetCard(0x15f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 规则层面操作：设置连锁处理的目标函数，检查是否满足发动条件。
function c19275188.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：检查自己场上是否有足够的特殊召唤区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 规则层面操作：检查卡组中是否存在满足条件的「战吼」怪兽。
		and Duel.IsExistingMatchingCard(c19275188.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 规则层面操作：设置连锁处理的信息，表明将要特殊召唤一张怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 规则层面操作：定义效果发动时的具体处理流程。
function c19275188.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：检查自己场上是否有足够的特殊召唤区域。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 规则层面操作：提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面操作：从卡组中选择满足条件的「战吼」怪兽。
	local g=Duel.SelectMatchingCard(tp,c19275188.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 规则层面操作：将选中的怪兽特殊召唤到场上。
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0
		-- 规则层面操作：判断该效果是否在对方回合发动。
		and Duel.GetTurnPlayer()==1-tp then
		-- 效果原文内容：这张卡在对方回合发动的场合，这个回合只要这个效果特殊召唤的怪兽在自己场上表侧表示存在，对方只能向那只怪兽攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetRange(LOCATION_MZONE)
		e1:SetTargetRange(0,LOCATION_MZONE)
		e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(c19275188.atklimit)
		tc:RegisterEffect(e1)
	end
end
-- 规则层面操作：定义攻击限制效果，使对方只能攻击该怪兽。
function c19275188.atklimit(e,c)
	return c~=e:GetHandler()
end

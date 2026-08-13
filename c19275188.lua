--ウォークライ・ジェネレート
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：对方场上的怪兽数量比自己场上的怪兽多的场合，自己·对方的战斗阶段才能发动。从卡组把1只「战吼」怪兽特殊召唤。这张卡在对方回合发动的场合，这个回合只要这个效果特殊召唤的怪兽在自己场上表侧表示存在，对方只能向那只怪兽攻击。
function c19275188.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：对方场上的怪兽数量比自己场上的怪兽多的场合，自己·对方的战斗阶段才能发动。从卡组把1只「战吼」怪兽特殊召唤。这张卡在对方回合发动的场合，这个回合只要这个效果特殊召唤的怪兽在自己场上表侧表示存在，对方只能向那只怪兽攻击。
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
-- 发动条件判定：当前必须处于战斗阶段（PHASE_BATTLE_START 到 PHASE_BATTLE 之间），且对方场上怪兽数量大于自己场上怪兽数量。
function c19275188.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前游戏阶段，用于判断是否处于战斗阶段。
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
		-- 比较双方主要怪兽区域的怪兽数量，要求对方场上的怪兽数量比自己场上的多。
		and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
end
-- 定义筛选函数：选择卡名含有「战吼」字段、且可以被本效果特殊召唤的怪兽（检查召唤条件与苏生限制）。
function c19275188.filter(c,e,tp)
	return c:IsSetCard(0x15f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的合法性检查：自己怪兽区域有空位，且卡组中存在符合条件的「战吼」怪兽；满足才能发动。
function c19275188.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- chk==0 时首先确认自己场上至少存在1个可用怪兽区域空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且确认卡组中存在至少1只满足 c19275188.filter 的「战吼」怪兽。
		and Duel.IsExistingMatchingCard(c19275188.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 向系统登记本次效果的预计操作：从卡组特殊召唤1只怪兽（分类为 CATEGORY_SPECIAL_SUMMON）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：先检查怪兽区域空位，再从卡组选1只「战吼」怪兽表侧表示特殊召唤；若是在对方回合发动且召唤成功，给该怪兽附加“对方只能向它攻击”的限制效果。
function c19275188.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 如果自己场上没有可用怪兽区域空位，则效果不继续处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示选择提示，让玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选出1只满足条件（「战吼」且可特殊召唤）的怪兽。
	local g=Duel.SelectMatchingCard(tp,c19275188.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 将选中的怪兽表侧表示特殊召唤到自己场上，并判断是否特殊召唤成功。
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0
		-- 同时判断当前回合玩家是否为对方，即这张卡是否在对方回合发动。
		and Duel.GetTurnPlayer()==1-tp then
		-- 这张卡在对方回合发动的场合，这个回合只要这个效果特殊召唤的怪兽在自己场上表侧表示存在，对方只能向那只怪兽攻击。
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
-- 攻击限制判定：若攻击对象不是持有该效果的怪兽，返回 true 禁止被选择，从而强制对方只能选择这只怪兽作为攻击对象。
function c19275188.atklimit(e,c)
	return c~=e:GetHandler()
end

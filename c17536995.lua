--紋章変換
-- 效果：
-- 对方怪兽的攻击宣言时才能发动。从手卡把1只名字带有「纹章兽」的怪兽特殊召唤，战斗阶段结束。
function c17536995.initial_effect(c)
	-- 对方怪兽的攻击宣言时才能发动。从手卡把1只名字带有「纹章兽」的怪兽特殊召唤，战斗阶段结束。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c17536995.condition)
	e1:SetTarget(c17536995.target)
	e1:SetOperation(c17536995.operation)
	c:RegisterEffect(e1)
end
-- 效果发动条件：判定当前攻击宣言的怪兽是否为对方控制，即“对方怪兽的攻击宣言时”。
function c17536995.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前攻击宣言的怪兽的控制者是否为对方（1-tp），是则满足发动条件。
	return Duel.GetAttacker():IsControler(1-tp)
end
-- 筛选手牌中满足「纹章兽」字段且可以被当前效果特殊召唤的怪兽。
function c17536995.filter(c,e,tp)
	return c:IsSetCard(0x76) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动前检查：若我方主要怪兽区有空位，且手牌存在至少1只符合filter的「纹章兽」怪兽，则效果可以发动；并准备将1只从手牌特殊召唤。
function c17536995.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 确认我方主要怪兽区是否有空位（用于特殊召唤）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认手牌中是否存在至少1只满足c17536995.filter（「纹章兽」且可特殊召唤）的怪兽。
		and Duel.IsExistingMatchingCard(c17536995.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：本次效果将从手牌特殊召唤1只怪兽（CATEGORY_SPECIAL_SUMMON），具体对象在处理时选择。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：若我方主要怪兽区有空位，从手牌选择1只「纹章兽」怪兽表侧表示特殊召唤；特殊召唤成功后，跳过对方战斗阶段以结束战斗阶段。
function c17536995.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 若我方主要怪兽区没有空位，则直接终止效果处理（无法特殊召唤）。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出选择提示，要求当前玩家从手牌选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让当前玩家从手牌中选出1张满足filter（「纹章兽」且可特殊召唤）的卡，作为本次特殊召唤的对象。
	local g=Duel.SelectMatchingCard(tp,c17536995.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	-- 若成功选出了怪兽且特殊召唤成功（返回数量>0），则继续执行后续跳过战斗阶段的处理；否则不执行。
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 中断当前效果，使后续的跳过战斗阶段作为独立的处理，避免时点上的混淆（对应当前特殊召唤处理后的战斗阶段结束处理）。
		Duel.BreakEffect()
		-- 跳过对方（1-tp）的战斗阶段，使战斗阶段直接结束。
		Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
	end
end

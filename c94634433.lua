--緊急同調
-- 效果：
-- ①：自己·对方的战斗阶段才能发动。把1只同调怪兽同调召唤。
function c94634433.initial_effect(c)
	-- ①：自己·对方的战斗阶段才能发动。把1只同调怪兽同调召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_BATTLE_START+TIMING_BATTLE_END)
	e1:SetCondition(c94634433.sccon)
	e1:SetTarget(c94634433.sctg)
	e1:SetOperation(c94634433.scop)
	c:RegisterEffect(e1)
end
-- 定义发动条件函数，限制在自己或对方的战斗阶段才能发动
function c94634433.sccon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否处于战斗阶段（从战斗阶段开始到战斗阶段结束）
	return (Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE)
end
-- 定义效果的发动准备（target）函数，检查可行性并设置操作信息
function c94634433.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查时，确认额外卡组是否存在可以进行同调召唤的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,nil) end
	-- 设置操作信息，表明此效果的处理为从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 定义效果处理（operation）函数，执行同调召唤
function c94634433.scop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取额外卡组中所有当前满足同调召唤条件的怪兽
	local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,nil)
	if g:GetCount()>0 then
		-- 向玩家发送提示信息，要求选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 对选定的怪兽进行同调召唤
		Duel.SynchroSummon(tp,sg:GetFirst(),nil)
	end
end

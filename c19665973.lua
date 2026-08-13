--バトルフェーダー
-- 效果：
-- ①：对方怪兽的直接攻击宣言时才能发动。这张卡从手卡特殊召唤。那之后，战斗阶段结束。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c19665973.initial_effect(c)
	-- 效果①：对方怪兽的直接攻击宣言时才能发动。这张卡从手卡特殊召唤。那之后，战斗阶段结束。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19665973,0))  --"结束战斗阶段"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c19665973.condition)
	e1:SetTarget(c19665973.target)
	e1:SetOperation(c19665973.operation)
	c:RegisterEffect(e1)
end
-- 效果发动条件：当前攻击宣言的怪兽是对方怪兽，且没有攻击对象（即对方怪兽的直接攻击宣言）。
function c19665973.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前正在攻击宣言的怪兽。
	local at=Duel.GetAttacker()
	-- 判定攻击怪兽是否为对方怪兽且攻击对象为空，即是否为对方怪兽的直接攻击宣言。
	return at:IsControler(1-tp) and Duel.GetAttackTarget()==nil
end
-- 发动时的处理：检查自己怪兽区是否有空位及此卡能否特殊召唤；若满足则设置特殊召唤的操作信息。
function c19665973.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		-- 确认自己主要怪兽区有空位，且此卡能够被特殊召唤。
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	-- 设置连锁操作信息：本次效果将特殊召唤此卡（数量1），供相关卡牌检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果处理：若此卡仍与效果关联，则将其以表侧表示特殊召唤到自己场上；召唤成功后中断效果处理、跳过对方战斗阶段，并给此卡赋予离场时除外效果。
function c19665973.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡仍与效果关联，并尝试以表侧表示特殊召唤到自己场上；仅当特殊召唤成功时继续后续处理。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 中断当前效果处理，使后续处理在时点上与特殊召唤分开，避免错失时点。
		Duel.BreakEffect()
		-- 跳过对方战斗阶段（包括结束步骤），实现‘那之后，战斗阶段结束’。
		Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1)
	end
end

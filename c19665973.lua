--バトルフェーダー
-- 效果：
-- ①：对方怪兽的直接攻击宣言时才能发动。这张卡从手卡特殊召唤。那之后，战斗阶段结束。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c19665973.initial_effect(c)
	-- 效果原文内容：①：对方怪兽的直接攻击宣言时才能发动。这张卡从手卡特殊召唤。那之后，战斗阶段结束。这个效果特殊召唤的这张卡从场上离开的场合除外。
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
-- 效果作用：判断是否满足发动条件，即攻击怪兽控制者不是自己且没有攻击目标
function c19665973.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前攻击的怪兽
	local at=Duel.GetAttacker()
	-- 效果作用：攻击怪兽控制者不是自己且没有攻击目标
	return at:IsControler(1-tp) and Duel.GetAttackTarget()==nil
end
-- 效果原文内容：①：对方怪兽的直接攻击宣言时才能发动。这张卡从手卡特殊召唤。那之后，战斗阶段结束。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c19665973.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		-- 效果作用：判断是否满足特殊召唤条件，即场上存在空位且此卡可以被特殊召唤
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	-- 效果作用：设置连锁操作信息，表明将要特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果原文内容：①：对方怪兽的直接攻击宣言时才能发动。这张卡从手卡特殊召唤。那之后，战斗阶段结束。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c19665973.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果作用：判断此卡是否还在场上且成功特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 效果作用：中断当前效果处理，使后续效果视为错时处理
		Duel.BreakEffect()
		-- 效果作用：跳过对方玩家的战斗阶段
		Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
		-- 效果原文内容：这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1)
	end
end

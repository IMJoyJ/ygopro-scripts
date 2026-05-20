--タスケナイト
-- 效果：
-- 这张卡在墓地存在，自己手卡是0张的场合，对方怪兽的攻击宣言时才能发动。这张卡从墓地特殊召唤，战斗阶段结束。「帮一把骑士」的效果在决斗中只能使用1次。
function c86039057.initial_effect(c)
	-- 这张卡在墓地存在，自己手卡是0张的场合，对方怪兽的攻击宣言时才能发动。这张卡从墓地特殊召唤，战斗阶段结束。「帮一把骑士」的效果在决斗中只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(86039057,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,86039057+EFFECT_COUNT_CODE_DUEL)
	e1:SetCondition(c86039057.condition)
	e1:SetTarget(c86039057.target)
	e1:SetOperation(c86039057.operation)
	c:RegisterEffect(e1)
end
-- 判断发动条件是否满足：对方怪兽攻击宣言，且自己手卡为0张
function c86039057.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发起攻击的怪兽
	local at=Duel.GetAttacker()
	-- 判断攻击怪兽是否为对方怪兽，且自己手卡数量是否为0
	return at:IsControler(1-tp) and Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0
end
-- 判断是否满足特殊召唤自身的基本条件（有空余怪兽区域且自身可特召）
function c86039057.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查时，判断自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理信息：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行效果处理：特殊召唤自身并结束战斗阶段
function c86039057.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡仍存在于墓地，则将其特殊召唤，并确认是否特殊召唤成功
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 跳过战斗阶段的其余步骤，强制结束战斗阶段
		Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
	end
end

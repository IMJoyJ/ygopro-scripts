--ソード・マスター
-- 效果：
-- 自己场上存在的战士族怪兽的攻击没让对方怪兽破坏的伤害步骤结束时，这张卡可以从手卡特殊召唤。此外，这张卡向守备表示怪兽攻击时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
function c81336148.initial_effect(c)
	-- 自己场上存在的战士族怪兽的攻击没让对方怪兽破坏的伤害步骤结束时，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(81336148,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_DAMAGE_STEP_END)
	e1:SetCondition(c81336148.spcon)
	e1:SetTarget(c81336148.sptg)
	e1:SetOperation(c81336148.spop)
	c:RegisterEffect(e1)
	-- 此外，这张卡向守备表示怪兽攻击时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)
end
-- 特殊召唤效果的发动条件判断函数（伤害步骤结束时，自己场上的战士族怪兽攻击且未破坏对方怪兽）
function c81336148.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取进行攻击的怪兽
	local a=Duel.GetAttacker()
	-- 获取被攻击的怪兽（攻击目标）
	local d=Duel.GetAttackTarget()
	-- 判断条件：存在攻击目标、当前是自己的回合、攻击怪兽是战士族，且攻击目标未被战斗破坏（仍在场或非因战斗破坏离场）
	return d and Duel.GetTurnPlayer()==tp and a:IsRace(RACE_WARRIOR) and (d:IsRelateToBattle() or not d:IsReason(REASON_BATTLE))
end
-- 特殊召唤效果的发动准备与合法性检测函数
function c81336148.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动阶段，检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 向系统宣告此效果包含将自身特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的实际处理函数
function c81336148.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到自己场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end

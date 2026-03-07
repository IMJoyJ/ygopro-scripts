--ダイナレスラー・カポエラプトル
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：攻击表示的这张卡不会被战斗破坏，被对方怪兽攻击的伤害步骤结束时这张卡变成守备表示。
-- ②：这张卡在怪兽区域守备表示存在的场合，自己·对方的准备阶段才能发动。从卡组把1只「恐龙摔跤手·卡波耶拉盗龙」特殊召唤。
function c29996433.initial_effect(c)
	-- 效果原文内容：①：攻击表示的这张卡不会被战斗破坏
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	e1:SetCondition(c29996433.indcon)
	c:RegisterEffect(e1)
	-- 效果原文内容：被对方怪兽攻击的伤害步骤结束时这张卡变成守备表示
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_DAMAGE_STEP_END)
	e2:SetCondition(c29996433.poscon)
	e2:SetOperation(c29996433.posop)
	c:RegisterEffect(e2)
	-- 效果原文内容：②：这张卡在怪兽区域守备表示存在的场合，自己·对方的准备阶段才能发动。从卡组把1只「恐龙摔跤手·卡波耶拉盗龙」特殊召唤
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(29996433,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,29996433)
	e3:SetCondition(c29996433.spcon)
	e3:SetTarget(c29996433.sptg)
	e3:SetOperation(c29996433.spop)
	c:RegisterEffect(e3)
end
-- 规则层面操作：判断当前卡片是否处于攻击表示
function c29996433.indcon(e)
	return e:GetHandler():IsAttackPos()
end
-- 规则层面操作：判断当前卡片是否为攻击阶段中被攻击的怪兽且参与了战斗
function c29996433.poscon(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：判断当前卡片是否为攻击阶段中被攻击的怪兽且参与了战斗
	return e:GetHandler()==Duel.GetAttackTarget() and e:GetHandler():IsRelateToBattle()
end
-- 规则层面操作：如果当前卡片处于攻击表示则将其变为守备表示
function c29996433.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsAttackPos() then
		-- 规则层面操作：将目标怪兽变为守备表示
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end
-- 规则层面操作：判断当前卡片是否处于守备表示
function c29996433.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsDefensePos()
end
-- 规则层面操作：过滤满足条件的卡片（卡号为29996433且可特殊召唤）
function c29996433.spfilter(c,e,tp)
	return c:IsCode(29996433) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 规则层面操作：判断在准备阶段发动效果时是否满足特殊召唤条件
function c29996433.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：判断目标玩家场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 规则层面操作：判断目标玩家卡组中是否存在满足条件的卡片
		and Duel.IsExistingMatchingCard(c29996433.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 规则层面操作：设置连锁操作信息，表示将要特殊召唤1张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 规则层面操作：执行特殊召唤操作
function c29996433.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：判断目标玩家场上是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 规则层面操作：向玩家提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面操作：从卡组中选择1张满足条件的卡片
	local g=Duel.SelectMatchingCard(tp,c29996433.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 规则层面操作：将选中的卡片特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

--ダイナレスラー・カポエラプトル
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：攻击表示的这张卡不会被战斗破坏，被对方怪兽攻击的伤害步骤结束时这张卡变成守备表示。
-- ②：这张卡在怪兽区域守备表示存在的场合，自己·对方的准备阶段才能发动。从卡组把1只「恐龙摔跤手·卡波耶拉盗龙」特殊召唤。
function c29996433.initial_effect(c)
	-- ①：攻击表示的这张卡不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	e1:SetCondition(c29996433.indcon)
	c:RegisterEffect(e1)
	-- 被对方怪兽攻击的伤害步骤结束时这张卡变成守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_DAMAGE_STEP_END)
	e2:SetCondition(c29996433.poscon)
	e2:SetOperation(c29996433.posop)
	c:RegisterEffect(e2)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡在怪兽区域守备表示存在的场合，自己·对方的准备阶段才能发动。从卡组把1只「恐龙摔跤手·卡波耶拉盗龙」特殊召唤。
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
-- 判定这张卡是否为攻击表示，仅在该状态下适用①的不被战斗破坏效果。
function c29996433.indcon(e)
	return e:GetHandler():IsAttackPos()
end
-- 判定本卡是被攻击的怪兽且与本次战斗保持关联，用于触发伤害步骤结束时的变守备效果。
function c29996433.poscon(e,tp,eg,ep,ev,re,r,rp)
	-- 本卡是被攻击对象且与战斗关联时才满足发动条件。
	return e:GetHandler()==Duel.GetAttackTarget() and e:GetHandler():IsRelateToBattle()
end
-- 效果处理：若这张卡仍为攻击表示，则将其变为表侧守备表示。
function c29996433.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsAttackPos() then
		-- 将这张卡的表示形式变为表侧守备表示。
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end
-- 判定这张卡是否以守备表示存在于怪兽区域，作为②的发动条件。
function c29996433.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsDefensePos()
end
-- 筛选卡组中卡名为「恐龙摔跤手·卡波耶拉盗龙」且能够被当前效果特殊召唤的卡。
function c29996433.spfilter(c,e,tp)
	return c:IsCode(29996433) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②的发动目标处理：己方怪兽区域有空位，且卡组中存在符合条件的同名卡。
function c29996433.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方主要怪兽区域是否还有可用空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1张满足条件的同名卡。
		and Duel.IsExistingMatchingCard(c29996433.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 登记本次连锁将执行从卡组特殊召唤1只怪兽的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：从卡组选择1张符合条件的同名卡特殊召唤到己方场上。
function c29996433.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认己方怪兽区域仍有空位，否则效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出提示文字，提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从己方卡组中选择1张满足条件的「恐龙摔跤手·卡波耶拉盗龙」。
	local g=Duel.SelectMatchingCard(tp,c29996433.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧攻击表示特殊召唤到己方场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

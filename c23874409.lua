--カラクリ将軍 無零
-- 效果：
-- 调整＋调整以外的机械族怪兽1只以上
-- 这张卡同调召唤成功时，可以从自己卡组把1只名字带有「机巧」的怪兽特殊召唤。1回合1次，可以选择场上存在的1只怪兽，把表示形式变更。
function c23874409.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只调整以外的机械族怪兽作为素材
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsRace,RACE_MACHINE),1)
	c:EnableReviveLimit()
	-- 这张卡同调召唤成功时，可以从自己卡组把1只名字带有「机巧」的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(23874409,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c23874409.spcon)
	e1:SetTarget(c23874409.sptg)
	e1:SetOperation(c23874409.spop)
	c:RegisterEffect(e1)
	-- 1回合1次，可以选择场上存在的1只怪兽，把表示形式变更。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(23874409,1))  --"改变表示形式"
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c23874409.postg)
	e2:SetOperation(c23874409.posop)
	c:RegisterEffect(e2)
end
-- 效果适用时，确保此卡为同调召唤成功
function c23874409.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤满足条件的「机巧」怪兽，用于特殊召唤
function c23874409.spfilter(c,e,tp)
	return c:IsSetCard(0x11) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足特殊召唤条件，包括场上是否有空位和卡组中是否存在符合条件的怪兽
function c23874409.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断卡组中是否存在符合条件的怪兽
		and Duel.IsExistingMatchingCard(c23874409.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 处理特殊召唤效果，选择并特殊召唤符合条件的怪兽
function c23874409.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有空位，若无则不执行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c23874409.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤可以改变表示形式的怪兽
function c23874409.filter(c)
	return c:IsCanChangePosition()
end
-- 设置改变表示形式效果的目标选择
function c23874409.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c23874409.filter(chkc) end
	-- 判断场上是否存在可以改变表示形式的怪兽
	if chk==0 then return Duel.IsExistingTarget(c23874409.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,c23874409.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置改变表示形式操作信息
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 处理改变表示形式效果，将目标怪兽变为守备表示
function c23874409.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标怪兽变为守备表示
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end

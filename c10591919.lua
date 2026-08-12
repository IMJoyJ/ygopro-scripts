--D・スコープン
-- 效果：
-- 这张卡得到这张卡的表示形式的以下效果。
-- ●攻击表示：1回合1次，可以从手卡把1只4星的名字带有「变形斗士」的怪兽特殊召唤。这个效果特殊召唤的怪兽在结束阶段时破坏。
-- ●守备表示：只要这张卡在场上表侧守备表示存在，这张卡的等级变成4星。
function c10591919.initial_effect(c)
	-- 攻击表示时，1回合1次，可以从手卡把1只4星的名字带有「变形斗士」的怪兽特殊召唤。这个效果特殊召唤的怪兽在结束阶段时破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10591919,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c10591919.cona)
	e1:SetTarget(c10591919.tga)
	e1:SetOperation(c10591919.opa)
	c:RegisterEffect(e1)
	-- 守备表示时，只要这张卡在场上表侧守备表示存在，这张卡的等级变成4星。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CHANGE_LEVEL)
	e2:SetCondition(c10591919.cond)
	e2:SetValue(4)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选手卡中满足条件的怪兽（4星、变形斗士系列、可特殊召唤）
function c10591919.filter(c,e,tp)
	return c:IsSetCard(0x26) and c:IsLevel(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断效果是否可以发动，条件为：此卡不是状态无效且处于攻击表示
function c10591919.cona(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsDisabled() and e:GetHandler():IsAttackPos()
end
-- 设置效果的发动目标，检查是否有满足条件的怪兽可特殊召唤
function c10591919.tga(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家手卡中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c10591919.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息，表示将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果发动时的处理函数，执行特殊召唤操作
function c10591919.opa(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有空位，没有则不执行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c10591919.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if not tc then return end
	-- 将选中的怪兽特殊召唤到场上
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	local fid=e:GetHandler():GetFieldID()
	tc:RegisterFlagEffect(10591919,RESET_EVENT+RESETS_STANDARD,0,1,fid)
	-- 创建一个在结束阶段时触发的效果，用于破坏特殊召唤的怪兽
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetLabel(fid)
	e1:SetLabelObject(tc)
	e1:SetCondition(c10591919.descon)
	e1:SetOperation(c10591919.desop)
	-- 将创建的破坏效果注册到场上
	Duel.RegisterEffect(e1,tp)
end
-- 判断是否需要触发破坏效果，通过标记检查怪兽是否仍处于特殊召唤状态
function c10591919.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(10591919)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 执行破坏操作，将目标怪兽破坏
function c10591919.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 将目标怪兽破坏
	Duel.Destroy(e:GetLabelObject(),REASON_EFFECT)
end
-- 判断效果是否可以发动，条件为：此卡处于守备表示
function c10591919.cond(e)
	return e:GetHandler():IsDefensePos()
end

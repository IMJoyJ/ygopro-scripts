--紋章変換
-- 效果：
-- 对方怪兽的攻击宣言时才能发动。从手卡把1只名字带有「纹章兽」的怪兽特殊召唤，战斗阶段结束。
function c17536995.initial_effect(c)
	-- 创建效果，设置为发动时点，攻击宣言时才能发动，效果分类为特殊召唤，条件为对方怪兽攻击宣言，目标为选择手卡的纹章兽怪兽，效果处理为特殊召唤该怪兽并跳过对方战斗阶段
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c17536995.condition)
	e1:SetTarget(c17536995.target)
	e1:SetOperation(c17536995.operation)
	c:RegisterEffect(e1)
end
-- 效果条件：攻击的怪兽控制者不是自己
function c17536995.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断攻击怪兽是否为对方控制
	return Duel.GetAttacker():IsControler(1-tp)
end
-- 过滤函数：选择手卡中名字带有「纹章兽」且可以特殊召唤的怪兽
function c17536995.filter(c,e,tp)
	return c:IsSetCard(0x76) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果目标：检查是否满足特殊召唤条件
function c17536995.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c17536995.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：准备特殊召唤1只怪兽到手卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：检查是否有空位，提示选择要特殊召唤的怪兽，选择并特殊召唤，若成功则中断效果并跳过对方战斗阶段
function c17536995.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有空位，若无则返回
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的1只怪兽
	local g=Duel.SelectMatchingCard(tp,c17536995.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	-- 判断是否成功特殊召唤，若成功则继续执行后续处理
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 跳过对方的战斗阶段
		Duel.SkipPhase(1-tp,PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE_STEP,1)
	end
end

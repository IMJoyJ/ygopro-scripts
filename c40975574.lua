--レッド・リゾネーター
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡召唤时才能发动。从手卡把1只4星以下的怪兽特殊召唤。
-- ②：这张卡特殊召唤时，以场上1只表侧表示怪兽为对象才能发动。自己基本分回复那只怪兽的攻击力的数值。
function c40975574.initial_effect(c)
	-- ①：这张卡召唤时才能发动。从手卡把1只4星以下的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40975574,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c40975574.sptg)
	e1:SetOperation(c40975574.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡特殊召唤时，以场上1只表侧表示怪兽为对象才能发动。自己基本分回复那只怪兽的攻击力的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(40975574,1))
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,40975574)
	e2:SetTarget(c40975574.rectg)
	e2:SetOperation(c40975574.recop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断手卡中是否存在4星以下且可以特殊召唤的怪兽
function c40975574.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足特殊召唤条件，包括场上是否有空位以及手卡中是否存在符合条件的怪兽
function c40975574.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空位可用于特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在至少1只4星以下的怪兽
		and Duel.IsExistingMatchingCard(c40975574.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息，表示将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 处理特殊召唤效果，选择并特殊召唤符合条件的怪兽
function c40975574.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有空位，若无则直接返回
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡中选择1只符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c40975574.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数，用于判断场上是否存在正面表示且攻击力大于0的怪兽
function c40975574.filter(c)
	return c:IsFaceup() and c:GetAttack()>0
end
-- 判断是否满足回复LP条件，包括场上是否存在符合条件的怪兽
function c40975574.rectg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c40975574.filter(chkc) end
	-- 检查场上是否存在至少1只正面表示且攻击力大于0的怪兽
	if chk==0 then return Duel.IsExistingTarget(c40975574.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择场上1只正面表示且攻击力大于0的怪兽作为对象
	local g=Duel.SelectTarget(tp,c40975574.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息，表示将要回复LP
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,g:GetFirst():GetAttack())
end
-- 处理回复LP效果，将对象怪兽的攻击力作为回复数值
function c40975574.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:GetAttack()>0 then
		-- 使玩家回复对象怪兽攻击力数值的LP
		Duel.Recover(tp,tc:GetAttack(),REASON_EFFECT)
	end
end

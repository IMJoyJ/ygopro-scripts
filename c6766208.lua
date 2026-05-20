--DDD疾風大王エグゼクティブ・アレクサンダー
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：场上有「DDD」怪兽3只以上存在的场合，这张卡的攻击力上升3000。
-- ②：这张卡在怪兽区域存在，自己场上有这张卡以外的「DD」怪兽召唤·特殊召唤的场合，以自己墓地1只「DD」怪兽为对象才能发动。那只怪兽特殊召唤。
function c6766208.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加同调召唤手续：调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡在怪兽区域存在，自己场上有这张卡以外的「DD」怪兽召唤·特殊召唤的场合，以自己墓地1只「DD」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(6766208,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,6766208)
	e1:SetCondition(c6766208.spcon)
	e1:SetTarget(c6766208.sptg)
	e1:SetOperation(c6766208.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ①：场上有「DDD」怪兽3只以上存在的场合，这张卡的攻击力上升3000。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c6766208.atkcon)
	e3:SetValue(3000)
	c:RegisterEffect(e3)
end
-- 过滤自己场上表侧表示的「DD」怪兽
function c6766208.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xaf) and c:IsControler(tp)
end
-- 判定自己场上是否有这张卡以外的「DD」怪兽召唤·特殊召唤
function c6766208.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c6766208.cfilter,1,nil,tp)
end
-- 过滤自己墓地中可以特殊召唤的「DD」怪兽
function c6766208.spfilter(c,e,tp)
	return c:IsSetCard(0xaf) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的靶向判定与对象选择（判定是否满足发动条件，并选择墓地的「DD」怪兽作为对象）
function c6766208.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c6766208.spfilter(chkc,e,tp) end
	-- 判定自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判定自己墓地是否存在可以作为对象的「DD」怪兽
		and Duel.IsExistingTarget(c6766208.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只「DD」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c6766208.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁处理的操作信息为：特殊召唤选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②的实际处理（将作为对象的怪兽特殊召唤）
function c6766208.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤场上表侧表示的「DDD」怪兽
function c6766208.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x10af)
end
-- 判定场上是否存在3只以上的「DDD」怪兽
function c6766208.atkcon(e)
	-- 统计双方场上表侧表示的「DDD」怪兽数量是否在3只以上
	return Duel.GetMatchingGroupCount(c6766208.atkfilter,e:GetHandlerPlayer(),LOCATION_MZONE,LOCATION_MZONE,nil)>=3
end

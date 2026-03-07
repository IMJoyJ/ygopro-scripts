--メルフィーのおいかけっこ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己墓地1只「童话动物」怪兽为对象才能发动。那只怪兽特殊召唤。
function c37256135.initial_effect(c)
	-- 效果原文内容：这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,37256135+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c37256135.target)
	e1:SetOperation(c37256135.activate)
	c:RegisterEffect(e1)
end
-- 检索满足条件的墓地「童话动物」怪兽（必须可以特殊召唤）
function c37256135.filter(c,e,tp)
	return c:IsSetCard(0x146) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果作用：处理选择目标时的条件判断
function c37256135.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c37256135.filter(chkc,e,tp) end
	-- 效果作用：判断玩家场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果作用：判断玩家墓地是否存在满足条件的怪兽
		and Duel.IsExistingTarget(c37256135.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 效果作用：向玩家提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 效果作用：选择1只满足条件的墓地怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c37256135.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 效果作用：设置连锁操作信息，确定将要特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果原文内容：①：以自己墓地1只「童话动物」怪兽为对象才能发动。那只怪兽特殊召唤。
function c37256135.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前连锁效果的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 效果作用：将对象怪兽以正面表示形式特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

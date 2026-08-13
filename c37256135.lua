--メルフィーのおいかけっこ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己墓地1只「童话动物」怪兽为对象才能发动。那只怪兽特殊召唤。
function c37256135.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己墓地1只「童话动物」怪兽为对象才能发动。那只怪兽特殊召唤。
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
-- 过滤条件：对象必须是持有「童话动物」字段的怪兽，且能被当前效果特殊召唤（同时检查召唤条件和苏生限制）。
function c37256135.filter(c,e,tp)
	return c:IsSetCard(0x146) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- target函数发动条件判定部分：先处理连锁回卷时对象合法性判定，再确认自己主要怪兽区有空位且墓地存在符合条件的「童话动物」怪兽。
function c37256135.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c37256135.filter(chkc,e,tp) end
	-- 发动条件之一：自己主要怪兽区存在可用的空格，用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件之二：自己墓地存在至少1只满足filter条件的「童话动物」怪兽，且该怪兽能成为当前效果对象。
		and Duel.IsExistingTarget(c37256135.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示“请选择要特殊召唤的卡”的提示，等待选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只符合条件的「童话动物」怪兽，并将选中的卡登记为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,c37256135.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 将本次连锁的操作信息设为“特殊召唤”，目标为已选择的卡，数量为1，供其他卡牌效果进行连锁/无效判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理函数：取得效果对象，若对象仍与效果关联（未离场等），则将其特殊召唤。
function c37256135.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的效果对象（即之前选择的墓地的「童话动物」怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到自己场上（sumtype为0，并检查召唤条件和苏生限制）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

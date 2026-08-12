--BF－逆巻のトルネード
-- 效果：
-- ①：特殊召唤的怪兽在对方场上存在，这张卡召唤成功时，以自己墓地1只「黑羽」调整为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。这个效果的发动后，直到回合结束时自己不是「黑羽」怪兽不能从额外卡组特殊召唤。
function c73534250.initial_effect(c)
	-- ①：特殊召唤的怪兽在对方场上存在，这张卡召唤成功时，以自己墓地1只「黑羽」调整为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。这个效果的发动后，直到回合结束时自己不是「黑羽」怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(73534250,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c73534250.spcon)
	e1:SetTarget(c73534250.sptg)
	e1:SetOperation(c73534250.spop)
	c:RegisterEffect(e1)
end
-- 过滤条件：是否为特殊召唤的怪兽
function c73534250.ctfilter(c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 发动条件：对方场上存在特殊召唤的怪兽
function c73534250.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方场上是否存在至少1只特殊召唤的怪兽
	return Duel.IsExistingMatchingCard(c73534250.ctfilter,tp,0,LOCATION_MZONE,1,nil)
end
-- 过滤条件：自己墓地的「黑羽」调整怪兽且能特殊召唤
function c73534250.filter(c,e,tp)
	return c:IsSetCard(0x33) and c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标选择与合法性检查
function c73534250.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c73534250.filter(chkc,e,tp) end
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在符合条件的「黑羽」调整怪兽
		and Duel.IsExistingTarget(c73534250.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只「黑羽」调整怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c73534250.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息：特殊召唤选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：特殊召唤目标怪兽并使其效果无效，并施加额外卡组特殊召唤限制
function c73534250.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果发动的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 若目标怪兽仍与效果相关，则尝试将其以表侧表示特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
	-- 完成特殊召唤的处理
	Duel.SpecialSummonComplete()
	-- 这个效果的发动后，直到回合结束时自己不是「黑羽」怪兽不能从额外卡组特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetTarget(c73534250.splimit)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 在全局注册该玩家的特殊召唤限制效果
	Duel.RegisterEffect(e3,tp)
end
-- 限制条件：不能从额外卡组特殊召唤「黑羽」以外的怪兽
function c73534250.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x33) and c:IsLocation(LOCATION_EXTRA)
end

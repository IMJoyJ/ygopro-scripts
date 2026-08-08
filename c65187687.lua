--巨骸竜フェルグラント
-- 效果：
-- 不死族调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤成功的场合，以对方的场上·墓地1只怪兽为对象才能发动。那只怪兽除外。
-- ②：这张卡已在怪兽区域存在的状态，从墓地有怪兽特殊召唤的场合，以这张卡以外的场上1只表侧表示怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。
local s,id,o=GetID()
-- 执行对应的效果条件检查或辅助函数处理
function c65187687.initial_effect(c)
	-- 执行对应的效果条件检查或辅助函数处理
	aux.AddSynchroProcedure(c,c65187687.synfilter,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 处理卡片效果的发动条件、目标选择及效果操作
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"对方怪兽除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,65187687)
	e1:SetTarget(c65187687.rmtg)
	e1:SetOperation(c65187687.rmop)
	c:RegisterEffect(e1)
	-- 处理卡片效果的发动条件、目标选择及效果操作
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"场上怪兽效果无效"
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,65187687+o)
	e2:SetCondition(c65187687.discon)
	e2:SetTarget(c65187687.distg)
	e2:SetOperation(c65187687.disop)
	c:RegisterEffect(e2)
end
-- 执行对应的效果条件检查或辅助函数处理
function c65187687.synfilter(c)
	return c:IsRace(RACE_ZOMBIE)
end
-- 执行对应的效果条件检查或辅助函数处理
function c65187687.rmfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- 执行对应的效果条件检查或辅助函数处理
function c65187687.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and chkc:IsControler(1-tp) and c65187687.rmfilter(chkc) end
	-- 执行对应的效果条件检查或辅助函数处理
	if chk==0 then return Duel.IsExistingTarget(c65187687.rmfilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,nil) end
	-- 执行对应的效果条件检查或辅助函数处理
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 执行对应的效果条件检查或辅助函数处理
	local g=aux.SelectTargetFromFieldFirst(tp,c65187687.rmfilter,tp,0,LOCATION_GRAVE+LOCATION_MZONE,1,1,nil)
	if g:GetFirst():IsLocation(LOCATION_GRAVE) then
		-- 执行对应的效果条件检查或辅助函数处理
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,1-tp,LOCATION_GRAVE)
	else
		-- 执行对应的效果条件检查或辅助函数处理
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	end
end
-- 执行对应的效果条件检查或辅助函数处理
function c65187687.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 执行对应的效果条件检查或辅助函数处理
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 执行对应的效果条件检查或辅助函数处理
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 执行对应的效果条件检查或辅助函数处理
function c65187687.spfilter(c)
	return c:IsSummonLocation(LOCATION_GRAVE) and c:GetOriginalType()&TYPE_MONSTER~=0
end
-- 执行对应的效果条件检查或辅助函数处理
function c65187687.discon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c65187687.spfilter,1,nil) and not eg:IsContains(e:GetHandler())
end
-- 执行对应的效果条件检查或辅助函数处理
function c65187687.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 执行对应的效果条件检查或辅助函数处理
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and aux.NegateEffectMonsterFilter(chkc) end
	-- 执行对应的效果条件检查或辅助函数处理
	if chk==0 then return Duel.IsExistingTarget(aux.NegateEffectMonsterFilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 执行对应的效果条件检查或辅助函数处理
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 执行对应的效果条件检查或辅助函数处理
	Duel.SelectTarget(tp,aux.NegateEffectMonsterFilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 执行对应的效果条件检查或辅助函数处理
function c65187687.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 执行对应的效果条件检查或辅助函数处理
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 执行对应的效果条件检查或辅助函数处理
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 处理卡片效果的发动条件、目标选择及效果操作
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 处理卡片效果的发动条件、目标选择及效果操作
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end

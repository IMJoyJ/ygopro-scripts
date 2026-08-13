--魔界闘士 バルムンク
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这张卡被卡的效果破坏送去墓地时，可以从自己墓地选择这张卡以外的1只4星以下的怪兽特殊召唤。
function c52639377.initial_effect(c)
	-- 为这张卡添加同调召唤手续：调整＋调整以外的怪兽1只以上。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 这张卡被卡的效果破坏送去墓地时，可以从自己墓地选择这张卡以外的1只4星以下的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(52639377,0))  --"特殊召唤"
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c52639377.spcon)
	e1:SetTarget(c52639377.sptg)
	e1:SetOperation(c52639377.spop)
	c:RegisterEffect(e1)
end
-- 效果发动条件：这张卡被卡的效果破坏并送去墓地时。
function c52639377.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT) and e:GetHandler():IsReason(REASON_DESTROY)
end
-- 特殊召唤的候选卡过滤条件：等级4以下且可以被特殊召唤的怪兽。
function c52639377.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动目标选择：从自己墓地选择这张卡以外的1只4星以下的怪兽作为特殊召唤对象。
function c52639377.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c52639377.spfilter(chkc,e,tp) end
	-- 发动合法性检查：自己场上有可用的主要怪兽区空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在这张卡以外的满足条件的4星以下怪兽。
		and Duel.IsExistingTarget(c52639377.spfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	-- 显示选择特殊召唤卡的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地中1只符合条件的怪兽作为效果的对象。
	local g=Duel.SelectTarget(tp,c52639377.spfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler(),e,tp)
	-- 设置操作信息：标记本次效果处理为特殊召唤，登记选择的对象。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：将选择的怪兽特殊召唤到自己场上。
function c52639377.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将对象怪兽以正面表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

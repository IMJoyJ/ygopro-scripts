--魔界闘士 バルムンク
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这张卡被卡的效果破坏送去墓地时，可以从自己墓地选择这张卡以外的1只4星以下的怪兽特殊召唤。
function c52639377.initial_effect(c)
	-- 为卡片添加同调召唤手续，要求1只调整和1只调整以外的怪兽
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
-- 效果发动的条件：卡片因效果破坏且被破坏
function c52639377.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT) and e:GetHandler():IsReason(REASON_DESTROY)
end
-- 过滤满足条件的怪兽：等级不超过4星且可以特殊召唤
function c52639377.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果的目标选择函数，用于选择墓地中的符合条件的怪兽
function c52639377.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c52639377.spfilter(chkc,e,tp) end
	-- 判断场上是否有足够的特殊召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断墓地中是否存在满足条件的怪兽
		and Duel.IsExistingTarget(c52639377.spfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	-- 向玩家发送提示信息，提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标怪兽并设置为效果对象
	local g=Duel.SelectTarget(tp,c52639377.spfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler(),e,tp)
	-- 设置连锁操作信息，确定将要特殊召唤的怪兽数量和位置
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理函数：将选中的怪兽特殊召唤到场上
function c52639377.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标怪兽以正面表示形式特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

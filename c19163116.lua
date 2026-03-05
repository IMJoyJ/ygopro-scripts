--ジェムナイト・オブシディア
-- 效果：
-- ①：这张卡从手卡送去墓地的场合，以自己墓地1只4星以下的通常怪兽为对象才能发动。那只怪兽特殊召唤。
function c19163116.initial_effect(c)
	-- 效果原文内容：①：这张卡从手卡送去墓地的场合，以自己墓地1只4星以下的通常怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19163116,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c19163116.spcon)
	e1:SetTarget(c19163116.sptg)
	e1:SetOperation(c19163116.spop)
	c:RegisterEffect(e1)
end
-- 规则层面作用：判断此卡是否由手牌送去墓地
function c19163116.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND)
end
-- 规则层面作用：筛选满足条件的墓地怪兽（4星以下、通常怪兽、可特殊召唤）
function c19163116.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsType(TYPE_NORMAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 规则层面作用：设置效果的发动条件，检查是否满足特殊召唤的条件
function c19163116.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c19163116.filter(chkc,e,tp) end
	-- 规则层面作用：检查玩家场上是否有足够的特殊召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 规则层面作用：检查玩家墓地是否存在满足条件的怪兽
		and Duel.IsExistingTarget(c19163116.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 规则层面作用：向玩家发送提示信息，提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面作用：选择满足条件的墓地怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c19163116.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 规则层面作用：设置连锁的操作信息，确定特殊召唤的怪兽数量和目标
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 规则层面作用：执行特殊召唤操作
function c19163116.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：检查场上是否还有特殊召唤区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 规则层面作用：获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 规则层面作用：将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

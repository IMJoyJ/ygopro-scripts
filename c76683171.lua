--ワーム・アグリィ
-- 效果：
-- 把这张卡解放对名字带有「异虫」的爬虫类族怪兽的上级召唤成功时，自己墓地存在的这张卡可以在对方场上表侧攻击表示特殊召唤。
function c76683171.initial_effect(c)
	-- 把这张卡解放对名字带有「异虫」的爬虫类族怪兽的上级召唤成功时，自己墓地存在的这张卡可以在对方场上表侧攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(76683171,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetCondition(c76683171.spcon)
	e1:SetTarget(c76683171.sptg)
	e1:SetOperation(c76683171.spop)
	c:RegisterEffect(e1)
end
-- 检查此卡是否在墓地，且是因为上级召唤被解放，且该上级召唤的怪兽是名字带有「异虫」的怪兽
function c76683171.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and r==REASON_SUMMON and c:GetReasonCard():IsSetCard(0x3e)
end
-- 检查对方场上是否有可用怪兽区域，以及此卡是否能特殊召唤到对方场上
function c76683171.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上的怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK,1-tp) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：若此卡仍与效果关联，则将此卡特殊召唤到对方场上
function c76683171.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡在对方场上表侧攻击表示特殊召唤
		Duel.SpecialSummon(c,0,tp,1-tp,false,false,POS_FACEUP_ATTACK)
	end
end

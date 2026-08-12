--魔轟神獣ガナシア
-- 效果：
-- ①：这张卡从手卡丢弃去墓地的场合发动。这张卡特殊召唤。这个效果特殊召唤的这张卡攻击力上升200，从场上离开的场合除外。
function c18282103.initial_effect(c)
	-- 创建一个诱发必发效果，用于处理卡片从手卡丢弃至墓地时的特殊召唤效果
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(18282103,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c18282103.spcon)
	e1:SetTarget(c18282103.sptg)
	e1:SetOperation(c18282103.spop)
	c:RegisterEffect(e1)
end
-- 判断该卡是否从手卡丢弃至墓地
function c18282103.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND) and bit.band(r,REASON_DISCARD)~=0
end
-- 设置效果处理时的连锁操作信息，表明将要特殊召唤此卡
function c18282103.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁操作为特殊召唤类别，目标为自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作，并为特殊召唤的卡片添加攻击力上升200的效果和离场时除外的效果
function c18282103.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查卡片是否与当前效果相关联，并尝试将其特殊召唤到场上
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 这个效果特殊召唤的这张卡攻击力上升200
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(200)
		c:RegisterEffect(e1)
		-- 从场上离开的场合除外
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e2:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e2,true)
	end
end

--魔轟神獣ガナシア
-- 效果：
-- ①：这张卡从手卡丢弃去墓地的场合发动。这张卡特殊召唤。这个效果特殊召唤的这张卡攻击力上升200，从场上离开的场合除外。
function c18282103.initial_effect(c)
	-- ①：这张卡从手卡丢弃去墓地的场合发动。这张卡特殊召唤。这个效果特殊召唤的这张卡攻击力上升200，从场上离开的场合除外。
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
-- 判定发动条件：这张卡被丢弃前位于手牌，且此次送去墓地的原因为丢弃。
function c18282103.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND) and bit.band(r,REASON_DISCARD)~=0
end
-- 诱发效果的发动处理：满足条件即可发动，无需选择对象，并将特殊召唤这张卡登记为处理信息。
function c18282103.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置本次效果的处理信息：将这张卡特殊召唤（数量1，对象为当前效果处理卡，归属暂未知）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：若这张卡仍与效果关联，则将这张卡表侧攻击表示特殊召唤；若成功，再给它附加攻击力上升200和离场时改为除外的效果。
function c18282103.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断这张卡仍与效果关联，并尝试将其表侧攻击表示特殊召唤；若特殊召唤成功（返回值非0）则继续执行后续处理。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 这个效果特殊召唤的这张卡攻击力上升200。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(200)
		c:RegisterEffect(e1)
		-- 从场上离开的场合除外。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e2:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e2,true)
	end
end

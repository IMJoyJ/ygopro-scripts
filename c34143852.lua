--H・C エクストラ・ソード
-- 效果：
-- 这张卡为素材的超量怪兽得到以下效果。
-- ●这次超量召唤成功时，这张卡的攻击力上升1000。
function c34143852.initial_effect(c)
	-- ①：场上的这张卡为素材作超量召唤的怪兽得到以下效果。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e1:SetCondition(c34143852.efcon)
	e1:SetOperation(c34143852.efop)
	c:RegisterEffect(e1)
end
-- 判定本卡是否作为超量召唤的素材被使用（r==REASON_XYZ），仅在作为超量素材时这个效果才适用。
function c34143852.efcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_XYZ
end
-- 作为素材时，获取那只超量召唤的怪兽，为其注册一个“这张卡超量召唤成功时攻击力上升1000”的诱发效果；若该怪兽不是效果怪兽，则额外将其变成效果怪兽以保证效果正常持有。
function c34143852.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- ●这张卡超量召唤的场合发动。这张卡的攻击力上升1000。
	local e1=Effect.CreateEffect(rc)
	e1:SetDescription(aux.Stringid(34143852,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c34143852.atkcon)
	e1:SetOperation(c34143852.atkop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	if not rc:IsType(TYPE_EFFECT) then
		-- ●这张卡超量召唤的场合发动。这张卡的攻击力上升1000。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e2,true)
	end
end
-- 判断效果持有怪兽是否确实以超量召唤的方式成功特殊召唤（IsSummonType(SUMMON_TYPE_XYZ)）。
function c34143852.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 效果处理时，若效果持有怪兽仍与此效果关联且表侧表示，则创建并注册一个上升1000攻击力的效果（离场/无效时重置）。
function c34143852.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的攻击力上升1000。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end

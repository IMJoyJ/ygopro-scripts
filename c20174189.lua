--ナチュル・バンブーシュート
-- 效果：
-- 把名字带有「自然」的怪兽解放作上级召唤成功的这张卡只要在场上表侧表示存在，对方不能把魔法·陷阱卡发动。
function c20174189.initial_effect(c)
	-- 把名字带有「自然」的怪兽解放作上级召唤成功的这张卡
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(c20174189.valcheck)
	c:RegisterEffect(e1)
	-- 把名字带有「自然」的怪兽解放作上级召唤成功的这张卡只要在场上表侧表示存在，对方不能把魔法·陷阱卡发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCondition(c20174189.regcon)
	e2:SetOperation(c20174189.regop)
	c:RegisterEffect(e2)
	e2:SetLabelObject(e1)
end
-- 检查这张卡的召唤素材中是否存在名字带有「自然」的怪兽，若存在则将 e 的 Label 标记为 1，用于记录是否满足“把名字带有「自然」的怪兽解放作上级召唤成功”的条件。
function c20174189.valcheck(e,c)
	local g=c:GetMaterial()
	local flag=0
	if g:IsExists(Card.IsSetCard,1,nil,0x2a) then flag=1 end
	e:SetLabel(flag)
end
-- 判定这张卡是否是以名字带有「自然」的怪兽解放作上级召唤成功：要求召唤类型为上级召唤，且素材检查记录的 Label 不为 0。
function c20174189.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
		and e:GetLabelObject():GetLabel()~=0
end
-- 满足条件后，给这张卡注册一个永续效果：只要这张卡在场上表侧表示存在，对方不能发动魔法·陷阱卡；该效果按标准重置规则在离场等时被重置。
function c20174189.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 只要在场上表侧表示存在，对方不能把魔法·陷阱卡发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	e1:SetValue(c20174189.aclimit)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e:GetHandler():RegisterEffect(e1)
end
-- 判定对方尝试发动的效果是否为魔法·陷阱卡的发动（类型为 EFFECT_TYPE_ACTIVATE），若是则不能发动。
function c20174189.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end

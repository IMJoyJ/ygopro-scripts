--ナチュル・バンブーシュート
-- 效果：
-- 把名字带有「自然」的怪兽解放作上级召唤成功的这张卡只要在场上表侧表示存在，对方不能把魔法·陷阱卡发动。
function c20174189.initial_effect(c)
	-- 把名字带有「自然」的怪兽解放作上级召唤成功的这张卡只要在场上表侧表示存在，对方不能把魔法·陷阱卡发动。
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
-- 检查出场时使用的素材中是否存在名字带有「自然」的怪兽，若存在则标记为1，否则为0。
function c20174189.valcheck(e,c)
	local g=c:GetMaterial()
	local flag=0
	if g:IsExists(Card.IsSetCard,1,nil,0x2a) then flag=1 end
	e:SetLabel(flag)
end
-- 判断此卡是否为上级召唤成功，并且之前检查的标记不为0。
function c20174189.regcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
		and e:GetLabelObject():GetLabel()~=0
end
-- 将一个永续效果注册到场上，使对方不能发动魔法·陷阱卡。
function c20174189.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 对方不能把魔法·陷阱卡发动。
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
-- 限制对方只能发动魔法·陷阱卡效果。
function c20174189.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end

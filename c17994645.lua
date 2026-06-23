--A BF－雨隠れのサヨ
-- 效果：
-- 调整＋调整以外的怪兽1只
-- ①：「黑羽」怪兽为素材作同调召唤的这张卡当作调整使用。
-- ②：这张卡1回合最多2次不会被战斗破坏。
function c17994645.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整作素材，1只调整以外的怪兽作素材
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1,1)
	c:EnableReviveLimit()
	-- ①：「黑羽」怪兽为素材作同调召唤的这张卡当作调整使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c17994645.tncon)
	e1:SetOperation(c17994645.tnop)
	c:RegisterEffect(e1)
	-- ①：「黑羽」怪兽为素材作同调召唤的这张卡当作调整使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c17994645.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	-- ②：这张卡1回合最多2次不会被战斗破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e3:SetCountLimit(2)
	e3:SetValue(c17994645.valcon)
	c:RegisterEffect(e3)
end
c17994645.treat_itself_tuner=true
-- 检查出场使用的素材中是否存在「黑羽」卡，是则标记为1，否则为0
function c17994645.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsSetCard,1,nil,0x33) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- 判断是否为同调召唤且标记为1（即使用了黑羽卡作为素材）
function c17994645.tncon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO) and e:GetLabel()==1
end
-- 若满足条件，则为自身添加调整属性
function c17994645.tnop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- ①：「黑羽」怪兽为素材作同调召唤的这张卡当作调整使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_ADD_TYPE)
	e1:SetValue(TYPE_TUNER)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
end
-- 判断破坏原因是否为战斗
function c17994645.valcon(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end

--鬼岩城
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这张卡的攻击力·守备力上升作为这张卡的同调素材的调整以外的怪兽数量×200的数值。
function c63422098.initial_effect(c)
	-- 为这张卡添加同调召唤手续：需要1只调整怪兽，以及1只以上的调整以外的怪兽
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 这张卡的攻击力·守备力上升作为这张卡的同调素材的调整以外的怪兽数量×200的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(c63422098.val)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	-- 这张卡的攻击力·守备力上升作为这张卡的同调素材的调整以外的怪兽数量×200的数值。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetOperation(c63422098.regop)
	c:RegisterEffect(e3)
end
-- 获取自身注册的标识效果的Label值，作为攻击力或守备力的上升数值
function c63422098.val(e,c)
	local ct=e:GetHandler():GetFlagEffectLabel(63422098)
	if not ct then return 0 end
	return ct
end
-- 同调召唤成功时，计算非调整素材的数量（素材总数减1），并将该数量乘以200作为Label注册标识效果
function c63422098.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsSummonType(SUMMON_TYPE_SYNCHRO) then
		local ct=c:GetMaterialCount()-1
		c:RegisterFlagEffect(63422098,RESET_EVENT+RESETS_STANDARD+RESET_DISABLE,0,0,ct*200)
	end
end

--合成魔獣 ガーゼット
-- 效果：
-- 这张卡的攻击力变成祭品召唤时作为祭品的2只怪兽的原本攻击力合计的数值。
function c8794435.initial_effect(c)
	-- 这张卡的攻击力变成祭品召唤时作为祭品的2只怪兽的原本攻击力合计的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(c8794435.valcheck)
	c:RegisterEffect(e1)
	-- 祭品召唤时
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SUMMON_COST)
	e2:SetOperation(c8794435.facechk)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
end
-- 获取作为祭品召唤素材的怪兽并累加它们的原本攻击力，若确认是祭品召唤则适用攻击力改变的效果
function c8794435.valcheck(e,c)
	local g=c:GetMaterial()
	local tc=g:GetFirst()
	local atk=0
	while tc do
		local catk=tc:GetTextAttack()
		atk=atk+(catk>=0 and catk or 0)
		tc=g:GetNext()
	end
	if e:GetLabel()==1 then
		e:SetLabel(0)
		-- 这张卡的攻击力变成祭品召唤时作为祭品的2只怪兽的原本攻击力合计的数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+0xff0000)
		c:RegisterEffect(e1)
	end
end
-- 在召唤程序开始时，将素材检查效果的Label设置为1，以标记该卡进行了祭品召唤
function c8794435.facechk(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():SetLabel(1)
end

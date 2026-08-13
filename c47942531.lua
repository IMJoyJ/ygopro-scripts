--偉大魔獣 ガーゼット
-- 效果：
-- 这张卡的攻击力变成祭品召唤时作为祭品的1只怪兽的原本攻击力2倍的数值。
function c47942531.initial_effect(c)
	-- 作为祭品的1只怪兽的原本攻击力
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(c47942531.valcheck)
	c:RegisterEffect(e1)
	-- 祭品召唤时
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SUMMON_COST)
	e2:SetOperation(c47942531.facechk)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
end
-- 获取召唤素材中第一只怪兽的原本攻击力并乘以2（负值按0处理）；若此前通过召唤代价标记了正在进行祭品召唤，则清除标记并注册一个持续攻击力设置效果，将这张卡的攻击力固定为计算出的数值
function c47942531.valcheck(e,c)
	local tc=c:GetMaterial():GetFirst()
	local atk=0
	if tc then atk=tc:GetTextAttack()*2 end
	if atk<0 then atk=0 end
	if e:GetLabel()==1 then
		e:SetLabel(0)
		-- 这张卡的攻击力变成祭品召唤时作为祭品的1只怪兽的原本攻击力2倍的数值
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+0xff0000)
		c:RegisterEffect(e1)
	end
end
-- 在祭品召唤的召唤代价阶段，将素材检查效果的标签设为1，用于标记本次为祭品召唤，使后续valcheck据此设置攻击力
function c47942531.facechk(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():SetLabel(1)
end

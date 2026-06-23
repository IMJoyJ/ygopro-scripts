--偉大魔獣 ガーゼット
-- 效果：
-- 这张卡的攻击力变成祭品召唤时作为祭品的1只怪兽的原本攻击力2倍的数值。
function c47942531.initial_effect(c)
	-- 这张卡的攻击力变成祭品召唤时作为祭品的1只怪兽的原本攻击力2倍的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(c47942531.valcheck)
	c:RegisterEffect(e1)
	-- 这张卡的攻击力变成祭品召唤时作为祭品的1只怪兽的原本攻击力2倍的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SUMMON_COST)
	e2:SetOperation(c47942531.facechk)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
end
-- 检索祭品召唤时作为祭品的怪兽并计算其攻击力的2倍作为自身攻击力
function c47942531.valcheck(e,c)
	local tc=c:GetMaterial():GetFirst()
	local atk=0
	if tc then atk=tc:GetTextAttack()*2 end
	if atk<0 then atk=0 end
	if e:GetLabel()==1 then
		e:SetLabel(0)
		-- 将自身攻击力设置为计算所得的数值
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+0xff0000)
		c:RegisterEffect(e1)
	end
end
-- 设置标记以触发攻击力计算效果
function c47942531.facechk(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():SetLabel(1)
end

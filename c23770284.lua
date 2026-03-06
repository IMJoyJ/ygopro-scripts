--ストロング・ウィンド・ドラゴン
-- 效果：
-- ①：把1只龙族怪兽解放对这张卡的上级召唤成功的场合发动。这张卡的攻击力上升解放的那只怪兽的原本攻击力一半数值。
-- ②：这张卡不会被和相同攻击力的怪兽的战斗破坏。
-- ③：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
function c23770284.initial_effect(c)
	-- ①：把1只龙族怪兽解放对这张卡的上级召唤成功的场合发动。这张卡的攻击力上升解放的那只怪兽的原本攻击力一半数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(23770284,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c23770284.condition)
	e1:SetOperation(c23770284.operation)
	c:RegisterEffect(e1)
	-- ①：把1只龙族怪兽解放对这张卡的上级召唤成功的场合发动。这张卡的攻击力上升解放的那只怪兽的原本攻击力一半数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c23770284.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	-- ②：这张卡不会被和相同攻击力的怪兽的战斗破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetValue(c23770284.indval)
	c:RegisterEffect(e3)
	-- ③：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e4)
end
-- 检查上级召唤时使用的素材是否为龙族怪兽，是则设置标签为1，否则为0。
function c23770284.valcheck(e,c)
	local g=c:GetMaterial()
	local tc=g:GetFirst()
	if tc:IsRace(RACE_DRAGON) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- 判断是否为上级召唤且标签为1，满足条件时发动效果。
function c23770284.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE) and e:GetLabel()==1
end
-- 检索上级召唤时使用的素材，获取其攻击力的一半数值并赋予自身攻击力提升效果。
function c23770284.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local atk=c:GetMaterial():GetFirst():GetTextAttack()
		if atk<0 then atk=0 end
		if atk>0 then
			-- 将攻击力提升效果注册给自身，提升值为素材怪兽攻击力的一半（向上取整）。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(math.ceil(atk/2))
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			c:RegisterEffect(e1)
		end
	end
end
-- 判断攻击对象的攻击力是否等于自身攻击力，若是则不会被战斗破坏。
function c23770284.indval(e,c)
	return c:IsAttack(e:GetHandler():GetAttack())
end

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
	-- 把1只龙族怪兽解放对这张卡的上级召唤成功的场合发动。
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
-- 检查这张卡上级召唤时使用的素材中是否存在龙族怪兽，将判定结果记录到e1的标签中，用于①效果的发动条件判断。
function c23770284.valcheck(e,c)
	local g=c:GetMaterial()
	local tc=g:GetFirst()
	if tc:IsRace(RACE_DRAGON) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- 判定①效果的发动条件：这张卡以龙族怪兽为解放素材上级召唤成功。
function c23770284.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE) and e:GetLabel()==1
end
-- 实现①效果的处理：取解放怪兽的原本攻击力，若原本攻击力小于0则视为0；若大于0，则给这张卡注册攻击力上升效果，上升数值为解放怪兽原本攻击力的一半（向上取整）。
function c23770284.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		local atk=c:GetMaterial():GetFirst():GetTextAttack()
		if atk<0 then atk=0 end
		if atk>0 then
			-- 这张卡的攻击力上升解放的那只怪兽的原本攻击力一半数值。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(math.ceil(atk/2))
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			c:RegisterEffect(e1)
		end
	end
end
-- 判定与这张卡战斗的怪兽的攻击力是否与这张卡的当前攻击力相同，若相同则这张卡不会被那次战斗破坏。
function c23770284.indval(e,c)
	return c:IsAttack(e:GetHandler():GetAttack())
end

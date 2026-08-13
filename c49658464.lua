--無千ジャミング
-- 效果：
-- ①：场上有攻击力1000以上的怪兽存在的场合，怪兽进行战斗的伤害计算时发动。场上的全部怪兽攻击力变成那自身攻击力每有1000则降1000的数值，守备力变成那自身守备力每有1000则降1000的数值。
-- ②：这张卡被破坏的场合发动。场上的全部怪兽直到回合结束时攻击力变成那自身攻击力每有1000则降1000的数值，守备力变成那自身守备力每有1000则降1000的数值。
local s,id,o=GetID()
-- 注册这张卡片的三个效果：e1为通常魔陷发动效果（允许发动），e2为①效果的伤害计算时必发效果，e3为②效果的被破坏时必发效果。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：场上有攻击力1000以上的怪兽存在的场合，怪兽进行战斗的伤害计算时发动。场上的全部怪兽攻击力变成那自身攻击力每有1000则降1000的数值，守备力变成那自身守备力每有1000则降1000的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.atkcon1)
	e2:SetOperation(s.atkop1)
	c:RegisterEffect(e2)
	-- ②：这张卡被破坏的场合发动。场上的全部怪兽直到回合结束时攻击力变成那自身攻击力每有1000则降1000的数值，守备力变成那自身守备力每有1000则降1000的数值。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetOperation(s.atkop2)
	c:RegisterEffect(e3)
end
-- 过滤条件：判定怪兽是否为表侧表示且攻击力在1000以上，用于检测①效果的发动前提。
function s.cfilter(c)
	return c:IsFaceup() and c:IsAttackAbove(1000)
end
-- ①效果的发动条件函数：检查双方场上是否存在至少1只表侧表示且攻击力1000以上的怪兽。
function s.atkcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 执行条件检查：若双方怪兽区存在至少1只满足s.cfilter的怪兽则返回true，允许①效果发动。
	return Duel.IsExistingMatchingCard(s.cfilter,0,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- ①效果处理：获取双方场上全部表侧表示怪兽，对每只怪兽把攻击力变为原攻击力除以1000的余数（即减去1000的倍数），守备力也同理（仅对守备力大于0的怪兽处理）。
function s.atkop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取双方场上所有表侧表示怪兽的集合，作为①效果要改变能力值的对象。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 遍历怪兽集合，逐一对每只怪兽应用攻击力/守备力下降效果。
	for tc in aux.Next(g) do
		-- 攻击力变成那自身攻击力每有1000则降1000的数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(tc:GetAttack()%1000)
		tc:RegisterEffect(e1)
		if tc:IsDefenseAbove(0) then
			local e2=e1:Clone()
			e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
			e2:SetValue(tc:GetDefense()%1000)
			tc:RegisterEffect(e2)
		end
	end
end
-- ②效果处理：获取双方场上全部表侧表示怪兽，将每只怪兽的攻击力变为原攻击力除以1000的余数，守备力也同理，且这些变化持续到回合结束时。
function s.atkop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取双方场上所有表侧表示怪兽的集合，作为②效果要改变能力值的对象。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 遍历怪兽集合，逐一对每只怪兽应用攻击力/守备力下降效果。
	for tc in aux.Next(g) do
		-- 攻击力变成那自身攻击力每有1000则降1000的数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(tc:GetAttack()%1000)
		tc:RegisterEffect(e1)
		if tc:IsDefenseAbove(0) then
			local e2=e1:Clone()
			e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
			e2:SetValue(tc:GetDefense()%1000)
			tc:RegisterEffect(e2)
		end
	end
end

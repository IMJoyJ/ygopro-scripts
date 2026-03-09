--無千ジャミング
-- 效果：
-- ①：场上有攻击力1000以上的怪兽存在的场合，怪兽进行战斗的伤害计算时发动。场上的全部怪兽攻击力变成那自身攻击力每有1000则降1000的数值，守备力变成那自身守备力每有1000则降1000的数值。
-- ②：这张卡被破坏的场合发动。场上的全部怪兽直到回合结束时攻击力变成那自身攻击力每有1000则降1000的数值，守备力变成那自身守备力每有1000则降1000的数值。
local s,id,o=GetID()
-- 初始化卡片效果，注册场地魔法卡的发动条件和两个触发效果
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
-- 过滤函数，用于判断场上是否存在至少一张攻击力不低于1000的表侧怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsAttackAbove(1000)
end
-- 效果条件函数，检查是否满足①效果发动条件（场上有攻击力1000以上的怪兽）
function s.atkcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查以玩家视角在双方主怪兽区是否存在至少一张攻击力不低于1000的表侧怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,0,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- ①效果的处理函数，将场上所有表侧怪兽的攻击力和守备力调整为自身攻击力/守备力对1000取余的结果
function s.atkop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取以玩家视角在双方主怪兽区的所有表侧怪兽组成的卡片组
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 遍历卡片组中的每张怪兽卡
	for tc in aux.Next(g) do
		-- 创建一个临时改变攻击力的效果，将其设置为该怪兽攻击力对1000取余的结果，并在伤害计算时生效
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
-- ②效果的处理函数，将场上所有表侧怪兽的攻击力和守备力调整为自身攻击力/守备力对1000取余的结果，并持续到回合结束
function s.atkop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取以玩家视角在双方主怪兽区的所有表侧怪兽组成的卡片组
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 遍历卡片组中的每张怪兽卡
	for tc in aux.Next(g) do
		-- 创建一个临时改变攻击力的效果，将其设置为该怪兽攻击力对1000取余的结果，并持续到回合结束时生效
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

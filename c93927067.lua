--カイザー・ブラッド・ヴォルス
-- 效果：
-- ①：自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：这张卡战斗破坏对方怪兽的场合发动。这张卡的攻击力上升500。
-- ③：这张卡被战斗破坏的场合发动。让把这张卡破坏的怪兽的攻击力下降500。
function c93927067.initial_effect(c)
	-- ①：自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(93927067,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c93927067.spcon)
	c:RegisterEffect(e1)
	-- ②：这张卡战斗破坏对方怪兽的场合发动。这张卡的攻击力上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(93927067,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	-- 设置发动条件为：这张卡与对方怪兽战斗，且该怪兽被战斗破坏
	e2:SetCondition(aux.bdocon)
	e2:SetOperation(c93927067.atkop)
	c:RegisterEffect(e2)
	-- ③：这张卡被战斗破坏的场合发动。让把这张卡破坏的怪兽的攻击力下降500。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(93927067,2))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetOperation(c93927067.desop)
	c:RegisterEffect(e3)
end
-- 特殊召唤规则的判定条件：自己场上没有怪兽存在，且自身怪兽区域有空位
function c93927067.spcon(e,c)
	if c==nil then return true end
	-- 检查自己场上的怪兽数量是否为0（即自己场上没有怪兽存在）
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
		-- 并且自己场上有可用的怪兽区域空位
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 战斗破坏对方怪兽时的效果处理：使自身攻击力上升500
function c93927067.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的攻击力上升500。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 自身被战斗破坏时的效果处理：使把这张卡破坏的怪兽的攻击力下降500
function c93927067.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	if not tc:IsRelateToBattle() or tc:IsFacedown() then return end
	-- 让把这张卡破坏的怪兽的攻击力下降500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(-500)
	tc:RegisterEffect(e1)
end

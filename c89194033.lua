--聖獣セルケト
-- 效果：
-- ①：自己场上没有「王家的神殿」存在的场合这张卡破坏。
-- ②：这张卡战斗破坏的怪兽不去墓地而除外。
-- ③：这张卡战斗破坏怪兽的场合发动。这张卡的攻击力上升500。
function c89194033.initial_effect(c)
	-- 注册该卡片在卡片效果中记载了「王家的神殿」这一信息
	aux.AddCodeList(c,29762407)
	-- ①：自己场上没有「王家的神殿」存在的场合这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_SELF_DESTROY)
	e1:SetCondition(c89194033.descon)
	c:RegisterEffect(e1)
	-- ②：这张卡战斗破坏的怪兽不去墓地而除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_BATTLE_DESTROY_REDIRECT)
	e2:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e2)
	-- ③：这张卡战斗破坏怪兽的场合发动。这张卡的攻击力上升500。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(89194033,0))  --"攻击上升"
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetCondition(c89194033.atkcon)
	e3:SetOperation(c89194033.atkop)
	c:RegisterEffect(e3)
end
-- 过滤函数：检查卡片是否为表侧表示的「王家的神殿」
function c89194033.desfilter(c)
	return c:IsFaceup() and c:IsCode(29762407)
end
-- 自我破坏效果的触发条件：自己魔陷区不存在表侧表示的「王家的神殿」
function c89194033.descon(e)
	-- 检查自己魔陷区是否存在至少1张表侧表示的「王家的神殿」，若不存在则返回true
	return not Duel.IsExistingMatchingCard(c89194033.desfilter,e:GetHandler():GetControler(),LOCATION_SZONE,0,1,nil)
end
-- 攻击力上升效果的发动条件：此卡在场上表侧表示且与本次战斗相关联
function c89194033.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsFaceup() and e:GetHandler():IsRelateToBattle()
end
-- 攻击力上升效果的执行操作：若此卡仍表侧表示存在，则使其攻击力永久上升500
function c89194033.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 这张卡的攻击力上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(500)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
end

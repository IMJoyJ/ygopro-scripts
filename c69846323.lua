--カンツウツボ
-- 效果：
-- 1回合1次，自己的主要阶段时把这张卡以外的自己场上1只鱼族·海龙族·水族怪兽解放才能发动。这张卡的攻击力上升600。此外，这张卡向守备表示怪兽攻击时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
function c69846323.initial_effect(c)
	-- 1回合1次，自己的主要阶段时把这张卡以外的自己场上1只鱼族·海龙族·水族怪兽解放才能发动。这张卡的攻击力上升600。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(69846323,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c69846323.cost)
	e1:SetOperation(c69846323.operation)
	c:RegisterEffect(e1)
	-- 此外，这张卡向守备表示怪兽攻击时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)
end
-- 过滤条件：是否为鱼族、水族或海龙族怪兽
function c69846323.cfilter(c)
	return c:IsRace(RACE_FISH+RACE_AQUA+RACE_SEASERPENT)
end
-- 发动代价：解放这张卡以外的自己场上1只鱼族·海龙族·水族怪兽
function c69846323.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在除这张卡以外、可解放的鱼族·水族·海龙族怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c69846323.cfilter,1,e:GetHandler()) end
	-- 选择自己场上除这张卡以外的1只鱼族·水族·海龙族怪兽
	local sg=Duel.SelectReleaseGroup(tp,c69846323.cfilter,1,1,e:GetHandler())
	-- 解放选中的怪兽
	Duel.Release(sg,REASON_COST)
end
-- 效果处理：使这张卡的攻击力上升600
function c69846323.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力上升600。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(600)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end

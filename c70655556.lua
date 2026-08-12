--スピア・シャーク
-- 效果：
-- 这张卡召唤成功时，可以让自己场上的全部鱼族·3星怪兽的等级上升1星。这张卡向守备表示怪兽攻击时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
function c70655556.initial_effect(c)
	-- 这张卡召唤成功时，可以让自己场上的全部鱼族·3星怪兽的等级上升1星。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(70655556,0))  --"等级上升"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c70655556.lvtg)
	e1:SetOperation(c70655556.lvop)
	c:RegisterEffect(e1)
	-- 这张卡向守备表示怪兽攻击时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)
end
-- 过滤自己场上表侧表示的鱼族·3星怪兽
function c70655556.filter(c)
	return c:IsFaceup() and c:IsLevel(3) and c:IsRace(RACE_FISH)
end
-- 等级上升效果的发动条件与对象确认
function c70655556.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只表侧表示的鱼族·3星怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c70655556.filter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 等级上升效果的执行，使自己场上全部鱼族·3星怪兽的等级上升1星
function c70655556.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有表侧表示的鱼族·3星怪兽
	local g=Duel.GetMatchingGroup(c70655556.filter,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 等级上升1星
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end

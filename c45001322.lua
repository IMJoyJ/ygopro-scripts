--リブロマンサー・ファイアスターター
-- 效果：
-- 「书灵师」卡降临。
-- ①：使用场上的怪兽作仪式召唤的这张卡不会被效果破坏，不能用效果除外。
-- ②：只要攻击力未满3000的这张卡在怪兽区域存在，每次对方把卡的效果发动，这张卡的攻击力·守备力上升200。
local s,id,o=GetID()
-- 初始化效果函数，注册所有效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- ①：使用场上的怪兽作仪式召唤的这张卡不会被效果破坏，不能用效果除外。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(s.matcheck)
	c:RegisterEffect(e1)
	-- ①：使用场上的怪兽作仪式召唤的这张卡不会被效果破坏，不能用效果除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.matcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ①：使用场上的怪兽作仪式召唤的这张卡不会被效果破坏，不能用效果除外。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_REMOVE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(1,1)
	e3:SetTarget(s.rmlimit)
	e3:SetCondition(s.matcon)
	c:RegisterEffect(e3)
	-- ②：只要攻击力未满3000的这张卡在怪兽区域存在，每次对方把卡的效果发动，这张卡的攻击力·守备力上升200。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetOperation(s.regop)
	c:RegisterEffect(e4)
	-- ②：只要攻击力未满3000的这张卡在怪兽区域存在，每次对方把卡的效果发动，这张卡的攻击力·守备力上升200。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_CHAIN_SOLVED)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(s.atkcon)
	e5:SetOperation(s.atkop)
	c:RegisterEffect(e5)
end
-- 检查是否使用了场上的怪兽作为仪式召唤的素材
function s.matcheck(e,c)
	if c:GetMaterial():IsExists(Card.IsLocation,1,nil,LOCATION_MZONE) then
		local reset=RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD
		c:RegisterFlagEffect(id,reset,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,0))  --"使用场上的怪兽作仪式召唤"
	end
end
-- 判断是否为仪式召唤且使用了场上的怪兽作为素材
function s.matcon(e)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_RITUAL) and c:GetFlagEffect(id)>0
end
-- 限制该卡被效果除外
function s.rmlimit(e,c,tp,r)
	return c==e:GetHandler() and r==REASON_EFFECT
end
-- 记录连锁发动的标志位
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_CHAIN,0,1)
end
-- 判断是否为对方发动效果且攻击力未满3000
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return ep~=tp and c:GetAttack()<3000 and c:GetFlagEffect(id)~=0
end
-- 提升攻击力和守备力各200
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示该卡发动了效果
	Duel.Hint(HINT_CARD,0,id)
	local c=e:GetHandler()
	-- ②：只要攻击力未满3000的这张卡在怪兽区域存在，每次对方把卡的效果发动，这张卡的攻击力·守备力上升200。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(200)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
end

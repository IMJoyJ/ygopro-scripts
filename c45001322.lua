--リブロマンサー・ファイアスターター
-- 效果：
-- 「书灵师」卡降临。
-- ①：使用场上的怪兽作仪式召唤的这张卡不会被效果破坏，不能用效果除外。
-- ②：只要攻击力未满3000的这张卡在怪兽区域存在，每次对方把卡的效果发动，这张卡的攻击力·守备力上升200。
local s,id,o=GetID()
-- 初始化效果注册：为这张卡开启苏生限制（对应「书灵师」卡降临），然后依次注册①的素材检查、效果破坏抗性、不能除外的效果，以及②的触发监听与攻防上升效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 使用场上的怪兽作仪式召唤的
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(s.matcheck)
	c:RegisterEffect(e1)
	-- 这张卡不会被效果破坏
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.matcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 不能用效果除外
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_REMOVE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(1,1)
	e3:SetTarget(s.rmlimit)
	e3:SetCondition(s.matcon)
	c:RegisterEffect(e3)
	-- 每次对方把卡的效果发动
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_CHAINING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetOperation(s.regop)
	c:RegisterEffect(e4)
	-- 只要攻击力未满3000的这张卡在怪兽区域存在，每次对方把卡的效果发动，这张卡的攻击力·守备力上升200。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_CHAIN_SOLVED)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(s.atkcon)
	e5:SetOperation(s.atkop)
	c:RegisterEffect(e5)
end
-- 素材检查：若仪式召唤所用的素材中存在来自场上的怪兽，则为这张卡注册一个标志（含客户端提示），用于标记其满足'使用场上的怪兽作仪式召唤'的条件。
function s.matcheck(e,c)
	if c:GetMaterial():IsExists(Card.IsLocation,1,nil,LOCATION_MZONE) then
		local reset=RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD
		c:RegisterFlagEffect(id,reset,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,0))  --"使用场上的怪兽作仪式召唤"
	end
end
-- 抗性适用条件：这张卡必须是仪式召唤出场，且拥有之前记录的使用过场上怪兽为素材的标志，才适用①的效果破坏抗性和不能除外的效果。
function s.matcon(e)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_RITUAL) and c:GetFlagEffect(id)>0
end
-- 不能除外的限制对象判定：仅当要被除外的卡是这张卡自身，且除外的原因是效果时，才禁止该除外操作。
function s.rmlimit(e,c,tp,r)
	return c==e:GetHandler() and r==REASON_EFFECT
end
-- 监听连锁处理：每当有卡的效果发动时，给这张卡注册一个单纯的标志，该标志会在连锁结束后重置；此标志用于记录'刚刚有效果发动'，以便后续判断②是否满足对方发动效果的条件。
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_CHAIN,0,1)
end
-- ②效果的触发条件：本次连锁的效果发动者是对方，这张卡当前的攻击力未满3000，且之前已记录到有效果发动的标志；条件满足时执行攻防上升。
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return ep~=tp and c:GetAttack()<3000 and c:GetFlagEffect(id)~=0
end
-- 执行②的攻防上升：将这张卡的攻击力和守备力各上升200，生成两个数值变化效果并注册（随标准重置和效果无效而失效）。
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 向双方展示这张卡的卡片动画，提示正在处理②的攻防上升效果（不入连锁）。
	Duel.Hint(HINT_CARD,0,id)
	local c=e:GetHandler()
	-- 攻击力上升200
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

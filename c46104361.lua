--サイバース・ホワイトハット
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次。
-- ①：自己场上有相同种族的怪兽2只以上存在的场合，这张卡可以从手卡特殊召唤。
-- ②：这张卡作为连接素材送去墓地的场合才能发动。对方场上的全部怪兽的攻击力直到回合结束时下降1000。
function c46104361.initial_effect(c)
	-- 效果原文：①：自己场上有相同种族的怪兽2只以上存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(46104361,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,46104361+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c46104361.spcon)
	c:RegisterEffect(e1)
	-- 效果原文：②：这张卡作为连接素材送去墓地的场合才能发动。对方场上的全部怪兽的攻击力直到回合结束时下降1000。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(46104361,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCondition(c46104361.atkcon)
	e2:SetTarget(c46104361.atktg)
	e2:SetOperation(c46104361.atkop)
	c:RegisterEffect(e2)
end
-- 规则层面：用于判断场上是否存在相同种族的怪兽，以满足特殊召唤条件。
function c46104361.filter(c,tp,race)
	if c:IsFacedown() then return false end
	if not race then
		-- 规则层面：检查自己场上是否存在至少1只与指定种族相同的怪兽。
		return Duel.IsExistingMatchingCard(c46104361.filter,tp,LOCATION_MZONE,0,1,c,tp,c:GetRace())
	else
		return c:IsRace(race)
	end
end
-- 规则层面：设置特殊召唤的触发条件，包括场地空位和种族条件。
function c46104361.spcon(e,c)
	if c==nil then return true end
	-- 规则层面：检查自己场上是否有足够的怪兽区域用于特殊召唤。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 规则层面：检查自己场上是否存在至少1只与指定种族相同的怪兽。
		and Duel.IsExistingMatchingCard(c46104361.filter,c:GetControler(),LOCATION_MZONE,0,1,nil,c:GetControler())
end
-- 规则层面：设置效果发动的条件，即此卡作为连接素材被送入墓地时。
function c46104361.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and r==REASON_LINK
end
-- 规则层面：设置效果的发动目标，检查对方场上是否存在至少1只表侧表示的怪兽。
function c46104361.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面：检查对方场上是否存在至少1只表侧表示的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
end
-- 规则层面：执行效果，将所有对方场上的表侧表示怪兽的攻击力下降1000点。
function c46104361.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：获取对方场上所有表侧表示的怪兽组成一个卡片组。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		-- 规则层面：为每个对方场上的表侧表示怪兽添加一个攻击力减少1000的效果，持续到回合结束。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end

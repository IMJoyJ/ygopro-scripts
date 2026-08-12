--キウイ・マジシャン・ガール
-- 效果：
-- ①：把这张卡从手卡丢弃才能发动。自己场上的「魔术少女」怪兽的攻击力·守备力直到回合结束时上升双方的场上·墓地的「魔术少女」怪兽种类×300。这个效果在对方回合也能发动。
-- ②：只要这张卡在怪兽区域存在，自己场上的魔法师族怪兽不会被效果破坏，不会成为对方的效果的对象。
function c82627406.initial_effect(c)
	-- ①：把这张卡从手卡丢弃才能发动。自己场上的「魔术少女」怪兽的攻击力·守备力直到回合结束时上升双方的场上·墓地的「魔术少女」怪兽种类×300。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(82627406,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置效果在伤害步骤中仅在伤害计算前可以发动
	e1:SetCondition(aux.dscon)
	e1:SetCost(c82627406.cost)
	e1:SetTarget(c82627406.target)
	e1:SetOperation(c82627406.operation)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，自己场上的魔法师族怪兽不会被效果破坏
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	-- 设置效果影响的对象为自己场上的魔法师族怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_SPELLCASTER))
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	-- 设置不会成为对方的效果的对象
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
end
-- 效果①的发动代价（Cost）函数，检查并执行丢弃自身
function c82627406.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 将自身作为发动代价丢弃送去墓地
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 过滤自己场上表侧表示的「魔术少女」怪兽
function c82627406.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x20a2)
end
-- 效果①的发动目标（Target）函数，检查自己场上是否存在符合条件的怪兽
function c82627406.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动准备阶段，检查自己场上是否存在至少1只表侧表示的「魔术少女」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c82627406.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 过滤双方场上表侧表示或墓地中的「魔术少女」怪兽卡
function c82627406.ctfilter(c)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x20a2)
end
-- 效果①的运行效果（Operation）函数，计算怪兽种类并提升自己场上「魔术少女」怪兽的攻击力和守备力
function c82627406.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有表侧表示的「魔术少女」怪兽
	local tg=Duel.GetMatchingGroup(c82627406.atkfilter,tp,LOCATION_MZONE,0,nil)
	-- 获取双方场上表侧表示及墓地中的所有「魔术少女」怪兽
	local g=Duel.GetMatchingGroup(c82627406.ctfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,nil)
	if tg:GetCount()>0 and g:GetCount()>0 then
		local d=g:GetClassCount(Card.GetCode)*300
		local sc=tg:GetFirst()
		while sc do
			-- 攻击力……直到回合结束时上升双方的场上·墓地的「魔术少女」怪兽种类×300
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e1:SetValue(d)
			sc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_UPDATE_DEFENSE)
			sc:RegisterEffect(e2)
			sc=tg:GetNext()
		end
	end
end

--防覇龍ヘリオスフィア
-- 效果：
-- 对方手卡是4张以下而自己场上的怪兽只有这张卡的场合，对方不能攻击宣言。此外，1回合1次，自己场上有龙族·8星怪兽存在的场合才能发动。这张卡的等级直到结束阶段时变成8星。
function c51043053.initial_effect(c)
	-- 对方手卡是4张以下而自己场上的怪兽只有这张卡的场合，对方不能攻击宣言。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetCondition(c51043053.atcon)
	c:RegisterEffect(e1)
	-- 1回合1次，自己场上有龙族·8星怪兽存在的场合才能发动。这张卡的等级直到结束阶段时变成8星。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(51043053,0))  --"等级变化"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c51043053.condition)
	e2:SetOperation(c51043053.operation)
	c:RegisterEffect(e2)
end
-- 检查是否满足效果发动条件：自己场上只有这张卡且对方手牌少于5张。
function c51043053.atcon(e)
	-- 检查自己场上是否只有1只怪兽。
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_MZONE,0)==1
		-- 检查对方手牌数量是否少于5张。
		and Duel.GetFieldGroupCount(e:GetHandlerPlayer(),0,LOCATION_HAND)<5
end
-- 过滤函数，用于筛选场上表侧表示的8星龙族怪兽。
function c51043053.filter(c)
	return c:IsFaceup() and c:IsLevel(8) and c:IsRace(RACE_DRAGON)
end
-- 检查是否满足等级变化效果发动条件：当前等级不是8星且自己场上存在至少1只8星龙族怪兽。
function c51043053.condition(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsLevel(8)
		-- 检查自己场上是否存在至少1只8星龙族怪兽。
		and Duel.IsExistingMatchingCard(c51043053.filter,tp,LOCATION_MZONE,0,1,nil)
end
-- 执行等级变化效果：将自身等级变为8星并设置在结束阶段重置。
function c51043053.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 设置自身等级变为8星的效果，并在结束阶段重置。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(8)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end

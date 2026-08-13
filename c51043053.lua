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
	-- 此外，1回合1次，自己场上有龙族·8星怪兽存在的场合才能发动。这张卡的等级直到结束阶段时变成8星。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(51043053,0))  --"等级变化"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c51043053.condition)
	e2:SetOperation(c51043053.operation)
	c:RegisterEffect(e2)
end
-- 效果1的适用条件：判断自己场上怪兽只有这张卡且对方手卡为4张以下时才允许封锁对方攻击宣言。
function c51043053.atcon(e)
	-- 统计该效果控制者自己场上怪兽区的卡数，判定是否只有这张卡（数量为1）。
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_MZONE,0)==1
		-- 统计对方手牌数量，判定是否在4张以下（小于5）。
		and Duel.GetFieldGroupCount(e:GetHandlerPlayer(),0,LOCATION_HAND)<5
end
-- 定义筛选器：用于检查怪兽是否表侧表示、等级为8且种族为龙族，作为“龙族·8星怪兽”的判定条件。
function c51043053.filter(c)
	return c:IsFaceup() and c:IsLevel(8) and c:IsRace(RACE_DRAGON)
end
-- 效果2的发动条件：这张卡自身当前不是8星，且自己场上有满足filter的龙族·8星怪兽存在。
function c51043053.condition(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsLevel(8)
		-- 检查自己场上是否存在至少1只表侧表示·等级8·龙族的怪兽，即满足“自己场上有龙族·8星怪兽存在”。
		and Duel.IsExistingMatchingCard(c51043053.filter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果2处理：若这张卡仍在场上且表侧表示，赋予它一个将等级变成8的临时效果，该效果持续到结束阶段并随离场等情况重置。
function c51043053.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的等级直到结束阶段时变成8星。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(8)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end

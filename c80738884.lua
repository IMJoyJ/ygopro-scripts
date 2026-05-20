--VS 龍帝ノ槍
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有「征服斗魂」怪兽存在，自己场上的卡为对象的怪兽的效果·魔法·陷阱卡由对方发动时才能发动。那个发动无效并破坏。那之后，可以选自己场上1只「征服斗魂」怪兽给与对方那个攻击力数值的伤害。
function c80738884.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上有「征服斗魂」怪兽存在，自己场上的卡为对象的怪兽的效果·魔法·陷阱卡由对方发动时才能发动。那个发动无效并破坏。那之后，可以选自己场上1只「征服斗魂」怪兽给与对方那个攻击力数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,80738884+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c80738884.condition)
	e1:SetTarget(c80738884.target)
	e1:SetOperation(c80738884.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的「征服斗魂」怪兽
function c80738884.cfilter1(c)
	return c:IsFaceup() and c:IsSetCard(0x195)
end
-- 过滤条件：自己场上的卡
function c80738884.cfilter2(c,tp)
	return c:IsOnField() and c:IsControler(tp)
end
-- 检查发动条件：对方发动了以自己场上的卡为对象的怪兽效果或魔法·陷阱卡的发动，且自己场上有「征服斗魂」怪兽存在，该连锁的发动可以被无效
function c80738884.condition(e,tp,eg,ep,ev,re,r,rp)
	if rp~=1-tp or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	if not re:IsActiveType(TYPE_MONSTER) and not re:IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	-- 获取当前连锁的对象卡片组
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 检查对象中是否存在自己场上的卡，且该连锁的发动可以被无效
	return tg and tg:IsExists(c80738884.cfilter2,1,nil,tp) and Duel.IsChainNegatable(ev)
		-- 检查自己场上是否存在表侧表示的「征服斗魂」怪兽
		and Duel.IsExistingMatchingCard(c80738884.cfilter1,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果发动时的目标处理：设置无效与破坏的操作信息
function c80738884.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将该发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：破坏该卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 过滤条件：自己场上表侧表示且攻击力大于0的「征服斗魂」怪兽
function c80738884.dmgfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x195) and c:GetAttack()>0
end
-- 效果处理：使发动无效并破坏，之后可选择给与对方伤害
function c80738884.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试使该连锁的发动无效
	if Duel.NegateActivation(ev)
		-- 若无效成功，且该卡在场，则将其破坏
		and re:GetHandler():IsRelateToEffect(re) and Duel.Destroy(eg,REASON_EFFECT)>0
		-- 检查自己场上是否存在符合伤害效果条件的「征服斗魂」怪兽
		and Duel.IsExistingMatchingCard(c80738884.dmgfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 询问玩家是否选择给与对方伤害
		and Duel.SelectYesNo(tp,aux.Stringid(80738884,1)) then  --"是否选怪兽给与对方伤害？"
		-- 中断当前效果，使后续的伤害处理与前面的破坏处理不视为同时进行
		Duel.BreakEffect()
		-- 提示玩家选择一张表侧表示的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		-- 玩家选择自己场上1只表侧表示的「征服斗魂」怪兽
		local g=Duel.SelectMatchingCard(tp,c80738884.dmgfilter,tp,LOCATION_MZONE,0,1,1,nil)
		-- 给与对方该怪兽攻击力数值的伤害
		Duel.Damage(1-tp,g:GetFirst():GetAttack(),REASON_EFFECT)
	end
end

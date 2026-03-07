--不朽の特殊合金
-- 效果：
-- ①：自己场上有「人造人-念力震慑者」存在的场合，可以从以下效果选择1个发动。
-- ●自己场上的全部机械族怪兽直到回合结束时不会被对方的效果破坏。
-- ●自己场上的机械族怪兽为对象的魔法·陷阱·怪兽的效果发动时才能发动。那个效果无效。
function c37042505.initial_effect(c)
	-- 记录此卡具有「人造人-念力震慑者」的卡片密码
	aux.AddCodeList(c,77585513)
	-- 自己场上有「人造人-念力震慑者」存在的场合，可以从以下效果选择1个发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37042505,0))  --"破坏耐性"
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c37042505.condition1)
	e1:SetCost(c37042505.target1)
	e1:SetOperation(c37042505.activate1)
	c:RegisterEffect(e1)
	-- 自己场上的机械族怪兽为对象的魔法·陷阱·怪兽的效果发动时才能发动。那个效果无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(37042505,1))  --"效果无效"
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCondition(c37042505.condition2)
	e2:SetTarget(c37042505.target2)
	e2:SetOperation(c37042505.activate2)
	c:RegisterEffect(e2)
end
-- 用于判断场上是否存在「人造人-念力震慑者」
function c37042505.cfilter(c)
	return c:IsCode(77585513) and c:IsFaceup()
end
-- 判断自己场上是否存在「人造人-念力震慑者」
function c37042505.condition1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张「人造人-念力震慑者」
	return Duel.IsExistingMatchingCard(c37042505.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 用于筛选场上存在的机械族怪兽
function c37042505.filter1(c)
	return c:IsRace(RACE_MACHINE) and c:IsFaceup()
end
-- 准备发动第一个效果，检查自己场上是否存在至少1张机械族怪兽
function c37042505.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1张机械族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c37042505.filter1,tp,LOCATION_MZONE,0,1,nil) end
	-- 向对方提示发动了第一个效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 使所有场上机械族怪兽直到回合结束时不会被对方的效果破坏
function c37042505.activate1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有机械族怪兽的卡片组
	local g=Duel.GetMatchingGroup(c37042505.filter1,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 为每个机械族怪兽添加不会被对方效果破坏的效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(c37042505.indoval)
		e1:SetOwnerPlayer(tp)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
-- 设定效果值，使该效果只对对方玩家的效果无效
function c37042505.indoval(e,re,rp)
	return rp==1-e:GetOwnerPlayer()
end
-- 用于筛选场上机械族怪兽作为效果对象
function c37042505.filter2(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsRace(RACE_MACHINE)
end
-- 判断是否满足发动第二个效果的条件
function c37042505.condition2(e,tp,eg,ep,ev,re,r,rp)
	if not c37042505.condition1(e,tp,eg,ep,ev,re,r,rp) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁的效果对象卡片组
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 检查连锁效果是否可以被无效且对象组中存在机械族怪兽
	return tg and Duel.IsChainDisablable(ev) and tg:IsExists(c37042505.filter2,1,nil,tp)
end
-- 准备发动第二个效果，设置操作信息并提示发动
function c37042505.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向对方提示发动了第二个效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息，表示将要使效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 使当前连锁的效果无效
function c37042505.activate2(e,tp,eg,ep,ev,re,r,rp)
	-- 使当前连锁的效果无效
	Duel.NegateEffect(ev)
end

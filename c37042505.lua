--不朽の特殊合金
-- 效果：
-- ①：自己场上有「人造人-念力震慑者」存在的场合，可以从以下效果选择1个发动。
-- ●自己场上的全部机械族怪兽直到回合结束时不会被对方的效果破坏。
-- ●自己场上的机械族怪兽为对象的魔法·陷阱·怪兽的效果发动时才能发动。那个效果无效。
function c37042505.initial_effect(c)
	-- 将卡号77585513（人造人-念力震慑者）登记到本卡的卡名列表中，使本卡在规则上被视为记载有该卡名。
	aux.AddCodeList(c,77585513)
	-- ●自己场上的全部机械族怪兽直到回合结束时不会被对方的效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37042505,0))  --"破坏耐性"
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c37042505.condition1)
	e1:SetCost(c37042505.target1)
	e1:SetOperation(c37042505.activate1)
	c:RegisterEffect(e1)
	-- ●自己场上的机械族怪兽为对象的魔法·陷阱·怪兽的效果发动时才能发动。那个效果无效。
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
-- 筛选函数：判断卡片是否为「人造人-念力震慑者」且处于表侧表示，用于后续发动条件检查。
function c37042505.cfilter(c)
	return c:IsCode(77585513) and c:IsFaceup()
end
-- 第一个效果的发动条件：自己场上存在表侧表示的「人造人-念力震慑者」。该条件也被第二个效果复用。
function c37042505.condition1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上（LOCATION_ONFIELD）是否存在至少1张满足cfilter的卡（即表侧表示的「人造人-念力震慑者」）。
	return Duel.IsExistingMatchingCard(c37042505.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 筛选函数：判断怪兽是否为自己场上表侧表示的机械族怪兽，用于选择要附加破坏耐性的对象。
function c37042505.filter1(c)
	return c:IsRace(RACE_MACHINE) and c:IsFaceup()
end
-- 第一个效果的cost函数：发动前确认自己场上存在表侧机械族怪兽，并向对方提示“选择了破坏耐性”这个效果。
function c37042505.target1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在cost合法性检查（chk==0）时，确认自己场上主要怪兽区存在至少1只表侧机械族怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c37042505.filter1,tp,LOCATION_MZONE,0,1,nil) end
	-- 向对方玩家发送提示，告知其“选择了这个效果”，提示文本来自e:GetDescription()。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 第一个效果处理：取得自己场上全部表侧机械族怪兽，为每只怪兽赋予“不会被对方的效果破坏”的效果，持续到回合结束。
function c37042505.activate1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有满足filter1（表侧机械族）的怪兽集合。
	local g=Duel.GetMatchingGroup(c37042505.filter1,tp,LOCATION_MZONE,0,nil)
	local tc=g:GetFirst()
	while tc do
		-- 自己场上的全部机械族怪兽直到回合结束时不会被对方的效果破坏。
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
-- 判定“破坏耐性”是否适用：当破坏效果的发动者rp是本效果所有者（e:GetOwnerPlayer()）的对手时返回true，即只有对方的效果破坏才被无效，自己或第三方的破坏不受保护。
function c37042505.indoval(e,re,rp)
	return rp==1-e:GetOwnerPlayer()
end
-- 筛选函数：判断卡是否为自己场上表侧表示的机械族怪兽，用于检查对方发动的取对象效果是否以我方机械族怪兽为对象。
function c37042505.filter2(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsRace(RACE_MACHINE)
end
-- 第二个效果的发动条件：自己场上存在「人造人-念力震慑者」，且对方发动的效果是取对象效果、可被无效，并且其对象中包含我方表侧机械族怪兽。
function c37042505.condition2(e,tp,eg,ep,ev,re,r,rp)
	if not c37042505.condition1(e,tp,eg,ep,ev,re,r,rp) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 从连锁信息中取得对方发动的效果的对象卡组（CHAININFO_TARGET_CARDS），用于后续检查对象中是否有我方机械族怪兽。
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 返回判断结果：对象卡组存在且连锁效果可被无效，且对象卡组中存在至少1张我方表侧机械族怪兽，满足这些条件本卡才能发动。
	return tg and Duel.IsChainDisablable(ev) and tg:IsExists(c37042505.filter2,1,nil,tp)
end
-- 第二个效果的target函数：合法性检查通过后，向对方提示选择了“效果无效”，并设置操作信息标记本次无效效果。
function c37042505.target2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向对方玩家发送提示，告知其“选择了‘效果无效’”。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置当前连锁的操作信息：效果分类为CATEGORY_DISABLE（无效效果），操作对象为eg（触发发动的连锁效果），数量为1，用于相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 第二个效果处理：执行使对方发动的那个取对象效果无效的操作。
function c37042505.activate2(e,tp,eg,ep,ev,re,r,rp)
	-- 使连锁序号ev对应的效果无效，即直接无效对方发动的魔法·陷阱·怪兽的效果。
	Duel.NegateEffect(ev)
end

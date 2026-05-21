--直通断線
-- 效果：
-- ①：和这张卡相同纵列有怪兽的效果·魔法·陷阱卡发动时才能把盖放的这张卡发动。那个发动无效并破坏。
function c88086137.initial_effect(c)
	-- ①：和这张卡相同纵列有怪兽的效果·魔法·陷阱卡发动时才能把盖放的这张卡发动。那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c88086137.condition)
	e1:SetTarget(c88086137.target)
	e1:SetOperation(c88086137.activate)
	c:RegisterEffect(e1)
end
-- 检查发动效果的卡是否与本卡在同一纵列，且该效果是怪兽效果或魔陷卡的发动，并且该发动可以被无效
function c88086137.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的发动位置（区域）、格子编号以及控制者
	local loc,seq,p=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION,CHAININFO_TRIGGERING_SEQUENCE,CHAININFO_TRIGGERING_CONTROLER)
	local col=0
	if loc&LOCATION_MZONE~=0 then
		-- 将怪兽区域的格子编号转换为标准的纵列索引
		col=aux.MZoneSequence(seq)
	elseif loc&LOCATION_SZONE~=0 then
		if seq>4 then return false end
		-- 将魔法与陷阱区域的格子编号转换为标准的纵列索引
		col=aux.SZoneSequence(seq)
	else
		return false
	end
	if p==1-tp then col=4-col end
	-- 判断发动效果的卡是否与本卡在同一纵列，且该效果是怪兽效果或魔法·陷阱卡的发动
	return aux.GetColumn(c,tp)==col	and (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE))
		-- 判断该连锁的发动是否可以被无效
		and Duel.IsChainNegatable(ev)
end
-- 设置效果处理的信息，声明该效果包含“使发动无效”和“破坏”的操作
function c88086137.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表明该效果会使该连锁的发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 若发动效果的卡可以被破坏且仍存在于关联状态，则设置操作信息，表明该效果会破坏该卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 执行效果处理，尝试无效该连锁的发动，若成功则将其破坏
function c88086137.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 如果成功使该连锁的发动无效，且发动效果的卡仍与该效果关联
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将该发动被无效的卡破坏
		Duel.Destroy(eg,REASON_EFFECT)
	end
end

--ヌメロン・ストーム
-- 效果：
-- ①：自己场上有「原数天灵」怪兽存在的场合才能发动。对方场上的魔法·陷阱卡全部破坏，给与对方1000伤害。
function c20936251.initial_effect(c)
	-- 创建效果，设置效果分类为破坏和伤害，类型为发动效果，触发条件为自由时点，条件函数为descon，目标函数为destg，效果处理函数为desop
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c20936251.descon)
	e1:SetTarget(c20936251.destg)
	e1:SetOperation(c20936251.desop)
	c:RegisterEffect(e1)
end
-- 过滤函数，检查是否为表侧表示的「原数天灵」怪兽
function c20936251.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x169)
end
-- 效果发动条件函数，检查自己场上是否存在「原数天灵」怪兽
function c20936251.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查以自己为视角的怪兽区域是否存在至少1张满足cfilter条件的卡
	return Duel.IsExistingMatchingCard(c20936251.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤函数，检查是否为魔法或陷阱卡
function c20936251.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果目标设定函数，检查对方场上是否存在魔法或陷阱卡，若存在则设置破坏和伤害的操作信息
function c20936251.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断是否为准备阶段，若为准备阶段则检查对方场上是否存在魔法或陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c20936251.desfilter,tp,0,LOCATION_ONFIELD,1,c) end
	-- 获取对方场上所有满足desfilter条件的卡组成的组
	local sg=Duel.GetMatchingGroup(c20936251.desfilter,tp,0,LOCATION_ONFIELD,c)
	-- 设置操作信息，将破坏的卡组和数量记录到当前连锁中
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
	-- 设置操作信息，将给与对方1000伤害的信息记录到当前连锁中
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
-- 效果处理函数，获取对方场上所有魔法或陷阱卡并破坏，若成功破坏则给与对方1000伤害
function c20936251.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有满足desfilter条件的卡组成的组，排除当前卡
	local sg=Duel.GetMatchingGroup(c20936251.desfilter,tp,0,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	-- 执行破坏操作，若成功破坏至少1张卡则继续执行伤害效果
	if Duel.Destroy(sg,REASON_EFFECT)>0 then
		-- 给与对方1000点伤害，伤害原因为效果
		Duel.Damage(1-tp,1000,REASON_EFFECT)
	end
end

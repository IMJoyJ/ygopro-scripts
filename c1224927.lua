--邪神の大災害
-- 效果：
-- ①：对方怪兽的攻击宣言时才能发动。场上的魔法·陷阱卡全部破坏。
function c1224927.initial_effect(c)
	-- ①：对方怪兽的攻击宣言时才能发动。场上的魔法·陷阱卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c1224927.condition)
	e1:SetTarget(c1224927.target)
	e1:SetOperation(c1224927.activate)
	c:RegisterEffect(e1)
end
-- 判断是否为对方回合
function c1224927.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 若当前回合玩家不是发动者，则满足条件
	return Duel.GetTurnPlayer()~=tp
end
-- 过滤函数，用于筛选魔法或陷阱卡
function c1224927.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 设置效果的发动条件
function c1224927.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查场上是否存在魔法或陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c1224927.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
	-- 获取场上所有魔法或陷阱卡
	local sg=Duel.GetMatchingGroup(c1224927.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
	-- 设置破坏效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 设置效果的发动时点
function c1224927.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有魔法或陷阱卡（排除此卡）
	local sg=Duel.GetMatchingGroup(c1224927.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	-- 将场上所有魔法或陷阱卡破坏
	Duel.Destroy(sg,REASON_EFFECT)
end

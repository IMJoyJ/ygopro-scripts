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
-- 条件函数：检测当前能否发动，要求处于对方回合（攻击宣言由对方怪兽发出）。
function c1224927.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家不是本卡控制者，确保只在对方回合发动。
	return Duel.GetTurnPlayer()~=tp
end
-- 筛选函数：选出场上所有的魔法·陷阱卡。
function c1224927.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 目标处理：确认存在可破坏的魔法·陷阱卡后，将场上除本卡外的所有魔法·陷阱卡作为破坏对象，并写入操作信息。
function c1224927.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在发动合法性检查时，确认场上是否存在除本卡以外的魔法·陷阱卡，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c1224927.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
	-- 获取场上除本卡以外的所有魔法·陷阱卡，作为准备破坏的对象集合。
	local sg=Duel.GetMatchingGroup(c1224927.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
	-- 设置操作信息：声明要破坏的卡片集合及数量，供后续效果处理和相关连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 效果处理：实际执行破坏，重新选取场上除本卡外的所有魔法·陷阱卡并全部破坏。
function c1224927.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时，获取场上除本卡以外的所有魔法·陷阱卡，作为实际破坏对象。
	local sg=Duel.GetMatchingGroup(c1224927.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	-- 以效果破坏的方式将这些卡片全部破坏。
	Duel.Destroy(sg,REASON_EFFECT)
end

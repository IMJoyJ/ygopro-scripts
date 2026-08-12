--スカル・マイスター
-- 效果：
-- ①：对方墓地有魔法·陷阱·怪兽的效果发动时，把这张卡从手卡送去墓地才能发动。那个效果无效。
function c67750322.initial_effect(c)
	-- ①：对方墓地有魔法·陷阱·怪兽的效果发动时，把这张卡从手卡送去墓地才能发动。那个效果无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(67750322,0))  --"墓地的卡发动的效果无效"
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c67750322.discon)
	e1:SetCost(c67750322.discost)
	e1:SetTarget(c67750322.distg)
	e1:SetOperation(c67750322.disop)
	c:RegisterEffect(e1)
end
-- 判断是否满足发动条件：对方在墓地发动可以被无效的效果
function c67750322.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取触发该连锁的效果的发动位置
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	-- 返回是否满足：发动玩家是对方、该效果可以被无效、且发动位置在墓地
	return ep~=tp and Duel.IsChainDisablable(ev) and loc==LOCATION_GRAVE
end
-- 检查并执行发动代价：把这张卡从手卡送去墓地
function c67750322.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将这张卡作为代价送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 设置效果无效的连锁目标和操作信息
function c67750322.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息为使该连锁的效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 执行效果处理：使该效果无效
function c67750322.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使该连锁的效果无效
	Duel.NegateEffect(ev)
end

--大革命返し
-- 效果：
-- ①：要让场上的卡2张以上破坏的怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效并除外。
function c99188141.initial_effect(c)
	-- ①：要让场上的卡2张以上破坏的怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效并除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c99188141.condition)
	-- 设置效果的发动时目标选择函数，用于锁定被连锁的那次效果，并声明对其发动无效和除外的意图。
	e1:SetTarget(aux.nbtg)
	e1:SetOperation(c99188141.activate)
	c:RegisterEffect(e1)
end
-- 发动条件判断：若被连锁的效果既不是怪兽效果，也不是魔法·陷阱卡的发动，或者该连锁不能被无效，则本卡不能发动；后续还需满足破坏场上2张以上卡的条件。
function c99188141.condition(e,tp,eg,ep,ev,re,r,rp)
	if (not re:IsActiveType(TYPE_MONSTER) and not re:IsHasType(EFFECT_TYPE_ACTIVATE))
		-- 附加条件：若该连锁效果的发动不能被无效，则本卡不能发动。
		or not Duel.IsChainNegatable(ev) then return false end
	-- 获取被连锁效果中是否存在破坏效果及其破坏对象/数量，用于判断是否满足“场上的卡2张以上破坏”这一发动条件。
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	return ex and tg~=nil and tc+tg:FilterCount(Card.IsOnField,nil)-tg:GetCount()>1
end
-- 效果处理：先无效该连锁的发动，若成功且该效果来源卡仍与效果关联，则将该卡表侧表示除外。
function c99188141.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若该连锁的发动被成功无效，且发动效果的卡仍与那个效果保持关联，则继续执行后续的除外操作。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将发动无效的那张卡以表侧表示除外，除外原因视为效果。
		Duel.Remove(re:GetHandler(),POS_FACEUP,REASON_EFFECT)
	end
end

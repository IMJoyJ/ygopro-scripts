--透破抜き
-- 效果：
-- ①：手卡·墓地有怪兽的效果发动时才能发动。那个发动无效并除外。
function c65703851.initial_effect(c)
	-- ①：手卡·墓地有怪兽的效果发动时才能发动。那个发动无效并除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c65703851.condition)
	-- 设置效果的目标检查函数为无效并除外的辅助函数
	e1:SetTarget(aux.nbtg)
	e1:SetOperation(c65703851.activate)
	c:RegisterEffect(e1)
end
-- 发动条件：手卡或墓地的怪兽效果发动，且该发动可以被无效
function c65703851.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中触发效果的卡片所在的位置
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	-- 判断触发位置是否为手卡或墓地，且触发的效果是否为怪兽效果，并且该发动可以被无效
	return (loc==LOCATION_HAND or loc==LOCATION_GRAVE) and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
-- 效果处理：使该发动无效，并将其除外
function c65703851.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 如果成功无效了该发动，并且该卡片与该效果仍有关联
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将触发效果的卡片以表侧表示除外
		Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
	end
end

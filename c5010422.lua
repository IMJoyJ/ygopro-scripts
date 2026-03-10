--占術姫ウィジャモリガン
-- 效果：
-- ①：这张卡反转的场合发动。那个回合的结束阶段把对方场上的守备表示怪兽全部破坏，给与对方破坏的怪兽数量×500伤害。
function c5010422.initial_effect(c)
	-- ①：这张卡反转的场合发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetOperation(c5010422.flipop)
	c:RegisterEffect(e1)
end
-- 在反转时将一个持续到结束阶段的效果注册给玩家，用于触发后续处理。
function c5010422.flipop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 那个回合的结束阶段把对方场上的守备表示怪兽全部破坏，给与对方破坏的怪兽数量×500伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetOperation(c5010422.desop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册给全局环境，使其在指定玩家的回合中生效。
	Duel.RegisterEffect(e1,tp)
end
-- 定义一个过滤函数，用于判断目标是否为守备表示的怪兽。
function c5010422.desfilter(c)
	return c:IsDefensePos()
end
-- 检索对方场上所有守备表示的怪兽，并对这些怪兽进行破坏和伤害计算。
function c5010422.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有守备表示的怪兽数量。
	local g=Duel.GetMatchingGroup(c5010422.desfilter,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 向玩家发送提示信息，显示该卡发动了效果。
		Duel.Hint(HINT_CARD,0,5010422)
		-- 将满足条件的怪兽全部破坏。
		local ct=Duel.Destroy(g,REASON_EFFECT)
		-- 根据被破坏怪兽数量给予对方相应伤害。
		Duel.Damage(1-tp,ct*500,REASON_EFFECT)
	end
end

--占術姫ウィジャモリガン
-- 效果：
-- ①：这张卡反转的场合发动。那个回合的结束阶段把对方场上的守备表示怪兽全部破坏，给与对方破坏的怪兽数量×500伤害。
function c5010422.initial_effect(c)
	-- ①：这张卡反转的场合发动。那个回合的结束阶段把对方场上的守备表示怪兽全部破坏，给与对方破坏的怪兽数量×500伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetOperation(c5010422.flipop)
	c:RegisterEffect(e1)
end
-- 反转时从效果e中取得此卡，然后创建一个场地持续效果：监听结束阶段，设置一回合一次，操作函数为desop，并在结束阶段结束时重置；将该效果注册给当前回合玩家tp，以便这张卡反转后的那个结束阶段执行后续破坏与伤害处理。
function c5010422.flipop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 那个回合的结束阶段把对方场上的守备表示怪兽全部破坏，给与对方破坏的怪兽数量×500伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetOperation(c5010422.desop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将上述延迟的场地持续效果e1注册到当前回合玩家tp名下，使该效果在tp的结束阶段满足条件时触发并执行desop。
	Duel.RegisterEffect(e1,tp)
end
-- 过滤函数：判断怪兽c是否为守备表示（IsDefensePos）。
function c5010422.desfilter(c)
	return c:IsDefensePos()
end
-- 结束阶段处理函数：获取对方场上所有守备表示怪兽；若存在，则展示本卡动画，将这些怪兽全部破坏，并按实际破坏数量×500给对方玩家造成效果伤害。
function c5010422.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 以tp为视角，获取对方怪兽区（LOCATION_MZONE）中所有满足desfilter（守备表示）的怪兽，nil表示不排除任何卡。
	local g=Duel.GetMatchingGroup(c5010422.desfilter,tp,0,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 向双方展示卡号为5010422的卡片发动动画，用于提示正在执行此卡的效果处理。
		Duel.Hint(HINT_CARD,0,5010422)
		-- 以效果原因（REASON_EFFECT）将集合g中的怪兽全部破坏，返回实际被破坏的数量ct。
		local ct=Duel.Destroy(g,REASON_EFFECT)
		-- 给对方玩家（1-tp）造成ct×500点效果伤害（REASON_EFFECT）。
		Duel.Damage(1-tp,ct*500,REASON_EFFECT)
	end
end

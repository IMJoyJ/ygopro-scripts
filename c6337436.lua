--連弾の魔術師
-- 效果：
-- 只要这张卡在场上表侧表示存在，每次自己发动通常魔法卡，给与对方基本分400分的伤害。
function c6337436.initial_effect(c)
	-- 只要这张卡在场上表侧表示存在，每次自己发动通常魔法卡，给与对方基本分400分的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(c6337436.damop)
	c:RegisterEffect(e1)
end
-- 在连锁处理完毕时，判断触发的效果是否为自己发动的通常魔法卡的发动，若是则执行伤害处理
function c6337436.damop(e,tp,eg,ep,ev,re,r,rp)
	if re:GetActiveType()==TYPE_SPELL and re:IsHasType(EFFECT_TYPE_ACTIVATE) and rp==tp then
		-- 给与对方玩家400点效果伤害
		Duel.Damage(1-tp,400,REASON_EFFECT)
	end
end

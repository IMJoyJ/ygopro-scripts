--天魔大帝
-- 效果：
-- ①：只要这张卡在怪兽区域存在，对方不能对应通常召唤的怪兽的效果的发动把魔法·陷阱·怪兽的效果发动。
function c90122655.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，对方不能对应通常召唤的怪兽的效果的发动把魔法·陷阱·怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(c90122655.chainop)
	c:RegisterEffect(e1)
end
-- 在有效果发动时，若该效果是怪兽区域的通常召唤的怪兽发动的，则限制后续连锁的发动
function c90122655.chainop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	-- 获取当前连锁中发动效果的卡片所在的位置
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	if re:IsActiveType(TYPE_MONSTER) and loc==LOCATION_MZONE and rc:IsSummonType(SUMMON_TYPE_NORMAL) then
		-- 设置连锁限制，调用连锁限制函数来阻止对方玩家进行连锁
		Duel.SetChainLimit(c90122655.chainlm)
	end
end
-- 连锁限制函数，当发动效果的玩家与当前限制效果的控制者相同时返回true，即仅允许自己连锁，从而阻止对方发动效果
function c90122655.chainlm(e,rp,tp)
	return tp==rp
end

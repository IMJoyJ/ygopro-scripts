--Ms.JUDGE
-- 效果：
-- 「审判女士」的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，对方的卡的效果发动的场合，那次处理进行时进行2次投掷硬币，2次都是表的场合，那个效果无效。
function c86767655.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，对方的卡的效果发动的场合
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_CHAINING)
	e0:SetRange(LOCATION_MZONE)
	-- 设置效果处理为：在连锁发生时，标记并记录这张卡在场上存在
	e0:SetOperation(aux.chainreg)
	c:RegisterEffect(e0)
	-- 「审判女士」的效果1回合只能使用1次。①：只要这张卡在怪兽区域存在，对方的卡的效果发动的场合，那次处理进行时进行2次投掷硬币，2次都是表的场合，那个效果无效。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCategory(CATEGORY_COIN)
	e1:SetCode(EVENT_CHAIN_SOLVING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,86767655)
	e1:SetCondition(c86767655.discon)
	e1:SetOperation(c86767655.disop)
	c:RegisterEffect(e1)
end
-- 判断是否为对方发动的效果，且连锁发生时这张卡在场上存在
function c86767655.discon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and e:GetHandler():GetFlagEffect(FLAG_ID_CHAINING)>0
end
-- 效果处理：发送卡片提示，进行2次投掷硬币，若2次都是正面则使该效果无效
function c86767655.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示，手动显示本卡（审判女士）的效果发动动画
	Duel.Hint(HINT_CARD,0,86767655)
	-- 让当前玩家进行2次投掷硬币
	local c1,c2=Duel.TossCoin(tp,2)
	if c1+c2==2 then
		-- 使该连锁的效果无效
		Duel.NegateEffect(ev)
	end
end

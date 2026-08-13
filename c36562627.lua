--セカンド・チャンス
-- 效果：
-- 这个卡名的①的效果1回合只能适用1次。
-- ①：自己进行投掷硬币的效果适用之际，可以从最初开始重新投掷硬币。
function c36562627.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己进行投掷硬币的效果适用之际，可以从最初开始重新投掷硬币。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_TOSS_COIN_NEGATE)
	e2:SetCondition(c36562627.coincon)
	e2:SetOperation(c36562627.coinop)
	c:RegisterEffect(e2)
end
-- 判断本次掷硬币事件是否满足发动条件：掷硬币的玩家是自己，且本回合尚未使用过此卡①的效果。
function c36562627.coincon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查进行掷硬币的玩家是否为这张卡的控制者（ep==tp），且该玩家本回合没有已使用过该卡效果的标记（GetFlagEffect为0）。
	return ep==tp and Duel.GetFlagEffect(tp,36562627)==0
end
-- 在条件满足时，询问控制者是否使用此效果；若选择是，则提示卡片发动、设置本回合使用标记并重新投掷与原来次数相同的硬币。
function c36562627.coinop(e,tp,eg,ep,ev,re,r,rp)
	-- 若该玩家本回合已使用过此卡效果（存在标记），则直接终止处理，不再重掷。
	if Duel.GetFlagEffect(tp,36562627)~=0 then return end
	-- 弹窗询问控制者是否使用「第二次机会」的效果；选择“是”才继续执行重掷处理。
	if Duel.SelectYesNo(tp,aux.Stringid(36562627,0)) then  --"是否要使用「第二次机会」的效果？"
		-- 向双方展示卡片动画，宣告发动「第二次机会」的效果。
		Duel.Hint(HINT_CARD,0,36562627)
		-- 为该玩家注册一个本回合结束阶段重置的标记，记录此卡名①的效果本回合已经适用过，以执行“1回合只能适用1次”的限制。
		Duel.RegisterFlagEffect(tp,36562627,RESET_PHASE+PHASE_END,0,1)
		-- 让该玩家重新投掷与原掷硬币次数（ev）相同的硬币，用新结果取代原结果。
		Duel.TossCoin(tp,ev)
	end
end

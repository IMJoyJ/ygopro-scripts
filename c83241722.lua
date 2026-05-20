--リバースダイス
-- 效果：
-- ①：这个回合，掷骰子的效果适用之际只有1次，可以重掷骰子。
function c83241722.initial_effect(c)
	-- ①：这个回合，掷骰子的效果适用之际只有1次，可以重掷骰子。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(c83241722.regop)
	c:RegisterEffect(e1)
end
-- 卡片发动时的效果处理：注册一个在回合结束前持续适用的、在掷骰子时触发的全局效果。
function c83241722.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合，掷骰子的效果适用之际只有1次，可以重掷骰子。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_TOSS_DICE_NEGATE)
	e1:SetCondition(c83241722.coincon)
	e1:SetOperation(c83241722.coinop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将重掷骰子的效果注册给玩家。
	Duel.RegisterEffect(e1,tp)
end
-- 重掷骰子效果的发动条件：本回合尚未适用过重掷骰子的效果。
function c83241722.coincon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家本回合是否尚未重掷过骰子。
	return Duel.GetFlagEffect(tp,83241722)==0
end
-- 重掷骰子效果的具体处理：若玩家选择重掷，则注册已使用标识，并重新进行相同次数的掷骰子。
function c83241722.coinop(e,tp,eg,ep,ev,re,r,rp)
	-- 安全检查，若本回合已经重掷过骰子，则不进行处理。
	if Duel.GetFlagEffect(tp,83241722)~=0 then return end
	-- 询问玩家是否要重掷骰子。
	if Duel.SelectYesNo(tp,aux.Stringid(83241722,0)) then  --"是否要重掷1次骰子？"
		-- 展示卡片发动动画，提示正在适用该卡的效果。
		Duel.Hint(HINT_CARD,0,83241722)
		-- 为玩家注册本回合已重掷过骰子的标识，该标识在回合结束时重置。
		Duel.RegisterFlagEffect(tp,83241722,RESET_PHASE+PHASE_END,0,1)
		local ct1=bit.band(ev,0xff)
		local ct2=bit.rshift(ev,16)
		-- 让原本掷骰子的玩家重新投掷对应数量的骰子。
		Duel.TossDice(ep,ct1,ct2)
	end
end

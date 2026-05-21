--終焉のカウントダウン
-- 效果：
-- ①：支付2000基本分才能发动。以发动的回合为第1回合来计算的第20回合的回合结束时自己决斗胜利。
function c95308449.initial_effect(c)
	-- ①：支付2000基本分才能发动。以发动的回合为第1回合来计算的第20回合的回合结束时自己决斗胜利。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c95308449.cost)
	e1:SetOperation(c95308449.activate)
	c:RegisterEffect(e1)
end
-- 检查并支付2000基本分的发动代价
function c95308449.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能够支付2000基本分
	if chk==0 then return Duel.CheckLPCost(tp,2000) end
	-- 玩家支付2000基本分作为发动代价
	Duel.PayLPCost(tp,2000)
end
-- 卡片发动时的效果处理：注册用于计算回合数和判定胜利的全局效果
function c95308449.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查玩家是否已经有该卡效果在生效，避免重复发动
	if Duel.GetFlagEffect(tp,95308449)~=0 then return end
	-- 为玩家注册一个持续20个回合结束阶段的标识效果，用于记录当前经过的回合数
	Duel.RegisterFlagEffect(tp,95308449,RESET_PHASE+PHASE_END,0,20)
	-- 以发动的回合为第1回合来计算的第20回合的回合结束时自己决斗胜利。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetOperation(c95308449.checkop)
	e1:SetCountLimit(1)
	e1:SetReset(RESET_PHASE+PHASE_END,20)
	-- 将用于在回合结束时进行计数和判定胜利的全局效果注册给玩家
	Duel.RegisterEffect(e1,tp)
	c:RegisterFlagEffect(1082946,RESET_PHASE+PHASE_END,0,20)
	c95308449[c]=e1
end
-- 每个回合结束阶段执行的操作：更新回合计数，并在达到第20个回合时宣告自己决斗胜利
function c95308449.checkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前已经过的回合数（即标识效果的数量）
	local ct=Duel.GetFlagEffect(tp,95308449)
	c:SetHint(CHINT_TURN,ct)
	-- 重新注册标识效果以增加计数，并设置其在剩余回合数后重置
	Duel.RegisterFlagEffect(tp,95308449,RESET_PHASE+PHASE_END,0,21-ct)
	if ct==20 then
		-- 令发动此卡效果的玩家因“终焉的倒计时”的效果直接获得决斗胜利
		Duel.Win(tp,0x11)
		c:ResetFlagEffect(1082946)
	end
end

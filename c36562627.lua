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
	-- 注册一个场地魔法卡的持续效果，用于在自己投掷硬币时触发第二次机会效果
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_TOSS_COIN_NEGATE)
	e2:SetCondition(c36562627.coincon)
	e2:SetOperation(c36562627.coinop)
	c:RegisterEffect(e2)
end
-- 判断是否为自己的投掷硬币效果且尚未使用过第二次机会效果
function c36562627.coincon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否已使用过此卡效果（防止重复使用）
	return ep==tp and Duel.GetFlagEffect(tp,36562627)==0
end
-- 执行第二次机会效果的处理逻辑，包括询问是否使用、注册标识效果并重新投掷硬币
function c36562627.coinop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否已使用过此卡效果，若已使用则直接返回不执行
	if Duel.GetFlagEffect(tp,36562627)~=0 then return end
	-- 向玩家询问是否使用「第二次机会」的效果
	if Duel.SelectYesNo(tp,aux.Stringid(36562627,0)) then  --"是否要使用「第二次机会」的效果？"
		-- 提示玩家使用了「第二次机会」卡片
		Duel.Hint(HINT_CARD,0,36562627)
		-- 为玩家注册一个标识效果，防止此卡效果在同回合再次使用
		Duel.RegisterFlagEffect(tp,36562627,RESET_PHASE+PHASE_END,0,1)
		-- 重新投掷硬币，次数等于原本投掷的次数
		Duel.TossCoin(tp,ev)
	end
end

--生命吸収装置
-- 效果：
-- 每次自己的准备阶段，回复之前的那个自己的回合支付的基本分的一半。
function c14318794.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 诱发必发效果，于准备阶段发动，效果原文：每次自己的准备阶段，回复之前的那个自己的回合支付的基本分的一半。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(14318794,0))  --"回复"
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCountLimit(1)
	e2:SetCondition(c14318794.reccon)
	e2:SetTarget(c14318794.rectg)
	e2:SetOperation(c14318794.recop)
	c:RegisterEffect(e2)
	if not c14318794.global_check then
		c14318794.global_check=true
		c14318794[0]=0
		c14318794[1]=0
		c14318794[2]=0
		c14318794[3]=0
		-- 用于记录玩家在回合中支付的生命值，效果原文：每次自己的准备阶段，回复之前的那个自己的回合支付的基本分的一半。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_PAY_LPCOST)
		ge1:SetOperation(c14318794.checkop)
		-- 将效果ge1注册到全局环境，使其在支付LP时触发。
		Duel.RegisterEffect(ge1,0)
		-- 用于在回合结束时清空并保存上一回合支付的生命值，效果原文：每次自己的准备阶段，回复之前的那个自己的回合支付的基本分的一半。
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_TURN_END)
		ge2:SetOperation(c14318794.clear)
		-- 将效果ge2注册到全局环境，使其在回合结束时触发。
		Duel.RegisterEffect(ge2,0)
	end
end
-- 当玩家支付LP时，计算其支付值的一半并累加到对应玩家的记录中。
function c14318794.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断支付LP的玩家是否为当前回合玩家。
	if ep==Duel.GetTurnPlayer() then
		local val=math.ceil(ev/2)
		c14318794[ep]=c14318794[ep]+val
	end
end
-- 在回合结束时，将当前回合玩家支付的LP值保存到ep+2位置，并将ep位置清零。
function c14318794.clear(e,tp,eg,ep,ev,re,r,rp)
	c14318794[ep+2]=c14318794[ep]
	c14318794[ep]=0
end
-- 判断是否为当前回合玩家，用于触发准备阶段效果。
function c14318794.reccon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家是否为效果发动者。
	return tp==Duel.GetTurnPlayer()
end
-- 设置连锁操作的目标玩家和参数，用于回复LP效果。
function c14318794.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	local val=c14318794[tp+2]
	if chk==0 then return val>0 end
	-- 设置连锁操作的目标玩家为tp。
	Duel.SetTargetPlayer(tp)
	-- 设置连锁操作的目标参数为val（即上回合支付的LP值的一半）。
	Duel.SetTargetParam(val)
	-- 设置连锁操作信息为回复效果，目标玩家为tp，回复值为val。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,val)
end
-- 执行回复LP操作，将目标玩家的LP回复指定值。
function c14318794.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁操作的目标玩家和参数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以REASON_EFFECT原因使玩家p回复值d的LP。
	Duel.Recover(p,d,REASON_EFFECT)
end

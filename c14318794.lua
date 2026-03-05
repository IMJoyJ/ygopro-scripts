--生命吸収装置
-- 效果：
-- 每次自己的准备阶段，回复之前的那个自己的回合支付的基本分的一半。
function c14318794.initial_effect(c)
	-- 卡片效果：每次自己的准备阶段，回复之前的那个自己的回合支付的基本分的一半。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 每次自己的准备阶段，回复之前的那个自己的回合支付的基本分的一半。
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
		-- 每次自己的准备阶段，回复之前的那个自己的回合支付的基本分的一半。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_PAY_LPCOST)
		ge1:SetOperation(c14318794.checkop)
		-- 注册一个在支付LP时触发的效果，用于记录玩家在该回合支付的LP数量。
		Duel.RegisterEffect(ge1,0)
		-- 每次自己的准备阶段，回复之前的那个自己的回合支付的基本分的一半。
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_TURN_END)
		ge2:SetOperation(c14318794.clear)
		-- 注册一个在回合结束时触发的效果，用于清空并保存上一回合支付的LP数量。
		Duel.RegisterEffect(ge2,0)
	end
end
-- 支付LP时的处理函数，用于记录当前回合支付的LP数量。
function c14318794.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断支付LP的玩家是否为当前回合玩家。
	if ep==Duel.GetTurnPlayer() then
		local val=math.ceil(ev/2)
		c14318794[ep]=c14318794[ep]+val
	end
end
-- 回合结束时的处理函数，用于保存并清空当前回合支付的LP数量。
function c14318794.clear(e,tp,eg,ep,ev,re,r,rp)
	c14318794[ep+2]=c14318794[ep]
	c14318794[ep]=0
end
-- 准备阶段触发效果的条件函数，用于判断是否为当前回合玩家。
function c14318794.reccon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前玩家是否为回合玩家。
	return tp==Duel.GetTurnPlayer()
end
-- 准备阶段触发效果的目标设定函数，用于设置回复LP的目标玩家和数值。
function c14318794.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	local val=c14318794[tp+2]
	if chk==0 then return val>0 end
	-- 设置连锁处理的目标玩家为当前玩家。
	Duel.SetTargetPlayer(tp)
	-- 设置连锁处理的目标参数为当前玩家上一回合支付的LP数量的一半。
	Duel.SetTargetParam(val)
	-- 设置连锁操作信息为回复LP效果，目标玩家为当前玩家，回复数值为上一回合支付的LP数量的一半。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,val)
end
-- 准备阶段触发效果的处理函数，用于执行回复LP操作。
function c14318794.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理的目标玩家和目标参数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因使目标玩家回复指定数值的LP。
	Duel.Recover(p,d,REASON_EFFECT)
end

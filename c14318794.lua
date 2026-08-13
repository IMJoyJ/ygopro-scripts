--生命吸収装置
-- 效果：
-- 每次自己的准备阶段，回复之前的那个自己的回合支付的基本分的一半。
function c14318794.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 回复之前的那个自己的回合支付的基本分的一半。
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
		-- 之前的那个自己的回合支付的基本分
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_PAY_LPCOST)
		ge1:SetOperation(c14318794.checkop)
		-- 将记录支付基本分的全局效果注册到全场（不归属特定卡片），使其持续监听所有玩家的LP支付。
		Duel.RegisterEffect(ge1,0)
		-- 每次自己的准备阶段，回复之前的那个自己的回合支付的基本分的一半。
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_TURN_END)
		ge2:SetOperation(c14318794.clear)
		-- 将回合结束时保存/清零记录值的全局效果注册到全场，用于把本回合累计的支付值转移到备份槽。
		Duel.RegisterEffect(ge2,0)
	end
end
-- 支付LP时，若支付者是当前回合玩家，则将其支付的LP数值的一半累计到该玩家的记录中。
function c14318794.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 仅当支付LP的玩家是当前回合玩家时，才记录该次支付的数值。
	if ep==Duel.GetTurnPlayer() then
		local val=math.ceil(ev/2)
		c14318794[ep]=c14318794[ep]+val
	end
end
-- 回合结束时，将本回合记录的该玩家支付值的一半存入备份槽（ep+2），并清零当前记录，供下个准备阶段使用。
function c14318794.clear(e,tp,eg,ep,ev,re,r,rp)
	c14318794[ep+2]=c14318794[ep]
	c14318794[ep]=0
end
-- 效果发动条件：仅在己方准备阶段且己方为当前回合玩家时满足，对应“每次自己的准备阶段”。
function c14318794.reccon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回是否为效果控制者的准备阶段（即效果控制者就是当前回合玩家）。
	return tp==Duel.GetTurnPlayer()
end
-- 效果发动时，从备份槽取出之前自己回合支付基本分的一半作为回复值，并设定回复对象玩家和回复数值。
function c14318794.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	local val=c14318794[tp+2]
	if chk==0 then return val>0 end
	-- 将本次回复的对象玩家设置为效果控制者自己。
	Duel.SetTargetPlayer(tp)
	-- 将本次回复的数值设置为之前记录的基本分一半。
	Duel.SetTargetParam(val)
	-- 向连锁系统登记本次操作是回复效果，回复玩家为tp，回复数值为val，供其他卡检测此效果。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,val)
end
-- 效果处理时，从连锁信息中读取之前设定的目标玩家与回复数值，然后执行LP回复。
function c14318794.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁中读取之前设定的目标玩家（CHAININFO_TARGET_PLAYER）和回复参数（CHAININFO_TARGET_PARAM）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因让玩家p回复d点LP，完成“回复基本分”的实质操作。
	Duel.Recover(p,d,REASON_EFFECT)
end

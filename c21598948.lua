--モンスターBOX
-- 效果：
-- 这张卡的控制者在每次自己准备阶段支付500基本分。或者不支付基本分让这张卡破坏。
-- ①：对方怪兽的攻击宣言时发动。进行1次投掷硬币，对里表作猜测。猜中的场合，那只攻击怪兽的攻击力只要这张卡在魔法与陷阱区域存在直到战斗阶段结束时变成0。
function c21598948.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：对方怪兽的攻击宣言时发动。进行1次投掷硬币，对里表作猜测。猜中的场合，那只攻击怪兽的攻击力只要这张卡在魔法与陷阱区域存在直到战斗阶段结束时变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21598948,0))  --"攻击变化"
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_COIN)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c21598948.atkcon)
	e2:SetTarget(c21598948.atktg)
	e2:SetOperation(c21598948.atkop)
	c:RegisterEffect(e2)
	-- 这张卡的控制者在每次自己准备阶段支付500基本分。或者不支付基本分让这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c21598948.mtcon)
	e3:SetOperation(c21598948.mtop)
	c:RegisterEffect(e3)
end
-- 效果发动条件：对方怪兽攻击宣言时
function c21598948.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 对方怪兽攻击宣言时，且不是自己回合
	return tp~=Duel.GetTurnPlayer()
end
-- 效果处理目标：设置攻击怪兽为连锁对象，并设置硬币效果操作信息
function c21598948.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置攻击怪兽为连锁对象
	Duel.SetTargetCard(Duel.GetAttacker())
	-- 设置硬币效果操作信息，提示对方选择硬币正反面
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
-- 效果处理过程：投掷硬币并判断结果，若猜错则将攻击怪兽攻击力变为0
function c21598948.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击怪兽
	local a=Duel.GetAttacker()
	if not a:IsRelateToEffect(e) then return end
	-- 提示玩家选择硬币正反面
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COIN)  --"请选择硬币的正反面"
	-- 玩家宣言硬币正反面
	local coin=Duel.AnnounceCoin(tp)
	-- 投掷一次硬币
	local res=Duel.TossCoin(tp,1)
	if coin~=res then
		-- 若猜错则将攻击怪兽攻击力变为0
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		a:RegisterEffect(e1)
	end
end
-- 准备阶段触发条件：当前回合玩家为自身
function c21598948.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家为自身时触发
	return Duel.GetTurnPlayer()==tp
end
-- 准备阶段处理过程：询问是否支付500基本分维持卡片，否则破坏
function c21598948.mtop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否能支付500基本分并询问玩家是否支付
	if Duel.CheckLPCost(tp,500) and Duel.SelectYesNo(tp,aux.Stringid(21598948,1)) then  --"是否要支付500基本分维持「怪兽箱」？"
		-- 支付500基本分
		Duel.PayLPCost(tp,500)
	else
		-- 破坏自身
		Duel.Destroy(e:GetHandler(),REASON_COST)
	end
end

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
-- 怪兽箱①效果的发动条件：仅在对方回合（当前回合玩家不是效果控制者）且对方怪兽攻击宣言时才能发动。
function c21598948.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家不是效果控制者，即只有对方回合的攻击宣言才能触发该效果。
	return tp~=Duel.GetTurnPlayer()
end
-- 攻击宣言时效果的发动目标设定：不取对象，将攻击怪兽设为关联对象，并设定操作信息为投掷1次硬币。
function c21598948.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将攻击宣言的怪兽设置为当前连锁的处理对象，用于后续判断其是否仍与效果关联。
	Duel.SetTargetCard(Duel.GetAttacker())
	-- 设置操作信息为硬币效果，预计进行1次投掷硬币（不取对象）。
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
end
-- 攻击宣言时效果的发动处理：玩家猜测硬币正反面，猜中的场合将攻击怪兽的攻击力变成0。
function c21598948.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前攻击宣言的怪兽。
	local a=Duel.GetAttacker()
	if not a:IsRelateToEffect(e) then return end
	-- 弹出选择提示，让玩家选择硬币的正反面。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COIN)  --"请选择硬币的正反面"
	-- 让玩家宣言硬币的正反面（正面0，反面1）。
	local coin=Duel.AnnounceCoin(tp)
	-- 实际投掷1次硬币，得到结果（正面1，反面0）。
	local res=Duel.TossCoin(tp,1)
	if coin~=res then
		-- 猜中的场合，那只攻击怪兽的攻击力只要这张卡在魔法与陷阱区域存在直到战斗阶段结束时变成0。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		a:RegisterEffect(e1)
	end
end
-- 维持费用的触发条件：当前回合玩家是这张卡的控制者，即自己的准备阶段。
function c21598948.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家等于效果控制者，确保只在控制者的准备阶段处理维持费用。
	return Duel.GetTurnPlayer()==tp
end
-- 准备阶段维持处理：玩家选择支付500基本分，否则这张卡破坏。
function c21598948.mtop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查控制者能否支付500基本分，并询问是否支付；能支付且选择“是”时执行支付，否则破坏。
	if Duel.CheckLPCost(tp,500) and Duel.SelectYesNo(tp,aux.Stringid(21598948,1)) then  --"是否要支付500基本分维持「怪兽箱」？"
		-- 让控制者支付500基本分作为维持费用。
		Duel.PayLPCost(tp,500)
	else
		-- 控制者不支付维持费用时，将这张卡以代价原因破坏。
		Duel.Destroy(e:GetHandler(),REASON_COST)
	end
end

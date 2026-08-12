--不吉な占い
-- 效果：
-- ①：自己准备阶段发动。对方手卡随机选1张，对那张卡的种类（怪兽·魔法·陷阱）作猜测。猜中的场合，给与对方700伤害。
function c56995655.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e1)
	-- ①：自己准备阶段发动。对方手卡随机选1张，对那张卡的种类（怪兽·魔法·陷阱）作猜测。猜中的场合，给与对方700伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(56995655,0))  --"猜测"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCondition(c56995655.con)
	e2:SetOperation(c56995655.op)
	c:RegisterEffect(e2)
end
-- 定义效果的发动条件函数
function c56995655.con(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己（即自己的准备阶段）
	return tp==Duel.GetTurnPlayer()
end
-- 定义效果的处理函数
function c56995655.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 从对方手卡中随机选择1张卡
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND):RandomSelect(tp,1)
	local tc=g:GetFirst()
	if not tc then return end
	-- 提示玩家选择卡片种类
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)  --"请选择一个种类"
	-- 让玩家宣言一个卡片种类（怪兽·魔法·陷阱）
	local op=Duel.AnnounceType(tp)
	-- 给发动效果的玩家确认选中的对方手卡
	Duel.ConfirmCards(tp,tc)
	-- 将对方的手卡重新洗牌
	Duel.ShuffleHand(1-tp)
	if (op==0 and tc:IsType(TYPE_MONSTER)) or (op==1 and tc:IsType(TYPE_SPELL)) or (op==2 and tc:IsType(TYPE_TRAP)) then
		-- 给予对方700点效果伤害
		Duel.Damage(1-tp,700,REASON_EFFECT)
	end
end

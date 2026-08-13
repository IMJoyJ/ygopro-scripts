--アロマガーデン
-- 效果：
-- ①：1回合1次，自己场上有「芳香」怪兽存在的场合才能发动。自己回复500基本分。这个效果的发动后，直到下次的对方回合结束时自己场上的怪兽的攻击力·守备力上升500。
-- ②：自己场上的「芳香」怪兽被战斗·效果破坏送去墓地的场合发动。自己回复1000基本分。
function c5050644.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，自己场上有「芳香」怪兽存在的场合才能发动。自己回复500基本分。这个效果的发动后，直到下次的对方回合结束时自己场上的怪兽的攻击力·守备力上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_RECOVER+CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCountLimit(1)
	e2:SetCondition(c5050644.recon1)
	e2:SetTarget(c5050644.retg1)
	e2:SetOperation(c5050644.reop1)
	c:RegisterEffect(e2)
	-- ②：自己场上的「芳香」怪兽被战斗·效果破坏送去墓地的场合发动。自己回复1000基本分。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_RECOVER)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCondition(c5050644.recon2)
	e3:SetTarget(c5050644.retg2)
	e3:SetOperation(c5050644.reop2)
	c:RegisterEffect(e3)
end
-- 过滤条件：卡片为表侧表示且属于「芳香」系列（0xc9），用于检查自己场上是否存在符合条件的怪兽。
function c5050644.cfilter1(c)
	return c:IsFaceup() and c:IsSetCard(0xc9)
end
-- ①效果的发动条件：自己场上存在至少1只表侧表示的「芳香」怪兽。
function c5050644.recon1(e,tp,eg,ep,ev,re,r,rp)
	-- 检索自己场上（LOCATION_MZONE）是否存在至少1张满足cfilter1的卡，存在则条件成立。
	return Duel.IsExistingMatchingCard(c5050644.cfilter1,tp,LOCATION_MZONE,0,1,nil)
end
-- ①效果的发动时处理：若检查通过，设置回复对象玩家为发动者、回复量为500，并登记回复效果的操作信息供连锁判定。
function c5050644.retg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将本次回复基本分的对象玩家设置为效果发动者tp，即回复自己的LP。
	Duel.SetTargetPlayer(tp)
	-- 将本次回复基本分的数值设定为500。
	Duel.SetTargetParam(500)
	-- 设置操作信息：本次连锁将执行回复500LP的CATEGORY_RECOVER处理，对象玩家为tp，不取对象。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,500)
end
-- ①效果处理：先回复500LP，然后给自己场上的怪兽赋予攻击力·守备力上升500的持续效果，该效果持续到下次对方回合结束。
function c5050644.reop1(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出之前设定的目标玩家（回复对象）和目标参数（回复数值）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 使目标玩家p回复d点基本分，回复原因记为效果（REASON_EFFECT）。
	Duel.Recover(p,d,REASON_EFFECT)
	-- ①中“这个效果的发动后，直到下次的对方回合结束时自己场上的怪兽的攻击力·守备力上升500。”以及②“自己场上的「芳香」怪兽被战斗·效果破坏送去墓地的场合发动。自己回复1000基本分。”
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetValue(500)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
	-- 将攻击力上升500的永续效果注册到场上，使其影响己方怪兽区（LOCATION_MZONE）的怪兽。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	-- 将守备力上升500的永续效果注册到场上，与攻击力上升效果持续期间相同。
	Duel.RegisterEffect(e2,tp)
end
-- ②效果的触发筛选条件：被送去墓地的卡必须是原控制者为tp、原位置为怪兽区、原表侧表示的「芳香」怪兽，且破坏原因包含战斗或效果。
function c5050644.cfilter2(c,tp)
	return c:IsSetCard(0xc9) and c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
end
-- ②效果的发动条件：本次被送去墓地的卡组（eg）中存在至少1张满足cfilter2的卡，即“自己场上的「芳香」怪兽被战斗·效果破坏送去墓地”的场合。
function c5050644.recon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c5050644.cfilter2,1,nil,tp)
end
-- ②效果的发动时处理：设置回复对象玩家为发动者、回复量为1000，并登记回复效果的操作信息。
function c5050644.retg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将本次回复基本分的对象玩家设置为效果发动者tp。
	Duel.SetTargetPlayer(tp)
	-- 将本次回复基本分的数值设定为1000。
	Duel.SetTargetParam(1000)
	-- 设置操作信息：本次连锁将执行回复1000LP的CATEGORY_RECOVER处理。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1000)
end
-- ②效果处理：根据之前设定的对象玩家和数值，为自己回复1000基本分。
function c5050644.reop2(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出目标玩家和回复数值。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 使目标玩家p回复d点基本分，回复原因记为效果（REASON_EFFECT）。
	Duel.Recover(p,d,REASON_EFFECT)
end

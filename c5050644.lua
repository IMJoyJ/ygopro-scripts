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
-- 过滤函数，检查以玩家来看的场上是否存在至少1张满足条件的「芳香」怪兽（正面表示）
function c5050644.cfilter1(c)
	return c:IsFaceup() and c:IsSetCard(0xc9)
end
-- 效果发动条件：检查以玩家来看的场上是否存在至少1张满足条件的「芳香」怪兽（正面表示）
function c5050644.recon1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查以玩家来看的场上是否存在至少1张满足条件的「芳香」怪兽（正面表示）
	return Duel.IsExistingMatchingCard(c5050644.cfilter1,tp,LOCATION_MZONE,0,1,nil)
end
-- 设置效果处理时的目标玩家为当前玩家，目标参数为500，操作信息包含回复500基本分
function c5050644.retg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的目标玩家设置为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的目标参数设置为500
	Duel.SetTargetParam(500)
	-- 设置当前处理的连锁的操作信息为回复500基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,500)
end
-- 效果处理函数：使目标玩家回复500基本分，并给对方场上所有怪兽增加500攻击力和守备力直到下次对方回合结束
function c5050644.reop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以REASON_EFFECT原因使目标玩家回复指定数值的基本分
	Duel.Recover(p,d,REASON_EFFECT)
	-- 创建一个影响全场的攻击力变更效果，并注册给当前玩家，持续到对方回合结束
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetValue(500)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
	-- 将攻击力变更效果注册给当前玩家
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	-- 将守备力变更效果注册给当前玩家
	Duel.RegisterEffect(e2,tp)
end
-- 过滤函数，检查被破坏送去墓地的卡是否为「芳香」怪兽且由战斗或效果破坏、前控制者为当前玩家、位置为场上正面表示
function c5050644.cfilter2(c,tp)
	return c:IsSetCard(0xc9) and c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP)
end
-- 效果发动条件：检查以玩家来看的墓地中是否存在至少1张满足条件的「芳香」怪兽（由战斗或效果破坏）
function c5050644.recon2(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c5050644.cfilter2,1,nil,tp)
end
-- 设置效果处理时的目标玩家为当前玩家，目标参数为1000，操作信息包含回复1000基本分
function c5050644.retg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的目标玩家设置为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的目标参数设置为1000
	Duel.SetTargetParam(1000)
	-- 设置当前处理的连锁的操作信息为回复1000基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1000)
end
-- 效果处理函数：使目标玩家回复1000基本分
function c5050644.reop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以REASON_EFFECT原因使目标玩家回复指定数值的基本分
	Duel.Recover(p,d,REASON_EFFECT)
end

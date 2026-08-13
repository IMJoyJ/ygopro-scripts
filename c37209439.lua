--誤封の契約書
-- 效果：
-- ①：1回合1次，自己场上有「DD」怪兽存在的场合才能把这个效果发动。直到回合结束时，这张卡以外的场上的陷阱卡的效果无效化。
-- ②：自己准备阶段发动。自己受到1000伤害。
function c37209439.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，自己场上有「DD」怪兽存在的场合才能把这个效果发动。直到回合结束时，这张卡以外的场上的陷阱卡的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(37209439,0))  --"效果无效"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1)
	e2:SetCondition(c37209439.negcon)
	e2:SetOperation(c37209439.negop)
	c:RegisterEffect(e2)
	-- ②：自己准备阶段发动。自己受到1000伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(37209439,1))  --"伤害"
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c37209439.damcon)
	e3:SetTarget(c37209439.damtg)
	e3:SetOperation(c37209439.damop)
	c:RegisterEffect(e3)
end
-- 过滤条件：判断怪兽是否表侧表示且属于「DD」字段，用于①的发动条件。
function c37209439.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xaf)
end
-- ①的发动条件：自己场上有表侧表示的「DD」怪兽存在。
function c37209439.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己怪兽区是否存在至少1张满足cfilter条件的表侧表示「DD」怪兽，即自己场上有「DD」怪兽存在。
	return Duel.IsExistingMatchingCard(c37209439.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ①的效果处理：从处理时到回合结束，使这张卡以外的场上的陷阱卡效果无效化；同时无效连锁中发动的陷阱卡效果，并使陷阱怪兽效果无效。
function c37209439.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local fid=c:GetFieldID()
	-- 直到回合结束时，这张卡以外的场上的陷阱卡的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DISABLE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_SZONE,LOCATION_SZONE)
	e1:SetTarget(c37209439.distg)
	e1:SetLabel(fid)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将e1（使场上其他陷阱卡效果无效化的永续效果）注册到当前玩家场上。
	Duel.RegisterEffect(e1,tp)
	-- 直到回合结束时，这张卡以外的场上的陷阱卡的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(c37209439.disop)
	e2:SetLabel(fid)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将e2（在连锁处理时对其他陷阱卡效果进行无效的辅助效果）注册到当前玩家场上。
	Duel.RegisterEffect(e2,tp)
	-- 直到回合结束时，这张卡以外的场上的陷阱卡的效果无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(c37209439.distg)
	e3:SetLabel(fid)
	e3:SetReset(RESET_PHASE+PHASE_END)
	-- 将e3（使陷阱怪兽效果无效化的效果）注册到当前玩家场上。
	Duel.RegisterEffect(e3,tp)
end
-- 无效对象筛选：该卡是陷阱卡，且其FieldID不等于本卡记录的FieldID，即排除本卡自身的其他陷阱卡。
function c37209439.distg(e,c)
	return c:GetFieldID()~=e:GetLabel() and c:IsType(TYPE_TRAP)
end
-- 连锁处理时，若正在处理的连锁来自魔陷区的陷阱卡且不是本卡，则将该连锁效果无效。
function c37209439.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁发生的位置（魔陷区、怪兽区等）。
	local tl=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	if tl==LOCATION_SZONE and re:IsActiveType(TYPE_TRAP) and re:GetHandler():GetFieldID()~=e:GetLabel() then
		-- 使当前连锁的效果无效，从而无效该陷阱卡的效果。
		Duel.NegateEffect(ev)
	end
end
-- ②的发动条件：当前回合玩家是这张卡的控制者，即自己准备阶段。
function c37209439.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否等于效果控制者tp，即确定是否为自己准备阶段。
	return Duel.GetTurnPlayer()==tp
end
-- ②的发动时目标设定：将对象玩家设为自己，伤害数值设为1000，并提交对应的伤害操作信息。
function c37209439.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设为自己，表示承受伤害的是自己。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设为1000，即伤害数值。
	Duel.SetTargetParam(1000)
	-- 声明本次连锁将对自己造成1000点伤害，用于时点检测和连锁响应。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,tp,1000)
end
-- ②的效果处理：实际对自己造成1000点效果伤害。
function c37209439.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出对象玩家和伤害数值。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因对对象玩家p造成d点伤害，即自己受到1000伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end

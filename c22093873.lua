--M・HERO カミカゼ
-- 效果：
-- 这张卡用「假面变化」的效果才能特殊召唤。
-- ①：这张卡不会被战斗破坏。
-- ②：只要这张卡在怪兽区域存在，对方在同1次的战斗阶段中只能用1只怪兽攻击。
-- ③：这张卡战斗破坏对方怪兽送去墓地时才能发动。自己抽1张。
function c22093873.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡用「假面变化」的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件判定函数：仅当以「假面变化」效果进行特殊召唤时才允许此卡特殊召唤。
	e1:SetValue(aux.MaskChangeLimit)
	c:RegisterEffect(e1)
	-- ①：这张卡不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在怪兽区域存在，对方在同1次的战斗阶段中只能用1只怪兽攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCondition(c22093873.atkcon)
	e3:SetTarget(c22093873.atktg)
	c:RegisterEffect(e3)
	-- ②：只要这张卡在怪兽区域存在，对方在同1次的战斗阶段中只能用1只怪兽攻击。（此为记录首次攻击宣言的辅助效果，用于实现该限制）
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetOperation(c22093873.checkop)
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4)
	-- ③：这张卡战斗破坏对方怪兽送去墓地时才能发动。自己抽1张。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(22093873,0))  --"抽1张卡"
	e5:SetCategory(CATEGORY_DRAW)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetCode(EVENT_BATTLE_DESTROYING)
	-- 设置该效果的发动条件：此卡与对方怪兽战斗并战斗破坏对方怪兽送去墓地时满足触发条件。
	e5:SetCondition(aux.bdogcon)
	e5:SetTarget(c22093873.drtg)
	e5:SetOperation(c22093873.drop)
	c:RegisterEffect(e5)
end
-- 攻击限制效果的可发动条件：此卡已记录本次战斗阶段首次攻击宣言（存在标记22093873），否则限制不生效。
function c22093873.atkcon(e)
	return e:GetHandler():GetFlagEffect(22093873)~=0
end
-- 攻击限制的对象判定：不允许对方场上除第一只已攻击怪兽以外的怪兽进行攻击宣言（即只能有1只怪兽攻击）。
function c22093873.atktg(e,c)
	return c:GetFieldID()~=e:GetLabel()
end
-- 攻击宣言时记录：若本卡尚未记录，则记录该攻击宣言怪兽的FieldID，注册标记，并将该ID存入攻击限制效果的Label，使后续其他怪兽不能再攻击宣言。
function c22093873.checkop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetFlagEffect(22093873)~=0 then return end
	local fid=eg:GetFirst():GetFieldID()
	e:GetHandler():RegisterFlagEffect(22093873,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	e:GetLabelObject():SetLabel(fid)
end
-- 抽卡效果发动时的目标处理：确认玩家可以抽1张卡，并记录抽卡对象玩家与抽卡数量。
function c22093873.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动条件检查：若自己不能抽1张卡，则不能发动。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 将本次连锁的对象玩家设为效果发动者自己，即抽卡玩家。
	Duel.SetTargetPlayer(tp)
	-- 设置本次连锁的对象参数为1，表示抽卡数量为1张。
	Duel.SetTargetParam(1)
	-- 登记操作信息：本连锁为抽卡效果，预计由tp玩家抽1张卡，供其他卡效果响应判定。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理时执行抽卡：读取记录的对象玩家和抽卡数量，让该玩家抽对应数量的卡。
function c22093873.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出对象玩家（p）和对象参数（d，抽卡数）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因让p玩家抽d张卡。
	Duel.Draw(p,d,REASON_EFFECT)
end

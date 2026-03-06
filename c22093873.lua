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
	-- 检测特殊召唤是否满足“假面变化”机制的召唤条件。
	e1:SetValue(aux.MaskChangeLimit)
	c:RegisterEffect(e1)
	-- 这张卡不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 只要这张卡在怪兽区域存在，对方在同1次的战斗阶段中只能用1只怪兽攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCondition(c22093873.atkcon)
	e3:SetTarget(c22093873.atktg)
	c:RegisterEffect(e3)
	-- 攻击宣言时，记录本次攻击的怪兽ID并设置为下一次攻击的限制条件。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetOperation(c22093873.checkop)
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4)
	-- 这张卡战斗破坏对方怪兽送去墓地时才能发动。自己抽1张。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(22093873,0))  --"抽1张卡"
	e5:SetCategory(CATEGORY_DRAW)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e5:SetCode(EVENT_BATTLE_DESTROYING)
	-- 检测是否满足战斗破坏对方怪兽送去墓地的条件。
	e5:SetCondition(aux.bdogcon)
	e5:SetTarget(c22093873.drtg)
	e5:SetOperation(c22093873.drop)
	c:RegisterEffect(e5)
end
-- 判断该效果是否处于激活状态，即是否已记录过本次战斗阶段的攻击限制。
function c22093873.atkcon(e)
	return e:GetHandler():GetFlagEffect(22093873)~=0
end
-- 判断目标怪兽是否为本次攻击的怪兽，若不是则允许攻击。
function c22093873.atktg(e,c)
	return c:GetFieldID()~=e:GetLabel()
end
-- 记录本次攻击的怪兽ID，并在结束阶段重置标记。
function c22093873.checkop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetFlagEffect(22093873)~=0 then return end
	local fid=eg:GetFirst():GetFieldID()
	e:GetHandler():RegisterFlagEffect(22093873,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	e:GetLabelObject():SetLabel(fid)
end
-- 设置抽卡效果的目标玩家和抽卡数量。
function c22093873.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足抽卡条件，即玩家可以抽卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置当前效果的目标玩家为发动者。
	Duel.SetTargetPlayer(tp)
	-- 设置当前效果的目标参数为抽卡数量1。
	Duel.SetTargetParam(1)
	-- 设置当前效果的操作信息为抽卡效果。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 执行抽卡操作，从玩家的牌组中抽取指定数量的卡。
function c22093873.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和抽卡数量。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家从牌组中抽取指定数量的卡，原因设为效果抽卡。
	Duel.Draw(p,d,REASON_EFFECT)
end

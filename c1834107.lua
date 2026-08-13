--エレキュア
-- 效果：
-- 自己场上存在的雷族怪兽给与对方基本分战斗伤害时，自己基本分回复给与的战斗伤害的数值。
function c1834107.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 自己场上存在的雷族怪兽给与对方基本分战斗伤害时，自己基本分回复给与的战斗伤害的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1834107,0))  --"回复LP"
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCondition(c1834107.reccon)
	e2:SetTarget(c1834107.rectg)
	e2:SetOperation(c1834107.recop)
	c:RegisterEffect(e2)
end
-- 满足条件时才能发动：伤害不是自己受到，且造成战斗伤害的怪兽是自己控制的雷族怪兽。
function c1834107.reccon(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp then return false end
	local rc=eg:GetFirst()
	return rc:IsControler(tp) and rc:IsRace(RACE_THUNDER)
end
-- 效果发动时设定回复对象为自己、回复数值为那次战斗伤害的数值，并登记相应的回复操作信息。
function c1834107.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设为自己的玩家，即回复LP的对象是自己。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设为战斗伤害数值ev，作为本次回复的LP数值。
	Duel.SetTargetParam(ev)
	-- 登记效果处理时的操作信息：本次效果处理将执行回复LP，目标玩家为自己，回复量为ev。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,ev)
end
-- 效果处理阶段，取出之前设定的回复玩家和回复数值，并实际执行回复LP。
function c1834107.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取得之前保存的对象玩家p和对象参数d，分别作为回复对象与回复数值。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 使玩家p回复d点基本分，回复原因记为效果（REASON_EFFECT）。
	Duel.Recover(p,d,REASON_EFFECT)
end

--エレキュア
-- 效果：
-- 自己场上存在的雷族怪兽给与对方基本分战斗伤害时，自己基本分回复给与的战斗伤害的数值。
function c1834107.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 诱发必发效果，当自己场上存在的雷族怪兽给与对方基本分战斗伤害时发动
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
-- 效果发动的条件：对方造成的战斗伤害，且造成伤害的怪兽是自己的雷族怪兽
function c1834107.reccon(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp then return false end
	local rc=eg:GetFirst()
	return rc:IsControler(tp) and rc:IsRace(RACE_THUNDER)
end
-- 设置效果的目标玩家和参数，准备进行LP回复
function c1834107.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前效果的目标玩家设置为效果发动者
	Duel.SetTargetPlayer(tp)
	-- 将当前效果的目标参数设置为造成的战斗伤害值
	Duel.SetTargetParam(ev)
	-- 设置连锁的操作信息，表示将要进行LP回复效果
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,ev)
end
-- 效果处理时点，读取连锁中的目标玩家和参数并执行LP回复
function c1834107.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁中获取目标玩家和伤害值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 使目标玩家回复对应伤害值的LP，回复原因来自效果
	Duel.Recover(p,d,REASON_EFFECT)
end

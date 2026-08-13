--シャトルロイド
-- 效果：
-- 这张卡被选择作为攻击对象时，可以把这张卡从游戏中除外。这个效果从游戏中除外的场合，这张卡在下次的自己的准备阶段时特殊召唤。那个时候，给与对方基本分1000分伤害。
function c10449150.initial_effect(c)
	-- 这张卡被选择作为攻击对象时，可以把这张卡从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10449150,0))  --"除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetTarget(c10449150.rmtg)
	e1:SetOperation(c10449150.rmop)
	c:RegisterEffect(e1)
	-- 这个效果从游戏中除外的场合，这张卡在下次的自己的准备阶段时特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(10449150,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_REMOVED)
	e2:SetCondition(c10449150.spcon)
	e2:SetTarget(c10449150.sptg)
	e2:SetOperation(c10449150.spop)
	c:RegisterEffect(e2)
	-- 那个时候，给与对方基本分1000分伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(10449150,2))  --"LP伤害"
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(c10449150.damcon)
	e3:SetTarget(c10449150.damtg)
	e3:SetOperation(c10449150.damop)
	c:RegisterEffect(e3)
end
-- 效果发动时的合法检测：确认此卡可以除外，并将除外自身写入操作信息。
function c10449150.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() end
	-- 设置操作信息：本次连锁将除外此卡（1张）。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetHandler(),1,0,0)
end
-- 效果处理：若此卡仍与效果关联，则将其表侧除外，并给它标记“航天机人”的发动记号，用于下次准备阶段特殊召唤。
function c10449150.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判定此卡仍与效果关联，且成功以表侧表示除外时才继续执行。
	if c:IsRelateToEffect(e) and Duel.Remove(c,POS_FACEUP,REASON_EFFECT)~=0 then
		c:RegisterFlagEffect(10449150,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,1)
	end
end
-- 特殊召唤效果的触发条件：当前回合玩家为自己，即只在“自己的准备阶段”才能发动。
function c10449150.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家是否是自己。
	return Duel.GetTurnPlayer()==tp
end
-- 特殊召唤效果的发动条件与目标设置：确认此卡带有标记，清除标记，并设置特殊召唤与伤害的操作信息。
function c10449150.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(10449150)~=0 end
	e:GetHandler():ResetFlagEffect(10449150)
	-- 设置操作信息：本次连锁将特殊召唤此卡（1张）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 设置操作信息：本次连锁将造成1000点伤害，伤害对象是对方玩家。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
-- 效果处理：若此卡仍与效果关联，则将其特殊召唤。
function c10449150.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 以自身效果（SUMMON_VALUE_SELF）将这张卡正面表示特殊召唤到自己场上。
	Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,false,false,POS_FACEUP)
end
-- 伤害效果的触发条件：确认这张卡是通过“航天机人”自身效果特殊召唤的。
function c10449150.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 伤害效果发动时设置目标：将对方玩家设为伤害对象，伤害参数设为1000，并写入操作信息。
function c10449150.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的对象玩家为对方（1-tp）。
	Duel.SetTargetPlayer(1-tp)
	-- 设置当前连锁的对象参数为1000（伤害数值）。
	Duel.SetTargetParam(1000)
	-- 设置操作信息：本次连锁将造成1000点伤害，对象为对方玩家。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
-- 效果处理：取出之前设置好的目标玩家和伤害数值，给对方造成效果伤害。
function c10449150.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取得目标玩家和伤害参数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 给对方造成1000点效果伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end

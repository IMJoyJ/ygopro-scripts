--墓荒らしの報い
-- 效果：
-- 每次自己的准备阶段，每存在1只除外的对方怪兽，对方受到100分的伤害。
function c33737664.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_STANDBY_PHASE,0)
	c:RegisterEffect(e1)
	-- 每次自己的准备阶段，每存在1只除外的对方怪兽，对方受到100分的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(33737664,0))  --"LP伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCondition(c33737664.damcon)
	e2:SetTarget(c33737664.damtg)
	e2:SetOperation(c33737664.damop)
	c:RegisterEffect(e2)
end
-- 效果发动条件判定：仅当本卡控制者即为当前回合玩家时，该触发效果才成立，以体现“自己的准备阶段”。
function c33737664.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定效果控制者是否为当前回合玩家，若是则条件满足，确保只在控制者自己的准备阶段发动。
	return tp==Duel.GetTurnPlayer()
end
-- 定义筛选条件：仅统计对方除外区表侧表示的怪兽。
function c33737664.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER)
end
-- 效果发动前设定：无条件允许发动，将伤害对象指定为对方玩家，并登记伤害类操作信息以供后续处理使用。
function c33737664.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将本次效果的伤害对象玩家设为1-tp，即对方玩家。
	Duel.SetTargetPlayer(1-tp)
	-- 登记操作信息为伤害分类，不指定具体卡，目标玩家为对方，用于伤害相关检测与后续处理。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
-- 效果处理时：从连锁信息取得伤害对象，统计对方除外区的符合条件的怪兽数量乘以100，给对方造成对应效果伤害。
function c33737664.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得连锁处理中记录的目标玩家（即对方），用于后续造成伤害。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 统计对方除外区满足filter条件的怪兽数量，并乘以100作为造成的伤害数值。
	local d=Duel.GetMatchingGroupCount(c33737664.filter,tp,0,LOCATION_REMOVED,nil)*100
	-- 给目标玩家p造成d点效果伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end

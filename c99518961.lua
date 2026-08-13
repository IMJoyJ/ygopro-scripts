--革命
-- 效果：
-- 对方受到（对方的手卡数×200）的伤害。
function c99518961.initial_effect(c)
	-- 对方受到（对方的手卡数×200）的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c99518961.damtg)
	e1:SetOperation(c99518961.damop)
	c:RegisterEffect(e1)
end
-- 效果发动时的判断与登记：检查对方手牌数大于0才能发动，将对方设为对象玩家，并登记伤害效果的操作信息，数值为对方手牌数×200。
function c99518961.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件判定：若对方手牌数为0则无法发动（伤害为0），只有对方手牌数大于0时才允许发动。
	if chk==0 then return Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)>0 end
	-- 将当前连锁的效果对象玩家设置为对方（1-tp），表示该效果以对方玩家为对象。
	Duel.SetTargetPlayer(1-tp)
	-- 登记操作信息：效果分类为伤害，对象玩家为对方，预计造成的伤害值为对方手牌数×200，因不取对象所以目标卡为nil。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)*200)
end
-- 效果处理时的实际操作：获取链锁中登记的对象玩家，根据其当前手牌数计算伤害并造成伤害。
function c99518961.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中登记的对象玩家，即效果发动时设置的对方玩家。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 以效果伤害方式对玩家p造成其手牌数×200的伤害。
	Duel.Damage(p,Duel.GetFieldGroupCount(p,LOCATION_HAND,0)*200,REASON_EFFECT)
end

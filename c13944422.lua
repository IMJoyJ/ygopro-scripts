--グラナドラ
-- 效果：
-- 这张卡召唤·反转召唤·特殊召唤成功时，自己回复1000基本分。这张卡被破坏送去墓地时，自己受到2000点伤害。
function c13944422.initial_effect(c)
	-- 这张卡召唤·反转召唤·特殊召唤成功时，自己回复1000基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(13944422,0))  --"回复1000"
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c13944422.rectg)
	e1:SetOperation(c13944422.recop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- 这张卡被破坏送去墓地时，自己受到2000点伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(13944422,1))  --"伤害2000"
	e4:SetCategory(CATEGORY_DAMAGE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(c13944422.damcon)
	e4:SetTarget(c13944422.damtg)
	e4:SetOperation(c13944422.damop)
	c:RegisterEffect(e4)
end
-- 设置效果目标为自身玩家并设定回复值为1000
function c13944422.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将连锁处理的目标玩家设置为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 将连锁处理的目标参数设置为1000
	Duel.SetTargetParam(1000)
	-- 设置连锁操作信息为回复效果，目标玩家为当前玩家，回复值为1000
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1000)
end
-- 设置效果操作函数为回复LP
function c13944422.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因使目标玩家回复指定数值的生命值
	Duel.Recover(p,d,REASON_EFFECT)
end
-- 判断效果触发条件是否为因破坏而进入墓地
function c13944422.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY)
end
-- 设置效果目标为自身玩家并设定伤害值为2000
function c13944422.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将连锁处理的目标玩家设置为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 将连锁处理的目标参数设置为2000
	Duel.SetTargetParam(2000)
	-- 设置连锁操作信息为伤害效果，目标玩家为当前玩家，伤害值为2000
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,2000)
end
-- 设置效果操作函数为造成伤害
function c13944422.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因使目标玩家受到指定数值的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end

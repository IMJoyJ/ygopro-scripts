--髑髏顔 天道虫
-- 效果：
-- 当这张卡被送去墓地时，自己回复1000基本分。
function c64306248.initial_effect(c)
	-- 当这张卡被送去墓地时，自己回复1000基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(64306248,0))  --"回复1000LP"
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetTarget(c64306248.target)
	e1:SetOperation(c64306248.operation)
	c:RegisterEffect(e1)
end
-- 效果发动的目标与操作信息设置函数
function c64306248.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的对象参数为1000
	Duel.SetTargetParam(1000)
	-- 设置当前连锁的操作信息为回复1000基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1000)
end
-- 效果处理的执行函数
function c64306248.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的对象玩家和回复数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因使目标玩家回复对应的基本分
	Duel.Recover(p,d,REASON_EFFECT)
end

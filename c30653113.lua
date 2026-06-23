--ナイルの恵み
-- 效果：
-- 每当因对方所控制的卡的效果使自己的手卡被弃进墓地时，自己回复1000基本分。
function c30653113.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 诱发必发效果，对应一速的【……发动】
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(30653113,0))  --"回复"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c30653113.condition)
	e2:SetTarget(c30653113.target)
	e2:SetOperation(c30653113.operation)
	c:RegisterEffect(e2)
end
-- 检查卡片是否从手牌被丢弃且为效果导致的丢弃
function c30653113.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_HAND) and c:IsControler(tp) and c:IsReason(REASON_EFFECT) and c:IsReason(REASON_DISCARD)
end
-- 判断是否为对方造成的丢弃且满足cfilter条件
function c30653113.condition(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and eg:IsExists(c30653113.cfilter,1,nil,tp)
end
-- 设置效果的目标玩家和参数为1000
function c30653113.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前处理的连锁的对象玩家为tp
	Duel.SetTargetPlayer(tp)
	-- 设置当前处理的连锁的对象参数为1000
	Duel.SetTargetParam(1000)
	-- 设置当前处理的连锁的操作信息为回复1000基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1000)
end
-- 执行回复基本分的操作
function c30653113.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁的目标玩家和参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因使目标玩家回复指定数值的基本分
	Duel.Recover(p,d,REASON_EFFECT)
end

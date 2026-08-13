--ナイルの恵み
-- 效果：
-- 每当因对方所控制的卡的效果使自己的手卡被弃进墓地时，自己回复1000基本分。
function c30653113.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 每当因对方所控制的卡的效果使自己的手卡被弃进墓地时，自己回复1000基本分。
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
-- 筛选因对方效果被丢弃进墓地的手牌：需满足此前位于手牌、控制者为己方、且丢弃原因是效果丢弃。
function c30653113.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_HAND) and c:IsControler(tp) and c:IsReason(REASON_EFFECT) and c:IsReason(REASON_DISCARD)
end
-- 触发条件为：这次送去墓地的卡由对方玩家的效果引起，且其中至少有一张满足手牌被效果丢弃筛选条件的卡。
function c30653113.condition(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and eg:IsExists(c30653113.cfilter,1,nil,tp)
end
-- 发动时无需选择目标；判定合法后，设置回复对象为己方玩家、回复数值为1000，并登记回复1000基本分的操作信息。
function c30653113.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设置为己方，即确定回复基本分的玩家。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设置为1000，即回复的基本分数值。
	Duel.SetTargetParam(1000)
	-- 登记操作信息：本效果属于回复效果，预计使己方玩家回复1000基本分。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,1000)
end
-- 效果处理阶段：从当前连锁中读取之前保存的目标玩家与回复数值，并让该玩家以效果原因回复相应基本分。
function c30653113.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中保存的目标玩家和参数，即回复对象与回复数值。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 使玩家p回复d点基本分，回复原因为效果，完成实际回复处理。
	Duel.Recover(p,d,REASON_EFFECT)
end

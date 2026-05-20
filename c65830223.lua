--棺桶売り
-- 效果：
-- 每次对方的怪兽卡送去墓地，对方基本分受到300分的伤害。
function c65830223.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 每次对方的怪兽卡送去墓地，对方基本分受到300分的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(65830223,0))  --"伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c65830223.condition)
	e2:SetTarget(c65830223.target)
	e2:SetOperation(c65830223.operation)
	c:RegisterEffect(e2)
end
-- 过滤出属于对方的怪兽卡
function c65830223.filter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:GetControler()==1-tp
end
-- 检查送去墓地的卡片中是否存在对方的怪兽卡
function c65830223.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c65830223.filter,1,nil,tp)
end
-- 设置效果发动的目标，确定受到伤害的玩家为对方以及伤害数值为300
function c65830223.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的对象玩家为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置当前连锁的对象参数为300
	Duel.SetTargetParam(300)
	-- 设置当前连锁的操作信息为给与对方玩家300分伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,1-tp,300)
end
-- 执行效果处理，获取目标玩家和伤害数值并给与伤害
function c65830223.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的对象玩家和对象参数（伤害数值）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因给与目标玩家对应的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end

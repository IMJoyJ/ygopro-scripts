--雷仙神
-- 效果：
-- ①：这张卡可以支付3000基本分从手卡特殊召唤。
-- ②：这张卡的①的方法特殊召唤的这张卡被对方破坏的场合发动。自己回复5000基本分。
function c70493141.initial_effect(c)
	-- ①：这张卡可以支付3000基本分从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c70493141.hspcon)
	e1:SetOperation(c70493141.hspop)
	e1:SetValue(SUMMON_VALUE_SELF)
	c:RegisterEffect(e1)
	-- ②：这张卡的①的方法特殊召唤的这张卡被对方破坏的场合发动。自己回复5000基本分。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(70493141,0))
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(c70493141.reccon)
	e2:SetTarget(c70493141.rectg)
	e2:SetOperation(c70493141.recop)
	c:RegisterEffect(e2)
end
-- 特殊召唤规则的条件过滤：检查怪兽区域空位以及是否能支付3000基本分
function c70493141.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有可用的怪兽区域
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己是否能支付3000基本分
		and Duel.CheckLPCost(tp,3000)
end
-- 特殊召唤规则的动作：支付3000基本分
function c70493141.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 让玩家支付3000基本分
	Duel.PayLPCost(tp,3000)
end
-- 发动条件：被对方破坏，且是以自身①的方法特殊召唤的、原本在自己场上存在的这张卡
function c70493141.reccon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
end
-- 效果目标：设置回复对象为自己，回复数值为5000，并注册回复操作信息
function c70493141.rectg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的对象玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的对象参数为5000
	Duel.SetTargetParam(5000)
	-- 设置当前连锁的操作信息为：使自己回复5000基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,5000)
end
-- 效果处理：获取连锁信息并执行回复5000基本分
function c70493141.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因使目标玩家回复对应的基本分
	Duel.Recover(p,d,REASON_EFFECT)
end

--溶岩魔神ラヴァ・ゴーレム
-- 效果：
-- 这张卡不能通常召唤。把对方场上2只怪兽解放的场合可以在对方场上特殊召唤。把这张卡特殊召唤的回合，自己不能通常召唤。
-- ①：自己准备阶段发动。自己受到1000伤害。
function c102380.initial_effect(c)
	c:EnableReviveLimit()
	-- 把对方场上2只怪兽解放的场合可以在对方场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(102380,0))  --"特殊召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e1:SetRange(LOCATION_HAND)
	e1:SetTargetRange(POS_FACEUP,1)
	e1:SetCondition(c102380.spcon)
	e1:SetTarget(c102380.sptg)
	e1:SetOperation(c102380.spop)
	c:RegisterEffect(e1)
	-- 自己准备阶段发动。自己受到1000伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetDescription(aux.Stringid(102380,1))  --"1000伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c102380.damcon)
	e2:SetTarget(c102380.damtg)
	e2:SetOperation(c102380.damop)
	c:RegisterEffect(e2)
	-- 把这张卡特殊召唤的回合，自己不能通常召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_SPSUMMON_COST)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCost(c102380.spcost)
	e3:SetOperation(c102380.spcop)
	c:RegisterEffect(e3)
end
-- 定义过滤函数，检查解放指定怪兽后对方场上是否有可用的怪兽区域。
function c102380.fselect(g,tp)
	-- 计算对方玩家在解放怪兽组后可用怪兽区的数量，并检查是否大于0。
	return Duel.GetMZoneCount(1-tp,g,tp)>0
end
-- 检查是否满足特殊召唤条件，即对方场上有可解放的怪兽且解放后有空位。
function c102380.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检索对方场上所有可以因特殊召唤而解放的怪兽。
	local rg=Duel.GetMatchingGroup(Card.IsReleasable,tp,0,LOCATION_MZONE,nil,REASON_SPSUMMON)
	return rg:CheckSubGroup(c102380.fselect,2,2,tp)
end
-- 处理特殊召唤时的目标选择，让玩家选择要解放的怪兽。
function c102380.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 检索对方场上可解放的怪兽组用于选择。
	local rg=Duel.GetMatchingGroup(Card.IsReleasable,tp,0,LOCATION_MZONE,nil,REASON_SPSUMMON)
	-- 提示玩家选择解放的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local sg=rg:SelectSubGroup(tp,c102380.fselect,true,2,2,tp)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 执行特殊召唤的操作，解放选择的怪兽。
function c102380.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 以特殊召唤的原因解放指定的怪兽。
	Duel.Release(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 检查是否在伤害效果的发动条件，即是否为自己的准备阶段。
function c102380.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为触发效果的玩家。
	return Duel.GetTurnPlayer()==tp
end
-- 设置伤害效果的目标和参数。
function c102380.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 指定伤害效果的目标玩家。
	Duel.SetTargetPlayer(tp)
	-- 指定伤害的数值为1000。
	Duel.SetTargetParam(1000)
	-- 声明效果处理时将造成1000点伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,tp,1000)
end
-- 执行伤害效果的处理。
function c102380.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 从连锁信息中获取目标玩家和伤害值。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 实施伤害，给予玩家指定数值的伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 检查特殊召唤的代价条件，即是否进行过通常召唤。
function c102380.spcost(e,c,tp)
	-- 检测玩家在本回合中通常召唤的次数是否为0。
	return Duel.GetActivityCount(tp,ACTIVITY_NORMALSUMMON)==0
end
-- 执行特殊召唤代价的操作，即施加不能通常召唤的效果。
function c102380.spcop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 把这张卡特殊召唤的回合，自己不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	-- 将“不能通常召唤”的效果注册到全局环境。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_MSET)
	-- 将“不能放置”的效果注册到全局环境。
	Duel.RegisterEffect(e2,tp)
end

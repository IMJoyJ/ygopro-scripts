--天空勇士ネオパーシアス
-- 效果：
-- ①：这张卡可以把自己场上1只「天空骑士 珀耳修斯」解放从手卡特殊召唤。
-- ②：场上有「天空的圣域」存在，自己基本分比对方多的场合，这张卡的攻击力·守备力上升那个相差数值。
-- ③：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
-- ④：这张卡给与对方战斗伤害的场合发动。自己从卡组抽1张。
function c12510878.initial_effect(c)
	-- 为卡片注册与「天空骑士 珀耳修斯」相关的代码列表，用于后续效果判断
	aux.AddCodeList(c,56433456)
	-- ①：这张卡可以把自己场上1只「天空骑士 珀耳修斯」解放从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c12510878.spcon)
	e1:SetTarget(c12510878.sptg)
	e1:SetOperation(c12510878.spop)
	c:RegisterEffect(e1)
	-- ④：这张卡给与对方战斗伤害的场合发动。自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(12510878,0))  --"抽卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCondition(c12510878.condition)
	e2:SetTarget(c12510878.target)
	e2:SetOperation(c12510878.operation)
	c:RegisterEffect(e2)
	-- ③：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e3)
	-- ②：场上有「天空的圣域」存在，自己基本分比对方多的场合，这张卡的攻击力·守备力上升那个相差数值。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(c12510878.val)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e5)
end
-- 定义用于判断是否可以解放的卡片过滤器函数
function c12510878.spfilter(c,tp)
	-- 判断目标卡片是否为表侧表示的「天空骑士 珀耳修斯」且场上存在可用怪兽区
	return c:IsFaceup() and c:IsCode(18036057) and Duel.GetMZoneCount(tp,c)>0
end
-- 定义特殊召唤的条件判断函数
function c12510878.spcon(e,c)
	if c==nil then return true end
	-- 检查玩家场上是否存在满足条件的可解放卡片
	return Duel.CheckReleaseGroupEx(c:GetControler(),c12510878.spfilter,1,REASON_SPSUMMON,false,nil,c:GetControler())
end
-- 定义特殊召唤的目标选择函数
function c12510878.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家可解放的卡片组并筛选出符合条件的卡片
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c12510878.spfilter,nil,tp)
	-- 向玩家发送提示信息，提示选择要解放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 定义特殊召唤的操作函数
function c12510878.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将指定卡片从场上解放以完成特殊召唤
	Duel.Release(g,REASON_SPSUMMON)
end
-- 定义战斗伤害发动效果的条件函数
function c12510878.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 定义抽卡效果的目标设定函数
function c12510878.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果的目标参数为抽卡数量1
	Duel.SetTargetParam(1)
	-- 设置效果的操作信息为抽卡效果
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 定义抽卡效果的操作函数
function c12510878.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家从卡组抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 定义攻击力/守备力提升值的计算函数
function c12510878.val(e,c)
	-- 若当前没有「天空的圣域」在场，则返回0
	if not Duel.IsEnvironment(56433456) then return 0 end
	-- 计算当前玩家与对方玩家的LP差值
	local v=Duel.GetLP(c:GetControler())-Duel.GetLP(1-c:GetControler())
	if v>0 then return v else return 0 end
end

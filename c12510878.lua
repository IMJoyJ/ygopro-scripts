--天空勇士ネオパーシアス
-- 效果：
-- ①：这张卡可以把自己场上1只「天空骑士 珀耳修斯」解放从手卡特殊召唤。
-- ②：场上有「天空的圣域」存在，自己基本分比对方多的场合，这张卡的攻击力·守备力上升那个相差数值。
-- ③：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
-- ④：这张卡给与对方战斗伤害的场合发动。自己从卡组抽1张。
function c12510878.initial_effect(c)
	-- 将「天空的圣域」(56433456)记录为这张卡上记载的卡名，供规则上需要查看卡名记载的场合使用。
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
-- 特殊召唤素材的过滤函数：判断一张卡是否为可解放的素材，要求表侧表示、卡名为「天空骑士 珀耳修斯」(18036057)，且将其解放后tp方的主要怪兽区仍有空位可特殊召唤。
function c12510878.spfilter(c,tp)
	-- 返回真需要同时满足：该卡是表侧表示的「天空骑士 珀耳修斯」，且解放后tp方仍有怪兽区空格。
	return c:IsFaceup() and c:IsCode(18036057) and Duel.GetMZoneCount(tp,c)>0
end
-- 特殊召唤规则效果的条件函数：如果c为空表示允许规则特殊召唤；否则检查这张卡的控制者场上是否存在1张满足spfilter的可解放素材且解放后有空位。
function c12510878.spcon(e,c)
	if c==nil then return true end
	-- 检查这张卡的控制者场上是否存在至少1只满足spfilter条件（表侧表示的「天空骑士 珀耳修斯」且解放后有空位）的可解放卡。
	return Duel.CheckReleaseGroupEx(c:GetControler(),c12510878.spfilter,1,REASON_SPSUMMON,false,nil,c:GetControler())
end
-- 特殊召唤规则效果的选择函数：从可选解放卡组中筛出符合条件的「天空骑士 珀耳修斯」，由玩家选择1只，将选中卡存入效果LabelObject，选择成功返回true，否则返回false。
function c12510878.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取tp方可解放（非上级召唤用）的卡组并过滤，得到候选解放素材：表侧表示的「天空骑士 珀耳修斯」且解放后tp方有怪兽区空格。
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c12510878.spfilter,nil,tp)
	-- 弹出选择提示，让玩家选择要解放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则效果的处理函数：取出之前选择的素材并解放，完成特殊召唤手续中的解放动作。
function c12510878.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的卡以特殊召唤手续的原因（REASON_SPSUMMON）解放。
	Duel.Release(g,REASON_SPSUMMON)
end
-- ④的发动条件：本次战斗伤害的受伤害玩家ep不是这张卡的控制者tp，即这张卡给与对方战斗伤害时才发动。
function c12510878.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- ④的发动时目标设定：无取对象，设置目标玩家为自己，目标参数为抽卡张数1，并登记抽卡操作信息。
function c12510878.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设置为这张卡的控制者tp（抽卡玩家自己）。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设置为1，表示抽卡数量为1张。
	Duel.SetTargetParam(1)
	-- 向系统登记本次效果将执行抽卡操作：目标玩家tp，抽卡数量1（CATEGORY_DRAW）。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ④的效果处理函数：从连锁信息中取出目标玩家和抽卡数量，让对应玩家抽对应数量的卡。
function c12510878.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中记录的对象玩家和对象参数，分别保存为p（抽卡玩家）和d（抽卡数量）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p以效果原因（REASON_EFFECT）抽d张卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
-- ②的攻击力/守备力上升数值计算函数：若场上没有「天空的圣域」则上升0；否则计算自己LP减去对方LP的差值，差值大于0时返回该差值，否则返回0。
function c12510878.val(e,c)
	-- 若场上不存在「天空的圣域」(56433456)，则不满足②的场地条件，攻击力·守备力上升数值为0。
	if not Duel.IsEnvironment(56433456) then return 0 end
	-- 计算这张卡控制者的LP减去对方LP的差值，用于判断和计算②的上升数值。
	local v=Duel.GetLP(c:GetControler())-Duel.GetLP(1-c:GetControler())
	if v>0 then return v else return 0 end
end

--咎を擁く魔瞳
-- 效果：
-- ①：这次决斗中，以下效果各适用。
-- ●自己不能把手卡的怪兽的效果发动。
-- ●自己在5星以上的怪兽召唤的场合需要的解放可以不用。
-- ●自己要为魔法·陷阱卡发动而支付的基本分变成不需要。
-- ②：把墓地的这张卡除外，把手卡1张「魔瞳」卡给对方观看才能发动。给人观看的卡回到卡组最下面。那之后，自己抽1张。
local s,id,o=GetID()
-- 初始化效果：注册卡片发动（e1）与墓地起动效果（e2）
function s.initial_effect(c)
	-- ①：这次决斗中，以下效果各适用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetLabel(id)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，把手卡1张「魔瞳」卡给对方观看才能发动。给人观看的卡回到卡组最下面。那之后，自己抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"「拥抱过咎的魔瞳」效果适用中"
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	-- 设置发动成本为将墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
end
-- 卡片发动的目标检查：检查本局决斗中是否尚未适用过此卡的效果
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否未注册过该卡的效果标识，确保决斗中只能适用一次
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
end
-- 卡片发动后的效果处理：为玩家注册三个决斗中适用的永续型效果，并注册已适用标识
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- ●自己不能把手卡的怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))  --"「拥抱过咎的魔瞳」效果适用中"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.aclimit)
	-- 将不能发动手卡怪兽效果的限制注册给玩家
	Duel.RegisterEffect(e1,tp)
	-- ●自己在5星以上的怪兽召唤的场合需要的解放可以不用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))  --"使用「拥抱过咎的魔瞳」效果不用解放召唤"
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SUMMON_PROC)
	e2:SetTargetRange(LOCATION_HAND,0)
	e2:SetCondition(s.ntcon)
	e2:SetTarget(s.nttg)
	-- 将5星以上怪兽召唤无需解放的效果注册给玩家
	Duel.RegisterEffect(e2,tp)
	-- ●自己要为魔法·陷阱卡发动而支付的基本分变成不需要。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_LPCOST_CHANGE)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	e3:SetValue(s.costchange)
	-- 将发动魔陷免除支付基本分的效果注册给玩家
	Duel.RegisterEffect(e3,tp)
	-- 为玩家注册该卡已适用的全局标识效果
	Duel.RegisterFlagEffect(tp,id,0,0,1)
end
-- 限制发动条件：限制在手卡发动的怪兽效果
function s.aclimit(e,re,tp)
	return re:GetActivateLocation()==LOCATION_HAND and re:IsActiveType(TYPE_MONSTER)
end
-- 无需解放召唤的条件：需要是不需要解放且己方场上有怪兽区域空位
function s.ntcon(e,c,minc)
	if c==nil then return true end
	-- 检查是否为通常召唤且己方场上有可用的怪兽区域
	return minc==0 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 无需解放召唤的对象过滤：等级在5星以上的怪兽
function s.nttg(e,c)
	return c:IsLevelAbove(5)
end
-- 基本分支付改变：若为魔法·陷阱卡的发动且非连锁处理中，则将支付的基本分变为0
function s.costchange(e,re,rp,val)
	if re and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsType(TYPE_SPELL+TYPE_TRAP)
		-- 确保不是在连锁处理中（仅在发动时免除基本分支付）
		and not Duel.IsChainSolving() then
		return 0
	else return val end
end
-- 过滤手卡中未公开且可回到卡组的「魔瞳」卡
function s.cfilter(c)
	return c:IsSetCard(0x1bb) and c:IsAbleToDeck() and not c:IsPublic()
end
-- 墓地效果的发动准备：检查手卡是否有「魔瞳」卡、玩家是否能抽卡，并进行目标选择与信息设置
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在至少1张满足条件的「魔瞳」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil)
		-- 同时检查玩家当前是否可以抽卡
		and Duel.IsPlayerCanDraw(tp,1) end
	-- 在客户端提示玩家选择要送回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从手卡选择1张「魔瞳」卡
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选择的卡给对方玩家确认
	Duel.ConfirmCards(1-tp,g)
	-- 将选择的卡设定为效果处理对象
	Duel.SetTargetCard(g)
	-- 设置连锁信息：包含将1张卡送回卡组的操作
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	-- 设置连锁信息：包含玩家抽1张卡的操作
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 墓地效果的处理：将选中的卡送回卡组最下面，成功后自己抽1张卡
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择并确认的「魔瞳」卡
	local tc=Duel.GetFirstTarget()
	-- 若该卡仍与连锁相关，则将其送回持有者卡组最下面
	if tc:IsRelateToChain() and Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)>0
		and tc:IsLocation(LOCATION_DECK) then
		-- 中断当前效果处理，使后续的抽卡与回卡组不视为同时处理
		Duel.BreakEffect()
		-- 让玩家因效果抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end

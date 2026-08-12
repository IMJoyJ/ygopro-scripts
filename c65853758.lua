--ヤミー★リデンプション
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：对方场上的怪兽的攻击力下降自己的场上·墓地的兽族·光属性怪兽数量×200。
-- ②：自己把兽族·光属性同调怪兽同调召唤的场合才能发动（同一连锁上最多1次）。自己抽1张。那之后，选自己1张手卡回到卡组最下面。
-- ③：把墓地的这张卡除外，以自己场上1只「味美喵」怪兽和对方场上1只怪兽为对象才能发动。那2只怪兽的控制权交换。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含卡片发动、①的攻击力下降效果、②的同调召唤抽卡效果、③的墓地除外交换控制权效果。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	c:RegisterEffect(e1)
	-- ①：对方场上的怪兽的攻击力下降自己的场上·墓地的兽族·光属性怪兽数量×200。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(s.val)
	c:RegisterEffect(e2)
	-- ②：自己把兽族·光属性同调怪兽同调召唤的场合才能发动（同一连锁上最多1次）。自己抽1张。那之后，选自己1张手卡回到卡组最下面。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))  --"抽卡"
	e3:SetCategory(CATEGORY_DRAW+CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e3:SetCondition(s.drcon)
	e3:SetTarget(s.drtg)
	e3:SetOperation(s.drop)
	c:RegisterEffect(e3)
	-- ③：把墓地的这张卡除外，以自己场上1只「味美喵」怪兽和对方场上1只怪兽为对象才能发动。那2只怪兽的控制权交换。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"交换控制权"
	e4:SetCategory(CATEGORY_CONTROL)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCountLimit(1,id+o)
	-- 设置发动代价为将墓地的这张卡除外。
	e4:SetCost(aux.bfgcost)
	e4:SetTarget(s.cttg)
	e4:SetOperation(s.ctop)
	c:RegisterEffect(e4)
end
-- 过滤场上·墓地的兽族·光属性怪兽。
function s.atkfilter(c)
	return c:IsRace(RACE_BEAST) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsType(TYPE_MONSTER) and c:IsFaceupEx()
end
-- 计算攻击力下降数值的函数，返回符合条件的怪兽数量×(-200)。
function s.val(e,c)
	local tp=e:GetHandlerPlayer()
	-- 获取自己场上及自己墓地所有满足条件的兽族·光属性怪兽。
	local g=Duel.GetMatchingGroup(s.atkfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)
	return g:GetCount()*(-200)
end
-- 过滤自己同调召唤成功的表侧表示兽族·光属性同调怪兽。
function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_BEAST) and c:IsAttribute(ATTRIBUTE_LIGHT)
		and c:IsType(TYPE_SYNCHRO) and c:IsSummonType(SUMMON_TYPE_SYNCHRO)
		and c:IsSummonPlayer(tp)
end
-- 检查是否有自己同调召唤成功的兽族·光属性同调怪兽，作为效果发动的条件。
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 抽卡效果的发动准备函数，检查是否能抽卡，并设置抽卡和回卡组的操作信息。
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家当前是否可以执行抽1张卡的效果。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置效果处理的目标玩家为自己。
	Duel.SetTargetPlayer(tp)
	-- 设置效果处理的目标参数为1（抽1张卡）。
	Duel.SetTargetParam(1)
	-- 设置连锁的操作信息为抽卡，数量为1张。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	-- 设置连锁的操作信息为将手卡中的1张卡送回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
-- 抽卡效果的处理函数，执行抽1张卡，然后选择1张手卡回到卡组最下面。
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和抽卡数量。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 成功抽卡且手卡中存在可以送回卡组的卡时才继续处理。
	if Duel.Draw(p,d,REASON_EFFECT)~=0 and Duel.IsExistingMatchingCard(Card.IsAbleToDeck,p,LOCATION_HAND,0,1,nil) then
		-- 中断当前效果处理，使后续的“回到卡组”与“抽卡”不视为同时处理。
		Duel.BreakEffect()
		-- 提示玩家选择要送回卡组的卡。
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 让玩家从手卡中选择1张可以送回卡组的卡。
		local g=Duel.SelectMatchingCard(p,Card.IsAbleToDeck,p,LOCATION_HAND,0,1,1,nil)
		-- 洗切玩家的手卡。
		Duel.ShuffleHand(p)
		-- 将选中的手卡送回持有者卡组的最下面。
		Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
	end
end
-- 过滤对方场上可以转移控制权，且转移后不超出怪兽区域限制的怪兽。
function s.ctfilter1(c)
	local tp=c:GetControler()
	-- 检查卡片是否可以改变控制权，且在离开后对方场上是否有空余的怪兽区域。
	return c:IsAbleToChangeControler() and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
end
-- 过滤自己场上表侧表示的「味美喵」怪兽，且该怪兽可以转移控制权并满足区域限制。
function s.ctfilter2(c)
	local tp=c:GetControler()
	return c:IsFaceup() and c:IsSetCard(0x1ca) and c:IsAbleToChangeControler()
		-- 检查该怪兽离开后，自己场上是否有空余的怪兽区域以容纳对方转移过来的怪兽。
		and Duel.GetMZoneCount(tp,c,tp,LOCATION_REASON_CONTROL)>0
end
-- 交换控制权效果的发动准备函数，进行取对象操作并设置操作信息。
function s.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查对方场上是否存在至少1只满足控制权转移条件的怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.ctfilter1,tp,0,LOCATION_MZONE,1,nil)
		-- 检查自己场上是否存在至少1只满足条件的「味美喵」怪兽。
		and Duel.IsExistingTarget(s.ctfilter2,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要改变控制权的对方怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上1只怪兽作为效果的对象。
	local g1=Duel.SelectTarget(tp,s.ctfilter1,tp,0,LOCATION_MZONE,1,1,nil)
	-- 提示玩家选择要改变控制权的自己怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择自己场上1只「味美喵」怪兽作为效果的对象。
	local g2=Duel.SelectTarget(tp,s.ctfilter2,tp,LOCATION_MZONE,0,1,1,nil)
	g1:Merge(g2)
	-- 设置连锁的操作信息为交换2只怪兽的控制权。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g1,2,0,0)
end
-- 交换控制权效果的处理函数，执行两只怪兽的控制权交换。
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的两个对象怪兽。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local a=g:GetFirst()
	local b=g:GetNext()
	if a:IsRelateToEffect(e) and b:IsRelateToEffect(e) then
		-- 交换这两只怪兽的控制权。
		Duel.SwapControl(a,b)
	end
end

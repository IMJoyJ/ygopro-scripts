--ロード・オブ・ザ・タキオンギャラクシー
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。自己场上有「银河眼时空龙」怪兽存在的场合，这张卡的发动从手卡也能用。
-- ①：自己·对方的战斗阶段，把自己场上的「银河眼」超量怪兽1个超量素材取除才能发动（自己场上有「混沌No.」怪兽存在的场合，这张卡的发动和效果不会被无效化）。让这个回合召唤·特殊召唤的对方场上的怪兽全部回到卡组。
local s,id,o=GetID()
-- 初始化该卡的效果：注册“①：战斗阶段取除素材回卡组”的发动/处理效果、手卡发动效果，并注册全局召唤成功监听用于标记本回合召唤/特殊召唤成功的怪兽。
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己·对方的战斗阶段，把自己场上的「银河眼」超量怪兽1个超量素材取除才能发动（自己场上有「混沌No.」怪兽存在的场合，这张卡的发动和效果不会被无效化）。让这个回合召唤·特殊召唤的对方场上的怪兽全部回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"全部回到卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.tdcon)
	e1:SetCost(s.tdcost)
	e1:SetTarget(s.tdtg)
	e1:SetOperation(s.tdop)
	c:RegisterEffect(e1)
	-- 自己场上有「银河眼时空龙」怪兽存在的场合，这张卡的发动从手卡也能用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"适用「时空银河支配者」的效果来发动"
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(s.handcon)
	c:RegisterEffect(e2)
	if not s.global_check then
		s.global_check=true
		-- 自己场上有「银河眼时空龙」怪兽存在的场合，这张卡的发动从手卡也能用。①：自己·对方的战斗阶段，把自己场上的「银河眼」超量怪兽1个超量素材取除才能发动（自己场上有「混沌No.」怪兽存在的场合，这张卡的发动和效果不会被无效化）。让这个回合召唤·特殊召唤的对方场上的怪兽全部回到卡组。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SUMMON_SUCCESS)
		ge1:SetOperation(s.checkop)
		-- 将ge1注册为全局效果，用于监听任意一方通常召唤成功时点。
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_SPSUMMON_SUCCESS)
		-- 将ge2注册为全局效果，用于监听任意一方特殊召唤成功时点。
		Duel.RegisterEffect(ge2,0)
	end
end
-- 全局监听回调：给本次召唤/特殊召唤成功的每只怪兽设置一个回合结束前有效的标记，用于之后筛选“这个回合召唤·特殊召唤的怪兽”。
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 遍历事件组eg中的每只怪兽，逐一处理标记。
	for tc in aux.Next(eg) do
		tc:RegisterFlagEffect(id,RESET_PHASE+PHASE_END,0,1)
	end
end
-- 判定怪兽是否为表侧表示且属于「银河眼时空龙」（0x307b）字段，用于手卡发动条件的判断。
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x307b)
end
-- 手卡发动效果的条件：自己场上有满足s.filter的「银河眼时空龙」怪兽存在。
function s.handcon(e)
	-- 检查自己场上是否存在至少1只表侧表示的「银河眼时空龙」怪兽。
	return Duel.IsExistingMatchingCard(s.filter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- ①效果发动条件：当前处于战斗阶段（战斗阶段开始或战斗阶段期间）。
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前决斗阶段并保存到局部变量ph。
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
-- 筛选条件：表侧表示的超量怪兽且属于「银河眼」（0x107b）字段，用于取除素材的代价选择。
function s.xfilter(c)
	return c:IsSetCard(0x107b) and c:IsType(TYPE_XYZ) and c:IsFaceup()
end
-- ①效果的代价处理：先收集自己场上所有符合条件的「银河眼」超量怪兽的超量素材，然后选择其中1个，作为取除素材的代价送入墓地。
function s.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local xg=Group.CreateGroup()
	-- 获取自己场上所有表侧表示的「银河眼」超量怪兽。
	local mg=Duel.GetMatchingGroup(s.xfilter,tp,LOCATION_MZONE,0,nil)
	-- 遍历这些超量怪兽，将其各自的超量素材合并到xg组中。
	for tc in aux.Next(mg) do
		xg:Merge(tc:GetOverlayGroup())
	end
	if chk==0 then return xg:GetCount()>0 end
	local cost=xg:Select(tp,1,1,nil)
	-- 将选中的超量素材作为代价（REASON_COST）送去墓地，完成取除素材。
	Duel.SendtoGrave(cost,REASON_COST)
end
-- 筛选带有本回合召唤/特殊召唤标记且可以返回卡组的怪兽，作为回卡组的对象。
function s.tdfilter(c)
	return c:GetFlagEffect(id)>0 and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 筛选自己场上表侧表示的「混沌No.」（0x1048）怪兽，用于赋予抗性。
function s.cfilter(c)
	return c:IsSetCard(0x1048) and c:IsFaceup()
end
-- ①效果发动时的目标处理：检查是否有符合条件的怪兽，登记回卡组操作信息；若自己场上有「混沌No.」怪兽，额外为效果附加‘不会被无效化’的属性。
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在chk==0的合法性检查中，确认对方场上至少存在1只可回卡组且带本回合召唤标记的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 取得所有当前符合回卡组条件的对方怪兽（本回合召唤/特殊召唤过的可回卡组怪兽）。
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,0,LOCATION_MZONE,nil)
	-- 为该连锁登记CATEGORY_TODECK操作信息，记录将要返回卡组的怪兽组及数量、位置（对方主要怪兽区），供相关效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,LOCATION_MZONE)
	-- 若自己场上存在表侧表示的「混沌No.」怪兽，则进入附加抗性的分支。
	if Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil) then
		e:SetProperty(EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	end
end
-- ①效果处理：取得对方场上所有本回合召唤/特殊召唤过且可回卡组的怪兽，使其全部返回卡组并洗牌。
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新获取符合条件的对方怪兽组，以反映当前场上状态。
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,0,LOCATION_MZONE,nil)
	-- 将这些怪兽以效果原因（REASON_EFFECT）送回持有者卡组，并使用SEQ_DECKSHUFFLE洗牌。
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end

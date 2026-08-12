--赫ける王の烙印
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：选需以「阿不思的落胤」为融合素材的自己场上1只融合怪兽，那只怪兽以外的场上的全部表侧表示的卡的效果直到回合结束时无效。
-- ②：这个回合有融合怪兽被送去自己墓地的场合，结束阶段才能发动。墓地的这张卡加入手卡。
local s,id,o=GetID()
-- 初始化效果函数，注册卡名代码列表并创建两个效果，分别对应①②效果
function s.initial_effect(c)
	-- 注册卡名代码列表，记录该卡与「阿不思的落胤」的关联
	aux.AddCodeList(c,68468459)
	-- ①：选需以「阿不思的落胤」为融合素材的自己场上1只融合怪兽，那只怪兽以外的场上的全部表侧表示的卡的效果直到回合结束时无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- ②：这个回合有融合怪兽被送去自己墓地的场合，结束阶段才能发动。墓地的这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(TIMING_END_PHASE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	if not s.global_check then
		s.global_check=true
		-- 全局监听墓地事件，用于检测是否有融合怪兽被送去墓地
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_TO_GRAVE)
		ge1:SetOperation(s.checkop)
		-- 将全局效果注册到游戏环境
		Duel.RegisterEffect(ge1,0)
	end
end
-- 检查目标是否为融合怪兽且控制者为指定玩家
function s.checkfilter(c,tp)
	return c:IsType(TYPE_FUSION) and c:IsControler(tp)
end
-- 当有卡送去墓地时，检查是否存在融合怪兽，若存在则为玩家注册标识效果
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	for p=0,1 do
		-- 若存在融合怪兽，则为对应玩家注册一个标识效果，用于标记该回合有融合怪兽被送去墓地
		if eg:IsExists(s.checkfilter,1,nil,p) then Duel.RegisterFlagEffect(p,id,RESET_PHASE+PHASE_END,0,1) end
	end
end
-- 筛选满足条件的融合怪兽，即表侧表示、融合类型、以「阿不思的落胤」为素材，并且场上存在可无效化的卡
function s.filter(c)
	-- 筛选表侧表示的融合怪兽，且以「阿不思的落胤」为素材
	return c:IsFaceup() and c:IsType(TYPE_FUSION) and aux.IsMaterialListCode(c,68468459)
		-- 确保场上存在可被无效化的卡
		and Duel.IsExistingMatchingCard(s.dfilter,0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
end
-- 筛选表侧表示的卡，用于判断是否可以被无效化
function s.dfilter(c)
	-- 判断卡是否可以被无效化
	return c:IsFaceup() and aux.NegateAnyFilter(c)
end
-- 目标函数，检查场上是否存在满足条件的融合怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的融合怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 效果处理函数，选择融合怪兽并使场上其他卡的效果无效
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足条件的融合怪兽
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	if #g==0 then return end
	-- 显示所选卡被选为对象的动画效果
	Duel.HintSelection(g)
	-- 获取所有可被无效化的场上卡
	local ng=Duel.GetMatchingGroup(s.dfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,g)
	-- 遍历所有可被无效化的卡
	for nc in aux.Next(ng) do
		-- 使目标卡相关的连锁无效化
		Duel.NegateRelatedChain(nc,RESET_TURN_SET)
		-- 创建一个使目标卡效果无效的永续效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		nc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		nc:RegisterEffect(e2)
		if nc:IsType(TYPE_TRAPMONSTER) then
			local e3=e1:Clone()
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			nc:RegisterEffect(e3)
		end
	end
end
-- 条件函数，判断是否满足②效果发动条件
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断该回合是否有融合怪兽被送去墓地且当前为结束阶段
	return Duel.GetFlagEffect(tp,id)>0 and Duel.GetCurrentPhase()==PHASE_END
end
-- 设置②效果的发动目标
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	-- 设置操作信息，指定将卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
-- ②效果的处理函数，将卡加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断卡是否与效果相关联，若关联则将其加入手牌
	if c:IsRelateToEffect(e) then Duel.SendtoHand(c,nil,REASON_EFFECT) end
end

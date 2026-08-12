--宝玉の奇跡
--not fully implemented
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：怪兽的效果·魔法·陷阱卡发动时才能发动。选自己场上1张「宝玉兽」卡破坏，那个发动无效并破坏。
-- ②：这张卡在墓地存在的状态，自己的魔法与陷阱区域有「宝玉兽」卡被放置的场合，把这张卡除外才能发动（伤害步骤也能发动）。从自己的手卡·卡组·墓地选1只「宝玉兽」怪兽当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
local s,id,o=GetID()
-- 注册两个效果：①连锁发动时无效并破坏宝玉兽卡；②墓地时，魔法陷阱区放置宝玉兽卡时可特殊召唤宝玉兽怪兽为永续魔法卡
function s.initial_effect(c)
	-- ①：怪兽的效果·魔法·陷阱卡发动时才能发动。选自己场上1张「宝玉兽」卡破坏，那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，自己的魔法与陷阱区域有「宝玉兽」卡被放置的场合，把这张卡除外才能发动（伤害步骤也能发动）。从自己的手卡·卡组·墓地选1只「宝玉兽」怪兽当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CUSTOM+id)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCondition(s.placecon)
	-- 将此卡除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.placetg)
	e2:SetOperation(s.placeop)
	c:RegisterEffect(e2)
	if not s.global_check then
		s.global_check=true
		-- 注册一个全局场上的移动事件监听器，用于检测宝玉兽卡被放置到场上时触发效果
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_MOVE)
		ge1:SetCondition(s.regcon)
		ge1:SetOperation(s.regop)
		-- 将效果ge1注册到玩家0（即全局）
		Duel.RegisterEffect(ge1,0)
	end
end
-- 判断连锁是否为魔法或怪兽卡发动且可被无效
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 发动无效且可被无效的魔法或怪兽卡
	return (re:IsHasType(EFFECT_TYPE_ACTIVATE) or re:IsActiveType(TYPE_MONSTER)) and Duel.IsChainNegatable(ev)
end
-- 过滤场上正面表示的宝玉兽卡
function s.desfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1034)
end
-- 设置效果处理信息：破坏一张宝玉兽卡和无效发动
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取场上正面表示的宝玉兽卡组
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_ONFIELD,0,nil)
	if chk==0 then return #g>0 end
	-- 设置破坏一张宝玉兽卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置无效发动的操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置同时破坏宝玉兽卡和发动卡的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g+eg,2,0,0)
	end
end
-- 执行效果：选择并破坏一张宝玉兽卡，无效发动并破坏发动卡
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要破坏的宝玉兽卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上正面表示的一张宝玉兽卡
	local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 破坏所选宝玉兽卡
	if Duel.Destroy(g,REASON_EFFECT)>0
		-- 无效发动并确认发动卡存在
		and Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏发动卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 过滤场上正面表示的宝玉兽卡（位于魔法陷阱区）
function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x1034) and c:IsControler(tp) and c:IsLocation(LOCATION_SZONE) and c:GetSequence()<5
end
-- 判断是否有宝玉兽卡被放置到场上
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	local v=0
	if eg:IsExists(s.cfilter,1,nil,0) then v=v+1 end
	if eg:IsExists(s.cfilter,1,nil,1) then v=v+2 end
	if v==0 then return false end
	e:SetLabel(({0,1,PLAYER_ALL})[v])
	return true
end
-- 触发自定义事件，通知②效果可以发动
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取墓地中的宝玉の奇跡卡组
	local g=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,id)
	-- 触发自定义事件，通知②效果可以发动
	Duel.RaiseEvent(g,EVENT_CUSTOM+id,re,r,rp,ep,e:GetLabel())
end
-- 判断是否为自己的宝玉兽卡被放置到场上
function s.placecon(e,tp,eg,ep,ev,re,r,rp)
	return (ev==tp or ev==PLAYER_ALL) and eg:IsContains(e:GetHandler())
end
-- 过滤可使用的宝玉兽怪兽卡
function s.filter(c)
	return c:IsSetCard(0x1034) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
-- 设置②效果的发动条件：手牌/卡组/墓地有宝玉兽怪兽且魔法陷阱区有空位
function s.placetg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌/卡组/墓地是否有宝玉兽怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND,0,1,nil)
		-- 检查魔法陷阱区是否有空位
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
end
-- 执行②效果：选择并特殊召唤宝玉兽怪兽为永续魔法卡
function s.placeop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查魔法陷阱区是否有空位
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 提示玩家选择要放置到场上的宝玉兽卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 选择一张宝玉兽怪兽卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将宝玉兽怪兽卡放置到魔法陷阱区
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		-- 将宝玉兽怪兽卡变为永续魔法卡
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
	end
end

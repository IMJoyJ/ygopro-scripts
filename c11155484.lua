--宝玉の奇跡
--not fully implemented
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：怪兽的效果·魔法·陷阱卡发动时才能发动。选自己场上1张「宝玉兽」卡破坏，那个发动无效并破坏。
-- ②：这张卡在墓地存在的状态，自己的魔法与陷阱区域有「宝玉兽」卡被放置的场合，把这张卡除外才能发动（伤害步骤也能发动）。从自己的手卡·卡组·墓地选1只「宝玉兽」怪兽当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
local s,id,o=GetID()
-- 注册这张卡的三个部分：①作为反击式通常魔法无效并破坏发动；②作为墓地中满足条件时除外自身从手卡·卡组·墓地选宝玉兽怪兽放置到魔陷区；以及一个全局监视效果，用于检测宝玉兽卡被放置到魔陷区以触发②。
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
	-- 设置②效果的发动代价：把墓地中的这张卡自身除外作为COST。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.placetg)
	e2:SetOperation(s.placeop)
	c:RegisterEffect(e2)
	if not s.global_check then
		s.global_check=true
		-- ①：怪兽的效果·魔法·陷阱卡发动时才能发动。选自己场上1张「宝玉兽」卡破坏，那个发动无效并破坏。②：这张卡在墓地存在的状态，自己的魔法与陷阱区域有「宝玉兽」卡被放置的场合，把这张卡除外才能发动（伤害步骤也能发动）。从自己的手卡·卡组·墓地选1只「宝玉兽」怪兽当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_MOVE)
		ge1:SetCondition(s.regcon)
		ge1:SetOperation(s.regop)
		-- 将全局监视效果注册为全场效果：监听卡片移动事件，以便在宝玉兽卡被放置到魔陷区时触发②效果所需的自定义时点。
		Duel.RegisterEffect(ge1,0)
	end
end
-- ①效果的发动条件函数：仅当连锁的是怪兽效果或魔法·陷阱卡发动，且该连锁能够被无效时，这张卡才能发动。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定条件：被连锁的发动是魔陷卡发动或怪兽效果发动，并且该连锁可被无效化。
	return (re:IsHasType(EFFECT_TYPE_ACTIVATE) or re:IsActiveType(TYPE_MONSTER)) and Duel.IsChainNegatable(ev)
end
-- ①效果的破坏对象筛选：选择自己场上表侧表示且卡名含有「宝玉兽」字段的卡。
function s.desfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1034)
end
-- ①效果发动时的目标处理：检索自己场上可破坏的宝玉兽卡，若存在则设置操作信息：破坏1张宝玉兽卡、无效该发动；若被无效的卡本身可破坏且仍与效果关联，则将其也列入破坏对象。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上所有表侧表示且卡名为「宝玉兽」的卡作为候选破坏对象。
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_ONFIELD,0,nil)
	if chk==0 then return #g>0 end
	-- 设置操作信息：预定从候选的宝玉兽卡中破坏1张（CATEGORY_DESTROY）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息：预定使当前连锁（eg）的发动无效（CATEGORY_NEGATE）。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 若被无效的卡本身可破坏且仍与那个效果关联，则将那张卡也加入破坏对象，合计预定破坏2张。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g+eg,2,0,0)
	end
end
-- ①效果处理：玩家从候选宝玉兽卡中选1张破坏；若破坏成功且该连锁被无效，并且被无效的卡仍与效果关联，则将发动中的那张卡也破坏。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示，让玩家选择要破坏的自己场上的「宝玉兽」卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从自己场上表侧表示的「宝玉兽」卡中选择1张作为破坏对象。
	local g=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 破坏所选的那张宝玉兽卡，并判断是否破坏成功（返回值大于0）。
	if Duel.Destroy(g,REASON_EFFECT)>0
		-- 检查是否成功无效了该连锁发动，并且发动无效的那张卡仍然与效果关联（未离场）。
		and Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将正在发动的那张卡（eg）破坏。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 筛选被移动的卡：是否为表侧表示的「宝玉兽」卡、控制者是否为指定玩家、且位于魔法与陷阱区域的通常区域（非场地格），用于判断宝玉兽卡是否被放置到魔陷区。
function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x1034) and c:IsControler(tp) and c:IsLocation(LOCATION_SZONE) and c:GetSequence()<5
end
-- 全局监视的条件：检测移动事件中是否有玩家0或玩家1的宝玉兽卡被放置到魔陷区，用标签记录触发玩家（0/1/双方），没有则返回false。
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	local v=0
	if eg:IsExists(s.cfilter,1,nil,0) then v=v+1 end
	if eg:IsExists(s.cfilter,1,nil,1) then v=v+2 end
	if v==0 then return false end
	e:SetLabel(({0,1,PLAYER_ALL})[v])
	return true
end
-- 全局监视的操作：当检测到宝玉兽卡被放置到魔陷区时，检索双方墓地中所有此卡，并向它们触发自定义事件，传递放置玩家的信息。
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方墓地中所有卡名为「宝玉的奇迹」的卡。
	local g=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,id)
	-- 向这些墓地的「宝玉的奇迹」触发EVENT_CUSTOM+id事件，并将触发方玩家信息（0/1/双方）作为ev数值传递。
	Duel.RaiseEvent(g,EVENT_CUSTOM+id,re,r,rp,ep,e:GetLabel())
end
-- ②效果的发动条件：事件ev表示放置宝玉兽卡的玩家是自己或双方，且事件对象中包含墓地中的这张卡。
function s.placecon(e,tp,eg,ep,ev,re,r,rp)
	return (ev==tp or ev==PLAYER_ALL) and eg:IsContains(e:GetHandler())
end
-- ②效果可选怪兽的筛选：卡名含「宝玉兽」的怪兽卡，且该卡没有被禁止（可以放置在魔陷区）。
function s.filter(c)
	return c:IsSetCard(0x1034) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
-- ②效果的发动目标检查：检索自己手卡·卡组·墓地是否存在符合条件的宝玉兽怪兽，且自己魔陷区有空位。
function s.placetg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手卡·卡组·墓地中是否存在至少1只符合条件的「宝玉兽」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND,0,1,nil)
		-- 并且自己的魔法与陷阱区域有空位可以放置。
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
end
-- ②效果处理：确认魔陷区有空位后，玩家从手卡·卡组·墓地选择1只符合条件的「宝玉兽」怪兽，移动到自己的魔陷区表侧表示放置，并附加‘当作永续魔法卡使用’的效果。
function s.placeop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果自己的魔陷区没有空位，则效果处理不执行。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 弹出选择提示，让玩家选择要放置到场上的「宝玉兽」怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从自己手卡·卡组·墓地选择符合条件的「宝玉兽」怪兽（使用王家长眠之谷过滤，防止选到受其影响无法从墓地移动的卡）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的「宝玉兽」怪兽移动到自己的魔法与陷阱区域，表侧表示放置，并使其效果立即适用。
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		-- 当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
	end
end

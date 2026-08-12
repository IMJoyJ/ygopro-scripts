--ARG☆S－栄冠のアドラ
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：对方回合，自己场上有永续陷阱卡存在的场合，把这张卡从手卡除外才能发动。场上1只怪兽的攻击力直到回合结束时变成0。
-- ②：这张卡召唤的场合发动。这个回合，对方不能对应自己的永续陷阱卡的效果的发动把效果发动。
-- ③：把场上的这张卡除外才能发动。从手卡·卡组把最多2张「阿尔戈☆群星」永续陷阱卡在自己的魔法与陷阱区域表侧表示放置（同名卡最多1张）。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数。
function s.initial_effect(c)
	-- ①：对方回合，自己场上有永续陷阱卡存在的场合，把这张卡从手卡除外才能发动。场上1只怪兽的攻击力直到回合结束时变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"攻击力变为0"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_DAMAGE_STEP)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.atkcon)
	-- 发动代价：把这张卡从手卡除外。
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤的场合发动。这个回合，对方不能对应自己的永续陷阱卡的效果的发动把效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"不能对应发动"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
	-- ③：把场上的这张卡除外才能发动。从手卡·卡组把最多2张「阿尔戈☆群星」永续陷阱卡在自己的魔法与陷阱区域表侧表示放置（同名卡最多1张）。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"表侧表示放置"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id)
	-- 发动代价：把场上的这张卡除外。
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)
end
-- 过滤条件：场上表侧表示的永续陷阱卡。
function s.cfilter(c)
	return c:IsAllTypes(TYPE_TRAP+TYPE_CONTINUOUS) and c:IsFaceup()
end
-- 效果①的发动条件：对方回合且自己场上有表侧表示的永续陷阱卡存在。
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为对方回合，以及自己场上是否存在表侧表示的永续陷阱卡。
	return Duel.GetTurnPlayer()~=tp and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 效果①的发动准备：检查场上是否存在攻击力不为0的怪兽，并设置改变攻击力的操作信息。
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取场上所有攻击力不为0的表侧表示怪兽。
	local g=Duel.GetMatchingGroup(aux.nzatk,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if chk==0 then return #g>0 end
	-- 设置操作信息：改变场上1只怪兽的攻击力。
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,g,1,0,0)
end
-- 效果①的处理：选择场上1只攻击力不为0的怪兽，使其攻击力直到回合结束时变成0。
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要操作的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 让玩家从场上选择1只攻击力不为0的表侧表示怪兽。
	local g=Duel.GetMatchingGroup(aux.nzatk,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil):Select(tp,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 闪烁显示被选择的怪兽。
		Duel.HintSelection(g)
		-- 场上1只怪兽的攻击力直到回合结束时变成0。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(0)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 效果②的处理：注册一个持续到回合结束的全局效果，用于限制对方的连锁。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合，对方不能对应自己的永续陷阱卡的效果的发动把效果发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAINING)
	e1:SetOperation(s.actop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将限制对方连锁的全局效果注册给发动效果的玩家。
	Duel.RegisterEffect(e1,tp)
end
-- 连锁发生时的处理：如果自己发动了永续陷阱卡的效果，则限制对方的连锁。
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if rc:IsAllTypes(TYPE_TRAP+TYPE_CONTINUOUS) and ep==tp then
		-- 设定连锁限制，阻止对方对应发动效果。
		Duel.SetChainLimit(s.chainlm)
	end
end
-- 连锁限制条件：只有发动玩家与当前连锁玩家相同时才能连锁（即对方不能连锁）。
function s.chainlm(e,rp,tp)
	return tp==rp
end
-- 过滤条件：手牌或卡组中可以表侧表示放置到魔陷区的「阿尔戈☆群星」永续陷阱卡。
function s.setfilter(c,tp)
	return c:IsSetCard(0x1c1) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
		and c:IsAllTypes(TYPE_TRAP+TYPE_CONTINUOUS)
end
-- 效果③的发动准备：检查手牌或卡组中是否存在可放置的「阿尔戈☆群星」永续陷阱卡，且自己魔陷区有空位。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取手牌和卡组中满足条件的「阿尔戈☆群星」永续陷阱卡。
	local g=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_DECK+LOCATION_HAND,0,nil,tp)
	-- 检查手牌或卡组中是否有符合条件的卡，且自己的魔法与陷阱区域是否有空位。
	if chk==0 then return #g>0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
end
-- 效果③的处理：从手牌·卡组选择最多2张卡名不同的「阿尔戈☆群星」永续陷阱卡在自己的魔法与陷阱区域表侧表示放置。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己魔法与陷阱区域的可用空格数。
	local ct=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if ct<1 then return end
	if ct>2 then ct=2 end
	-- 重新获取手牌和卡组中满足条件的「阿尔戈☆群星」永续陷阱卡。
	local g=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_DECK+LOCATION_HAND,0,nil,tp)
	-- 提示玩家选择要放置到场上的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 让玩家选择最多等同于空位数（且最多2张）的卡名不同的卡片组。
	local tg1=g:SelectSubGroup(tp,aux.dncheck,false,1,ct)
	if tg1 then
		-- 遍历玩家选择的卡片。
		for tc in aux.Next(tg1) do
			-- 将选中的卡片在自己的魔法与陷阱区域表侧表示放置。
			Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		end
	end
end

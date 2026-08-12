--目白圧し
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个，若非怪兽区域的卡和魔法与陷阱区域的表侧表示的怪兽卡合计10张以上存在的场合则不能发动。
-- ①：从卡组把1只怪兽当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
-- ②：把墓地的这张卡除外才能发动。从卡组把1只怪兽当作永续陷阱卡使用在自己的魔法与陷阱区域表侧表示放置。
local s,id,o=GetID()
-- 注册两个效果：①作为永续魔法卡发动的效果和②从墓地发动作为永续陷阱卡发动的效果
function s.initial_effect(c)
	-- ①：从卡组把1只怪兽当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。从卡组把1只怪兽当作永续陷阱卡使用在自己的魔法与陷阱区域表侧表示放置。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.condition)
	-- 将此卡除外作为效果②的费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation2)
	c:RegisterEffect(e2)
end
-- 判断是否为非怪兽区域的卡或魔法与陷阱区域的表侧表示怪兽卡
function s.check(c)
	return c:IsLocation(LOCATION_MZONE) or (c:GetOriginalType()&TYPE_MONSTER>0 and c:IsFaceup())
end
-- 判断非怪兽区域的卡和魔法与陷阱区域的表侧表示的怪兽卡合计是否超过9张
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 非怪兽区域的卡和魔法与陷阱区域的表侧表示的怪兽卡合计超过9张
	return Duel.GetMatchingGroupCount(s.check,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)>9
end
-- 过滤函数，筛选可使用的怪兽卡
function s.filter(c)
	return c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
-- 判断是否满足发动条件：卡组存在可用怪兽且场上存在空位
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 卡组中是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil)
		-- 场上是否存在空位
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
end
-- 效果①的处理函数：从卡组选择一只怪兽当作永续魔法卡放置到场上
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否还有空位
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 提示玩家选择要放置到场上的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从卡组中选择一张满足条件的怪兽卡
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽卡移动到场上作为永续魔法卡
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		-- 将选中的怪兽卡变为永续魔法卡类型
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
	end
end
-- 效果②的处理函数：从墓地发动，从卡组选择一只怪兽当作永续陷阱卡放置到场上
function s.operation2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否还有空位
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 提示玩家选择要放置到场上的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从卡组中选择一张满足条件的怪兽卡
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽卡移动到场上作为永续陷阱卡
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		-- 将选中的怪兽卡变为永续陷阱卡类型
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_TRAP+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
	end
end

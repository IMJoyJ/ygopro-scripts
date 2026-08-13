--目白圧し
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个，若非怪兽区域的卡和魔法与陷阱区域的表侧表示的怪兽卡合计10张以上存在的场合则不能发动。
-- ①：从卡组把1只怪兽当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
-- ②：把墓地的这张卡除外才能发动。从卡组把1只怪兽当作永续陷阱卡使用在自己的魔法与陷阱区域表侧表示放置。
local s,id,o=GetID()
-- 创建并注册两个效果：e1为①效果，作为魔法卡发动；e2为②效果，在墓地作为起动效果；二者通过SetCountLimit(1,id)共用1回合1次的发动次数，并都受s.condition限制。
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个，若非怪兽区域的卡和魔法与陷阱区域的表侧表示的怪兽卡合计10张以上存在的场合则不能发动。①：从卡组把1只怪兽当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个，若非怪兽区域的卡和魔法与陷阱区域的表侧表示的怪兽卡合计10张以上存在的场合则不能发动。②：把墓地的这张卡除外才能发动。从卡组把1只怪兽当作永续陷阱卡使用在自己的魔法与陷阱区域表侧表示放置。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.condition)
	-- 设置②效果的发动代价为：把墓地里的这张卡除外（aux.bfgcost实现）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation2)
	c:RegisterEffect(e2)
end
-- s.check用于统计发动条件所需卡片：位于主要怪兽区的卡，或原本是怪兽且表侧表示的卡（包括被放置在魔法与陷阱区域的表侧怪兽卡）均计入。
function s.check(c)
	return c:IsLocation(LOCATION_MZONE) or (c:GetOriginalType()&TYPE_MONSTER>0 and c:IsFaceup())
end
-- s.condition为发动条件：双方场上满足s.check的卡合计超过9张（即10张以上）时才能发动。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 统计双方场上满足s.check的卡数量是否大于9，即是否达到10张以上。
	return Duel.GetMatchingGroupCount(s.check,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)>9
end
-- s.filter为选择卡组怪兽的过滤条件：怪兽卡且未被禁止（非禁止卡）。
function s.filter(c)
	return c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
-- s.target为发动时的合法性检查：卡组中存在至少1只满足s.filter的怪兽，且自己的魔法与陷阱区域有空位。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只满足s.filter的怪兽卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil)
		-- 同时检查自己的魔法与陷阱区域是否有空位（大于0）。
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 end
end
-- ①效果处理：若自己的魔陷区有空位，从卡组选择1只满足s.filter的怪兽，移动到自己的魔法与陷阱区域表侧表示放置，并给它附加变为永续魔法卡的效果。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 处理前再次确认自己的魔法与陷阱区域有空位，若没有空位则不执行放置。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 向操作者显示提示文字，要求选择要放置到场上的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从卡组中选出1只满足s.filter的怪兽卡。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽卡由当前玩家移动到自己的魔法与陷阱区域，以表侧表示放置。
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		-- 从卡组把1只怪兽当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
	end
end
-- ②效果处理：若自己的魔陷区有空位，从卡组选择1只满足s.filter的怪兽，移动到自己的魔法与陷阱区域表侧表示放置，并给它附加变为永续陷阱卡的效果。
function s.operation2(e,tp,eg,ep,ev,re,r,rp)
	-- 处理前再次确认自己的魔法与陷阱区域有空位，若没有空位则不执行放置。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 向操作者显示提示文字，要求选择要放置到场上的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从卡组中选出1只满足s.filter的怪兽卡。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽卡由当前玩家移动到自己的魔法与陷阱区域，以表侧表示放置。
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		-- 从卡组把1只怪兽当作永续陷阱卡使用在自己的魔法与陷阱区域表侧表示放置。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_TRAP+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
	end
end

--再世十戒
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：和自己场上的「再世」怪兽相同纵列的对方场上的全部卡受以下效果适用。
-- ●表侧表示卡：效果无效化。
-- ●里侧表示怪兽：不能把表示形式变更。
-- ●里侧表示的魔法·陷阱卡：直到下个回合的结束时不能发动。
local s,id,o=GetID()
-- 初始化并注册卡片的效果，设置同名卡一回合只能发动一张的限制。
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：筛选自己场上表侧表示的「再世」怪兽，且其相同纵列的对方场上存在可适用效果的卡。
function s.cfilter(c,tp)
	local g=c:GetColumnGroup():Filter(Card.IsControler,nil,1-tp)
	return c:IsFaceup() and c:IsSetCard(0x1c5)
		and g:IsExists(s.dfilter,1,nil)
end
-- 过滤函数：检查纵列上的对方卡片是否符合适用效果的条件（表侧表示可无效，或里侧表示）。
function s.dfilter(c)
	if c:IsFaceup() then
		-- 检查该表侧表示卡片是否属于可被无效化的卡片类型。
		return aux.NegateAnyFilter(c)
	elseif c:IsFacedown() then
		return true
	end
	return false
end
-- 效果发动的目标检查，确认自己场上是否存在符合条件的「再世」怪兽。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只相同纵列有对方卡片可适用效果的表侧表示「再世」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
end
-- 核心处理函数：根据卡片的表里侧状态及卡片类型，分别适用无效化、不能变更表示形式或不能发动的效果。
function s.dop(c,e)
	-- 判断卡片是否为表侧表示、符合无效条件且可以被该效果无效。
	if c:IsFaceup() and aux.NegateAnyFilter(c) and c:IsCanBeDisabledByEffect(e,false) then
		-- 使与该卡相关的连锁中已发动的效果无效化。
		Duel.NegateRelatedChain(c,RESET_TURN_SET)
		-- ●表侧表示卡：效果无效化。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		c:RegisterEffect(e2)
		if c:IsType(TYPE_TRAPMONSTER) then
			local e3=e1:Clone()
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			c:RegisterEffect(e3)
		end
	end
	if c:IsFacedown() and c:IsType(TYPE_MONSTER) then
		-- ●里侧表示怪兽：不能把表示形式变更。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	elseif c:IsFacedown() and c:IsType(TYPE_SPELL+TYPE_TRAP) then
		-- ●里侧表示的魔法·陷阱卡：直到下个回合的结束时不能发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		c:RegisterEffect(e1)
	end
end
-- 效果处理函数：获取自己场上所有「再世」怪兽相同纵列的对方场上卡片，并对其适用相应的效果。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有相同纵列存在对方卡片的表侧表示「再世」怪兽。
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil,tp)
	if g:GetCount()==0 then return end
	local sg=Group.CreateGroup()
	-- 遍历这些「再世」怪兽，获取并合并它们相同纵列的对方卡片。
	for tc in aux.Next(g) do
		local tg=tc:GetColumnGroup():Filter(Card.IsControler,nil,1-tp)
		Group.Merge(sg,tg)
	end
	-- 遍历合并后的对方卡片组，对其逐一适用效果。
	for oc in aux.Next(sg) do
		s.dop(oc,e)
	end
end

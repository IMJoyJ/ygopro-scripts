--The despair URANUS
-- 效果：
-- ①：自己场上没有魔法·陷阱卡存在，这张卡上级召唤成功时才能发动。对方宣言卡的种类（永续魔法·永续陷阱）。自己从卡组选宣言的种类的1张卡在自己的魔法与陷阱区域盖放。
-- ②：这张卡的攻击力上升自己场上的表侧表示的魔法·陷阱卡数量×300。
-- ③：只要这张卡在怪兽区域存在，自己的魔法与陷阱区域的表侧表示的卡不会被效果破坏。
function c32588805.initial_effect(c)
	-- 效果原文：①：自己场上没有魔法·陷阱卡存在，这张卡上级召唤成功时才能发动。对方宣言卡的种类（永续魔法·永续陷阱）。自己从卡组选宣言的种类的1张卡在自己的魔法与陷阱区域盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(32588805,0))
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c32588805.setcon)
	e1:SetTarget(c32588805.settg)
	e1:SetOperation(c32588805.setop)
	c:RegisterEffect(e1)
	-- 效果原文：②：这张卡的攻击力上升自己场上的表侧表示的魔法·陷阱卡数量×300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c32588805.atkval)
	c:RegisterEffect(e2)
	-- 效果原文：③：只要这张卡在怪兽区域存在，自己的魔法与陷阱区域的表侧表示的卡不会被效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_SZONE,0)
	e3:SetTarget(c32588805.indtg)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
-- 规则层面：判断上级召唤成功且自己场上没有魔法·陷阱卡存在
function c32588805.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
		-- 规则层面：自己场上没有魔法·陷阱卡存在
		and not Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_ONFIELD,0,1,nil,TYPE_SPELL+TYPE_TRAP)
end
-- 规则层面：过滤函数，用于筛选可以盖放的永续魔法或永续陷阱卡
function c32588805.setfilter1(c)
	return c:IsType(TYPE_CONTINUOUS) and c:IsSSetable()
end
-- 规则层面：设置效果目标，检查是否有足够的魔法与陷阱区域空位及卡组中存在可盖放的卡
function c32588805.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面：检查自己魔法与陷阱区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 规则层面：检查卡组中是否存在满足条件的永续魔法或永续陷阱卡
		and Duel.IsExistingMatchingCard(c32588805.setfilter1,tp,LOCATION_DECK,0,1,nil) end
end
-- 规则层面：过滤函数，根据指定类型筛选可盖放的卡
function c32588805.setfilter2(c,typ)
	return c:GetType()==typ and c:IsSSetable()
end
-- 规则层面：处理效果发动，选择对方宣言的卡种类并从卡组选择对应类型的卡进行盖放
function c32588805.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：检查是否还有魔法与陷阱区域的空位
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 规则层面：提示对方选择卡的种类（永续魔法或永续陷阱）
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_OPTION)  --"请选择一个选项"
	-- 规则层面：让对方选择卡的种类（选项0为永续魔法，选项1为永续陷阱）
	local op=Duel.SelectOption(1-tp,71,72)
	-- 规则层面：提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	local g=nil
	-- 规则层面：根据对方选择的种类，从卡组中选择对应类型的卡
	if op==0 then g=Duel.SelectMatchingCard(tp,c32588805.setfilter2,tp,LOCATION_DECK,0,1,1,nil,TYPE_SPELL+TYPE_CONTINUOUS)
	-- 规则层面：根据对方选择的种类，从卡组中选择对应类型的卡
	else g=Duel.SelectMatchingCard(tp,c32588805.setfilter2,tp,LOCATION_DECK,0,1,1,nil,TYPE_TRAP+TYPE_CONTINUOUS) end
	if g:GetCount()>0 then
		-- 规则层面：将选中的卡在自己的魔法与陷阱区域盖放
		Duel.SSet(tp,g:GetFirst())
	end
end
-- 规则层面：过滤函数，用于统计自己场上表侧表示的魔法与陷阱卡
function c32588805.atkfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsFaceup()
end
-- 规则层面：计算攻击力提升值，为场上表侧表示的魔法与陷阱卡数量乘以300
function c32588805.atkval(e,c)
	-- 规则层面：返回场上表侧表示的魔法与陷阱卡数量乘以300作为攻击力提升值
	return Duel.GetMatchingGroupCount(c32588805.atkfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,nil)*300
end
-- 规则层面：目标过滤函数，用于判断是否为自己的魔法与陷阱区域中表侧表示的卡
function c32588805.indtg(e,c)
	return c:GetSequence()<5 and c:IsFaceup()
end

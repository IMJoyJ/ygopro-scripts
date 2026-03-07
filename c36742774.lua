--シンクロ・ワールド
-- 效果：
-- ①：每次怪兽同调召唤给这张卡放置2个信号指示物。
-- ②：可以把自己场上的信号指示物的以下数量取除，那个效果发动。
-- ●4：自己场上1只表侧表示怪兽的等级上升或下降1星。
-- ●7：从自己墓地把1只调整特殊召唤。
-- ●10：从自己墓地把1只同调怪兽特殊召唤。
-- ③：场上的这张卡被对方的效果破坏的场合才能发动。从额外卡组把1只「红龙」特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，注册场地魔法卡的通用发动效果并设置同调召唤时添加指示物的处理
function s.initial_effect(c)
	-- 记录该卡与「红龙」卡名的关联
	aux.AddCodeList(c,63436931)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 当有怪兽同调召唤成功时，给这张卡放置2个信号指示物
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetOperation(s.ctop)
	c:RegisterEffect(e2)
	-- 消耗4个信号指示物时，选择自己场上1只表侧表示怪兽使其等级上升或下降1星
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))  --"4个：等级变化"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetLabel(4)
	e3:SetCost(s.countercost)
	e3:SetTarget(s.lvtg)
	e3:SetOperation(s.lvop)
	c:RegisterEffect(e3)
	-- 消耗7个信号指示物时，从自己墓地把1只调整特殊召唤
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"7个：调整特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_FZONE)
	e4:SetLabel(7)
	e4:SetCost(s.countercost)
	e4:SetTarget(s.sptg1)
	e4:SetOperation(s.spop1)
	c:RegisterEffect(e4)
	-- 消耗10个信号指示物时，从自己墓地把1只同调怪兽特殊召唤
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,2))  --"10个：同调怪兽特殊召唤"
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_FZONE)
	e5:SetLabel(10)
	e5:SetCost(s.countercost)
	e5:SetTarget(s.sptg2)
	e5:SetOperation(s.spop2)
	c:RegisterEffect(e5)
	-- 场上的这张卡被对方的效果破坏的场合才能发动，从额外卡组把1只「红龙」特殊召唤
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,3))  --"从额外卡组把1只「红龙」特殊召唤"
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetProperty(EFFECT_FLAG_DELAY)
	e6:SetCode(EVENT_DESTROYED)
	e6:SetCondition(s.spcon)
	e6:SetTarget(s.sptg3)
	e6:SetOperation(s.spop3)
	c:RegisterEffect(e6)
end
s.counter_add_list={0x104d}
-- 过滤函数，判断是否为表侧表示的同调召唤怪兽
function s.ctfilter(c)
	return c:IsFaceup() and c:IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 当有同调召唤成功的怪兽时，给这张卡添加2个信号指示物
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(s.ctfilter,1,nil) then
		e:GetHandler():AddCounter(0x104d,2)
	end
end
-- 检查是否能移除指定数量的信号指示物作为发动代价
function s.countercost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否能移除指定数量的信号指示物作为发动代价
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x104d,e:GetLabel(),REASON_COST) end
	-- 向对方玩家提示发动了该效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 移除指定数量的信号指示物作为发动代价
	Duel.RemoveCounter(tp,1,0,0x104d,e:GetLabel(),REASON_COST)
end
-- 过滤函数，判断是否为表侧表示且等级大于0的怪兽
function s.lvfilter(c)
	return c:IsFaceup() and c:GetLevel()>0
end
-- 判断是否能选择1只表侧表示的怪兽作为等级变化的目标
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否能选择1只表侧表示的怪兽作为等级变化的目标
	if chk==0 then return Duel.IsExistingMatchingCard(s.lvfilter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 处理等级变化效果，选择提升或降低等级
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择1只表侧表示的怪兽作为等级变化的目标
	local g=Duel.SelectMatchingCard(tp,s.lvfilter,tp,LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 显示被选中的怪兽
		Duel.HintSelection(g)
		local sel=0
		local lvl=1
		if tc:IsLevel(1) then
			-- 选择等级上升的效果
			sel=Duel.SelectOption(tp,aux.Stringid(id,4))  --"等级上升"
		else
			-- 选择等级上升或下降的效果
			sel=Duel.SelectOption(tp,aux.Stringid(id,4),aux.Stringid(id,5))  --"等级上升/等级下降"
		end
		if sel==1 then
			lvl=-1
		end
		-- 给目标怪兽添加等级变化效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(lvl)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- 过滤函数，判断是否为调整类型且可特殊召唤的怪兽
function s.spfilter1(c,e,tp)
	return c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否能从墓地特殊召唤1只调整
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否能从墓地特殊召唤1只调整
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否能从墓地特殊召唤1只调整
		and Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息，表示将特殊召唤1只调整
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 处理特殊召唤调整的效果
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有足够的特殊召唤空间
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择1只可特殊召唤的调整
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter1),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的调整特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数，判断是否为同调类型且可特殊召唤的怪兽
function s.spfilter2(c,e,tp)
	return c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否能从墓地特殊召唤1只同调怪兽
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否能从墓地特殊召唤1只同调怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否能从墓地特殊召唤1只同调怪兽
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息，表示将特殊召唤1只同调怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 处理特殊召唤同调怪兽的效果
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有足够的特殊召唤空间
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择1只可特殊召唤的同调怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter2),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的同调怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断该卡是否因对方效果被破坏且满足发动条件
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_FZONE) and c:IsReason(REASON_EFFECT)
end
-- 过滤函数，判断是否为「红龙」且可特殊召唤的怪兽
function s.spfilter3(c,e,tp)
	return c:IsCode(63436931) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 判断是否有足够的特殊召唤空间
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 判断是否能从额外卡组特殊召唤1只「红龙」
function s.sptg3(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否能从额外卡组特殊召唤1只「红龙」
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter3,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置操作信息，表示将特殊召唤1只「红龙」
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 处理从额外卡组特殊召唤「红龙」的效果
function s.spop3(e,tp,eg,ep,ev,re,r,rp)
	-- 选择1只可特殊召唤的「红龙」
	local tg=Duel.GetFirstMatchingCard(s.spfilter3,tp,LOCATION_EXTRA,0,nil,e,tp)
	if tg then
		-- 将选中的「红龙」特殊召唤到场上
		Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP)
	end
end

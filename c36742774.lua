--シンクロ・ワールド
-- 效果：
-- ①：每次怪兽同调召唤给这张卡放置2个信号指示物。
-- ②：可以把自己场上的信号指示物的以下数量取除，那个效果发动。
-- ●4：自己场上1只表侧表示怪兽的等级上升或下降1星。
-- ●7：从自己墓地把1只调整特殊召唤。
-- ●10：从自己墓地把1只同调怪兽特殊召唤。
-- ③：场上的这张卡被对方的效果破坏的场合才能发动。从额外卡组把1只「红龙」特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，注册场地卡通用发动效果并设置同调召唤时添加指示物的持续效果
function s.initial_effect(c)
	-- 记录该卡与「红龙」卡名关联，用于效果判定
	aux.AddCodeList(c,63436931)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 设置触发效果，当有怪兽同调召唤成功时执行ctop函数
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetOperation(s.ctop)
	c:RegisterEffect(e2)
	-- 设置4个指示物消耗的效果，可使场上一只表侧表示怪兽等级上升或下降1星
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))  --"4个：等级变化"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetLabel(4)
	e3:SetCost(s.countercost)
	e3:SetTarget(s.lvtg)
	e3:SetOperation(s.lvop)
	c:RegisterEffect(e3)
	-- 设置7个指示物消耗的效果，可从墓地特殊召唤一只调整
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
	-- 设置10个指示物消耗的效果，可从墓地特殊召唤一只同调怪兽
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
	-- 设置场上的这张卡被对方效果破坏时才能发动的效果，从额外卡组特殊召唤一只「红龙」
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
s.mentioned_counter={
	[0x104d]=true,
}
-- 过滤函数，用于判断是否为表侧表示的同调召唤怪兽
function s.ctfilter(c)
	return c:IsFaceup() and c:IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 当有同调召唤成功时，给场地卡添加2个信号指示物
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(s.ctfilter,1,nil) then
		e:GetHandler():AddCounter(0x104d,2)
	end
end
-- 检查是否能移除指定数量的指示物作为效果发动的代价
function s.countercost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 如果无法支付指示物代价则返回false
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x104d,e:GetLabel(),REASON_COST) end
	-- 向对方玩家提示当前效果发动了什么
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 移除指定数量的指示物作为效果发动的代价
	Duel.RemoveCounter(tp,1,0,0x104d,e:GetLabel(),REASON_COST)
end
-- 过滤函数，用于判断是否为表侧表示且等级大于0的怪兽
function s.lvfilter(c)
	return c:IsFaceup() and c:GetLevel()>0
end
-- 设置等级变化效果的目标选择函数，检查场上是否存在满足条件的怪兽
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 如果场上不存在满足条件的怪兽则返回false
	if chk==0 then return Duel.IsExistingMatchingCard(s.lvfilter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 执行等级变化效果，选择目标怪兽并决定提升或降低其等级
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择一张表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足条件的一张怪兽作为目标
	local g=Duel.SelectMatchingCard(tp,s.lvfilter,tp,LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 显示被选中的怪兽动画效果
		Duel.HintSelection(g)
		local sel=0
		local lvl=1
		if tc:IsLevel(1) then
			-- 当目标怪兽等级为1时，仅提供“等级上升”选项
			sel=Duel.SelectOption(tp,aux.Stringid(id,4))  --"等级上升"
		else
			-- 当目标怪兽等级大于1时，提供“等级上升”和“等级下降”两个选项
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
-- 过滤函数，用于判断是否为调整类型且可特殊召唤的墓地怪兽
function s.spfilter1(c,e,tp)
	return c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置调整特殊召唤效果的目标选择函数，检查墓地是否存在满足条件的调整
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 如果场上没有空位则返回false
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在满足条件的调整
		and Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息，表示将要特殊召唤一张调整
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 执行调整特殊召唤效果，从墓地选择并特殊召唤一只调整
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 如果场上没有空位则直接返回
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的一张调整怪兽作为目标
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter1),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的调整怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数，用于判断是否为同调类型且可特殊召唤的墓地怪兽
function s.spfilter2(c,e,tp)
	return c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置同调怪兽特殊召唤效果的目标选择函数，检查墓地是否存在满足条件的同调怪兽
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 如果场上没有空位则返回false
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在满足条件的同调怪兽
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息，表示将要特殊召唤一只同调怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 执行同调怪兽特殊召唤效果，从墓地选择并特殊召唤一只同调怪兽
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 如果场上没有空位则直接返回
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的一张同调怪兽作为目标
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter2),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的同调怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 设置破坏效果发动的条件，必须是被对方效果破坏且在场上的状态
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_FZONE) and c:IsReason(REASON_EFFECT)
end
-- 过滤函数，用于判断是否为「红龙」且可特殊召唤的额外卡组怪兽
function s.spfilter3(c,e,tp)
	return c:IsCode(63436931) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查是否有足够的特殊召唤位置
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 设置红龙特殊召唤效果的目标选择函数，检查额外卡组是否存在满足条件的「红龙」
function s.sptg3(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 如果额外卡组不存在满足条件的「红龙」则返回false
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter3,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置操作信息，表示将要特殊召唤一只「红龙」
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 执行红龙特殊召唤效果，从额外卡组选择并特殊召唤一只「红龙」
function s.spop3(e,tp,eg,ep,ev,re,r,rp)
	-- 选择满足条件的第一只「红龙」作为目标
	local tg=Duel.GetFirstMatchingCard(s.spfilter3,tp,LOCATION_EXTRA,0,nil,e,tp)
	if tg then
		-- 将选中的「红龙」特殊召唤到场上
		Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP)
	end
end

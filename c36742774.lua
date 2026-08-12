--シンクロ・ワールド
-- 效果：
-- ①：每次怪兽同调召唤给这张卡放置2个信号指示物。
-- ②：可以把自己场上的信号指示物的以下数量取除，那个效果发动。
-- ●4：自己场上1只表侧表示怪兽的等级上升或下降1星。
-- ●7：从自己墓地把1只调整特殊召唤。
-- ●10：从自己墓地把1只同调怪兽特殊召唤。
-- ③：场上的这张卡被对方的效果破坏的场合才能发动。从额外卡组把1只「红龙」特殊召唤。
local s,id,o=GetID()
-- 初始化函数：注册这张卡的卡名记载列表与全部效果，包括场地魔法的发动空效果、每次同调召唤放置信号指示物的永续触发效果、取除4/7/10个信号指示物的三个起动效果，以及被对方效果破坏时从额外卡组特殊召唤「红龙」的诱发效果
function s.initial_effect(c)
	-- 在这张卡的代码列表中记载卡名63436931（「红龙」），表示这张卡上写有该卡名
	aux.AddCodeList(c,63436931)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：每次怪兽同调召唤给这张卡放置2个信号指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetOperation(s.ctop)
	c:RegisterEffect(e2)
	-- ②：可以把自己场上的信号指示物的以下数量取除，那个效果发动。●4：自己场上1只表侧表示怪兽的等级上升或下降1星。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))  --"4个：等级变化"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetLabel(4)
	e3:SetCost(s.countercost)
	e3:SetTarget(s.lvtg)
	e3:SetOperation(s.lvop)
	c:RegisterEffect(e3)
	-- ②：可以把自己场上的信号指示物的以下数量取除，那个效果发动。●7：从自己墓地把1只调整特殊召唤。
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
	-- ②：可以把自己场上的信号指示物的以下数量取除，那个效果发动。●10：从自己墓地把1只同调怪兽特殊召唤。
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
	-- ③：场上的这张卡被对方的效果破坏的场合才能发动。从额外卡组把1只「红龙」特殊召唤。
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
-- 过滤函数：判断怪兽是否为表侧表示且是这次同调召唤出场的怪兽
function s.ctfilter(c)
	return c:IsFaceup() and c:IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 永续触发处理：若这次特殊召唤成功的怪兽中存在同调召唤出场的怪兽，则给这张卡放置2个信号指示物
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(s.ctfilter,1,nil) then
		e:GetHandler():AddCounter(0x104d,2)
	end
end
-- ②效果的发动代价：检查并以代价形式从自己场上的卡上取除对应数量的信号指示物，并向对方提示选择了哪个效果
function s.countercost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：自己场上是否能以代价取除Label数量的信号指示物（分别为4、7、10个）
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x104d,e:GetLabel(),REASON_COST) end
	-- 向对方玩家提示自己选择了发动哪个效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 从自己场上的卡上以代价取除Label数量的信号指示物
	Duel.RemoveCounter(tp,1,0,0x104d,e:GetLabel(),REASON_COST)
end
-- 过滤函数：判断怪兽是否为表侧表示且等级大于0（可以升降等级的怪兽）
function s.lvfilter(c)
	return c:IsFaceup() and c:GetLevel()>0
end
-- 目标检查函数：检查自己场上是否存在可以改变等级的表侧表示怪兽
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：自己场上是否存在1只以上表侧表示且等级大于0的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.lvfilter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 效果处理：让自己选择自己场上1只表侧表示的怪兽，根据该怪兽当前等级选择令其等级上升或下降1星，并给它注册持续改变等级的效果
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 向自己显示「请选择表侧表示的卡」的选卡提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让自己从自己场上选择1只表侧表示且等级大于0的怪兽
	local g=Duel.SelectMatchingCard(tp,s.lvfilter,tp,LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 显示所选怪兽的选中动画，并记录该怪兽被选择
		Duel.HintSelection(g)
		local sel=0
		local lvl=1
		if tc:IsLevel(1) then
			-- 当目标怪兽等级为1时，只能让其选择「等级上升」这一项
			sel=Duel.SelectOption(tp,aux.Stringid(id,4))  --"等级上升"
		else
			-- 让目标怪兽的选择者在「等级上升」与「等级下降」两个选项中选择
			sel=Duel.SelectOption(tp,aux.Stringid(id,4),aux.Stringid(id,5))  --"等级上升/等级下降"
		end
		if sel==1 then
			lvl=-1
		end
		-- ●4：自己场上1只表侧表示怪兽的等级上升或下降1星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(lvl)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- 过滤函数：判断卡片是否为调整且可以被特殊召唤
function s.spfilter1(c,e,tp)
	return c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 目标检查函数：检查自己主要怪兽区是否有空格且墓地存在可以特殊召唤的调整
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：自己主要怪兽区有可用的空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件检查：自己墓地存在1只以上可以被特殊召唤的调整
		and Duel.IsExistingMatchingCard(s.spfilter1,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：宣言将从墓地把1张卡特殊召唤，供星尘龙等效果的连锁检测使用
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果处理：若主要怪兽区仍有空格，让自己从墓地选择1只不受「王家长眠之谷」影响的可特殊召唤的调整，并将其以表侧表示特殊召唤
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 处理前检查：若自己主要怪兽区已无空格则不处理特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向自己显示「请选择要特殊召唤的卡」的选卡提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让自己从自己墓地选择1只可以被特殊召唤且不受「王家长眠之谷」影响的调整
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter1),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的调整以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数：判断卡片是否为同调怪兽且可以被特殊召唤
function s.spfilter2(c,e,tp)
	return c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 目标检查函数：检查自己主要怪兽区是否有空格且墓地存在可以特殊召唤的同调怪兽
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：自己主要怪兽区有可用的空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件检查：自己墓地存在1只以上可以被特殊召唤的同调怪兽
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：宣言将从墓地把1张卡特殊召唤，供星尘龙等效果的连锁检测使用
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果处理：若主要怪兽区仍有空格，让自己从墓地选择1只不受「王家长眠之谷」影响的可特殊召唤的同调怪兽，并将其以表侧表示特殊召唤
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 处理前检查：若自己主要怪兽区已无空格则不处理特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向自己显示「请选择要特殊召唤的卡」的选卡提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让自己从自己墓地选择1只可以被特殊召唤且不受「王家长眠之谷」影响的同调怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter2),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的同调怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 发动条件检查：场上的这张卡在自己的控制下于场地区被对方的效果破坏的场合才能发动
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_FZONE) and c:IsReason(REASON_EFFECT)
end
-- 过滤函数：判断卡片是否为「红龙」（卡号63436931）、可以被特殊召唤且额外卡组怪兽出场所需的格子可用
function s.spfilter3(c,e,tp)
	return c:IsCode(63436931) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 发动条件检查：把该卡从额外卡组特殊召唤所需的场上空格数大于0
		and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 目标检查函数：检查额外卡组是否存在可以特殊召唤的「红龙」，并设置操作信息宣言将从额外卡组特殊召唤1只怪兽
function s.sptg3(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：自己额外卡组存在1只以上满足条件的「红龙」
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter3,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置操作信息：宣言将从额外卡组把1只怪兽特殊召唤，供星尘龙等效果的连锁检测使用
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：从自己额外卡组找出1只满足条件的「红龙」，并将其以表侧表示特殊召唤
function s.spop3(e,tp,eg,ep,ev,re,r,rp)
	-- 从自己额外卡组取得第1只满足条件的「红龙」
	local tg=Duel.GetFirstMatchingCard(s.spfilter3,tp,LOCATION_EXTRA,0,nil,e,tp)
	if tg then
		-- 将取得的「红龙」以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tg,0,tp,tp,false,false,POS_FACEUP)
	end
end

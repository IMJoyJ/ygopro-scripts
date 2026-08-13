--永遠の魂
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：可以从以下效果选择1个发动。
-- ●从自己的手卡·墓地把1只「黑魔术师」特殊召唤。
-- ●从卡组把1张「黑·魔·导」或「千把刀」加入手卡。
-- ②：只要这张卡在魔法与陷阱区域存在，自己的怪兽区域的「黑魔术师」不受对方的效果影响。
-- ③：表侧表示的这张卡从场上离开的场合发动。自己场上的怪兽全部破坏。
function c48680970.initial_effect(c)
	-- 将「黑魔术师」（46986414）登记为这张卡记述的卡名，使与卡名记述相关的效果能够正确关联。
	aux.AddCodeList(c,46986414)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e1)
	-- 这个卡名的①的效果1回合只能使用1次。①：可以从以下效果选择1个发动。●从自己的手卡·墓地把1只「黑魔术师」特殊召唤。●从卡组把1张「黑·魔·导」或「千把刀」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1,48680970)
	e2:SetTarget(c48680970.target)
	e2:SetOperation(c48680970.operation)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在魔法与陷阱区域存在，自己的怪兽区域的「黑魔术师」不受对方的效果影响。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(c48680970.etarget)
	e3:SetValue(c48680970.efilter)
	c:RegisterEffect(e3)
	-- ③：表侧表示的这张卡从场上离开的场合发动。自己场上的怪兽全部破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetCondition(c48680970.descon)
	e4:SetTarget(c48680970.destg)
	e4:SetOperation(c48680970.desop)
	c:RegisterEffect(e4)
end
-- 筛选条件：卡为「黑魔术师」（46986414）且能够被当前效果特殊召唤（遵守苏生限制与召唤条件）。
function c48680970.filter1(c,e,tp)
	return c:IsCode(46986414) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 筛选条件：卡为「黑·魔·导」（2314238）或「千把刀」（63391643）且能够加入手卡。
function c48680970.filter2(c)
	return c:IsCode(2314238,63391643) and c:IsAbleToHand()
end
-- ①效果的发动条件判断与分支选择：检测能否进行特殊召唤或检索，至少一个分支可行时允许发动；发动时由玩家选择要使用的分支，将选择结果存入标签，并设置对应的效果类别与操作信息。
function c48680970.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区域是否存在可用空格（特殊召唤需要空位）。
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的手卡·墓地是否存在至少1只满足筛选条件的「黑魔术师」可供特殊召唤。
		and Duel.IsExistingMatchingCard(c48680970.filter1,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp)
	-- 检查自己的卡组是否存在至少1张满足筛选条件的「黑·魔·导」或「千把刀」可供加入手卡。
	local b2=Duel.IsExistingMatchingCard(c48680970.filter2,tp,LOCATION_DECK,0,1,nil)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		-- 当两个分支都可行时，弹出选项让玩家选择发动哪一个效果（0：特殊召唤「黑魔术师」，1：将「黑·魔·导」或「千把刀」加入手卡）。
		op=Duel.SelectOption(tp,aux.Stringid(48680970,1),aux.Stringid(48680970,2))  --"「黑魔术师」特殊召唤/「黑·魔·导」或者「千把刀」加入手卡"
	elseif b1 then
		-- 仅特殊召唤分支可行时，直接选择该分支（op=0）。
		op=Duel.SelectOption(tp,aux.Stringid(48680970,1))  --"「黑魔术师」特殊召唤"
	else
		-- 仅检索分支可行时，选择该分支并通过+1将op设为1（与特殊召唤分支区分）。
		op=Duel.SelectOption(tp,aux.Stringid(48680970,2))+1  --"「黑·魔·导」或者「千把刀」加入手卡"
	end
	e:SetLabel(op)
	if op==0 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		-- 设置操作信息：将进行特殊召唤，数量为1，可能的对象来源为手卡·墓地。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
	else
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		-- 设置操作信息：将进行检索，把1张卡从卡组加入手卡（类别为回手牌+检索）。
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	end
end
-- ①效果处理：根据发动时保存的分支执行——分支0：从手卡·墓地选择1只「黑魔术师」特殊召唤；分支1：从卡组选择1张「黑·魔·导」或「千把刀」加入手卡，并向对方展示。
function c48680970.operation(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		-- 若自己主要怪兽区域没有空位，则无法进行特殊召唤，直接结束处理。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 显示选择提示，要求玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从自己的手卡·墓地中筛选出1只「黑魔术师」，并通过「王家长眠之谷」过滤排除不能从墓地特殊召唤的情况。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c48680970.filter1),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的「黑魔术师」以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	else
		-- 显示选择提示，要求玩家选择要加入手卡的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从自己的卡组中筛选出1张满足条件的「黑·魔·导」或「千把刀」。
		local g=Duel.SelectMatchingCard(tp,c48680970.filter2,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的卡加入其持有者的手卡。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方玩家展示这次加入手卡的卡，确认检索内容。
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- ②效果的保护对象过滤：仅保护卡名为「黑魔术师」（46986414）的怪兽。
function c48680970.etarget(e,c)
	return c:IsCode(46986414)
end
-- ②效果的免疫条件：当效果的持有者不是这张卡的控制者（即对方发动的效果）时，使「黑魔术师」不受该效果影响。
function c48680970.efilter(e,re)
	return re:GetOwnerPlayer()~=e:GetHandlerPlayer()
end
-- ③效果的发动条件：这张卡以表侧表示状态从场上离开。
function c48680970.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP)
end
-- ③效果的发动时点：确认可发动，并取得自己场上全部怪兽，设置破坏这些怪兽的操作信息。
function c48680970.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 取得自己怪兽区域上的全部怪兽（作为之后破坏的对象集合）。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,0,nil)
	-- 设置操作信息：破坏自己场上全部怪兽，数量为取得的怪兽数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- ③效果处理：将自己场上全部怪兽破坏。
function c48680970.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 再次取得自己怪兽区域上的全部怪兽（效果处理时确定当前场上存在的怪兽）。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,0,nil)
	-- 以效果原因将这些怪兽全部破坏。
	Duel.Destroy(g,REASON_EFFECT)
end

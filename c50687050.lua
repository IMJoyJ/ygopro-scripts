--針淵のヴァリアンツ－アルクトスⅩⅡ
-- 效果：
-- ←12 【灵摆】 12→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：可以从以下效果选择1个发动。
-- ●这张卡在正对面的自己的主要怪兽区域特殊召唤。
-- ●选自己的主要怪兽区域1只怪兽，那个位置向那个相邻的怪兽区域移动。
-- 【怪兽效果】
-- 5星以上的「群豪」怪兽×2
-- 额外卡组的里侧表示的这张卡在把自己场上的上记卡解放的场合才能从额外卡组特殊召唤。这个卡名的①②的怪兽效果1回合各能使用1次。
-- ①：自己·对方回合可以发动。从主要怪兽区域选2只自己怪兽或者2只对方怪兽，那2只的位置交换。
-- ②：怪兽区域的卡向其他的怪兽区域移动的场合才能发动。选场上1张卡破坏。
local s,id,o=GetID()
-- 卡片初始化函数：为这张卡注册灵摆怪兽属性、融合/接触融合手续、苏生限制、特殊召唤限制、P区灵摆效果以及怪兽的①位置交换和②破坏效果。
function s.initial_effect(c)
	-- 为这张卡添加灵摆怪兽属性（灵摆召唤/可作为灵摆卡放置），同时关闭灵摆卡“卡的发动”效果的注册。
	aux.EnablePendulumAttribute(c,false)
	-- 为这张卡添加融合召唤手续：需要用2只满足s.matfilter（5星以上的「群豪」怪兽）作为融合素材。
	aux.AddFusionProcFunRep(c,s.matfilter,2,true)
	-- 为这张卡添加接触融合特殊召唤手续：把自己场上可解放的主要怪兽区域怪兽作为素材，用Duel.Release解放，原因记为特殊召唤和融合素材。
	aux.AddContactFusionProcedure(c,aux.FilterBoolFunction(Card.IsReleasable,REASON_SPSUMMON),LOCATION_MZONE,0,Duel.Release,REASON_SPSUMMON+REASON_MATERIAL)
	c:EnableReviveLimit()
	-- 额外卡组的里侧表示的这张卡在把自己场上的上记卡解放的场合才能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(s.splimit)
	c:RegisterEffect(e1)
	-- 这个卡名的灵摆效果1回合只能使用1次。①：可以从以下效果选择1个发动。●这张卡在正对面的自己的主要怪兽区域特殊召唤。●选自己的主要怪兽区域1只怪兽，那个位置向那个相邻的怪兽区域移动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.petg)
	e2:SetOperation(s.peop)
	c:RegisterEffect(e2)
	-- 这个卡名的①②的怪兽效果1回合各能使用1次。①：自己·对方回合可以发动。从主要怪兽区域选2只自己怪兽或者2只对方怪兽，那2只的位置交换。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))  --"位置交换"
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END+TIMING_END_PHASE)
	e3:SetTarget(s.chtg)
	e3:SetOperation(s.chop)
	c:RegisterEffect(e3)
	-- 这个卡名的①②的怪兽效果1回合各能使用1次。②：怪兽区域的卡向其他的怪兽区域移动的场合才能发动。选场上1张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,4))  --"卡片破坏"
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_MOVE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+o*2)
	e4:SetCondition(s.descon)
	e4:SetTarget(s.destg)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)
end
-- 融合素材过滤函数：素材必须满足「群豪」字段且等级在5星以上。
function s.matfilter(c)
	return c:IsFusionSetCard(0x17d) and c:IsLevelAbove(5)
end
-- 特殊召唤条件判定：这张卡不在额外卡组，或已在额外卡组表侧表示时才允许被特殊召唤；额外卡组里侧表示状态不能通过其他方式特殊召唤。
function s.splimit(e,se,sp,st)
	local c=e:GetHandler()
	return not c:IsLocation(LOCATION_EXTRA) or c:IsFaceup()
end
-- 灵摆效果移动怪兽的候选过滤：选择我方主要怪兽区域（seq≤4）的1只怪兽，且其左侧或右侧相邻的主要怪兽区域存在空格。
function s.pfilter(c)
	local seq=c:GetSequence()
	local tp=c:GetControler()
	if seq>4 then return false end
	-- 若该怪兽不在最左侧（seq>0）且左侧相邻主要怪兽区域可用，则可向左移动。
	return (seq>0 and Duel.CheckLocation(tp,LOCATION_MZONE,seq-1))
		-- 若该怪兽不在最右侧（seq<4）且右侧相邻主要怪兽区域可用，则可向右移动。
		or (seq<4 and Duel.CheckLocation(tp,LOCATION_MZONE,seq+1))
end
-- 灵摆效果的发动目标函数：判定“特殊召唤自身”或“移动其他怪兽”两个选项是否可行，发动时让玩家选择一项，把选项存入e:SetLabel。
function s.petg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local zone=1<<c:GetSequence()
	local b1=zone~=0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
	-- 检查我方主要怪兽区域是否存在至少1只满足s.pfilter的怪兽，决定“位置移动”选项是否可选。
	local b2=Duel.IsExistingMatchingCard(s.pfilter,tp,LOCATION_MZONE,0,1,nil)
	if chk==0 then return b1 or b2 end
	e:SetCategory(0)
	local off=1
	local ops={}
	local opval={}
	if b1 then
		ops[off]=aux.Stringid(id,1)  --"特殊召唤"
		opval[off]=0
		off=off+1
	end
	if b2 then
		ops[off]=aux.Stringid(id,2)  --"位置移动"
		opval[off]=1
		off=off+1
	end
	-- 让玩家从可用选项中选择一项（Duel.SelectOption返回0基序号，+1后用于取得opval中的选项编号）。
	local op=Duel.SelectOption(tp,table.unpack(ops))+1
	local sel=opval[op]
	if sel==0 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		-- 设置本次效果处理为特殊召唤这张卡（目标卡为c，数量1）的操作信息，便于发动时点检测。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	end
	e:SetLabel(sel)
end
-- 灵摆效果的处理：根据之前选择的选项执行：选项0将这张卡特殊召唤到正对面的主要怪兽区域；选项1选择一只可移动怪兽并移动到相邻空格。
function s.peop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local op=e:GetLabel()
	if op==0 then
		-- 将这张卡以表侧表示特殊召唤到由其灵摆区位置换算出的正对面的主要怪兽区域（用zone位指定）。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP,1<<c:GetSequence())
	elseif op==1 then
		-- 弹出“请选择要操作的卡”的选择提示，供后续SelectMatchingCard使用。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
		-- 选择1张我方主要怪兽区域中满足s.pfilter（有相邻空格可移动）的怪兽作为移动对象。
		local sg=Duel.SelectMatchingCard(tp,s.pfilter,tp,LOCATION_MZONE,0,1,1,nil)
		if #sg>0 then
			local sc=sg:GetFirst()
			local seq=sc:GetSequence()
			if seq>4 then return end
			local flag=0
			-- 如果选中怪兽左侧（seq-1）是空的主要怪兽区域，则把该格子加入可移动位置标记flag。
			if seq>0 and Duel.CheckLocation(tp,LOCATION_MZONE,seq-1) then flag=flag|(1<<(seq-1)) end
			-- 如果选中怪兽右侧（seq+1）是空的主要怪兽区域，则把该格子加入可移动位置标记flag。
			if seq<4 and Duel.CheckLocation(tp,LOCATION_MZONE,seq+1) then flag=flag|(1<<(seq+1)) end
			if flag==0 then return end
			-- 弹出“请选择要移动到的位置”的格子选择提示。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)  --"请选择要移动到的位置"
			-- 让玩家在flag标记的可选空格中选择1个位置，传入~flag表示除这些可选格以外的格子均禁用。
			local s=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,~flag)
			local nseq=math.log(s,2)
			-- 为选中的要移动的怪兽显示被选为对象的动画，并记录其被选择状态。
			Duel.HintSelection(sg)
			-- 把该怪兽移动到目标序号nseq对应的主要怪兽区域。
			Duel.MoveSequence(sc,nseq)
		end
	end
end
-- 位置交换效果的目标过滤：只选择位于主要怪兽区域（序号0-4）的怪兽，不选择额外怪兽区。
function s.chfilter(c)
	return c:GetSequence()<5
end
-- 子组检查：所选2只怪兽的控制者种类只有1种，即必须同为己方怪兽或同为对方怪兽。
function s.gcheck(g)
	return g:GetClassCount(Card.GetControler)==1
end
-- 位置交换效果的发动条件：场上存在2只来自同一控制者的主要怪兽区域怪兽，可以作为2张卡选出。
function s.chtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取双方场上所有主要怪兽区域且满足s.chfilter的怪兽作为候选组。
	local g=Duel.GetMatchingGroup(s.chfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if chk==0 then return g:CheckSubGroup(s.gcheck,2,2) end
end
-- 位置交换效果处理：从双方主要怪兽区域选择2只属于同一控制者的怪兽，HintSelection后交换位置。
function s.chop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 再次获取双方场上主要怪兽区域怪兽作为处理时的候选组（该效果不取对象，处理时选择）。
	local g=Duel.GetMatchingGroup(s.chfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 弹出“请选择要操作的卡”的选择提示，供选择要交换位置的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	local sg=g:SelectSubGroup(tp,s.gcheck,false,2,2)
	if sg then
		-- 为选中的2只怪兽显示被选为对象的动画。
		Duel.HintSelection(sg)
		local tc1=sg:GetFirst()
		local tc2=sg:GetNext()
		-- 交换tc1和tc2所在的怪兽区域位置。
		Duel.SwapSequence(tc1,tc2)
	end
end
-- 移动判定过滤：该卡当前在主要怪兽区域且之前也在主要怪兽区域，且区域序号或控制者发生了变化，视为“怪兽区域的卡向其他怪兽区域移动”。
function s.cfilter(c)
	return c:IsLocation(LOCATION_MZONE) and c:IsPreviousLocation(LOCATION_MZONE)
		and (c:GetPreviousSequence()~=c:GetSequence() or c:GetPreviousControler()~=c:GetControler())
end
-- 移动诱发效果的发动条件：本次EVENT_MOVE事件中存在至少1张满足s.cfilter的卡。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil)
end
-- 破坏效果的目标判定：场上存在可被破坏的卡，并设置破坏1张卡的操作信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取场上所有卡（双方怪兽区域和魔陷区域）作为破坏候选组。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if chk==0 then return #g>0 end
	-- 设置操作信息：本次效果预定的破坏对象为场上1张卡，候选组为场上所有卡（处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果处理：从双方场上选择1张卡并破坏。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出“请选择要破坏的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从双方场上选择1张卡作为破坏对象（不取对象，效果处理时选择）。
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		-- 为选中的要破坏的卡显示被选为对象的动画。
		Duel.HintSelection(g)
		-- 以效果原因破坏所选卡，将其送去墓地。
		Duel.Destroy(g,REASON_EFFECT)
	end
end

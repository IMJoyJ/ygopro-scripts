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
-- 初始化卡片效果，设置灵摆属性、融合召唤条件、接触融合程序并启用复活限制
function s.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性，不注册灵摆卡发动效果
	aux.EnablePendulumAttribute(c,false)
	-- 添加融合召唤手续，使用2个满足s.matfilter条件的怪兽作为融合素材
	aux.AddFusionProcFunRep(c,s.matfilter,2,true)
	-- 添加接触融合特殊召唤规则，通过解放场上的怪兽从额外卡组特殊召唤
	aux.AddContactFusionProcedure(c,aux.FilterBoolFunction(Card.IsReleasable,REASON_SPSUMMON),LOCATION_MZONE,0,Duel.Release,REASON_SPSUMMON+REASON_MATERIAL)
	c:EnableReviveLimit()
	-- 设置该卡的特殊召唤条件，使其只能在特定条件下从额外卡组特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(s.splimit)
	c:RegisterEffect(e1)
	-- 设置灵摆区域的起动效果，可以选择发动特殊召唤或移动怪兽位置
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.petg)
	e2:SetOperation(s.peop)
	c:RegisterEffect(e2)
	-- 设置怪兽区域的诱发即时效果，可以在自己或对方回合交换2只怪兽位置
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
	-- 设置场地区域的触发效果，当有怪兽移入其他区域时可以破坏1张卡
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
-- 定义融合素材过滤条件，要求是群豪卡组且等级5以上
function s.matfilter(c)
	return c:IsFusionSetCard(0x17d) and c:IsLevelAbove(5)
end
-- 限制该卡从额外卡组特殊召唤的条件，必须在场上正面表示或不在额外卡组
function s.splimit(e,se,sp,st)
	local c=e:GetHandler()
	return not c:IsLocation(LOCATION_EXTRA) or c:IsFaceup()
end
-- 定义灵摆区域选择怪兽的过滤条件，检查相邻位置是否可用
function s.pfilter(c)
	local seq=c:GetSequence()
	local tp=c:GetControler()
	if seq>4 then return false end
	-- 检查当前怪兽左侧位置是否可用
	return (seq>0 and Duel.CheckLocation(tp,LOCATION_MZONE,seq-1))
		-- 检查当前怪兽右侧位置是否可用
		or (seq<4 and Duel.CheckLocation(tp,LOCATION_MZONE,seq+1))
end
-- 设置灵摆效果的目标函数，允许玩家选择特殊召唤或移动怪兽位置
function s.petg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local zone=1<<c:GetSequence()
	local b1=zone~=0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
	-- 检查场上是否存在满足pfilter条件的怪兽
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
	-- 让玩家从选项中选择一个操作
	local op=Duel.SelectOption(tp,table.unpack(ops))+1
	local sel=opval[op]
	if sel==0 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		-- 设置操作信息为特殊召唤类别
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	end
	e:SetLabel(sel)
end
-- 设置灵摆效果的操作函数，根据选择执行特殊召唤或移动怪兽位置
function s.peop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local op=e:GetLabel()
	if op==0 then
		-- 将该卡特殊召唤到指定区域
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP,1<<c:GetSequence())
	elseif op==1 then
		-- 提示玩家选择要操作的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
		-- 选择满足pfilter条件的怪兽
		local sg=Duel.SelectMatchingCard(tp,s.pfilter,tp,LOCATION_MZONE,0,1,1,nil)
		if #sg>0 then
			local sc=sg:GetFirst()
			local seq=sc:GetSequence()
			if seq>4 then return end
			local flag=0
			-- 如果左侧位置可用，则将其标记为可选位置
			if seq>0 and Duel.CheckLocation(tp,LOCATION_MZONE,seq-1) then flag=flag|(1<<(seq-1)) end
			-- 如果右侧位置可用，则将其标记为可选位置
			if seq<4 and Duel.CheckLocation(tp,LOCATION_MZONE,seq+1) then flag=flag|(1<<(seq+1)) end
			if flag==0 then return end
			-- 提示玩家选择要移动到的位置
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)  --"请选择要移动到的位置"
			-- 选择一个不可用的位置作为目标位置
			local s=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,~flag)
			local nseq=math.log(s,2)
			-- 显示被选中的怪兽动画效果
			Duel.HintSelection(sg)
			-- 将怪兽移动到指定位置
			Duel.MoveSequence(sc,nseq)
		end
	end
end
-- 定义交换怪兽位置的过滤条件，只检查主要怪兽区域的怪兽
function s.chfilter(c)
	return c:GetSequence()<5
end
-- 定义子组检查函数，确保所选怪兽属于同一玩家
function s.gcheck(g)
	return g:GetClassCount(Card.GetControler)==1
end
-- 设置交换怪兽位置的效果目标函数，检查是否存在满足条件的怪兽组合
function s.chtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取所有主要怪兽区域的怪兽
	local g=Duel.GetMatchingGroup(s.chfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if chk==0 then return g:CheckSubGroup(s.gcheck,2,2) end
end
-- 设置交换怪兽位置的效果操作函数，选择并交换两个怪兽的位置
function s.chop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取所有主要怪兽区域的怪兽
	local g=Duel.GetMatchingGroup(s.chfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 提示玩家选择要操作的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	local sg=g:SelectSubGroup(tp,s.gcheck,false,2,2)
	if sg then
		-- 显示被选中的怪兽动画效果
		Duel.HintSelection(sg)
		local tc1=sg:GetFirst()
		local tc2=sg:GetNext()
		-- 交换两个怪兽的位置
		Duel.SwapSequence(tc1,tc2)
	end
end
-- 定义移动怪兽时的检查条件，判断是否发生位置或控制权变化
function s.cfilter(c)
	return c:IsLocation(LOCATION_MZONE) and c:IsPreviousLocation(LOCATION_MZONE)
		and (c:GetPreviousSequence()~=c:GetSequence() or c:GetPreviousControler()~=c:GetControler())
end
-- 设置破坏效果的触发条件，当有怪兽移入其他区域时触发
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil)
end
-- 设置破坏效果的目标函数，选择场上任意一张卡进行破坏
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取场上的所有卡
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if chk==0 then return #g>0 end
	-- 设置操作信息为破坏类别
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 设置破坏效果的操作函数，选择并破坏一张卡
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上任意一张卡进行破坏
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		-- 显示被选中的卡动画效果
		Duel.HintSelection(g)
		-- 将所选卡破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end

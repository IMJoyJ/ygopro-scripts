--ヴァリアンツの聚－幻中
-- 效果：
-- ←10 【灵摆】 10→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：可以从以下效果选择1个发动。
-- ●这张卡在正对面的自己的主要怪兽区域特殊召唤。
-- ●选自己的主要怪兽区域1只怪兽，那个位置向那个相邻的怪兽区域移动。
-- 【怪兽效果】
-- 「群豪」怪兽×3
-- 这个卡名的①的怪兽效果1回合只能使用1次。
-- ①：双方的主要阶段，以对方的主要怪兽区域1只效果怪兽为对象才能发动。那只对方怪兽在和那只是相同纵列的对方的魔法与陷阱区域当作永续魔法卡使用以表侧表示放置（所要放置区的卡破坏，那是怪兽卡的场合，对方失去那个攻击力数值的基本分）。
-- ②：特殊召唤的这张卡被对方的效果破坏的场合才能发动。这张卡在自己的灵摆区域放置。
function c40680521.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：用3只满足“群豪”字段条件的怪兽作为融合素材来融合召唤。
	aux.AddFusionProcFunRep(c,c40680521.ffilter,3,true)
	-- 为这张卡添加灵摆怪兽属性（灵摆召唤・灵摆卡的发动）；传入false表示不注册灵摆卡“卡的发动”效果，因为其灵摆效果通过单独的起动效果实现。
	aux.EnablePendulumAttribute(c,false)
	-- 对应效果原文：这个卡名的灵摆效果1回合只能使用1次。①：可以从以下效果选择1个发动。●这张卡在正对面的自己的主要怪兽区域特殊召唤。●选自己的主要怪兽区域1只怪兽，那个位置向那个相邻的怪兽区域移动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,40680521)
	e1:SetTarget(c40680521.ptg)
	e1:SetOperation(c40680521.pop)
	c:RegisterEffect(e1)
	-- 对应效果原文：①：双方的主要阶段，以对方的主要怪兽区域1只效果怪兽为对象才能发动。那只对方怪兽在和那只是相同纵列的对方的魔法与陷阱区域当作永续魔法卡使用以表侧表示放置（所要放置区的卡破坏，那是怪兽卡的场合，对方失去那个攻击力数值的基本分）。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,40680522)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCondition(c40680521.stcon)
	e2:SetTarget(c40680521.sttg)
	e2:SetOperation(c40680521.stop)
	c:RegisterEffect(e2)
	-- 对应效果原文：②：特殊召唤的这张卡被对方的效果破坏的场合才能发动。这张卡在自己的灵摆区域放置。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(c40680521.pencon)
	e3:SetTarget(c40680521.pentg)
	e3:SetOperation(c40680521.penop)
	c:RegisterEffect(e3)
end
-- 融合素材筛选函数：判断素材卡是否属于“群豪”系列（SetCard为0x17d）。
function c40680521.ffilter(c,fc,sub,mg,sg)
	return c:IsFusionSetCard(0x17d)
end
-- 灵摆效果“位置移动”的筛选函数：选取自己主要怪兽区域中，左边或右边相邻的主怪兽区域有空位的怪兽（且不在额外怪兽区）。
function c40680521.pfilter(c)
	local seq=c:GetSequence()
	local tp=c:GetControler()
	if seq>4 then return false end
	-- 检查该怪兽左侧相邻的主怪兽区域是否为空位可用（seq>0且seq-1位置可正常使用）。
	return (seq>0 and Duel.CheckLocation(tp,LOCATION_MZONE,seq-1))
		-- 检查该怪兽右侧相邻的主怪兽区域是否为空位可用（seq<4且seq+1位置可正常使用）。
		or (seq<4 and Duel.CheckLocation(tp,LOCATION_MZONE,seq+1))
end
-- 灵摆效果①的发动判定与分支选择：分别判定自己能否特殊召唤到正对面主怪兽区、是否存在可移动的怪兽；若可行则让玩家选择要发动的分支（特殊召唤/位置移动），将选择结果存入效果标签，并在选择特殊召唤时设置特殊召唤的操作信息。
function c40680521.ptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local zone=1<<c:GetSequence()
	local b1=c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
	-- 检查自己场上是否存在至少1只满足pfilter条件的怪兽（旁边有可用相邻空格的主怪兽区怪兽），用于“位置移动”分支。
	local b2=Duel.IsExistingMatchingCard(c40680521.pfilter,tp,LOCATION_MZONE,0,1,nil)
	if chk==0 then return b1 or b2 end
	local s=0
	if b1 and not b2 then
		-- 当仅可特殊召唤时，让玩家选择“特殊召唤”选项，返回的选项序号0直接作为分支标签。
		s=Duel.SelectOption(tp,aux.Stringid(40680521,0))  --"特殊召唤"
	end
	if not b1 and b2 then
		-- 当仅可位置移动时，让玩家选择“位置移动”选项，返回值加1作为分支标签（对应1）。
		s=Duel.SelectOption(tp,aux.Stringid(40680521,1))+1  --"位置移动"
	end
	if b1 and b2 then
		-- 当两个分支都可用时，弹出“特殊召唤/位置移动”两个选项，玩家选择后得到的分支标签（0或1）。
		s=Duel.SelectOption(tp,aux.Stringid(40680521,0),aux.Stringid(40680521,1))  --"特殊召唤/位置移动"
	end
	e:SetLabel(s)
	if s==0 then
		-- 设置操作信息：声明本效果包含特殊召唤分类（CATEGORY_SPECIAL_SUMMON），目标为这张卡自身，数量1，供其他卡片在效果发动时检测。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	end
end
-- 灵摆效果①的解决处理：根据发动时选择的分支标签执行；标签0则将这张卡特殊召唤到正对面自己的主怪兽区；标签1则选择一只可移动的怪兽并将其移动到相邻的空位。
function c40680521.pop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local zone=1<<c:GetSequence()
	if e:GetLabel()==0 then
		-- 将这张卡以表侧表示特殊召唤到自己场上由zone指定的主怪兽区域（由灵摆卡的纵列位置计算出的正对面区域）。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP,zone)
	end
	if e:GetLabel()==1 then
		-- 弹出“请选择移动位置的怪兽”的提示消息，用于后续选择卡片的提示。
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(40680521,2))  --"请选择移动位置的怪兽"
		-- 从自己场上选择1只满足pfilter条件（旁边有相邻空位）的怪兽，作为位置移动的对象。
		local sc=Duel.SelectMatchingCard(tp,c40680521.pfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
		if sc then
			local seq=sc:GetSequence()
			if seq>4 then return end
			local flag=0
			-- 若该怪兽左侧相邻的主怪兽区域为空，则将左侧格子加入可选移动位置标记flag中（用位标记表示该序号）。
			if seq>0 and Duel.CheckLocation(tp,LOCATION_MZONE,seq-1) then flag=flag|(1<<(seq-1)) end
			-- 若该怪兽右侧相邻的主怪兽区域为空，则将右侧格子加入可选移动位置标记flag中。
			if seq<4 and Duel.CheckLocation(tp,LOCATION_MZONE,seq+1) then flag=flag|(1<<(seq+1)) end
			if flag==0 then return end
			-- 弹出“请选择要移动到的位置”提示消息，用于选择格子的提示。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)  --"请选择要移动到的位置"
			-- 让玩家在可选移动格子中选1个位置，~flag作为不可选位置的过滤；返回的位标记中唯一置1的位即所选格子。
			local s=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,~flag)
			local nseq=math.log(s,2)
			-- 将选中的怪兽移动到玩家选择的格子（nseq是从位标记解析出的格子序号）。
			Duel.MoveSequence(sc,nseq)
		end
	end
end
-- 怪兽效果①的发动条件判定：当前阶段是主要阶段1或主要阶段2。
function c40680521.stcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前阶段是否为主要阶段1或主要阶段2（即双方主要阶段）。
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 怪兽效果①的对象筛选函数：选取对方场上表侧表示的效果怪兽，且位于主要怪兽区域（seq<=4，排除额外怪兽区）。
function c40680521.stfilter(c)
	local seq=c:GetSequence()
	return seq<=4 and c:IsType(TYPE_EFFECT) and c:IsFaceup()
end
-- 怪兽效果①的发动目标选择：以对方主要怪兽区域的1只表侧效果怪兽为对象；先判定是否存在合法目标，存在则提示并选择目标。
function c40680521.sttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c40680521.stfilter(chkc) end
	-- 效果发动时检查对方主要怪兽区域是否存在至少1只表侧效果怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c40680521.stfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 弹出“请选择要放置到后场的怪兽”提示消息，用于选择对象卡。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(40680521,3))  --"请选择要放置到后场的怪兽"
	-- 选择对方主要怪兽区域的1只表侧效果怪兽，并将其设为当前连锁的对象（取对象）。
	Duel.SelectTarget(tp,c40680521.stfilter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 怪兽效果①的解决处理：取得对象怪兽，验证其仍与效果相关且不是免疫效果；计算其所在纵列对应的对方魔法与陷阱区域，若有卡则规则破坏；若被破坏的是怪兽卡则对方受到攻击力数值的伤害；最后将对象怪兽移动到该魔陷区并让其变成永续魔法卡。
function c40680521.stop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本效果发动时选择的对象怪兽（此处为一个目标）。
	local tc=Duel.GetFirstTarget()
	if not (tc:IsRelateToEffect(e) and tc:IsControler(1-tp) and not tc:IsImmuneToEffect(e)) then return end
	local zone=1<<tc:GetSequence()
	-- 获取对方魔法与陷阱区域中与对象怪兽相同纵列（sequence相同）的卡（若有），作为需要破坏的卡。
	local oc=Duel.GetMatchingGroup(c40680521.seqfilter,tp,0,LOCATION_SZONE,nil,tc:GetSequence()):GetFirst()
	-- 若该纵列存在卡且被规则破坏成功，并且被破坏的卡是怪兽卡的场合，则执行后续扣LP效果。
	if oc and Duel.Destroy(oc,REASON_RULE)>0 and oc:IsType(TYPE_MONSTER) then
		-- 对方失去被破坏怪兽卡攻击力数值的基本分（即造成该攻击力数值的伤害）。
		Duel.SetLP(1-tp,Duel.GetLP(1-tp)-oc:GetAttack())
	end
	-- 将对象怪兽移动到对方场上与其原纵列对应的魔法与陷阱区域，表侧表示放置；若移动成功则继续将其变为永续魔法卡。
	if Duel.MoveToField(tc,tp,1-tp,LOCATION_SZONE,POS_FACEUP,true,zone) then
		-- 对应效果原文：那只对方怪兽在和那只是相同纵列的对方的魔法与陷阱区域当作永续魔法卡使用以表侧表示放置。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
	end
end
-- 过滤函数：判断卡片所在区域序号（纵列）是否等于指定seq，用于查找同一纵列的魔陷区卡片。
function c40680521.seqfilter(c,seq)
	return c:GetSequence()==seq
end
-- 怪兽效果②的发动条件：这张卡是以特殊召唤方式出场，被对方的效果破坏，且破坏前控制者为自己、位于自己主要怪兽区域、表侧表示。
function c40680521.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_SPECIAL) and rp==1-tp and c:IsReason(REASON_EFFECT)
		and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
-- 怪兽效果②发动时检查自己灵摆区域是否有空位，有才可发动。
function c40680521.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己灵摆区域的第1个（左）或第2个（右）位置是否有空位。
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
-- 怪兽效果②的解决处理：若这张卡仍与触发效果相关，则将其放置到自己的灵摆区域。
function c40680521.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡移动到自己灵摆区域（系统自动选择空位），表侧表示放置。
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end

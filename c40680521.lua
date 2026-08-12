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
	-- 为卡片添加融合召唤手续，使用3个满足条件的怪兽作为融合素材
	aux.AddFusionProcFunRep(c,c40680521.ffilter,3,true)
	-- 为灵摆怪兽添加灵摆属性，不注册灵摆卡的发动效果
	aux.EnablePendulumAttribute(c,false)
	-- ①：可以从以下效果选择1个发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,40680521)
	e1:SetTarget(c40680521.ptg)
	e1:SetOperation(c40680521.pop)
	c:RegisterEffect(e1)
	-- ①：双方的主要阶段，以对方的主要怪兽区域1只效果怪兽为对象才能发动。
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
	-- ②：特殊召唤的这张卡被对方的效果破坏的场合才能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(c40680521.pencon)
	e3:SetTarget(c40680521.pentg)
	e3:SetOperation(c40680521.penop)
	c:RegisterEffect(e3)
end
-- 融合素材必须是「群豪」卡组的怪兽
function c40680521.ffilter(c,fc,sub,mg,sg)
	return c:IsFusionSetCard(0x17d)
end
-- 检查怪兽是否可以移动到相邻位置
function c40680521.pfilter(c)
	local seq=c:GetSequence()
	local tp=c:GetControler()
	if seq>4 then return false end
	-- 检查怪兽左侧位置是否可用
	return (seq>0 and Duel.CheckLocation(tp,LOCATION_MZONE,seq-1))
		-- 检查怪兽右侧位置是否可用
		or (seq<4 and Duel.CheckLocation(tp,LOCATION_MZONE,seq+1))
end
-- 设置灵摆效果的发动条件和操作
function c40680521.ptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local zone=1<<c:GetSequence()
	local b1=c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
	-- 检查是否存在可以移动的怪兽
	local b2=Duel.IsExistingMatchingCard(c40680521.pfilter,tp,LOCATION_MZONE,0,1,nil)
	if chk==0 then return b1 or b2 end
	local s=0
	if b1 and not b2 then
		-- 选择是否发动特殊召唤
		s=Duel.SelectOption(tp,aux.Stringid(40680521,0))  --"特殊召唤"
	end
	if not b1 and b2 then
		-- 选择是否发动位置移动
		s=Duel.SelectOption(tp,aux.Stringid(40680521,1))+1  --"位置移动"
	end
	if b1 and b2 then
		-- 选择发动特殊召唤或位置移动
		s=Duel.SelectOption(tp,aux.Stringid(40680521,0),aux.Stringid(40680521,1))  --"特殊召唤/位置移动"
	end
	e:SetLabel(s)
	if s==0 then
		-- 设置操作信息，表示将特殊召唤
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	end
end
-- 执行灵摆效果的操作
function c40680521.pop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local zone=1<<c:GetSequence()
	if e:GetLabel()==0 then
		-- 将卡片特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP,zone)
	end
	if e:GetLabel()==1 then
		-- 提示选择要移动的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(40680521,2))  --"请选择移动位置的怪兽"
		-- 选择要移动的怪兽
		local sc=Duel.SelectMatchingCard(tp,c40680521.pfilter,tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
		if sc then
			local seq=sc:GetSequence()
			if seq>4 then return end
			local flag=0
			-- 设置可移动的左侧位置
			if seq>0 and Duel.CheckLocation(tp,LOCATION_MZONE,seq-1) then flag=flag|(1<<(seq-1)) end
			-- 设置可移动的右侧位置
			if seq<4 and Duel.CheckLocation(tp,LOCATION_MZONE,seq+1) then flag=flag|(1<<(seq+1)) end
			if flag==0 then return end
			-- 提示选择要移动到的位置
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)  --"请选择要移动到的位置"
			-- 选择要移动到的位置
			local s=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,~flag)
			local nseq=math.log(s,2)
			-- 将怪兽移动到指定位置
			Duel.MoveSequence(sc,nseq)
		end
	end
end
-- 设置怪兽效果的发动条件
function c40680521.stcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为主要阶段
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 设置怪兽效果的目标过滤条件
function c40680521.stfilter(c)
	local seq=c:GetSequence()
	return seq<=4 and c:IsType(TYPE_EFFECT) and c:IsFaceup()
end
-- 设置怪兽效果的目标选择
function c40680521.sttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c40680521.stfilter(chkc) end
	-- 检查是否存在满足条件的目标
	if chk==0 then return Duel.IsExistingTarget(c40680521.stfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示选择要放置到后场的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(40680521,3))  --"请选择要放置到后场的怪兽"
	-- 选择要放置到后场的怪兽
	Duel.SelectTarget(tp,c40680521.stfilter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 执行怪兽效果的操作
function c40680521.stop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if not (tc:IsRelateToEffect(e) and tc:IsControler(1-tp) and not tc:IsImmuneToEffect(e)) then return end
	local zone=1<<tc:GetSequence()
	-- 获取目标怪兽所在位置的魔法与陷阱区的卡
	local oc=Duel.GetMatchingGroup(c40680521.seqfilter,tp,0,LOCATION_SZONE,nil,tc:GetSequence()):GetFirst()
	-- 如果目标位置有卡则破坏并计算攻击力
	if oc and Duel.Destroy(oc,REASON_RULE)>0 and oc:IsType(TYPE_MONSTER) then
		-- 对对方造成攻击力数值的基本分伤害
		Duel.SetLP(1-tp,Duel.GetLP(1-tp)-oc:GetAttack())
	end
	-- 将目标怪兽移动到魔法与陷阱区
	if Duel.MoveToField(tc,tp,1-tp,LOCATION_SZONE,POS_FACEUP,true,zone) then
		-- 将目标怪兽变为永续魔法卡
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
	end
end
-- 用于筛选指定位置的卡
function c40680521.seqfilter(c,seq)
	return c:GetSequence()==seq
end
-- 设置灵摆效果的发动条件
function c40680521.pencon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_SPECIAL) and rp==1-tp and c:IsReason(REASON_EFFECT)
		and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsFaceup()
end
-- 设置灵摆效果的发动条件
function c40680521.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查灵摆区域是否有空位
	if chk==0 then return Duel.CheckLocation(tp,LOCATION_PZONE,0) or Duel.CheckLocation(tp,LOCATION_PZONE,1) end
end
-- 执行灵摆效果的操作
function c40680521.penop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将卡片移动到灵摆区域
		Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end

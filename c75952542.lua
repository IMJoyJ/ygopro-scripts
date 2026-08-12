--VV－百識公国
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：作为这张卡的发动时的效果处理，从卡组把「群豪世界-百识公国」以外的1张「群豪」场地魔法卡在对方的场地区域表侧表示放置。
-- ②：场地区域有2张卡的场合，回合玩家以自身怪兽的正对面的对方的主要怪兽区域1只效果怪兽为对象才能发动。那只对方怪兽在相同纵列的对方的魔法与陷阱区域当作永续魔法卡使用以表侧表示放置（所要放置区的卡破坏）。
function c75952542.initial_effect(c)
	-- ①：作为这张卡的发动时的效果处理，从卡组把「群豪世界-百识公国」以外的1张「群豪」场地魔法卡在对方的场地区域表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c75952542.target)
	e1:SetOperation(c75952542.activate)
	c:RegisterEffect(e1)
	-- ②：场地区域有2张卡的场合，回合玩家以自身怪兽的正对面的对方的主要怪兽区域1只效果怪兽为对象才能发动。那只对方怪兽在相同纵列的对方的魔法与陷阱区域当作永续魔法卡使用以表侧表示放置（所要放置区的卡破坏）。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_BOTH_SIDE+EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,75952542)
	e2:SetCondition(c75952542.stcon)
	e2:SetTarget(c75952542.sttg)
	e2:SetOperation(c75952542.stop)
	c:RegisterEffect(e2)
end
-- 过滤卡组中「群豪世界-百识公国」以外的「群豪」场地魔法卡
function c75952542.setfilter(c,tp)
	return c:IsSetCard(0x17d) and not c:IsCode(75952542) and c:IsType(TYPE_FIELD) and not c:IsForbidden() and c:CheckUniqueOnField(1-tp)
end
-- 卡片发动时的效果处理（效果①）的靶向函数
function c75952542.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可放置的「群豪」场地魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c75952542.setfilter,tp,LOCATION_DECK,0,1,nil,tp) end
end
-- 卡片发动时的效果处理（效果①）的执行函数
function c75952542.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要放置到场上的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 从卡组中选择1张满足条件的「群豪」场地魔法卡
	local tc=Duel.SelectMatchingCard(tp,c75952542.setfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if tc then
		-- 获取对方场地区域原本存在的卡片
		local fc=Duel.GetFieldCard(1-tp,LOCATION_SZONE,5)
		if fc then
			-- 因规则原因将对方场地区域原本存在的卡片送去墓地
			Duel.SendtoGrave(fc,REASON_RULE)
			-- 中断当前效果，使后续的放置处理与送去墓地不视为同时处理
			Duel.BreakEffect()
		end
		-- 将选择的场地魔法卡在对方的场地区域表侧表示放置
		Duel.MoveToField(tc,tp,1-tp,LOCATION_FZONE,POS_FACEUP,true)
	end
end
-- 效果②的发动条件函数
function c75952542.stcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查双方场地区域的卡片总数是否为2张
	return Duel.GetFieldGroupCount(tp,LOCATION_FZONE,LOCATION_FZONE)==2
end
-- 过滤对方主要怪兽区域中正对面有己方怪兽的效果怪兽
function c75952542.stfilter(c,tp)
	local seq=c:GetSequence()
	return seq<=4 and c:IsType(TYPE_EFFECT) and c:IsFaceup()
		-- 检查在相同纵列（正对面）的己方主要怪兽区域是否存在怪兽
		and Duel.IsExistingMatchingCard(c75952542.cfilter,tp,LOCATION_MZONE,0,1,nil,seq)
end
-- 过滤与指定怪兽区域序号处于相同纵列（正对面）的己方怪兽
function c75952542.cfilter(c,seq)
	-- 判定怪兽的区域序号是否与对方怪兽的区域序号在相同纵列（正对面）
	return aux.MZoneSequence(c:GetSequence())==4-seq
end
-- 效果②的发动准备与对象选择函数
function c75952542.sttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c75952542.stfilter(chkc,tp) end
	-- 检查是否存在可以作为效果对象的、正对面有己方怪兽的对方效果怪兽
	if chk==0 then return Duel.IsExistingTarget(c75952542.stfilter,tp,0,LOCATION_MZONE,1,nil,tp) end
	-- 提示玩家选择要放置到后场的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(75952542,0))  --"请选择要放置到后场的怪兽"
	-- 选择1只满足条件的对方效果怪兽作为效果对象
	Duel.SelectTarget(tp,c75952542.stfilter,tp,0,LOCATION_MZONE,1,1,nil,tp)
end
-- 效果②的执行函数
function c75952542.stop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if not (tc:IsRelateToEffect(e) and tc:IsControler(1-tp) and not tc:IsImmuneToEffect(e)) then return end
	local zone=1<<tc:GetSequence()
	-- 获取与该怪兽相同纵列的对方魔法与陷阱区域中已存在的卡片
	local oc=Duel.GetMatchingGroup(c75952542.seqfilter,tp,0,LOCATION_SZONE,nil,tc:GetSequence()):GetFirst()
	if oc then
		-- 因规则原因破坏所要放置区域原本存在的卡片
		Duel.Destroy(oc,REASON_RULE)
	end
	-- 将该对方怪兽移动到相同纵列的对方魔法与陷阱区域表侧表示放置
	if Duel.MoveToField(tc,tp,1-tp,LOCATION_SZONE,POS_FACEUP,true,zone) then
		-- 当作永续魔法卡使用
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetCode(EFFECT_CHANGE_TYPE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
		tc:RegisterEffect(e1)
	end
end
-- 过滤指定区域序号的卡片
function c75952542.seqfilter(c,seq)
	return c:GetSequence()==seq
end

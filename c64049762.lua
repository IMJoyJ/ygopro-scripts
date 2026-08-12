--雷盟－ブレイクアウェイ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：可以从以下效果选择1个发动。
-- ●从卡组把1张「雷盟」永续陷阱卡在自己场上表侧表示放置。
-- ●让自己场上1只雷族怪兽回到手卡，以场上1张卡为对象才能发动。那张卡破坏。
-- ②：这张卡在墓地存在的状态，自己的「雷盟」卡的效果把卡破坏的场合才能发动。这张卡加入手卡。
local s,id,o=GetID()
-- 在卡片效果初始化函数中，注册该卡的发动效果e1（包含破坏、取对象、次数限制等属性），以及其在墓地诱发的回手效果e2（包含时点、延迟发动、次数限制、墓地触发范围等属性）。
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：可以从以下效果选择1个发动。●从卡组把1张「雷盟」永续陷阱卡在自己场上表侧表示放置。●让自己场上1只雷族怪兽回到手卡，以场上1张卡为对象才能发动。那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，自己的「雷盟」卡的效果把卡破坏的场合才能发动。这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回到手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数：筛选卡组中属于「雷盟」字段（0x1df）的永续陷阱卡，且该卡未被封锁且在场上唯一存在。
function s.pfilter(c,tp)
	return c:IsType(TYPE_CONTINUOUS) and c:IsType(TYPE_TRAP) and c:IsSetCard(0x1df)
		and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- 过滤函数：筛选自己场上表侧表示的雷族怪兽，要求其能作为Cost回到手牌，且场上存在可供选择为对象的其他卡片。
function s.cfilter(c,ec,tp)
	return c:IsFaceup() and c:IsRace(RACE_THUNDER) and c:IsAbleToHandAsCost()
		-- 检查场上是否存在除自身与当前卡以外的、可作为破坏对象的目标卡。
		and Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,Group.FromCards(c,ec))
end
-- 效果发动时的Cost校验与处理函数，检测当前可发动的效果分支，由玩家进行选择，若选择了“破坏效果”则执行雷族怪兽回手牌的Cost操作。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上魔法与陷阱区域的空余格子数量。
	local ct=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) and not e:GetHandler():IsLocation(LOCATION_SZONE) then ct=ct-1 end
	-- 校验第一个分支（放置永续陷阱）的可行性：魔陷区有空位，且卡组中存在符合条件的「雷盟」永续陷阱。
	local b1=ct>0 and Duel.IsExistingMatchingCard(s.pfilter,tp,LOCATION_DECK,0,1,nil,tp)
	-- 校验第二个分支（回手破坏）的可行性：自己场上存在可作为Cost回手的雷族怪兽，且场上有其他可破坏的目标。
	local b2=Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,e:GetHandler(),e:GetHandler(),tp)
	if chk==0 then return b1 or b2 end
	-- 让玩家在符合发动条件的两个分支效果中选择一个执行。
	local op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,2),1},  --"放置永续陷阱卡"
			{b2,aux.Stringid(id,3),2})  --"破坏效果"
	if op==2 then
		-- 向玩家发送提示，指示选择作为Cost返回手牌的怪兽卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
		-- 让玩家选择1只满足条件的雷族怪兽以作为Cost送回手牌。
		local rg=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler(),e:GetHandler(),tp)
		-- 手动为选中的怪兽卡显示被选择的动画效果。
		Duel.HintSelection(rg)
		-- 将选定的雷族怪兽作为Cost返回手牌。
		Duel.SendtoHand(rg,nil,REASON_COST)
	end
	e:SetLabel(op)
end
-- 效果发动时的目标选择与校验函数，根据玩家选择的效果分支，设定卡片效果分类与对象属性，若为破坏分支则让玩家选择1张场上的卡作为对象并设置操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc~=e:GetHandler() and chkc:IsOnField() end
	-- 检测自己魔陷区是否有空余的格子。
	local b1=Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检测卡组中是否存在可以放置的「雷盟」永续陷阱。
		and Duel.IsExistingMatchingCard(s.pfilter,tp,LOCATION_DECK,0,1,nil,tp)
	-- 检测场上是否存在除当前卡以外的任何卡片可以作为破坏的对象。
	local b2=Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler())
	if chk==0 then return e:IsCostChecked() or b1 or b2 end
	local op=0
	if e:IsCostChecked() then
		op=e:GetLabel()
	else
		-- 在未支付Cost进行合法性检查时，让玩家选择要发动的效果分支。
		op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,2),1},  --"放置永续陷阱卡"
			{b2,aux.Stringid(id,3),2})  --"破坏效果"
	end
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(0)
			e:SetProperty(0)
		end
	elseif op==2 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_DESTROY)
			e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		end
		-- 对于破坏效果分支：向玩家发送提示，指示选择要破坏的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 对于破坏效果分支：让玩家选择场上1张卡作为该破坏效果的对象。
		local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
		-- 对于破坏效果分支：设置连锁处理的操作信息，声明本次效果会破坏1张选定的卡。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	end
end
-- 效果处理函数：根据玩家所选择的分支，执行对应的处理（从卡组表侧放置「雷盟」永续陷阱，或者破坏被选为对象的那张卡）。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- 对于放置分支：若魔陷区没有空余位置，则无法放置，效果处理终止。
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
		-- 对于放置分支：向玩家发送提示，指示选择要放置到场上的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
		-- 对于放置分支：让玩家从卡组中选择1张符合条件的「雷盟」永续陷阱卡。
		local tc=Duel.SelectMatchingCard(tp,s.pfilter,tp,LOCATION_DECK,0,1,1,nil,tp):GetFirst()
		if tc then
			-- 对于放置分支：将选中的永续陷阱卡在自己的魔法与陷阱区域表侧表示放置，并使其立刻适用效果。
			Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		end
	elseif e:GetLabel()==2 then
		-- 对于破坏分支：获取被选作效果对象的目标卡。
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToChain() and tc:IsOnField() then
			-- 对于破坏分支：因效果将选定的目标卡破坏并送去墓地。
			Duel.Destroy(tc,REASON_EFFECT)
		end
	end
end
-- 过滤函数：用于筛选因效果而被破坏的卡。
function s.dcfilter(c)
	return c:IsReason(REASON_EFFECT)
end
-- 诱发效果的触发条件函数：检查该卡是否在墓地、是否由玩家自己的「雷盟」卡片的效果造成了卡片破坏。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return re and rp==tp and eg:IsExists(s.dcfilter,1,c) and re:GetHandler():IsSetCard(0x1df)
end
-- 诱发效果的发动目标校验函数，检查墓地中的该卡是否能加入手牌，并设置操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置连锁处理的操作信息，声明本次效果会将墓地中的这张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 诱发效果的处理函数：若该卡仍与连锁相关且未受到王家长眠之谷的妨碍，则将此卡加入手牌并给对方确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查墓地的该卡是否仍与当前连锁相关，并对其应用王家长眠之谷的过滤规则。
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 因效果将该卡从墓地送回持有者的手牌。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 将加入手牌的卡片向对方玩家进行展示确认。
		Duel.ConfirmCards(1-tp,c)
	end
end

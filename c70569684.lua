--ハイレート・ドロー
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：选自己场上的怪兽2只以上任意数量破坏，破坏的怪兽每有2只，自己从卡组抽1张。
-- ②：这张卡在墓地存在的场合，对方主要阶段，以自己场上1只怪兽为对象才能发动。那只怪兽破坏，这张卡在自己场上盖放。这个效果盖放的这张卡从场上离开的场合除外。
function c70569684.initial_effect(c)
	-- ①：选自己场上的怪兽2只以上任意数量破坏，破坏的怪兽每有2只，自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(70569684,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c70569684.target)
	e1:SetOperation(c70569684.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，对方主要阶段，以自己场上1只怪兽为对象才能发动。那只怪兽破坏，这张卡在自己场上盖放。这个效果盖放的这张卡从场上离开的场合除外。这个卡名的②的效果1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(70569684,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMING_MAIN_END)
	e2:SetCountLimit(1,70569684)
	e2:SetCondition(c70569684.setcon)
	e2:SetTarget(c70569684.settg)
	e2:SetOperation(c70569684.setop)
	c:RegisterEffect(e2)
end
-- ①效果的发动准备（检查场上怪兽数量及是否能抽卡，并设置破坏与抽卡的操作信息）
function c70569684.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上的所有怪兽
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,0,nil)
	-- 检查自己场上怪兽是否在2只以上，且自己是否可以抽卡
	if chk==0 then return g:GetCount()>=2 and Duel.IsPlayerCanDraw(tp,1) end
	-- 设置破坏操作信息，预计破坏至少2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
	-- 设置抽卡操作信息，预计抽至少1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ①效果的处理（选择并破坏怪兽，根据破坏数量进行抽卡）
function c70569684.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前自己场上的所有怪兽
	local cg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,0,nil)
	if #cg<2 then return end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择自己场上2只以上任意数量的怪兽
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_MZONE,0,2,99,nil)
	if #g==0 then return end
	-- 破坏选中的怪兽，并获取实际被破坏的怪兽数量
	local num=Duel.Destroy(g,REASON_EFFECT)
	num=math.floor(num/2)
	if num<1 then return end
	-- 自己从卡组抽对应数量（破坏数量除以2）的卡
	Duel.Draw(tp,num,REASON_EFFECT)
end
-- ②效果的发动条件（对方主要阶段）
function c70569684.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前阶段
	local ph=Duel.GetCurrentPhase()
	-- 判断当前是否为对方回合的主要阶段1或主要阶段2
	return Duel.GetTurnPlayer()==1-tp and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
end
-- ②效果的发动准备（选择自己场上1只怪兽作为对象，并设置破坏与盖放的操作信息）
function c70569684.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) end
	-- 检查自己场上是否存在可以作为对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,0,1,nil)
		and e:GetHandler():IsSSetable() end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置破坏操作信息，预计破坏1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置涉及墓地卡片移动的操作信息
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- ②效果的处理（破坏对象怪兽，并将此卡在场上盖放，设置离场除外效果）
function c70569684.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍适用此效果，则将其破坏
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0
		-- 若此卡仍适用此效果，则将此卡在自己场上盖放
		and c:IsRelateToEffect(e) and Duel.SSet(tp,c)>0 then
		-- 这个效果盖放的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1)
	end
end

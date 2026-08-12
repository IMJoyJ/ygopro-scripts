--ジョーカーズ・ワイルド
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段以及战斗阶段，从卡组把有「王后骑士」「卫兵骑士」「国王骑士」的卡名全部记述的1张魔法卡送去墓地才能发动。这个效果变成和那张魔法卡发动时的效果相同。
-- ②：自己·对方的结束阶段，以自己墓地1只战士族·光属性怪兽为对象才能发动。那只怪兽回到卡组，墓地的这张卡加入手卡。
function c81945678.initial_effect(c)
	-- 在卡片中注册关联卡名「王后骑士」、「卫兵骑士」、「国王骑士」，以便后续进行效果文本检索判定
	aux.AddCodeList(c,25652259,64788463,90876561)
	-- ①：自己·对方的主要阶段以及战斗阶段，从卡组把有「王后骑士」「卫兵骑士」「国王骑士」的卡名全部记述的1张魔法卡送去墓地才能发动。这个效果变成和那张魔法卡发动时的效果相同。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(81945678,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END+TIMING_BATTLE_START)
	e1:SetCountLimit(1,81945678)
	e1:SetCondition(c81945678.cpcon)
	e1:SetCost(c81945678.cpcost)
	e1:SetTarget(c81945678.cptg)
	e1:SetOperation(c81945678.cpop)
	c:RegisterEffect(e1)
	-- ②：自己·对方的结束阶段，以自己墓地1只战士族·光属性怪兽为对象才能发动。那只怪兽回到卡组，墓地的这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(81945678,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCountLimit(1,81945679)
	e2:SetCondition(c81945678.tdcon)
	e2:SetTarget(c81945678.tdtg)
	e2:SetOperation(c81945678.tdop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件判定函数（自己·对方的主要阶段以及战斗阶段）
function c81945678.cpcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的游戏阶段
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2 or (ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE)
end
-- 过滤卡组中记述了「王后骑士」「卫兵骑士」「国王骑士」卡名的魔法卡
function c81945678.cpfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToGraveAsCost() and c:CheckActivateEffect(false,true,false)~=nil
		-- 判定卡片效果文本中是否同时记述了「王后骑士」、「卫兵骑士」和「国王骑士」的卡名
		and aux.IsCodeListed(c,25652259) and aux.IsCodeListed(c,64788463) and aux.IsCodeListed(c,90876561)
end
-- 效果①的发动代价（Cost）处理函数，用于在发动时标记并执行后续的Cost处理
function c81945678.cpcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	if chk==0 then return true end
end
-- 效果①的发动准备（Target）处理函数，包含选择卡片送去墓地作为Cost，并复制该魔法卡的发动效果
function c81945678.cptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()==0 then return false end
		e:SetLabel(0)
		-- 检查自己卡组是否存在至少1张满足条件的魔法卡
		return Duel.IsExistingMatchingCard(c81945678.cpfilter,tp,LOCATION_DECK,0,1,nil)
	end
	e:SetLabel(0)
	-- 在客户端提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1张满足条件的魔法卡
	local g=Duel.SelectMatchingCard(tp,c81945678.cpfilter,tp,LOCATION_DECK,0,1,1,nil)
	local te,ceg,cep,cev,cre,cr,crp=g:GetFirst():CheckActivateEffect(false,true,true)
	-- 将选择的卡作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
	e:SetProperty(te:GetProperty())
	local tg=te:GetTarget()
	if tg then tg(e,tp,ceg,cep,cev,cre,cr,crp,1) end
	te:SetLabelObject(e:GetLabelObject())
	e:SetLabelObject(te)
	-- 清除当前连锁的操作信息，防止被其他卡片进行不当响应
	Duel.ClearOperationInfo(0)
end
-- 效果①的效果处理（Operation）函数，执行被复制的魔法卡的效果
function c81945678.cpop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if te then
		e:SetLabelObject(te:GetLabelObject())
		local op=te:GetOperation()
		if op then op(e,tp,eg,ep,ev,re,r,rp) end
	end
end
-- 效果②的发动条件判定函数（自己·对方的结束阶段）
function c81945678.tdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前阶段是否为结束阶段
	return Duel.GetCurrentPhase()==PHASE_END
end
-- 过滤自己墓地中可以回到卡组的战士族·光属性怪兽
function c81945678.tdfilter(c)
	return c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToDeck()
end
-- 效果②的发动准备（Target）处理函数，选择墓地的战士族·光属性怪兽为对象
function c81945678.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c81945678.tdfilter(chkc) end
	-- 检查自己墓地是否存在至少1只可以作为对象的战士族·光属性怪兽
	if chk==0 then return Duel.IsExistingTarget(c81945678.tdfilter,tp,LOCATION_GRAVE,0,1,nil)
		and e:GetHandler():IsAbleToHand() end
	-- 在客户端提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己墓地1只战士族·光属性怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c81945678.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置当前连锁的操作信息为“将目标怪兽回到卡组”
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	-- 设置当前连锁的操作信息为“将墓地的这张卡加入手卡”
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果②的效果处理（Operation）函数，执行怪兽回到卡组以及此卡加入手卡的处理
function c81945678.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 判定对象怪兽是否仍适用此效果，并将其送回卡组（或额外卡组）并洗牌，确认成功回到卡组
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA)
		and c:IsRelateToEffect(e) then
		-- 将墓地的这张卡加入手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end

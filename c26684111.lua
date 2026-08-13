--天空の聖水
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从卡组把1张「天空的圣域」发动或把有「天空的圣域」的卡名记述的1只怪兽加入手卡。那之后，场上或者墓地有「天空的圣域」存在的场合，自己可以回复自己场上的「许珀里翁」怪兽以及「代行者」怪兽数量×500基本分。
-- ②：有「天空的圣域」的卡名记述的自己怪兽被战斗破坏的场合，可以作为代替把墓地的这张卡除外。
function c26684111.initial_effect(c)
	-- 将本卡登记为卡名中记载了「天空的圣域」（56433456）的卡，使 aux.IsCodeListed 可检测该关系。
	aux.AddCodeList(c,56433456)
	-- ①：从卡组把1张「天空的圣域」发动或把有「天空的圣域」的卡名记述的1只怪兽加入手卡。那之后，场上或者墓地有「天空的圣域」存在的场合，自己可以回复自己场上的「许珀里翁」怪兽以及「代行者」怪兽数量×500基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCountLimit(1,26684111)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c26684111.target)
	e1:SetOperation(c26684111.activate)
	c:RegisterEffect(e1)
	-- ②：有「天空的圣域」的卡名记述的自己怪兽被战斗破坏的场合，可以作为代替把墓地的这张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,26684112)
	e2:SetTarget(c26684111.reptg)
	e2:SetValue(c26684111.repval)
	e2:SetOperation(c26684111.repop)
	c:RegisterEffect(e2)
end
-- 定义检索过滤器：卡必须是「天空的圣域」（56433456），且其场地魔法效果在当前状态下可以由 tp 发动。
function c26684111.actfilter(c,tp)
	return c:IsCode(56433456) and c:GetActivateEffect():IsActivatable(tp,true,true)
end
-- 定义检索怪兽的过滤器：必须是效果文本中记述了「天空的圣域」的怪兽，并且能够加入手卡。
function c26684111.thfilter(c)
	-- 检查是否为怪兽、是否卡名记载了「天空的圣域」、以及是否能被加入手卡。
	return c:IsType(TYPE_MONSTER) and aux.IsCodeListed(c,56433456) and c:IsAbleToHand()
end
-- ①效果的发动条件判定：检查卡组中是否至少存在一张可发动的「天空的圣域」或可加入手卡的记述怪兽，满足其一即可发动。
function c26684111.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在满足条件的「天空的圣域」（可发动），存在则 b1 为 true。
	local b1=Duel.IsExistingMatchingCard(c26684111.actfilter,tp,LOCATION_DECK,0,1,nil,tp)
	-- 检查卡组是否存在满足条件的记述怪兽（可加入手卡），存在则 b2 为 true。
	local b2=Duel.IsExistingMatchingCard(c26684111.thfilter,tp,LOCATION_DECK,0,1,nil)
	if chk==0 then return b1 or b2 end
end
-- 定义基本分回复计数用的过滤器：表侧表示且属于「代行者」（0x44）或「许珀里翁」（0x16f）系列的怪兽。
function c26684111.recfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x44,0x16f)
end
-- 执行①效果：先让玩家选择从卡组发动「天空的圣域」还是将记述怪兽加入手卡；若进行了其中任一操作，且场上或墓地存在「天空的圣域」，则再询问玩家是否回复 LP，回复量为自己场上符合条件的怪兽数量×500。
function c26684111.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 再次检查卡组是否存在可发动的「天空的圣域」，用于决定选项是否可用。
	local b1=Duel.IsExistingMatchingCard(c26684111.actfilter,tp,LOCATION_DECK,0,1,nil,tp)
	-- 再次检查卡组是否存在可加入手卡的记述怪兽，用于决定选项是否可用。
	local b2=Duel.IsExistingMatchingCard(c26684111.thfilter,tp,LOCATION_DECK,0,1,nil)
	local off=1
	local ops,opval={},{}
	if b1 then
		ops[off]=aux.Stringid(26684111,0)  --"把「天空的圣域」发动"
		opval[off]=0
		off=off+1
	end
	if b2 then
		ops[off]=aux.Stringid(26684111,1)  --"把怪兽加入手卡"
		opval[off]=1
		off=off+1
	end
	-- 弹出选项菜单让玩家选择操作方式，返回的序号加 1 后作为数组索引取 opval 中的实际选择。
	local op=Duel.SelectOption(tp,table.unpack(ops))+1
	local sel=opval[op]
	local resolve=false
	if sel==0 then
		-- 发送选择提示，提示玩家正在选择要操作的卡（用于发动「天空的圣域」时选择卡组中的卡）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
		-- 在卡组中选择一张满足条件的「天空的圣域」作为要发动的卡。
		local g=Duel.SelectMatchingCard(tp,c26684111.actfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
		local tc=g:GetFirst()
		if tc then
			local te=tc:GetActivateEffect()
			-- 取得己方场地区域（LOCATION_FZONE）当前存在的卡，用于后续处理已有场地魔法。
			local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
			if fc then
				-- 若己方场地区已有卡片，则按规则将其送去墓地（为发动新的场地魔法做准备）。
				Duel.SendtoGrave(fc,REASON_RULE)
				-- 中断当前效果处理，使后续操作视为另一次处理，避免时点被遗漏。
				Duel.BreakEffect()
			end
			-- 将选中的「天空的圣域」以表侧表示放置到己方场地区域，并立即适用其效果。
			Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
			te:UseCountLimit(tp,1,true)
			local tep=tc:GetControler()
			local cost=te:GetCost()
			if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
			-- 发动这张场地魔法卡，触发 EVENT 4179255（卡发动）时点，使相关诱发效果可以响应。
			Duel.RaiseEvent(tc,4179255,te,0,tp,tp,Duel.GetCurrentChain())
			resolve=true
		end
	else
		-- 发送选择提示，提示玩家正在选择要加入手卡的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 在卡组中选择一张满足条件的记述怪兽作为要加入手卡的对象。
		local g=Duel.SelectMatchingCard(tp,c26684111.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选择的怪兽以效果原因加入其持有者的手卡。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 将加入手卡的卡展示给对方玩家确认。
			Duel.ConfirmCards(1-tp,g)
			resolve=true
		end
	end
	-- 检查当前是否有「天空的圣域」存在于场上或墓地（PLAYER_ALL 表示任一玩家的场上或墓地），结果存为 check。
	local check=Duel.IsEnvironment(56433456,PLAYER_ALL,LOCATION_ONFIELD+LOCATION_GRAVE)
	-- 统计自己场上表侧表示且属于「代行者」或「许珀里翁」的怪兽数量，作为回复基本分的倍数。
	local ct=Duel.GetMatchingGroupCount(c26684111.recfilter,tp,LOCATION_MZONE,0,nil)
	-- 若已经成功进行了①的检索/发动操作，且场上或墓地有「天空的圣域」，且己方场上有符合条件的怪兽，则询问玩家是否回复基本分。
	if resolve and check and ct>0 and Duel.SelectYesNo(tp,aux.Stringid(26684111,2)) then  --"是否回复基本分？"
		-- 中断效果处理，使回复基本分作为另一次处理，避免时点问题。
		Duel.BreakEffect()
		-- 己方回复 ct×500 基本分，ct 为自己场上符合条件的怪兽数量。
		Duel.Recover(tp,ct*500,REASON_EFFECT)
	end
end
-- 定义代替破坏的适用条件：被破坏的卡为表侧表示、卡名记述了「天空的圣域」、位于己方怪兽区域、控制者是 tp，且破坏原因为战斗破坏且尚未被代替破坏。
function c26684111.repfilter(c,tp)
	-- 检查该卡是否为表侧表示，且其卡名中记载了「天空的圣域」。
	return c:IsFaceup() and aux.IsCodeListed(c,56433456)
		and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:IsReason(REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
end
-- ②效果的触发判定：墓地的本卡可以被除外，且存在满足条件的战斗破坏怪兽（未被代替破坏）；若满足则让玩家选择是否发动代替破坏。
function c26684111.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c26684111.repfilter,1,nil,tp) end
	-- 弹出‘是否使用代替破坏效果’的确认框（描述编号 96），由玩家决定是否发动。
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 返回被破坏的怪兽是否满足代替破坏条件（内部以从 effect 的持有者玩家角度判断）。
function c26684111.repval(e,c)
	return c26684111.repfilter(c,e:GetHandlerPlayer())
end
-- 执行②的代替破坏：将墓地的本卡除外，代替怪兽被战斗破坏。
function c26684111.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将墓地的这张卡以表侧表示除外（作为代替破坏的代价）。
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end

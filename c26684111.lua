--天空の聖水
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从卡组把1张「天空的圣域」发动或把有「天空的圣域」的卡名记述的1只怪兽加入手卡。那之后，场上或者墓地有「天空的圣域」存在的场合，自己可以回复自己场上的「许珀里翁」怪兽以及「代行者」怪兽数量×500基本分。
-- ②：有「天空的圣域」的卡名记述的自己怪兽被战斗破坏的场合，可以作为代替把墓地的这张卡除外。
function c26684111.initial_effect(c)
	-- 记录此卡效果文本上记载着「天空的圣域」的卡名
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
-- 过滤函数，用于判断卡组中是否存在可发动的「天空的圣域」
function c26684111.actfilter(c,tp)
	return c:IsCode(56433456) and c:GetActivateEffect():IsActivatable(tp,true,true)
end
-- 过滤函数，用于判断卡组中是否存在有「天空的圣域」的卡名记述的怪兽
function c26684111.thfilter(c)
	-- 判断怪兽是否为怪兽类型且记载着「天空的圣域」且可加入手牌
	return c:IsType(TYPE_MONSTER) and aux.IsCodeListed(c,56433456) and c:IsAbleToHand()
end
-- 判断卡组中是否存在可发动的「天空的圣域」或可加入手牌的有「天空的圣域」的怪兽
function c26684111.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断卡组中是否存在可发动的「天空的圣域」
	local b1=Duel.IsExistingMatchingCard(c26684111.actfilter,tp,LOCATION_DECK,0,1,nil,tp)
	-- 判断卡组中是否存在有「天空的圣域」的卡名记述的怪兽
	local b2=Duel.IsExistingMatchingCard(c26684111.thfilter,tp,LOCATION_DECK,0,1,nil)
	if chk==0 then return b1 or b2 end
end
-- 过滤函数，用于判断自己场上是否存在「许珀里翁」或「代行者」怪兽
function c26684111.recfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x44,0x16f)
end
-- 发动效果时，选择从卡组发动「天空的圣域」或加入手牌
function c26684111.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 判断卡组中是否存在可发动的「天空的圣域」
	local b1=Duel.IsExistingMatchingCard(c26684111.actfilter,tp,LOCATION_DECK,0,1,nil,tp)
	-- 判断卡组中是否存在有「天空的圣域」的卡名记述的怪兽
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
	-- 让玩家选择操作选项
	local op=Duel.SelectOption(tp,table.unpack(ops))+1
	local sel=opval[op]
	local resolve=false
	if sel==0 then
		-- 提示玩家选择要操作的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
		-- 选择满足条件的「天空的圣域」
		local g=Duel.SelectMatchingCard(tp,c26684111.actfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
		local tc=g:GetFirst()
		if tc then
			local te=tc:GetActivateEffect()
			-- 获取玩家场上已存在的场地卡
			local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
			if fc then
				-- 将场上已存在的场地卡送去墓地
				Duel.SendtoGrave(fc,REASON_RULE)
				-- 中断当前效果处理
				Duel.BreakEffect()
			end
			-- 将「天空的圣域」移至场上
			Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
			te:UseCountLimit(tp,1,true)
			local tep=tc:GetControler()
			local cost=te:GetCost()
			if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
			-- 触发「天空的圣域」的发动时点
			Duel.RaiseEvent(tc,4179255,te,0,tp,tp,Duel.GetCurrentChain())
			resolve=true
		end
	else
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 选择满足条件的怪兽加入手牌
		local g=Duel.SelectMatchingCard(tp,c26684111.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将怪兽加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 确认玩家选择的怪兽
			Duel.ConfirmCards(1-tp,g)
			resolve=true
		end
	end
	-- 判断场上或墓地是否存在「天空的圣域」
	local check=Duel.IsEnvironment(56433456,PLAYER_ALL,LOCATION_ONFIELD+LOCATION_GRAVE)
	-- 计算自己场上的「许珀里翁」或「代行者」怪兽数量
	local ct=Duel.GetMatchingGroupCount(c26684111.recfilter,tp,LOCATION_MZONE,0,nil)
	-- 若已执行操作且存在「天空的圣域」且场上存在「许珀里翁」或「代行者」怪兽，则询问是否回复基本分
	if resolve and check and ct>0 and Duel.SelectYesNo(tp,aux.Stringid(26684111,2)) then  --"是否回复基本分？"
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 回复基本分，数值为场上「许珀里翁」或「代行者」怪兽数量乘以500
		Duel.Recover(tp,ct*500,REASON_EFFECT)
	end
end
-- 过滤函数，用于判断被战斗破坏的自己怪兽是否记载着「天空的圣域」
function c26684111.repfilter(c,tp)
	-- 判断怪兽是否为表侧表示且记载着「天空的圣域」
	return c:IsFaceup() and aux.IsCodeListed(c,56433456)
		and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:IsReason(REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
end
-- 判断是否可以发动代替破坏效果
function c26684111.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c26684111.repfilter,1,nil,tp) end
	-- 询问玩家是否发动代替破坏效果
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 返回代替破坏效果的判断条件
function c26684111.repval(e,c)
	return c26684111.repfilter(c,e:GetHandlerPlayer())
end
-- 执行代替破坏效果，将此卡除外
function c26684111.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将此卡从墓地除外
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end

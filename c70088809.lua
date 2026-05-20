--調和ノ天救竜
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：对方场上的怪兽把效果发动时，把手卡的这张卡和额外卡组最多5只同调怪兽给对方观看才能发动。给人观看的数量的以下效果全部适用。这个效果的发动后，直到下次的自己回合的结束时，自己不能把同调怪兽以外的从额外卡组特殊召唤的怪兽的效果发动。
-- ●2只以上：这张卡特殊召唤。
-- ●4只以上：给人观看的同调怪兽之内的1只送去墓地。
-- ●6只：对方场上1只怪兽破坏。
local s,id,o=GetID()
-- 定义并注册「调和之天救龙」的①效果
function s.initial_effect(c)
	-- ①：对方场上的怪兽把效果发动时，把手卡的这张卡和额外卡组最多5只同调怪兽给对方观看才能发动。给人观看的数量的以下效果全部适用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"展示额外并发动效果"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
end
-- 检查发动条件：对方场上的怪兽发动效果时
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER) and re:GetActivateLocation()==LOCATION_MZONE
end
-- 过滤条件：额外卡组的同调怪兽
function s.cfilter(c)
	return c:IsAllTypes(TYPE_SYNCHRO+TYPE_MONSTER)
end
-- 过滤条件：可以送去墓地的卡
function s.tgfilter(c)
	return c:IsAbleToGrave()
end
-- 检查选取的同调怪兽组是否合法（若选了3张以上，即总数达4张以上时，必须包含至少1张能送去墓地的卡）
function s.scheck(g)
	return g:GetCount()<3 or g:IsExists(Card.IsAbleToGrave,1,nil)
end
-- 检查发动代价：手牌的这张卡未公开，且额外卡组存在至少1只同调怪兽
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic()
		-- 检查额外卡组是否存在至少1只同调怪兽
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 获取额外卡组中所有的同调怪兽
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_EXTRA,0,nil)
	local ct=4
	-- 如果对方场上有怪兽，则最多可以从额外卡组选择5只同调怪兽（加上手牌的这张卡共6只，以满足破坏效果的条件）
	if Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) then ct=5 end
	-- 提示玩家选择要给对方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	local sg=g:SelectSubGroup(tp,s.scheck,false,1,ct)
	-- 给对方玩家确认选中的额外卡组同调怪兽
	Duel.ConfirmCards(1-tp,sg)
	-- 洗切己方的额外卡组
	Duel.ShuffleExtra(tp)
	e:SetLabel(sg:GetCount()+1)
	-- 将展示的额外卡组同调怪兽设为效果处理的对象（广义对象）
	Duel.SetTargetCard(sg)
	-- 遍历所有被展示的额外卡组同调怪兽
	for tc in aux.Next(sg) do
		tc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD+RESET_CHAIN,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,1))  --"被「调和之天救龙」展示"
	end
end
-- 效果发动时的目标确认与操作信息设置
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	if e:GetLabel()>5 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY+CATEGORY_TOGRAVE)
		-- 获取对方场上的所有怪兽
		local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
		-- 设置破坏对方场上1只怪兽的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
		-- 设置将额外卡组1张卡送去墓地的操作信息（对应4只以上的效果）
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_EXTRA)
	elseif e:GetLabel()>3 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
		-- 设置将额外卡组1张卡送去墓地的操作信息（对应4只以上的效果）
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_EXTRA)
	else
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
	end
end
-- 效果处理的核心逻辑，根据展示的卡片数量依次适用对应效果，并注册后续的额外卡组怪兽效果发动限制
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将这张卡表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	if e:GetLabel()>3 then
		-- 中断当前效果处理，使后续处理不与特殊召唤同时进行
		Duel.BreakEffect()
		-- 获取发动时作为对象（被展示）的卡片组
		local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
		local tg=g:Filter(Card.IsRelateToChain,nil)
		if tg:GetCount()>0 then
			-- 提示玩家选择要送去墓地的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
			local og=tg:FilterSelect(tp,Card.IsAbleToGrave,1,1,nil)
			if og:GetCount()>0 then
				-- 将选中的同调怪兽因效果送去墓地
				Duel.SendtoGrave(og,REASON_EFFECT)
			end
		end
	end
	if e:GetLabel()>5 then
		-- 中断当前效果处理，使后续处理不与送去墓地同时进行
		Duel.BreakEffect()
		-- 提示玩家选择要破坏的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 让玩家选择对方场上的1只怪兽
		local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
		if g:GetCount()>0 then
			-- 显式地在场上框选被选中的怪兽
			Duel.HintSelection(g)
			-- 破坏选中的对方怪兽
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
	-- 这个效果的发动后，直到下次的自己回合的结束时，自己不能把同调怪兽以外的从额外卡组特殊召唤的怪兽的效果发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,2))  --"「调和之天救龙」效果适用中"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(s.aclimit)
	-- 判断当前是否为自己的回合，以确定限制效果的持续回合数
	if Duel.GetTurnPlayer()==tp then
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
	else
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,1)
	end
	-- 向玩家注册该限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制效果的过滤条件：不能发动从额外卡组特殊召唤的同调怪兽以外的怪兽的效果
function s.aclimit(e,re,tp)
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and rc:IsSummonLocation(LOCATION_EXTRA) and rc:IsLocation(LOCATION_MZONE)
		and not rc:IsType(TYPE_SYNCHRO)
end

--トリプル・ヴァレル・リボルブ
-- 效果：
-- ①：可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
-- ●从自己墓地让1只龙族怪兽回到卡组。那之后，可以把和回去的怪兽卡名不同的1只「弹丸」怪兽从卡组特殊召唤。
-- ●从自己墓地让2只龙族怪兽回到卡组。那之后，从自己墓地把1张场地魔法卡加入手卡。
-- ●从自己墓地让3只龙族怪兽回到卡组。那之后，从对方墓地让最多3只怪兽回到卡组。
local s,id,o=GetID()
-- 注册卡片发动的初始化函数
function s.initial_effect(c)
	-- ①：可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_DECKDES+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：过滤自己墓地可回到卡组的龙族怪兽
function s.tdfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsAbleToDeck()
end
-- 过滤条件：过滤自己墓地可加入手牌的场地魔法卡
function s.thfilter(c)
	return c:IsType(TYPE_FIELD) and c:IsAbleToHand()
end
-- 过滤条件：过滤对方墓地可回到卡组的怪兽
function s.tdfilter2(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 效果发动靶向：检查分支效果发动条件、让玩家选择分支效果并注册一回合一次的Flag限制，以及设置操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少1只龙族怪兽
	local b1=Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,1,nil)
		-- 检查当前回合玩家是否还未选择过第一个效果
		and (not e:IsCostChecked() or Duel.GetFlagEffect(tp,id)==0)
	-- 检查自己墓地是否存在至少2只龙族怪兽
	local b2=Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,2,nil)
		-- 检查自己墓地是否存在至少1张可以加入手牌的场地魔法卡
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil)
		-- 检查当前回合玩家是否还未选择过第二个效果
		and (not e:IsCostChecked() or Duel.GetFlagEffect(tp,id+o)==0)
	-- 检查自己墓地是否存在至少3只龙族怪兽
	local b3=Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,3,nil)
		-- 检查对方墓地是否存在至少1只可以回到卡组的怪兽
		and Duel.IsExistingMatchingCard(s.tdfilter2,tp,0,LOCATION_GRAVE,1,nil)
		-- 检查当前回合玩家是否还未选择过第三个效果
		and (not e:IsCostChecked() or Duel.GetFlagEffect(tp,id+o*2)==0)
	if chk==0 then return b1 or b2 or b3 end
	-- 让玩家从当前可发动的分支效果中选择一个发动
	local op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,1),1},  --"让1只回到卡组"
			{b2,aux.Stringid(id,2),2},  --"让2只回到卡组"
			{b3,aux.Stringid(id,3),3})  --"让3只回到卡组"
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK+CATEGORY_DECKDES)
			-- 注册本卡名第一个分支效果在一回合内已被使用过的Flag限制
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		end
		-- 设置操作信息：预计将自己墓地的1张卡送回卡组
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
	elseif op==2 then
		if e:IsCostChecked() then
			-- 注册本卡名第二个分支效果在一回合内已被使用过的Flag限制
			Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,0,1)
			e:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
		end
		-- 设置操作信息：预计将自己墓地的2张卡送回卡组
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,2,tp,LOCATION_GRAVE)
		-- 设置操作信息：预计将自己墓地的1张卡加入玩家手牌
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
	elseif op==3 then
		if e:IsCostChecked() then
			-- 注册本卡名第三个分支效果在一回合内已被使用过的Flag限制
			Duel.RegisterFlagEffect(tp,id+o*2,RESET_PHASE+PHASE_END,0,1)
			e:SetCategory(CATEGORY_TODECK)
		end
		-- 设置操作信息：预计将双方墓地的共4张卡送回卡组
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,4,PLAYER_ALL,LOCATION_GRAVE)
	end
end
-- 过滤条件：过滤卡组中卡名不同于指定卡名，且可以特殊召唤的「弹丸」怪兽
function s.spfilter(c,e,tp,code)
	return not c:IsCode(code) and c:IsSetCard(0x102) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理：根据玩家选择的分支效果，处理对应的回到卡组并特召、加入手牌或让对方怪兽回卡组的效果
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local sel=e:GetLabel()
	-- 检查自己墓地是否存在足够数量且不受「王家长眠之谷」影响的龙族怪兽，若无则返回
	if not Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE,0,sel,nil) then return end
	if sel==1 then
		-- 提示玩家选择要返回卡组的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 让玩家从自己墓地选择1只满足条件的龙族怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE,0,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			-- 手动显示所选怪兽被选为对象的动画
			Duel.HintSelection(g)
			-- 如果成功将所选怪兽送回自己卡组
			if Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0
				and tc:IsLocation(LOCATION_DECK+LOCATION_EXTRA)
				-- 并且自己场上的怪兽区域有空位
				and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
				-- 并且自己卡组中存在与送回卡组的龙族怪兽卡名不同的「弹丸」怪兽
				and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp,tc:GetCode())
				-- 并且玩家选择进行特殊召唤
				and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then  --"是否特殊召唤？"
				-- 提示玩家选择要特殊召唤的怪兽
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				-- 让玩家从自己卡组选择1只卡名与送回卡组的龙族怪兽不同的「弹丸」怪兽
				local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,tc:GetCode())
				if sg:GetCount()>0 then
					-- 中断当前效果，使后续的特殊召唤处理与回到卡组不视为同时处理
					Duel.BreakEffect()
					-- 将选定的「弹丸」怪兽特殊召唤到自己场上
					Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
				end
			end
		end
	elseif sel==2 then
		-- 提示玩家选择要返回卡组的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 让玩家从自己墓地选择2只满足条件的龙族怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE,0,2,2,nil)
		if g:GetCount()==2 then
			-- 手动显示所选的2只怪兽被选为对象的动画
			Duel.HintSelection(g)
			-- 如果成功将这2只怪兽送回自己卡组
			if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0
				and g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)==2
				-- 并且自己墓地中存在至少1张可加入手牌的场地魔法卡
				and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,nil) then
				-- 提示玩家选择要加入手牌的卡
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
				-- 让玩家从自己墓地选择1张场地魔法卡
				local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
				if sg:GetCount()>0 then
					-- 将选定的场地魔法卡加入手牌
					Duel.SendtoHand(sg,nil,REASON_EFFECT)
					-- 给对方确认加入手牌的卡
					Duel.ConfirmCards(1-tp,sg)
				end
			end
		end
	elseif sel==3 then
		-- 提示玩家选择要返回卡组的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 让玩家从自己墓地选择3只满足条件的龙族怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE,0,3,3,nil)
		if g:GetCount()==3 then
			-- 手动显示所选的3只怪兽被选为对象的动画
			Duel.HintSelection(g)
			-- 如果成功将这3只怪兽送回自己卡组
			if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0
				and g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)==3
				-- 并且对方墓地中存在至少1只可送回卡组的怪兽
				and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.tdfilter2),tp,0,LOCATION_GRAVE,1,nil) then
				-- 提示玩家选择要返回卡组的卡
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
				-- 让玩家从对方墓地选择最多3只怪兽
				local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tdfilter2),tp,0,LOCATION_GRAVE,1,3,nil)
				if sg:GetCount()>0 then
					-- 手动显示对方墓地中所选怪兽被选为对象的动画
					Duel.HintSelection(sg)
					-- 将选定的对方墓地怪兽送回对方卡组
					Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
				end
			end
		end
	end
end

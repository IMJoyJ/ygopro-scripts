--闇の眼を持つ幻想師・ノー・フェイス
local s,id,o=GetID()
-- 定义初始效果函数，用于注册卡片的效果。
function s.initial_effect(c)
	-- 将卡片代码列表添加到该卡片上，记录了这张卡记载的其他卡名。
	aux.AddCodeList(c,15259703,34298391)
	-- 创建并注册一个起动效果，描述信息从id为0的字符串中获取。此效果在手牌发动，需要支付代价、指定目标和执行操作。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- 创建并注册一个永续场地效果，使这张卡自身或战斗对象不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.indtg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
-- 定义效果的代价函数，检查是否可以丢弃该卡片。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将发动卡送入墓地作为代价。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
	-- 设置当前处理连锁的目标卡为发动卡。
	Duel.SetTargetCard(e:GetHandler())
end
-- 定义一个过滤函数，用于选择场上存在的代码为34298391且没有被禁止的、唯一的怪兽。
function s.tffilter(c,tp)
	return c:IsCode(34298391)
		and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- 定义一个过滤函数，用于选择手牌或墓地中记载着卡片代码15259703、类型为怪兽并且可以加入手牌的卡片。
function s.thfilter(c)
	-- 检查卡片是否记载了指定代码且是怪兽类型，并判断该卡是否能够被加入手牌。
	return aux.IsCodeListed(c,15259703) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 定义效果的目标函数，用于确定目标卡和操作。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上的空余超量怪兽区数量是否大于0。
	local b1=Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查是否有满足tffilter条件的卡片在手牌或卡组中。
		and Duel.IsExistingMatchingCard(s.tffilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,tp)
		-- 如果已经检查过代价，或者玩家的Flag效果为0则返回true。
		and (not e:IsCostChecked() or Duel.GetFlagEffect(tp,id)==0)
	-- 检查墓地中是否存在满足thfilter条件的卡片，且该卡是发动这张卡片的卡。
	local b2=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler())
		-- 如果已经检查过代价，或者玩家的Flag效果为id+o等于0则返回true。
		and (not e:IsCostChecked() or Duel.GetFlagEffect(tp,id+o)==0)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 or b2 then
		-- 使用aux.SelectFromOptions让玩家选择操作选项。
		op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,1),1},
			{b2,aux.Stringid(id,2),2})
	end
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(0)
			-- 注册一个标识效果，用于限制该卡每回合只能发动一次起动效果。
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		end
	elseif op==2 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
			-- 注册一个标识效果，用于限制该卡每回合只能发动一次特殊召唤效果。
			Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,0,1)
		end
		-- 设置当前处理连锁的操作信息，表示将一张卡加入手牌。
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
	end
end
-- 定义效果的执行函数，根据选择的操作进行不同的处理。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- 如果场上的超量怪兽区数量小于等于0则直接返回。
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
		-- 提示玩家选择要放置到场上的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
		-- 从手牌或卡组中选择满足tffilter条件的卡片，并获取第一张卡。
		local tc=Duel.SelectMatchingCard(tp,s.tffilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,tp):GetFirst()
		if tc then
			-- 将选中的卡片移动到场上的超量怪兽区。
			Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
		end
	elseif e:GetLabel()==2 then
		-- 提示玩家选择要加入手牌的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从墓地中选择满足thfilter条件的卡片，并忽略王家长眠之谷的效果。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,1,aux.ExceptThisCard(e))
		local tc=g:GetFirst()
		if tc then
			-- 将选中的卡片送入持有者的手牌。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 确认玩家1-tp收到的卡片。
			Duel.ConfirmCards(1-tp,g)
			if tc:IsLocation(LOCATION_HAND)
				-- 检查场上的怪兽区是否有空位，并且选中的卡片是否可以特殊召唤。
				and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,true,false)
				-- 询问玩家是否要特殊召唤该卡片。
				and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
				-- 中断当前效果，使之后的效果处理视为不同时处理。
				Duel.BreakEffect()
				-- 将选中的卡片特殊召唤到场上。
				Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
			end
		end
	end
end
-- 定义一个目标函数，用于判断目标卡是否为这张卡自身或其战斗对象。
function s.indtg(e,c)
	local tc=e:GetHandler()
	return c==tc or c==tc:GetBattleTarget()
end

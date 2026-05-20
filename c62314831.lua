--新世壊＝アムリターラ
-- 效果：
-- 场上有「维萨斯-斯塔弗罗斯特」存在的场合才能把这张卡发动。
-- ①：1回合1次，自己场上的怪兽因战斗·效果而破坏，被送去墓地的场合或者被除外的场合，可以从以下效果选择1个发动。
-- ●那之内的1只在自己场上守备表示特殊召唤。
-- ●场上1只调整的攻击力上升那之内的1只的攻击力一半数值。
-- ●那之内的1只回到卡组，自己抽1张。
-- ●这张卡回到卡组，从自己墓地把1张场地魔法卡加入手卡。
local s,id,o=GetID()
-- 定义卡片效果：注册卡片发动（e0）以及在场地区域时怪兽被破坏送墓/除外时选择效果发动（e1）的效果。
function s.initial_effect(c)
	-- 将「维萨斯-斯塔弗罗斯特」的卡片密码加入此卡的关联卡片列表中。
	aux.AddCodeList(c,56099748)
	-- 场上有「维萨斯-斯塔弗罗斯特」存在的场合才能把这张卡发动。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCondition(s.accon)
	c:RegisterEffect(e0)
	-- ①：1回合1次，自己场上的怪兽因战斗·效果而破坏，被送去墓地的场合或者被除外的场合，可以从以下效果选择1个发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"选择效果发动"
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetRange(LOCATION_FZONE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1)
	e1:SetTarget(s.target)
	c:RegisterEffect(e1)
end
-- 过滤条件：场上表侧表示存在的「维萨斯-斯塔弗罗斯特」。
function s.confilter(c)
	return c:IsFaceup() and c:IsCode(56099748)
end
-- 卡片发动的条件：检查场上是否存在「维萨斯-斯塔弗罗斯特」。
function s.accon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查双方场上是否存在至少1张表侧表示的「维萨斯-斯塔弗罗斯特」。
	return Duel.IsExistingMatchingCard(s.confilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
-- 过滤条件：可以以表侧守备表示特殊召唤的怪兽。
function s.filter1(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 过滤条件：攻击力大于0的怪兽。
function s.filter2(c)
	return c:GetAttack()>0
end
-- 过滤条件：可以回到卡组的卡。
function s.filter3(c)
	return c:IsAbleToDeck()
end
-- 过滤条件：因战斗或效果破坏，从自己场上送去墓地或被除外的怪兽。
function s.filter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsType(TYPE_MONSTER)
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
		and c:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED)
end
-- 过滤条件：场上表侧表示存在的调整怪兽。
function s.atkfilter(c)
	return c:IsType(TYPE_TUNER) and c:IsFaceup()
end
-- 过滤条件：墓地中可以加入手牌的场地魔法卡。
function s.thfilter(c)
	return c:IsType(TYPE_FIELD) and c:IsAbleToHand()
end
-- 效果发动的目标选择与可行性检查：筛选符合条件的被破坏怪兽，判断4个分支效果哪个可以发动，并让玩家选择其中一个发动，设置对应的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=eg:Filter(s.filter,nil,tp)
	local b1=g:IsExists(s.filter1,1,nil,e,tp)
	-- 检查分支2是否可行：被破坏的怪兽中存在攻击力大于0的怪兽，且场上存在表侧表示的调整怪兽。
	local b2=g:IsExists(s.filter2,1,nil) and Duel.IsExistingMatchingCard(s.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
	-- 检查分支3是否可行：被破坏的怪兽中存在可以回到卡组的怪兽，且自己可以抽卡。
	local b3=g:IsExists(s.filter3,1,nil,e,tp) and Duel.IsPlayerCanDraw(tp,1)
	-- 检查分支4是否可行：存在被破坏的怪兽，此卡可以回到卡组，且自己墓地存在可以加入手牌的场地魔法卡。
	local b4=#g>0 and c:IsAbleToDeck() and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil)
	if chk==0 then return b1 or b2 or b3 or b4 end
	-- 将符合条件的被破坏怪兽群组设为当前连锁的目标卡片。
	Duel.SetTargetCard(g)
	local off=1
	local ops={}
	local opval={}
	if b1 then
		ops[off]=aux.Stringid(id,1)  --"特殊召唤"
		opval[off-1]=1
		off=off+1
	end
	if b2 then
		ops[off]=aux.Stringid(id,2)  --"上升攻击力"
		opval[off-1]=2
		off=off+1
	end
	if b3 then
		ops[off]=aux.Stringid(id,3)  --"回收并抽卡"
		opval[off-1]=3
		off=off+1
	end
	if b4 then
		ops[off]=aux.Stringid(id,4)  --"回收场地"
		opval[off-1]=4
		off=off+1
	end
	-- 给玩家发送提示信息，提示选择要发动的效果。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)  --"请选择要发动的效果"
	-- 让玩家从可行的分支效果中选择一个发动，并获取其选择的索引。
	local op=Duel.SelectOption(tp,table.unpack(ops))
	if opval[op]==1 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e:SetOperation(s.spop)
		-- 设置操作信息：从墓地或除外状态特殊召唤1只怪兽。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
	elseif opval[op]==2 then
		e:SetCategory(CATEGORY_ATKCHANGE)
		e:SetOperation(s.atkop)
		-- 设置操作信息：涉及被破坏怪兽群组中的1只怪兽。
		Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
	elseif opval[op]==3 then
		e:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
		e:SetOperation(s.todeckop)
		-- 设置操作信息：将墓地或除外状态的1只怪兽送回卡组。
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
		-- 设置操作信息：玩家抽1张卡。
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	elseif opval[op]==4 then
		e:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
		e:SetOperation(s.tohandop)
		-- 设置操作信息：将这张卡送回卡组。
		Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
		-- 设置操作信息：从墓地将1张卡加入手牌。
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
	end
end
-- 分支效果1的处理：从符合条件的被破坏怪兽中选择1只，在自己场上以表侧守备表示特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示信息，提示选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local g=eg:Filter(Card.IsRelateToChain,nil):FilterSelect(tp,s.filter1,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧守备表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 分支效果2的处理：选择1只被破坏的怪兽和场上1只调整怪兽，使该调整怪兽的攻击力上升被破坏怪兽攻击力一半的数值。
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local g1=eg:Filter(Card.IsRelateToChain,nil):Filter(s.filter2,nil)
	-- 获取双方场上所有表侧表示的调整怪兽。
	local g2=Duel.GetMatchingGroup(s.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #g1~=0 and #g2~=0 then
		-- 闪烁显示符合条件的被破坏怪兽，供玩家确认。
		Duel.HintSelection(g1)
		-- 闪烁显示场上符合条件的调整怪兽，供玩家确认。
		Duel.HintSelection(g2)
		-- 给玩家发送提示信息，提示选择要操作的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
		local tc=g1:Select(tp,1,1,nil):GetFirst()
		-- 给玩家发送提示信息，提示选择表侧表示的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		local hc=g2:Select(tp,1,1,nil):GetFirst()
		local atk=tc:GetAttack()
		-- ●场上1只调整的攻击力上升那之内的1只的攻击力一半数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(math.ceil(atk/2))
		hc:RegisterEffect(e1)
	end
end
-- 分支效果3的处理：选择1只被破坏的怪兽回到卡组，之后自己抽1张卡。
function s.todeckop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示信息，提示选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	local g=eg:Filter(Card.IsRelateToChain,nil):FilterSelect(tp,s.filter3,1,1,nil,e,tp)
	if #g>0 then
		-- 闪烁显示选中的要返回卡组的怪兽。
		Duel.HintSelection(g)
		-- 尝试将选中的怪兽送回卡组并洗卡组，若成功且自己可以抽卡，则进行后续处理。
		if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and Duel.IsPlayerCanDraw(tp,1) then
			-- 洗切玩家的卡组。
			Duel.ShuffleDeck(tp)
			-- 玩家因效果抽1张卡。
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end
-- 分支效果4的处理：将这张卡送回卡组，然后从自己墓地选择1张场地魔法卡加入手牌。
function s.tohandop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 尝试将这张卡送回卡组并洗卡组，若成功则进行后续处理。
	if Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
		-- 给玩家发送提示信息，提示选择要返回手牌的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
		-- 让玩家从自己墓地选择1张场地魔法卡。
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		if #g~=0 then
			-- 将选中的场地魔法卡加入玩家手牌。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 给对方玩家确认加入手牌的卡片。
			Duel.ConfirmCards(1-tp,g)
		end
	end
end

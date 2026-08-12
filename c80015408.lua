--糾罪巧－裁誕
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己的手卡·场上（表侧表示）让「纠罪巧」怪兽卡任意数量回到卡组。那之后，自己抽出回去的数量。
-- ②：这张卡在墓地存在的状态，对方把怪兽召唤·特殊召唤的场合，可以把这张卡除外，从以下效果选择1个发动。
-- ●从手卡把1只「纠罪巧」怪兽里侧守备表示特殊召唤。
-- ●自己场上1只里侧守备表示的「纠罪巧」怪兽变成表侧守备表示。
local s,id,o=GetID()
-- 初始化卡片效果：注册卡片发动效果（e1），以及在墓地对方召唤（e2）·特殊召唤（e3）怪兽时除外自身发动的两个分支选择的诱发效果。
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从自己的手卡·场上（表侧表示）让「纠罪巧」怪兽卡任意数量回到卡组。那之后，自己抽出回去的数量。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，对方把怪兽召唤·特殊召唤的场合，可以把这张卡除外，从以下效果选择1个发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"选择效果"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_POSITION+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(s.spcon)
	-- 设置发动代价为将墓地的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.fsop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 过滤条件：手卡或场上表侧表示的「纠罪巧」怪兽卡，且可以回到卡组。
function s.tdfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x1d4) and (c:GetOriginalType()&TYPE_MONSTER)~=0 and c:IsAbleToDeck()
end
-- 效果①的发动准备（检查是否可以抽卡，以及手卡·场上是否存在可以回到卡组的「纠罪巧」怪兽卡）。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家当前是否可以进行抽卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp)
		-- 检查手卡或场上（除这张卡以外）是否存在至少1张满足条件的「纠罪巧」怪兽卡。
		and Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,e:GetHandler()) end
	-- 设置当前连锁的效果处理对象玩家为发动玩家。
	Duel.SetTargetPlayer(tp)
	-- 设置收集信息：预计将手卡或场上的至少1张卡送回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND+LOCATION_ONFIELD)
end
-- 效果①的效果处理：让手卡·场上任意数量的「纠罪巧」怪兽卡回到卡组，并抽出回去的数量。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 提示玩家选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从手卡·场上选择任意数量（1-63张）满足条件的「纠罪巧」怪兽卡。
	local g=Duel.SelectMatchingCard(p,s.tdfilter,p,LOCATION_HAND+LOCATION_ONFIELD,0,1,63,nil)
	if g:GetCount()>0 then
		local fg=g:Filter(Card.IsLocation,nil,LOCATION_ONFIELD)
		if #fg>0 then
			-- 为选中的场上的卡片显示被选为对象的动画效果。
			Duel.HintSelection(fg)
		end
		local hg=g:Filter(Card.IsLocation,nil,LOCATION_HAND)
		if #hg>0 then
			-- 给对方玩家确认选中的手卡。
			Duel.ConfirmCards(1-p,hg)
		end
		-- 将选中的卡片送回持有者的卡组并洗卡。
		local ct=Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		local rt=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
		if rt>0 then
			if g:FilterCount(function(c) return c:IsLocation(LOCATION_DECK) and c:IsControler(p) end,nil)>0 then
				-- 洗切发动玩家的卡组。
				Duel.ShuffleDeck(p)
			end
			if g:FilterCount(function(c) return c:IsLocation(LOCATION_DECK) and c:IsControler(1-p) end,nil)>0 then
				-- 洗切对方玩家的卡组。
				Duel.ShuffleDeck(1-p)
			end
			-- 中断当前效果处理，使后续的抽卡处理与回卡组不视为同时进行。
			Duel.BreakEffect()
			-- 让发动玩家抽出与实际回到卡组数量相同的卡。
			Duel.Draw(p,rt,REASON_EFFECT)
		end
	end
end
-- 过滤条件：检查怪兽是否由指定玩家召唤·特殊召唤。
function s.cfilter(c,sp)
	return c:IsSummonPlayer(sp)
end
-- 效果②的发动条件：对方把怪兽召唤·特殊召唤成功。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,1-tp)
end
-- 过滤条件：手卡中可以里侧守备表示特殊召唤的「纠罪巧」怪兽。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1d4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 过滤条件：自己场上里侧守备表示的「纠罪巧」怪兽。
function s.posfilter(c)
	return c:IsSetCard(0x1d4) and c:IsFacedown() and c:IsDefensePos()
end
-- 效果②的发动准备：检查两个分支效果是否满足发动条件，并让玩家选择其中一个效果发动，设置相应的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域（用于分支一）。
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且手卡中存在可以里侧守备表示特殊召唤的「纠罪巧」怪兽（用于分支一）。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
	-- 检查自己场上是否存在里侧守备表示的「纠罪巧」怪兽（用于分支二）。
	local b2=Duel.IsExistingMatchingCard(s.posfilter,tp,LOCATION_MZONE,0,1,nil)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 or b2 then
		-- 让玩家从满足条件的选项中选择一个效果发动。
		op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,2),1},  --"特殊召唤"
			{b2,aux.Stringid(id,3),2})  --"改变表示形式"
	end
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
		-- 设置收集信息：从手卡特殊召唤1只怪兽。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	elseif op==2 then
		e:SetCategory(CATEGORY_POSITION)
		-- 设置收集信息：改变1只怪兽的表示形式。
		Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,0,0)
	end
end
-- 效果②的效果处理：根据玩家选择的分支，执行特殊召唤或改变表示形式的操作。
function s.fsop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- 检查自己场上是否有空余的怪兽区域。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
			-- 提示玩家选择要特殊召唤的怪兽。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 让玩家从手卡选择1只满足特殊召唤条件的「纠罪巧」怪兽。
			local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
			if g:GetCount()>0 then
				-- 将选中的怪兽以里侧守备表示特殊召唤到自己场上。
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
				-- 给对方玩家确认特殊召唤的里侧怪兽。
				Duel.ConfirmCards(1-tp,g)
			end
		end
	elseif e:GetLabel()==2 then
		-- 提示玩家选择要改变表示形式的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
		-- 让玩家从自己场上选择1只里侧守备表示的「纠罪巧」怪兽。
		local g=Duel.SelectMatchingCard(tp,s.posfilter,tp,LOCATION_MZONE,0,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			-- 为选中的怪兽显示被选为对象的动画效果。
			Duel.HintSelection(g)
			-- 将选中的怪兽变成表侧守备表示。
			Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)
		end
	end
end

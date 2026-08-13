--ニュービー！
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：自己墓地有攻击力和守备力是0的怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：这张卡从手卡特殊召唤的场合才能发动。以下效果各能适用。
-- ●「菜鸟新蜂族！」以外的自己墓地1只昆虫族·光属性怪兽加入手卡。
-- ●自己的墓地·除外状态的1张陷阱卡回到卡组最上面或最下面。
local s,id,o=GetID()
-- 为这张卡注册两个效果：e1是在手卡作为特殊召唤规则效果（①方式）使用，e2是在从手卡特殊召唤成功时发动的诱发效果（②方式），并分别设置对应的1回合1次限制。
function s.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：自己墓地有攻击力和守备力是0的怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	-- ②的效果1回合只能使用1次。②：这张卡从手卡特殊召唤的场合才能发动。以下效果各能适用。●「菜鸟新蜂族！」以外的自己墓地1只昆虫族·光属性怪兽加入手卡。●自己的墓地·除外状态的1张陷阱卡回到卡组最上面或最下面。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"发动效果"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK+CATEGORY_GRAVE_ACTION)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.accon)
	e2:SetTarget(s.actg)
	e2:SetOperation(s.acop)
	c:RegisterEffect(e2)
end
-- 定义过滤器：筛选攻击力和守备力都为0的怪兽卡，用于①特殊召唤时检查墓地是否存在这样的怪兽。
function s.filter(c)
	return c:IsAttack(0) and c:IsDefense(0) and c:IsType(TYPE_MONSTER)
end
-- ①特殊召唤规则效果的条件：当c为空时表示规则上可发动；当实际要特殊召唤这张卡时，需要自己主要怪兽区有空位，且自己墓地存在至少1只攻击力和守备力都是0的怪兽。
function s.spcon(e,c)
	if c==nil then return true end
	-- 检查这张卡的控制者场上是否还有可用的主要怪兽区空格，以确保可以从手卡特殊召唤到场上。
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查这张卡的控制者墓地是否存在至少1只满足s.filter（攻击力和守备力都是0的怪兽）的卡。
		and Duel.IsExistingMatchingCard(s.filter,c:GetControler(),LOCATION_GRAVE,0,1,nil)
end
-- ②效果的发动条件：这张卡是从手卡特殊召唤成功的场合才能发动，即判定其特殊召唤时的来源位置是手牌。
function s.accon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonLocation(LOCATION_HAND)
end
-- 定义过滤器：筛选「菜鸟新蜂族！」以外的、自己墓地的昆虫族·光属性怪兽，并且该怪兽可以被加入手卡。
function s.thfilter(c)
	return not c:IsCode(id) and c:IsRace(RACE_INSECT) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToHand()
end
-- 定义过滤器：筛选自己墓地或除外状态的表侧表示的陷阱卡，并且该陷阱卡可以回到卡组。
function s.tdfilter(c)
	return c:IsFaceupEx() and c:IsType(TYPE_TRAP) and c:IsAbleToDeck()
end
-- ②效果的发动时点检测：满足至少能检索到符合条件的昆虫族·光属性怪兽，或符合条件的陷阱卡时，效果才能发动。
function s.actg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在墓地检查是否存在s.thfilter对应的昆虫族·光属性怪兽，或在墓地+除外检查是否存在s.tdfilter对应的陷阱卡，二者有其一的场合可发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) or Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
end
-- ②效果的处理：先判定两个可选效果各自是否存在可处理的对象；若可行则询问玩家是否适用，按顺序分别处理“昆虫族·光属性怪兽加入手卡”和“陷阱卡回到卡组最上面或最下面”；两个效果都处理时用Duel.BreakEffect分隔。
function s.acop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己墓地是否存在至少1只符合条件的昆虫族·光属性怪兽（使用王家长眠之谷过滤，避免受其效果影响）。
	local b1=Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,nil)
	-- 判断自己墓地·除外是否存在至少1张符合条件的陷阱卡（使用王家长眠之谷过滤，避免受其效果影响）。
	local b2=Duel.IsExistingMatchingCard(aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil)
	local res=false
	-- 当存在可加入手卡的怪兽，且（不存在可回卡组的陷阱或玩家选择发动怪兽加入手卡效果）时，进入第一个可选效果的处理。
	if b1 and (not b2 or Duel.SelectYesNo(tp,aux.Stringid(id,2))) then  --"是否把怪兽加入手卡？"
		res=true
		-- 向玩家发送选择提示，要求从墓地选择要加入手卡的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让玩家从自己墓地选择1只符合条件的昆虫族·光属性怪兽（不取对象，效果处理时选择）。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选择的怪兽加入其持有者的手卡。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方玩家展示加入手卡的怪兽，以确认选择了哪张卡。
			Duel.ConfirmCards(1-tp,g)
		end
	end
	-- 当存在可回卡组的陷阱，且（之前未发动过怪兽加入手卡效果或玩家选择发动陷阱回卡组效果）时，进入第二个可选效果的处理。
	if b2 and (not res or Duel.SelectYesNo(tp,aux.Stringid(id,3))) then  --"是否让陷阱回到卡组？"
		if res then
			-- 中断当前效果处理，使后续的陷阱回卡组处理与之前的怪兽加入手卡处理视为不同时处理，避免错时点。
			Duel.BreakEffect()
		end
		-- 向玩家发送选择提示，要求选择要返回卡组的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
		-- 让玩家从自己墓地·除外选择1张符合条件的陷阱卡（不取对象，效果处理时选择）。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
		if g:GetCount()>0 then
			-- 为被选择的陷阱卡显示被选为对象的动画，并记录这些卡成为对象。
			Duel.HintSelection(g)
			-- 检查自己的卡组是否为0张，若卡组为空则只能将陷阱卡放回卡组最下面。
			if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 then
				-- 当卡组为空时，将选择的陷阱卡以效果送回卡组最下面。
				Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
			else
				-- 当卡组不为空时，让玩家选择将陷阱卡放回卡组最上面还是最下面。
				local opt=Duel.SelectOption(tp,aux.Stringid(id,4),aux.Stringid(id,5))  --"卡组最上面/卡组最下面"
				if opt==0 then
					-- 玩家选择放回卡组最上面时，将陷阱卡以效果送回卡组最上面。
					Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_EFFECT)
				else
					-- 玩家选择放回卡组最下面时，将陷阱卡以效果送回卡组最下面。
					Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
				end
			end
		end
	end
end

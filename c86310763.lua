--粛声なる威光
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己·对方的主要阶段，可以从以下效果选择1个发动。
-- ●从自己的手卡·墓地让1只战士族·龙族而光属性的仪式怪兽或者1张仪式魔法卡回到卡组，从卡组选1只「肃声」怪兽加入手卡或特殊召唤。
-- ●以最多有自己场上的战士族·龙族而光属性的仪式怪兽数量的对方场上的卡为对象才能发动。那些卡和这张卡破坏。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含魔陷发动效果以及两个可选择发动的二速效果。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ●从自己的手卡·墓地让1只战士族·龙族而光属性的仪式怪兽或者1张仪式魔法卡回到卡组，从卡组选1只「肃声」怪兽加入手卡或特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"从卡组加入手卡或特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TODECK+CATEGORY_GRAVE_ACTION)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
	-- ●以最多有自己场上的战士族·龙族而光属性的仪式怪兽数量的对方场上的卡为对象才能发动。那些卡和这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"这张卡和对方的卡破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e3:SetCondition(s.condition)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
-- 效果发动条件：自己或对方的主要阶段。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前阶段是否为主要阶段1或主要阶段2。
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 过滤条件：卡组中可以加入手卡或在有空位时特殊召唤的「肃声」怪兽。
function s.dfilter(c,e,tp,ft)
	return c:IsSetCard(0x1a6) and c:IsType(TYPE_MONSTER) and (c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
-- 过滤条件：手卡或墓地中可以回到卡组的光属性战士族/龙族仪式怪兽或仪式魔法卡。
function s.tdfilter(c)
	return c:IsAbleToDeck() and c:IsType(TYPE_RITUAL) and ((c:IsRace(RACE_WARRIOR+RACE_DRAGON) and c:IsType(TYPE_MONSTER) and c:IsAttribute(ATTRIBUTE_LIGHT)) or c:IsType(TYPE_SPELL))
end
-- 效果①第一个选项的发动准备与合法性检查。
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上可用的怪兽区域空格数。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检查卡组中是否存在至少1只满足条件的「肃声」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.dfilter,tp,LOCATION_DECK,0,1,nil,e,tp,ft)
		-- 并且检查手卡或墓地中是否存在至少1张可回到卡组的仪式怪兽或仪式魔法卡。
		and Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil) end
end
-- 效果①第一个选项的效果处理：将手卡/墓地的特定卡回到卡组，并从卡组检索或特殊召唤「肃声」怪兽。
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从手卡或墓地选择1张满足条件的卡（受王家之谷影响）。
	local g1=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil)
	local tc1=g1:GetFirst()
	if not tc1 then return end
	if tc1:IsLocation(LOCATION_HAND) then
		-- 如果选择的是手卡中的卡，则向对方玩家展示该卡。
		Duel.ConfirmCards(1-tp,tc1)
	end
	if tc1:IsLocation(LOCATION_GRAVE) then
		-- 如果选择的是墓地中的卡，则在墓地中高亮显示该卡。
		Duel.HintSelection(g1)
	end
	-- 将选择的卡送回卡组并洗牌，若成功返回则继续处理。
	if Duel.SendtoDeck(tc1,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
		-- 重新获取自己场上可用的怪兽区域空格数。
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		-- 提示玩家选择要操作的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
		-- 让玩家从卡组选择1只满足条件的「肃声」怪兽。
		local g=Duel.SelectMatchingCard(tp,s.dfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,ft)
		local tc=g:GetFirst()
		if tc then
			if ft>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
				-- 判定是否只能特殊召唤，或者在两者皆可时由玩家选择特殊召唤。
				and (not tc:IsAbleToHand() or Duel.SelectOption(tp,1190,1152)==1) then
				-- 将选择的怪兽以表侧表示特殊召唤。
				Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
			else
				-- 将选择的怪兽加入手卡。
				Duel.SendtoHand(tc,nil,REASON_EFFECT)
				-- 向对方玩家展示加入手卡的怪兽。
				Duel.ConfirmCards(1-tp,tc)
			end
		end
	end
end
-- 过滤条件：自己场上表侧表示的光属性战士族/龙族仪式怪兽。
function s.desfilters(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and c:IsType(TYPE_RITUAL) and c:IsRace(RACE_WARRIOR+RACE_DRAGON) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
-- 效果①第二个选项的发动准备与对象选择。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 检查自己场上是否存在至少1只满足条件的光属性战士族/龙族仪式怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.desfilters,tp,LOCATION_MZONE,0,1,nil)
		-- 并且检查对方场上是否存在至少1张可以作为对象的卡。
		and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 计算自己场上满足条件的光属性战士族/龙族仪式怪兽的数量，作为可选对象的最大数量。
	local ct=Duel.GetMatchingGroupCount(s.desfilters,tp,LOCATION_MZONE,0,e:GetHandler())
	-- 提示玩家选择要破坏的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择最多等同于上述数量的对方场上的卡作为效果对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,ct,nil)
	-- 设置当前连锁的操作信息，表明将要破坏选中的卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果①第二个选项的效果处理：破坏选中的对方卡片和这张卡。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡片组。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local g=tg:Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		g:AddCard(e:GetHandler())
		-- 破坏所有仍存在于场上的对象卡片以及这张卡。
		Duel.Destroy(g,REASON_EFFECT)
	end
end

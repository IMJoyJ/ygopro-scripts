--粛声の竜賢聖サウラヴィス
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：这张卡可以从自己的手卡·墓地让包含仪式魔法卡的2张魔法卡回到卡组，从手卡特殊召唤。
-- ②：对方把卡的效果发动时，让场上的这张卡回到手卡才能发动。从手卡·卡组把1只战士族·龙族而光属性的仪式怪兽特殊召唤。这个效果特殊召唤的怪兽在下个回合的结束阶段回到卡组。
local s,id,o=GetID()
-- 注册卡片效果：①手卡特殊召唤的规则，②对方发动效果时让自身回手卡并从手卡·卡组特殊召唤光属性战士族·龙族仪式怪兽的诱发即时效果
function s.initial_effect(c)
	-- ①：这张卡可以从自己的手卡·墓地让包含仪式魔法卡的2张魔法卡回到卡组，从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.sprcon)
	e1:SetOperation(s.sprop)
	c:RegisterEffect(e1)
	-- ②：对方把卡的效果发动时，让场上的这张卡回到手卡才能发动。从手卡·卡组把1只战士族·龙族而光属性的仪式怪兽特殊召唤。这个效果特殊召唤的怪兽在下个回合的结束阶段回到卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.con)
	e2:SetCost(s.cost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
-- 过滤手卡·墓地可以作为特殊召唤Cost返回卡组的魔法卡
function s.sprfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToDeckAsCost()
end
-- 检查选取的卡片组中是否包含至少1张仪式魔法卡
function s.gcheck(g)
	return g:IsExists(Card.IsType,1,nil,TYPE_RITUAL)
end
-- 自身特殊召唤规则的条件：自身怪兽区域有空位，且手卡·墓地存在包含仪式魔法卡的2张魔法卡
function s.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取玩家手卡和墓地中所有可以返回卡组的魔法卡
	local g=Duel.GetMatchingGroup(s.sprfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,nil)
	-- 检查玩家的主要怪兽区域是否有空位
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and g:CheckSubGroup(s.gcheck,2,2)
end
-- 自身特殊召唤规则的操作：选择手卡·墓地包含仪式魔法卡的2张魔法卡展示并返回卡组
function s.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取玩家手卡和墓地中所有可以返回卡组的魔法卡
	local g=Duel.GetMatchingGroup(s.sprfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,nil)
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	local sg=g:SelectSubGroup(tp,s.gcheck,false,2,2)
	local hg=sg:Filter(Card.IsLocation,nil,LOCATION_HAND)
	if #hg>0 then
		-- 给对方玩家确认从手卡选择的魔法卡
		Duel.ConfirmCards(1-tp,hg)
	end
	local gg=sg:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	if #gg>0 then
		-- 给对方玩家确认并显示从墓地选择的魔法卡
		Duel.HintSelection(gg)
	end
	-- 将选中的2张魔法卡作为特殊召唤的代替Cost返回持有者卡组并洗牌
	Duel.SendtoDeck(sg,nil,2,REASON_COST)
end
-- 诱发即时效果的发动条件：对方把卡的效果发动时
function s.con(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
-- 诱发即时效果的发动Cost：让场上的这张卡回到手卡
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHandAsCost() end
	-- 将场上的这张卡作为Cost送回持有者手卡
	Duel.SendtoHand(c,nil,REASON_COST)
end
-- 过滤手卡·卡组中满足条件的光属性战士族或龙族仪式怪兽
function s.filter(c,e,tp)
	return c:IsRace(RACE_DRAGON+RACE_WARRIOR) and c:IsType(TYPE_RITUAL) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsCanBeSpecialSummoned(e,0,tp,false,true)
end
-- 诱发即时效果的靶向检测：检查自身离场后是否有可用的怪兽区域，以及手卡·卡组是否存在可特殊召唤的合法怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自身离场后，玩家场上是否有可用于特殊召唤的怪兽区域
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 检查手卡或卡组中是否存在至少1只满足条件的光属性战士族或龙族仪式怪兽
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁中的操作信息：从手卡或卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- 诱发即时效果的效果处理：从手卡·卡组特殊召唤1只光属性战士族·龙族仪式怪兽，并注册在下个回合结束阶段返回卡组的延迟效果
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 过滤并让玩家从手卡或卡组选择1只满足条件的光属性战士族或龙族仪式怪兽
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		local sc=g:GetFirst()
		-- 尝试将选中的怪兽以表侧表示特殊召唤（不检查仪式召唤条件，但受特殊召唤限制）
		if Duel.SpecialSummonStep(sc,0,tp,tp,false,true,POS_FACEUP) then
			sc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
			-- 这个效果特殊召唤的怪兽在下个回合的结束阶段回到卡组。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetCountLimit(1)
			e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			-- 将当前回合数记录在效果的Label中，用于后续判断是否到了“下个回合”
			e1:SetLabel(Duel.GetTurnCount())
			e1:SetLabelObject(sc)
			e1:SetCondition(s.tdcon)
			e1:SetOperation(s.tdop)
			e1:SetReset(RESET_PHASE+PHASE_END,2)
			-- 注册该全局延迟效果
			Duel.RegisterEffect(e1,tp)
		end
		-- 完成特殊召唤的最终处理
		Duel.SpecialSummonComplete()
	end
end
-- 延迟效果的发动条件：当前回合数不等于特殊召唤时的回合数（即到了下个回合），且该怪兽仍带有对应的标记
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 检查当前回合数是否与特殊召唤时的回合数不同（确保是下个回合），且目标怪兽身上的标记依然存在
	return Duel.GetTurnCount()~=e:GetLabel() and tc:GetFlagEffect(id)~=0
end
-- 延迟效果的效果处理：将特殊召唤的怪兽送回卡组并洗牌
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示发动该效果的卡片（显示卡片动画）
	Duel.Hint(HINT_CARD,0,id)
	local tc=e:GetLabelObject()
	-- 将目标怪兽送回持有者卡组并洗牌
	Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end

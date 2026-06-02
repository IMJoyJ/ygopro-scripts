--心宿りし青眼竜
-- 效果：
-- 这个卡名在规则上也当作「千年」卡使用。这个卡名的①的效果1回合只能使用1次，③的效果在自己把「千年十字」发动的决斗中才能使用1次。
-- ①：把这张卡从手卡丢弃才能发动。从卡组把1张「千年十字」加入手卡。
-- ②：这张卡的控制权不能变更。
-- ③：这张卡在墓地存在的状态，对方把8星以上或攻击力3000以上的怪兽召唤·特殊召唤的场合才能发动。那些怪兽送去墓地，这张卡特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果的函数，注册各项效果及全局监听。
function s.initial_effect(c)
	-- 记录卡片效果中记载了「千年十字」（卡号37613663）。
	aux.AddCodeList(c,37613663)
	-- ①：把这张卡从手卡丢弃才能发动。从卡组把1张「千年十字」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡的控制权不能变更。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
	c:RegisterEffect(e2)
	-- ③：这张卡在墓地存在的状态，对方把8星以上或攻击力3000以上的怪兽召唤·特殊召唤的场合才能发动。那些怪兽送去墓地，这张卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_CUSTOM+id)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+EFFECT_COUNT_CODE_DUEL)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	-- 注册合并延迟事件，用于监听对方召唤怪兽的时点。
	aux.RegisterMergedDelayedEvent(c,id,EVENT_SUMMON_SUCCESS)
	-- 注册合并延迟事件，用于监听对方特殊召唤怪兽的时点。
	aux.RegisterMergedDelayedEvent(c,id,EVENT_SPSUMMON_SUCCESS)
	if not s.global_check then
		s.global_check=true
		-- 这个卡名的③的效果在自己把「千年十字」发动的决斗中才能使用1次。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAINING)
		ge1:SetCondition(s.checkcon)
		ge1:SetOperation(s.checkop)
		-- 注册全局效果，用于在决斗中记录玩家是否发动过「千年十字」。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 全局效果的触发条件：发动的卡是「千年十字」且是魔法卡的发动。
function s.checkcon(e,tp,eg,ep,ev,re,r,rp)
	return re:GetHandler():IsCode(37613663) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 全局效果的处理：给发动「千年十字」的玩家注册标记，若连锁被无效则清除标记。
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查该玩家当前是否尚未注册发动过「千年十字」的标记。
	if Duel.GetFlagEffect(rp,id)==0 then
		-- 给该玩家注册表示已发动过「千年十字」的全局标记。
		Duel.RegisterFlagEffect(rp,id,0,0,0)
		-- 这个卡名的③的效果在自己把「千年十字」发动的决斗中才能使用1次。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAIN_NEGATED)
		e1:SetOperation(s.rsop)
		e1:SetLabelObject(re)
		e1:SetReset(RESET_CHAIN)
		-- 注册一个在当前连锁结算时检测是否被无效的效果。
		Duel.RegisterEffect(e1,rp)
	end
end
-- 连锁被无效时的处理函数：重置（清除）玩家已发动「千年十字」的标记。
function s.rsop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabelObject()==re then
		-- 清除玩家已发动「千年十字」的标记。
		Duel.ResetFlagEffect(tp,id)
	end
end
-- 效果①的消耗：把这张卡从手卡丢弃。
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 将手卡的这张卡丢弃送去墓地。
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 检索过滤条件：卡名为「千年十字」且能加入手卡。
function s.thfilter(c)
	return c:IsCode(37613663) and c:IsAbleToHand()
end
-- 效果①的靶向：检查卡组是否存在「千年十字」，并设置检索操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以加入手牌的「千年十字」。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的处理：从卡组把1张「千年十字」加入手卡并给对方确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 获取卡组中满足条件的「千年十字」。
	local tc=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil):GetFirst()
	if tc then
		-- 将选中的「千年十字」加入手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡。
		Duel.ConfirmCards(1-tp,tc)
	end
end
-- 效果③的发动条件：自己在这场决斗中发动过「千年十字」。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己是否拥有已发动过「千年十字」的全局标记。
	return Duel.GetFlagEffect(tp,id)>0
end
-- 过滤条件：对方场上表侧表示存在的、由对方召唤·特殊召唤的8星以上或攻击力3000以上的怪兽。
function s.tdfilter(c,tp,e)
	return (c:IsAttackAbove(3000) or c:IsLevelAbove(8)) and c:IsFaceup() and c:IsSummonPlayer(1-tp) and c:IsLocation(LOCATION_MZONE)
end
-- 效果③的靶向：筛选出符合条件的对方怪兽并设为效果目标，设置送去墓地和特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=eg:Filter(s.tdfilter,nil,tp)
	-- 检查在那些怪兽离开场后是否有可用的怪兽区域，且这张卡可以特殊召唤。
	if chk==0 then return Duel.GetMZoneCount(tp,g,tp)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and g:GetCount()>0 end
	-- 将符合条件的对方怪兽设为当前连锁的效果处理对象。
	Duel.SetTargetCard(g)
	-- 设置操作信息：将这张卡特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
	-- 设置操作信息：将目标怪兽送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,#g,0,0)
end
-- 效果③的处理：将目标怪兽送去墓地，若成功送墓，则将这张卡特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中仍存在且为怪兽的目标卡片。
	local g=Duel.GetTargetsRelateToChain():Filter(Card.IsType,nil,TYPE_MONSTER)
	-- 如果目标怪兽存在，则将其送去墓地，并确认至少有1张成功送入墓地。
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 and g:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE)
		-- 检查这张卡是否仍与效果相关联，且不受王家长眠之谷的影响。
		and c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) then
		-- 将这张卡在自己场上表侧表示特殊召唤。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

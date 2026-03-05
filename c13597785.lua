--耀聖の花詩ルキナ
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②③的效果1回合各能使用1次。
-- ①：这张卡可以从手卡往自己的中央的主要怪兽区域特殊召唤。
-- ②：自己主要阶段才能发动。从卡组把「耀圣之花诗 卢西娜」以外的1只「耀圣」怪兽加入手卡。
-- ③：对方回合才能发动。自己的主要怪兽区域的这张卡和中央的怪兽的位置交换。那之后，可以让对方场上1只6星以下的怪兽回到手卡。
local s,id,o=GetID()
-- 注册卡片的三个效果：①特殊召唤、②检索、③交换位置并可能让对方怪兽回手
function s.initial_effect(c)
	-- ①：这张卡可以从手卡往自己的中央的主要怪兽区域特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	e1:SetValue(s.spval)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。从卡组把「耀圣之花诗 卢西娜」以外的1只「耀圣」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"检索怪兽"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ③：对方回合才能发动。自己的主要怪兽区域的这张卡和中央的怪兽的位置交换。那之后，可以让对方场上1只6星以下的怪兽回到手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"交换位置"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END+TIMING_END_PHASE)
	e3:SetCondition(s.chcon)
	e3:SetTarget(s.chtg)
	e3:SetOperation(s.chop)
	c:RegisterEffect(e3)
end
-- 判断是否满足特殊召唤条件：检查是否有足够的怪兽区域
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查当前玩家的怪兽区域是否还有空位
	return Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,0x4)>0
end
-- 设置特殊召唤的参数：返回0和0x4作为特殊召唤的参数
function s.spval(e,c)
	return 0,0x4
end
-- 检索过滤器：筛选不是自身且为耀圣卡组的怪兽
function s.thfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x1d8) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 设置检索效果的目标：检查是否有满足条件的怪兽
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置检索效果的操作信息：准备将1张卡从卡组加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的处理：选择并把怪兽加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方看到加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 交换位置效果的发动条件：必须在对方回合且自身在主要怪兽区
function s.chcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否在对方回合且自身在主要怪兽区
	return e:GetHandler():GetSequence()<5 and Duel.GetTurnPlayer()==1-tp
end
-- 交换位置的过滤器：筛选中央怪兽
function s.chfilter(c)
	return c:GetSequence()==2
end
-- 设置交换位置效果的目标：检查是否有中央怪兽
function s.chtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有中央怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.chfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
end
-- 让对方怪兽回手的过滤器：筛选6星以下的对方怪兽
function s.rthfilter(c)
	return c:IsFaceup() and c:IsAbleToHand() and c:IsLevelBelow(6)
end
-- 交换位置效果的处理：交换位置并可能让对方怪兽回手
function s.chop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cs=c:GetSequence()
	if not c:IsRelateToChain() or not c:IsControler(tp) or cs>4 or cs==2 then return end
	-- 获取所有满足交换条件的怪兽
	local g=Duel.GetMatchingGroup(s.chfilter,tp,LOCATION_MZONE,0,nil)
	if g:GetCount()==1 then
		local tc=g:GetFirst()
		-- 交换自身与目标怪兽的位置
		Duel.SwapSequence(c,tc)
		if c:GetSequence()==cs then return end
		-- 检查对方场上是否有6星以下的怪兽
		if Duel.IsExistingMatchingCard(s.rthfilter,tp,0,LOCATION_MZONE,1,nil)
			-- 询问玩家是否让怪兽回手
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否让怪兽回到手卡？"
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 提示玩家选择要返回手牌的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
			-- 选择满足条件的对方怪兽
			local rg=Duel.SelectMatchingCard(tp,s.rthfilter,tp,0,LOCATION_MZONE,1,1,nil)
			-- 显示选中的怪兽被选为对象
			Duel.HintSelection(rg)
			-- 将选中的怪兽送回手牌
			Duel.SendtoHand(rg,nil,REASON_EFFECT)
		end
	end
end

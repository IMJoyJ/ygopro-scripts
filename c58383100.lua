--光波鏡騎士
-- 效果：
-- 「光波镜骑士」的②的效果1回合只能使用1次。
-- ①：自己的「光波」怪兽1只被战斗破坏送去自己墓地时，把这张卡从手卡丢弃才能发动。选自己的手卡·场上1张卡送去墓地，那只破坏的怪兽特殊召唤。
-- ②：这张卡被送去墓地的回合的结束阶段才能发动。从卡组把1张「光波」卡加入手卡。
function c58383100.initial_effect(c)
	-- ①：自己的「光波」怪兽1只被战斗破坏送去自己墓地时，把这张卡从手卡丢弃才能发动。选自己的手卡·场上1张卡送去墓地，那只破坏的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(58383100,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c58383100.spcon)
	e1:SetCost(c58383100.spcost)
	e1:SetTarget(c58383100.sptg)
	e1:SetOperation(c58383100.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡被送去墓地的回合的结束阶段才能发动。从卡组把1张「光波」卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(c58383100.regop)
	c:RegisterEffect(e2)
	-- 「光波镜骑士」的②的效果1回合只能使用1次。②：这张卡被送去墓地的回合的结束阶段才能发动。从卡组把1张「光波」卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(58383100,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,58383100)
	e3:SetCondition(c58383100.thcon)
	e3:SetTarget(c58383100.thtg)
	e3:SetOperation(c58383100.thop)
	c:RegisterEffect(e3)
end
-- 过滤条件：属于自己、因战斗破坏送去自己墓地、原本属于自己且原本在怪兽区域的「光波」怪兽，且该怪兽可以特殊召唤
function c58383100.cfilter(c,e,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_BATTLE)
		and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousSetCard(0xe5)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①发动条件：仅有1只满足过滤条件的怪兽被送去墓地时
function c58383100.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetCount()==1 and c58383100.cfilter(eg:GetFirst(),e,tp)
end
-- 效果①发动代价：把手卡的这张卡丢弃
function c58383100.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将自身作为发动代价丢弃送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 过滤条件：可以送去墓地，且该卡离开后能为特殊召唤留出空余怪兽区域的卡片
function c58383100.filter(c,tp)
	-- 检查卡片是否能送去墓地，且该卡离开后自己场上是否有可用的怪兽区域
	return c:IsAbleToGrave() and Duel.GetMZoneCount(tp,c)>0
end
-- 效果①发动准备：检查自己手卡或场上是否有可送去墓地的卡，将战斗破坏的怪兽设为效果处理对象，并注册送去墓地和特殊召唤的操作信息
function c58383100.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手卡或场上（排除这张卡自身）是否存在至少1张满足送墓且能留出怪兽区域条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c58383100.filter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,e:GetHandler(),tp) end
	local ec=eg:GetFirst()
	-- 将被战斗破坏的怪兽设为当前连锁的处理对象
	Duel.SetTargetCard(ec)
	-- 设置操作信息：预计将自己手卡或场上的1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND+LOCATION_ONFIELD)
	-- 设置操作信息：预计将对象怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,ec,1,0,0)
end
-- 效果①效果处理：选自己手卡或场上1张卡送去墓地，若成功送墓，则将对象怪兽特殊召唤
function c58383100.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家选择自己手卡或场上1张满足条件的卡
	local tg=Duel.SelectMatchingCard(tp,c58383100.filter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil,tp)
	local tc=tg:GetFirst()
	-- 将选中的卡因效果送去墓地，并确认其已成功到达墓地
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE) then
		-- 获取之前设定的效果处理对象（即被战斗破坏的怪兽）
		local ec=Duel.GetFirstTarget()
		if ec:IsRelateToEffect(e) then
			-- 将该怪兽以表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(ec,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 效果②辅助处理：在这张卡被送去墓地时，给其注册一个持续到回合结束的标记，用于记录“被送去墓地的回合”这一状态
function c58383100.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(58383100,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 效果②发动条件：检查这张卡是否带有在被送去墓地回合注册的标记
function c58383100.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(58383100)>0
end
-- 过滤条件：卡组中可以加入手卡的「光波」卡片
function c58383100.thfilter(c)
	return c:IsSetCard(0xe5) and c:IsAbleToHand()
end
-- 效果②发动准备：检查卡组中是否存在可检索的「光波」卡，并注册加入手卡的操作信息
function c58383100.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组中是否存在至少1张可以加入手卡的「光波」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c58383100.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：预计从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②效果处理：从卡组选择1张「光波」卡加入手卡，并给对方确认
function c58383100.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足条件的「光波」卡
	local g=Duel.SelectMatchingCard(tp,c58383100.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end

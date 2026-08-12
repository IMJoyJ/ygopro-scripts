--源竜星－ボウテンコウ
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 自己对「源龙星-望天吼」1回合只能有1次特殊召唤。
-- ①：这张卡特殊召唤成功的场合才能发动。从卡组把1张「龙星」卡加入手卡。
-- ②：1回合1次，从卡组把1只幻龙族怪兽送去墓地才能发动。这张卡的等级变成和送去墓地的怪兽相同。
-- ③：表侧表示的这张卡从场上离开的场合才能发动。从卡组把1只「龙星」怪兽特殊召唤。
function c65536818.initial_effect(c)
	c:SetSPSummonOnce(65536818)
	-- 为这张卡添加同调召唤手续（需要1只调整和1只以上调整以外的怪兽）
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤成功的场合才能发动。从卡组把1张「龙星」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(65536818,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(c65536818.thtg)
	e1:SetOperation(c65536818.thop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，从卡组把1只幻龙族怪兽送去墓地才能发动。这张卡的等级变成和送去墓地的怪兽相同。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(65536818,1))  --"改变等级"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c65536818.lvcost)
	e2:SetOperation(c65536818.lvop)
	c:RegisterEffect(e2)
	-- ③：表侧表示的这张卡从场上离开的场合才能发动。从卡组把1只「龙星」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(65536818,2))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(c65536818.spcon)
	e3:SetTarget(c65536818.sptg)
	e3:SetOperation(c65536818.spop)
	c:RegisterEffect(e3)
end
-- 过滤卡组中「龙星」卡片且能加入手牌的过滤函数
function c65536818.thfilter(c)
	return c:IsSetCard(0x9e) and c:IsAbleToHand()
end
-- 效果①（检索卡组「龙星」卡）的发动准备与合法性检测函数
function c65536818.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张可以加入手牌的「龙星」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c65536818.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息，表示该效果会将卡组的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①（检索卡组「龙星」卡）的效果处理函数
function c65536818.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足过滤条件的「龙星」卡
	local g=Duel.SelectMatchingCard(tp,c65536818.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡因效果加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤卡组中等级与自身不同、等级在1以上且能作为cost送去墓地的幻龙族怪兽的过滤函数
function c65536818.costfilter(c,lv)
	return not c:IsLevel(lv) and c:IsLevelAbove(1) and c:IsRace(RACE_WYRM) and c:IsAbleToGraveAsCost()
end
-- 效果②（改变等级）的发动代价（cost）处理函数
function c65536818.lvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local lv=e:GetHandler():GetLevel()
	-- 检查卡组中是否存在可以作为cost送去墓地的幻龙族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c65536818.costfilter,tp,LOCATION_DECK,0,1,nil,lv) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1只满足条件的幻龙族怪兽
	local g=Duel.SelectMatchingCard(tp,c65536818.costfilter,tp,LOCATION_DECK,0,1,1,nil,lv)
	-- 将选择的怪兽作为发动代价（cost）送去墓地
	Duel.SendtoGrave(g,REASON_COST)
	e:SetLabel(g:GetFirst():GetLevel())
end
-- 效果②（改变等级）的效果处理函数
function c65536818.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local lv=e:GetLabel()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的等级变成和送去墓地的怪兽相同。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(lv)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 效果③（离场特召）的发动条件函数（必须是表侧表示的这张卡从场上离开）
function c65536818.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤卡组中可以特殊召唤的「龙星」怪兽的过滤函数
function c65536818.spfilter(c,e,tp)
	return c:IsSetCard(0x9e) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果③（离场特召）的发动准备与合法性检测函数
function c65536818.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查卡组中是否存在可以特殊召唤的「龙星」怪兽
		and Duel.IsExistingMatchingCard(c65536818.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息，表示该效果会从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果③（离场特召）的效果处理函数
function c65536818.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域空格，若无可用空格则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只满足条件的「龙星」怪兽
	local g=Duel.SelectMatchingCard(tp,c65536818.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的怪兽以表侧表示特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

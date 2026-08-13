--コード・イグナイター
-- 效果：
-- 4星怪兽×2
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡超量召唤的场合才能发动。从卡组把1只电子界族仪式怪兽加入手卡。
-- ②：把这张卡1个超量素材取除才能发动。等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己的手卡·场上的怪兽解放，从手卡把1只仪式怪兽仪式召唤。
-- ③：这张卡作为连接素材送去墓地的场合才能发动。从卡组把1张「“艾”」陷阱卡加入手卡。
local s,id,o=GetID()
-- 初始化卡牌的完整效果：为“代码点火员”添加超量召唤手续（4星怪兽×2）、苏生限制，并依次注册①检索电子界族仪式怪兽、②取除素材进行仪式召唤、③作为连接素材送墓时检索“艾”陷阱卡这三个效果，同时分别给三个效果设置1回合1次的卡名次数限制。
function s.initial_effect(c)
	-- 为这张卡添加超量召唤手续：需要用2只4星怪兽叠放进行超量召唤，对应效果文本“4星怪兽×2”。
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- 这个卡名的①②③的效果1回合各能使用1次。①：这张卡超量召唤的场合才能发动。从卡组把1只电子界族仪式怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索效果"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- 调用辅助函数生成②的仪式召唤效果原型：将手卡·场上的怪兽解放，直到等级合计达到仪式怪兽等级以上，从手卡仪式召唤1只仪式怪兽；这里不限制仪式怪兽种类，不立即注册，后续再改为起动效果并附加取除1个超量素材的cost。
	local e2=aux.AddRitualProcGreater2(c,aux.TRUE,nil,nil,aux.TRUE,true)
	e2:SetDescription(aux.Stringid(id,1))  --"仪式召唤"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.rscost)
	c:RegisterEffect(e2)
	-- 这个卡名的①②③的效果1回合各能使用1次。③：这张卡作为连接素材送去墓地的场合才能发动。从卡组把1张「“艾”」陷阱卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"检索"
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCondition(s.thcon2)
	e3:SetTarget(s.thtg2)
	e3:SetOperation(s.thop2)
	c:RegisterEffect(e3)
end
-- ①的发动条件：在超量召唤成功时，判定这张卡是否确实通过超量召唤方式特殊召唤成功，只有满足该条件才能发动①效果。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 定义①的检索过滤条件：必须是电子界族、仪式怪兽，且能够被加入手牌。
function s.thfilter(c)
	return c:IsRace(RACE_CYBERSE) and c:IsType(TYPE_RITUAL) and c:IsAbleToHand()
end
-- ①的发动判定与操作信息设定：在chk==0时检查卡组中是否存在符合条件的电子界族仪式怪兽；若可以发动，则设置本次连锁将要把卡组中的卡加入手牌。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- ①的发动合法性检查：确认卡组中至少存在1张满足s.thfilter的电子界族仪式怪兽，否则效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：声明本效果涉及从卡组将1张卡加入手牌（CATEGORY_TOHAND），数量为1，检索位置为卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：给玩家显示选择提示，从卡组选择1张符合条件的电子界族仪式怪兽加入手牌，并向对方展示确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向发动玩家显示“请选择要加入手牌的卡”的选择提示，供随后选择检索卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 发动玩家从卡组中精确选择1张满足s.thfilter的电子界族仪式怪兽作为检索对象。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡片以效果处理原因（REASON_EFFECT）加入其持有者的手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示本次检索加入手牌的卡片，公开检索结果。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②的发动代价处理：chk==0时检查这张卡能否取除1个超量素材；实际发动时取除这张卡的1个超量素材作为代价（REASON_COST）。
function s.rscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- ③的发动条件：这张卡被用作连接素材而送入墓地时（r==REASON_LINK），并且当前位于墓地，才满足③的发动条件。
function s.thcon2(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_LINK and e:GetHandler():IsLocation(LOCATION_GRAVE)
end
-- 定义③的检索过滤条件：字段为「“艾”」（0x136）、陷阱卡，且能够加入手牌。
function s.thfilter2(c)
	return c:IsSetCard(0x136) and c:IsType(TYPE_TRAP) and c:IsAbleToHand()
end
-- ③的发动判定与操作信息设定：在chk==0时检查卡组中是否存在符合条件的“艾”陷阱卡；若可以发动，则设置本次连锁将要把卡组中的卡加入手牌。
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- ③的发动合法性检查：确认卡组中至少存在1张满足s.thfilter2的“艾”陷阱卡，否则效果不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：声明本效果涉及从卡组将1张“艾”陷阱卡加入手牌，数量为1，位置为卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ③效果处理：给玩家显示选择提示，从卡组选择1张符合条件的“艾”陷阱卡加入手牌，并向对方展示确认。
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 向发动玩家显示“请选择要加入手牌的卡”的选择提示，用于选择“艾”陷阱卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 发动玩家从卡组中精确选择1张满足s.thfilter2的“艾”陷阱卡作为检索对象。
	local g=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的“艾”陷阱卡以效果处理原因（REASON_EFFECT）加入其持有者的手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示本次加入手牌的“艾”陷阱卡，公开检索结果。
		Duel.ConfirmCards(1-tp,g)
	end
end

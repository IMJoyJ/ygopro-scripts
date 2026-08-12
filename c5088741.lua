--コード・イグナイター
-- 效果：
-- 4星怪兽×2
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡超量召唤的场合才能发动。从卡组把1只电子界族仪式怪兽加入手卡。
-- ②：把这张卡1个超量素材取除才能发动。等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己的手卡·场上的怪兽解放，从手卡把1只仪式怪兽仪式召唤。
-- ③：这张卡作为连接素材送去墓地的场合才能发动。从卡组把1张「“艾”」陷阱卡加入手卡。
local s,id,o=GetID()
-- 注册卡片效果，设置超量召唤程序并添加三个触发效果
function s.initial_effect(c)
	-- 为卡片添加超量召唤手续，使用4星怪兽叠放2次
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- ①：这张卡超量召唤的场合才能发动。从卡组把1只电子界族仪式怪兽加入手卡。
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
	-- 为卡片注册仪式召唤程序，满足等级合计条件后可从手卡仪式召唤怪兽
	local e2=aux.AddRitualProcGreater2(c,aux.TRUE,nil,nil,aux.TRUE,true)
	e2:SetDescription(aux.Stringid(id,1))  --"仪式召唤"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.rscost)
	c:RegisterEffect(e2)
	-- ③：这张卡作为连接素材送去墓地的场合才能发动。从卡组把1张「“艾”」陷阱卡加入手卡。
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
-- 效果条件：确认此卡为超量召唤成功
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
-- 检索过滤器：筛选电子界族仪式怪兽
function s.thfilter(c)
	return c:IsRace(RACE_CYBERSE) and c:IsType(TYPE_RITUAL) and c:IsAbleToHand()
end
-- 效果目标：检查卡组是否存在符合条件的卡片并设置操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足检索条件
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，指定将要处理的卡牌类别和数量
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：选择并把符合条件的怪兽加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家进行选择
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择一张符合条件的卡片
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡片送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认所选卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果代价：移除自身一个超量素材
function s.rscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果条件：确认此卡因连接召唤而送去墓地
function s.thcon2(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_LINK and e:GetHandler():IsLocation(LOCATION_GRAVE)
end
-- 检索过滤器：筛选「艾」系列陷阱卡
function s.thfilter2(c)
	return c:IsSetCard(0x136) and c:IsType(TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果目标：检查卡组是否存在符合条件的卡片并设置操作信息
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足检索条件
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，指定将要处理的卡牌类别和数量
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：选择并把符合条件的陷阱卡加入手牌
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家进行选择
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择一张符合条件的卡片
	local g=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认所选卡片
		Duel.ConfirmCards(1-tp,g)
	end
end

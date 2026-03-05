--トリックスター・フーディ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有「淘气仙星」融合·连接怪兽的其中任意种存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡作为「淘气仙星」连接怪兽的连接素材送去墓地的场合才能发动。从卡组把1张「淘气仙星融合」或「淘气仙星扩散融合」加入手卡。
local s,id,o=GetID()
-- 初始化效果函数，注册两个效果：①特殊召唤效果和②墓地触发效果
function s.initial_effect(c)
	-- 记录该卡与「淘气仙星融合」（88693151）和「淘气仙星扩散融合」（63181559）的关联
	aux.AddCodeList(c,88693151,63181559)
	-- ①：自己场上有「淘气仙星」融合·连接怪兽的其中任意种存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡作为「淘气仙星」连接怪兽的连接素材送去墓地的场合才能发动。从卡组把1张「淘气仙星融合」或「淘气仙星扩散融合」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断场上是否存在「淘气仙星」融合或连接怪兽
function s.cfilter(c)
	return c:IsSetCard(0xfb) and c:IsType(TYPE_FUSION+TYPE_LINK) and c:IsFaceup()
end
-- 判断条件函数，检查自己场上是否存在「淘气仙星」融合或连接怪兽
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张「淘气仙星」融合或连接怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 特殊召唤效果的发动时点处理函数，判断是否满足特殊召唤条件
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理函数，将该卡特殊召唤到场上
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 执行将该卡特殊召唤到场上的操作
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 墓地触发效果的发动条件函数，判断该卡是否作为连接怪兽的素材被送去墓地
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_LINK and e:GetHandler():GetReasonCard():IsSetCard(0xfb)
end
-- 检索过滤函数，用于筛选「淘气仙星融合」或「淘气仙星扩散融合」卡
function s.thfilter(c)
	return (c:IsCode(88693151) or c:IsCode(63181559)) and c:IsAbleToHand()
end
-- 墓地触发效果的发动时点处理函数，判断是否满足检索条件
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张「淘气仙星融合」或「淘气仙星扩散融合」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置检索效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 墓地触发效果的处理函数，从卡组检索符合条件的卡并加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张符合条件的卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看了送入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end

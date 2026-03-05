--トリックスター・フーディ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有「淘气仙星」融合·连接怪兽的其中任意种存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡作为「淘气仙星」连接怪兽的连接素材送去墓地的场合才能发动。从卡组把1张「淘气仙星融合」或「淘气仙星扩散融合」加入手卡。
local s,id,o=GetID()
-- 初始化卡片效果函数
function s.initial_effect(c)
	-- 为卡片注册关联卡片代码列表，用于识别与「淘气仙星」融合或连接怪兽的关联性
	aux.AddCodeList(c,88693151,63181559)
	-- ①：自己场上有「淘气仙星」融合·连接怪兽的其中任意种存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
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
-- 判断效果发动条件，检查自己场上是否存在「淘气仙星」融合或连接怪兽
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在满足条件的「淘气仙星」融合或连接怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 设置特殊召唤效果的目标函数
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足特殊召唤的条件，包括是否有足够的召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理时的操作信息，指定将要特殊召唤的卡片
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤效果的操作函数
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将卡片以正面表示的形式特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断效果发动条件，检查该卡是否作为连接素材被送去墓地且来源为「淘气仙星」连接怪兽
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_LINK and e:GetHandler():GetReasonCard():IsSetCard(0xfb)
end
-- 过滤函数，用于检索卡组中符合条件的「淘气仙星融合」或「淘气仙星扩散融合」卡片
function s.thfilter(c)
	return (c:IsCode(88693151) or c:IsCode(63181559)) and c:IsAbleToHand()
end
-- 设置检索效果的目标函数
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理时的操作信息，指定将要加入手牌的卡片
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索效果的操作函数
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 从卡组中选择满足条件的卡片
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片送入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看所选中的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end

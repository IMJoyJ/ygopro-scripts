--トリックスター・フーディ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有「淘气仙星」融合·连接怪兽的其中任意种存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡作为「淘气仙星」连接怪兽的连接素材送去墓地的场合才能发动。从卡组把1张「淘气仙星融合」或「淘气仙星扩散融合」加入手卡。
local s,id,o=GetID()
-- 定义该卡的初始化函数：向规则系统登记卡名提及的卡片，创建并注册①特殊召唤效果与②检索融合卡效果，并设置各自发动次数限制。
function s.initial_effect(c)
	-- 记录这张卡文本中提到的「淘气仙星融合」（88693151）与「淘气仙星扩散融合」（63181559），使相关检索或判别效果能正确识别这些卡名。
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
-- 定义筛选函数：卡片需为表侧表示、属于「淘气仙星」字段且同时是融合或连接怪兽。
function s.cfilter(c)
	return c:IsSetCard(0xfb) and c:IsType(TYPE_FUSION+TYPE_LINK) and c:IsFaceup()
end
-- ①效果的发动条件：检查自己场上是否存在至少1只满足s.cfilter的「淘气仙星」融合·连接怪兽。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场地区域是否存在至少1只表侧表示的「淘气仙星」融合·连接怪兽。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ①效果的发动目标条件：自己场上有可用怪兽区域，且手牌中的这张卡能够基于此效果被特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否还有空余的主要怪兽区域可用来特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 在发动时向连锁系统通告本次操作属特殊召唤，并指定对象为自身，用于后续时点和效果的判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的处理：若此卡仍与该效果保持关联，则将其表侧表示特殊召唤到自己场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧攻击表示特殊召唤到自己场上，不检查召唤条件与苏生限制。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的发动条件：这张卡作为「淘气仙星」连接怪兽的连接素材被送入墓地。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_LINK and e:GetHandler():GetReasonCard():IsSetCard(0xfb)
end
-- 定义检索筛选函数：卡片卡名必须为「淘气仙星融合」或「淘气仙星扩散融合」，且能够被加入手卡。
function s.thfilter(c)
	return (c:IsCode(88693151) or c:IsCode(63181559)) and c:IsAbleToHand()
end
-- ②效果的发动目标条件：卡组中存在满足s.thfilter的卡片，并在发动时通告系统本次为检索加入手卡的效果。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张符合条件的「淘气仙星融合」或「淘气仙星扩散融合」。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 通告系统本次效果将涉及从卡组把卡片加入手卡，供连锁、时点等判定使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果的处理：从卡组选择1张符合条件的「淘气仙星融合」或「淘气仙星扩散融合」加入手牌，并向对方玩家确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示当前玩家选择要加入手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足s.thfilter的卡片。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片送至其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将检索到的卡片展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end

--発条空母ゼンマイティ
-- 效果：
-- 3星怪兽×2
-- ①：1回合1次，把这张卡1个超量素材取除才能发动。从手卡·卡组把1只「发条」怪兽特殊召唤。
-- ②：场上的表侧表示的「发条」怪兽被战斗以外破坏送去自己墓地时，把这张卡1个超量素材取除，以那1只「发条」怪兽为对象才能发动。那只怪兽加入手卡。
function c81122844.initial_effect(c)
	-- 添加超量召唤手续：3星怪兽×2
	aux.AddXyzProcedure(c,nil,3,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除才能发动。从手卡·卡组把1只「发条」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetDescription(aux.Stringid(81122844,0))  --"特殊召唤"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c81122844.cost)
	e1:SetTarget(c81122844.sptg)
	e1:SetOperation(c81122844.spop)
	c:RegisterEffect(e1)
	-- ②：场上的表侧表示的「发条」怪兽被战斗以外破坏送去自己墓地时，把这张卡1个超量素材取除，以那1只「发条」怪兽为对象才能发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetDescription(aux.Stringid(81122844,1))  --"返回手卡"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c81122844.thcon)
	e2:SetCost(c81122844.cost)
	e2:SetTarget(c81122844.thtg)
	e2:SetOperation(c81122844.thop)
	c:RegisterEffect(e2)
end
-- 把这张卡1个超量素材取除的代价处理
function c81122844.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤手卡·卡组中可以特殊召唤的「发条」怪兽
function c81122844.spfilter(c,e,tp)
	return c:IsSetCard(0x58) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动准备与检测（检查怪兽区域空位以及手卡·卡组是否存在可特召的「发条」怪兽，并设置特召操作信息）
function c81122844.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡或卡组中是否存在至少1只满足特召条件的「发条」怪兽
		and Duel.IsExistingMatchingCard(c81122844.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置当前连锁的操作信息为从手卡或卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- ①效果的处理（从手卡·卡组选择1只「发条」怪兽特殊召唤）
function c81122844.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若此时自己场上没有可用的怪兽区域空格，则效果不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡或卡组选择1只满足条件的「发条」怪兽
	local g=Duel.SelectMatchingCard(tp,c81122844.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤原本在自己场上表侧表示存在、因破坏送去自己墓地的「发条」怪兽
function c81122844.tgfilter(c,e,tp)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousPosition(POS_FACEUP) and c:IsControler(tp)
		and c:IsReason(REASON_DESTROY) and c:IsSetCard(0x58) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand() and c:IsCanBeEffectTarget(e)
end
-- ②效果的发动条件检测（检查是否有符合条件的「发条」怪兽被送去自己墓地）
function c81122844.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c81122844.tgfilter,1,nil,e,tp)
end
-- ②效果的发动准备（选择送去自己墓地的1只「发条」怪兽作为效果对象，并设置回收手牌的操作信息）
function c81122844.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) and c81122844.tgfilter(chkc,e,tp) end
	if chk==0 then return true end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	local g=eg:FilterSelect(tp,c81122844.tgfilter,1,1,nil,e,tp)
	-- 将选择的卡作为效果的对象
	Duel.SetTargetCard(g)
	-- 设置当前连锁的操作信息为将对象卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果的处理（将作为对象的「发条」怪兽加入手牌并给对方确认）
function c81122844.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为效果对象的卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 通过效果将对象卡加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡
		Duel.ConfirmCards(1-tp,tc)
	end
end

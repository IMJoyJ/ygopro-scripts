--武神姫－アマテラス
-- 效果：
-- 4星怪兽×3
-- ①：「武神姬-天照」在自己场上只能有1只表侧表示存在。
-- ②：自己·对方回合1次，把这张卡1个超量素材取除，以除外的1只自己的4星以下的怪兽为对象才能发动。发动回合的以下效果适用。
-- ●自己回合：作为对象的怪兽特殊召唤。
-- ●对方回合：作为对象的怪兽加入手卡。
function c68618157.initial_effect(c)
	c:SetUniqueOnField(1,0,68618157)
	-- 添加XYZ召唤手续：4星怪兽×3
	aux.AddXyzProcedure(c,nil,4,3)
	c:EnableReviveLimit()
	-- ②：自己·对方回合1次，把这张卡1个超量素材取除，以除外的1只自己的4星以下的怪兽为对象才能发动。发动回合的以下效果适用。●自己回合：作为对象的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(68618157,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c68618157.spcon)
	e1:SetCost(c68618157.cost)
	e1:SetTarget(c68618157.sptg)
	e1:SetOperation(c68618157.spop)
	c:RegisterEffect(e1)
	-- ②：自己·对方回合1次，把这张卡1个超量素材取除，以除外的1只自己的4星以下的怪兽为对象才能发动。发动回合的以下效果适用。●对方回合：作为对象的怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(68618157,1))  --"加入手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c68618157.thcon)
	e2:SetCost(c68618157.cost)
	e2:SetTarget(c68618157.thtg)
	e2:SetOperation(c68618157.thop)
	c:RegisterEffect(e2)
end
-- 自己回合特殊召唤效果的发动条件判定函数
function c68618157.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前是否为自己回合
	return Duel.GetTurnPlayer()==tp
end
-- 效果发动的代价：取除这张卡的1个超量素材
function c68618157.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤除外区中表侧表示、4星以下且可以特殊召唤的怪兽
function c68618157.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 自己回合特殊召唤效果的发动准备与目标选择
function c68618157.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c68618157.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查除外区是否存在符合特殊召唤条件的怪兽
		and Duel.IsExistingTarget(c68618157.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择除外区1只符合条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c68618157.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置效果处理信息为特殊召唤该目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 自己回合特殊召唤效果的处理函数
function c68618157.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将作为对象的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 对方回合加入手卡效果的发动条件判定函数
function c68618157.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前是否为对方回合
	return Duel.GetTurnPlayer()~=tp
end
-- 过滤除外区中表侧表示、4星以下且可以加入手卡的怪兽
function c68618157.thfilter(c)
	return c:IsFaceup() and c:IsLevelBelow(4) and c:IsAbleToHand()
end
-- 对方回合加入手卡效果的发动准备与目标选择
function c68618157.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c68618157.thfilter(chkc) end
	-- 检查除外区是否存在符合加入手卡条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c68618157.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择除外区1只符合条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c68618157.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置效果处理信息为将该目标怪兽加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 对方回合加入手卡效果的处理函数
function c68618157.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将作为对象的怪兽加入持有者的手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,tc)
	end
end

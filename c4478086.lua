--クロック・スパルトイ
-- 效果：
-- 电子界族怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡连接召唤成功的场合才能发动。从卡组把1张「电脑网融合」加入手卡。
-- ②：这张卡所连接区有怪兽特殊召唤的场合，以自己墓地1只4星以下的电子界族怪兽为对象才能发动。那只怪兽效果无效特殊召唤。这个效果的发动后，直到回合结束时自己不是融合怪兽不能从额外卡组特殊召唤。
function c4478086.initial_effect(c)
	-- 为卡片添加连接召唤手续，要求使用2只电子界族怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_CYBERSE),2,2)
	c:EnableReviveLimit()
	-- ①：这张卡连接召唤成功的场合才能发动。从卡组把1张「电脑网融合」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(4478086,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,4478086)
	e1:SetCondition(c4478086.thcon)
	e1:SetTarget(c4478086.thtg)
	e1:SetOperation(c4478086.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡所连接区有怪兽特殊召唤的场合，以自己墓地1只4星以下的电子界族怪兽为对象才能发动。那只怪兽效果无效特殊召唤。这个效果的发动后，直到回合结束时自己不是融合怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(4478086,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,4478087)
	e2:SetCondition(c4478086.spcon)
	e2:SetTarget(c4478086.sptg)
	e2:SetOperation(c4478086.spop)
	c:RegisterEffect(e2)
end
-- 判断此卡是否为连接召唤成功
function c4478086.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 过滤满足条件的「电脑网融合」卡片
function c4478086.thfilter(c)
	return c:IsCode(65801012) and c:IsAbleToHand()
end
-- 检查场上是否存在满足条件的「电脑网融合」卡片
function c4478086.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的「电脑网融合」卡片
	if chk==0 then return Duel.IsExistingMatchingCard(c4478086.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，指定将1张卡从卡组加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 处理效果发动时的卡牌选择与处理
function c4478086.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的「电脑网融合」卡片
	local g=Duel.SelectMatchingCard(tp,c4478086.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 判断目标卡片是否在连接组中
function c4478086.cfilter(c,lg)
	return lg:IsContains(c)
end
-- 判断是否有怪兽在连接区被特殊召唤
function c4478086.spcon(e,tp,eg,ep,ev,re,r,rp)
	local lg=e:GetHandler():GetLinkedGroup()
	return eg:IsExists(c4478086.cfilter,1,nil,lg)
end
-- 过滤满足条件的电子界族4星以下怪兽
function c4478086.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_CYBERSE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
-- 检查场上是否存在满足条件的墓地怪兽
function c4478086.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c4478086.filter(chkc,e,tp) end
	-- 检查场上是否存在满足条件的墓地怪兽
	if chk==0 then return Duel.IsExistingTarget(c4478086.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 检查玩家场上是否有空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地怪兽
	local g=Duel.SelectTarget(tp,c4478086.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁操作信息，指定将1只怪兽特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 处理效果发动时的卡牌选择与处理
function c4478086.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否有效且能特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 使目标怪兽效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 使目标怪兽效果无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
	-- 完成特殊召唤步骤
	Duel.SpecialSummonComplete()
	-- 设置直到回合结束时自己不能从额外卡组特殊召唤非融合怪兽的效果
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c4478086.splimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册给玩家
	Duel.RegisterEffect(e2,tp)
end
-- 限制玩家不能特殊召唤非融合怪兽
function c4478086.splimit(e,c)
	return not c:IsType(TYPE_FUSION) and c:IsLocation(LOCATION_EXTRA)
end

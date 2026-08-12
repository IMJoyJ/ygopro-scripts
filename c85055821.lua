--森の聖獣 カルピポニカ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡从手卡送去墓地的场合，以这张卡以外的自己墓地的兽族·兽战士族·鸟兽族·昆虫族·植物族怪兽合计2只为对象才能发动（相同种族最多1只）。那些怪兽回到卡组，这张卡特殊召唤。
-- ②：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把「森之圣兽 熊四手兽」以外的1只「森之圣兽」怪兽或者「森之圣灵」怪兽加入手卡。
function c85055821.initial_effect(c)
	-- ①：这张卡从手卡送去墓地的场合，以这张卡以外的自己墓地的兽族·兽战士族·鸟兽族·昆虫族·植物族怪兽合计2只为对象才能发动（相同种族最多1只）。那些怪兽回到卡组，这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(85055821,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,85055821)
	e1:SetCondition(c85055821.spcon)
	e1:SetTarget(c85055821.sptg)
	e1:SetOperation(c85055821.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把「森之圣兽 熊四手兽」以外的1只「森之圣兽」怪兽或者「森之圣灵」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(85055821,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,85055822)
	e2:SetTarget(c85055821.thtg)
	e2:SetOperation(c85055821.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 判断这张卡是否是从手卡送去墓地
function c85055821.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND)
end
-- 过滤自己墓地中可以作为效果对象的兽族、兽战士族、鸟兽族、昆虫族、植物族怪兽
function c85055821.tdfilter(c,e)
	return c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST+RACE_INSECT+RACE_PLANT) and c:IsCanBeEffectTarget(e)
end
-- ①号效果的发动准备与目标选择
function c85055821.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取自己墓地中除自身以外所有符合种族条件的怪兽
	local g=Duel.GetMatchingGroup(c85055821.tdfilter,tp,LOCATION_GRAVE,0,e:GetHandler(),e)
	if chkc then return false end
	-- 检查墓地中是否存在2张种族互不相同的目标怪兽
	if chk==0 then return g:CheckSubGroup(aux.drccheck,2,2)
		-- 检查自己场上是否有可用的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 提示玩家选择要返回卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家选择2张种族互不相同的目标怪兽
	local sg=g:SelectSubGroup(tp,aux.drccheck,false,2,2)
	-- 将选中的怪兽设为效果处理的对象
	Duel.SetTargetCard(sg)
	-- 设置当前连锁的操作信息为：将选中的怪兽送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,sg,sg:GetCount(),0,0)
	-- 设置当前连锁的操作信息为：将这张卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①号效果的实际处理（将对象怪兽回到卡组，这张卡特殊召唤）
function c85055821.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取仍与该效果关联的对象怪兽
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()<=0 then return end
	-- 将对象怪兽送回持有者卡组并洗牌
	Duel.SendtoDeck(tg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	-- 获取实际被送回卡组的卡片组
	local g=Duel.GetOperatedGroup()
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK+LOCATION_EXTRA) and c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤卡组中除「森之圣兽 熊四手兽」以外的「森之圣兽」或「森之圣灵」怪兽
function c85055821.thfilter(c)
	return c:IsSetCard(0x1167,0x2167) and c:IsType(TYPE_MONSTER) and not c:IsCode(85055821) and c:IsAbleToHand()
end
-- ②号效果的发动准备与目标确认
function c85055821.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可检索的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c85055821.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置当前连锁的操作信息为：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②号效果的实际处理（从卡组检索怪兽加入手卡）
function c85055821.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手卡的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c85055821.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end

--恐楽園の死配人 ＜Arlechino＞
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有「惊乐」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。那之后，可以从自己的卡组·墓地把1张「惊乐家族脸」加入手卡。
-- ②：对方回合，以场上1只其他的效果怪兽为对象才能发动。这张卡回到持有者卡组，从卡组把1只「惊乐园的支配人 ＜∀丑角＞」特殊召唤。那之后，作为对象的怪兽的攻击力变成0。
function c31600845.initial_effect(c)
	-- ①：自己场上有「惊乐」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。那之后，可以从自己的卡组·墓地把1张「惊乐家族脸」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_ACTION+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,31600845)
	e1:SetCondition(c31600845.spcon)
	e1:SetTarget(c31600845.sptg)
	e1:SetOperation(c31600845.spop)
	c:RegisterEffect(e1)
	-- ②：对方回合，以场上1只其他的效果怪兽为对象才能发动。这张卡回到持有者卡组，从卡组把1只「惊乐园的支配人 ＜∀丑角＞」特殊召唤。那之后，作为对象的怪兽的攻击力变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(31600845,1))
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(TIMING_DAMAGE_STEP,0x21e0)
	e2:SetCountLimit(1,31600846)
	e2:SetCondition(c31600845.dhcon)
	e2:SetTarget(c31600845.dhtg)
	e2:SetOperation(c31600845.dhop)
	c:RegisterEffect(e2)
end
-- 检查自己场上是否存在1只以上「惊乐」怪兽（包括里侧表示）
function c31600845.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在1只以上「惊乐」怪兽（包括里侧表示）
	return Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsSetCard),tp,LOCATION_MZONE,0,1,nil,0x15b)
end
-- 设置效果发动时的处理条件
function c31600845.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否存在空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理时的特殊召唤操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 检索满足条件的「惊乐家族脸」卡片过滤器
function c31600845.thfilter(c)
	return c:IsCode(20989253) and c:IsAbleToHand()
end
-- 将此卡从手牌特殊召唤到场上
function c31600845.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将此卡从手牌特殊召唤到场上
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	-- 检索满足条件的「惊乐家族脸」卡片组
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c31600845.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
	-- 若检索到「惊乐家族脸」则询问是否加入手牌
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(31600845,0)) then  --"是否把「惊乐家族脸」加入手卡？"
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local tag=g:Select(tp,1,1,nil)
		-- 将选择的卡加入手牌
		Duel.SendtoHand(tag,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,tag)
	end
end
-- 检查是否为对方回合且未在伤害步骤中
function c31600845.dhcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否为对方回合且未在伤害步骤中
	return Duel.GetTurnPlayer()==1-tp and aux.dscon(e,tp,eg,ep,ev,re,r,rp)
end
-- 筛选场上攻击力大于0的效果怪兽
function c31600845.xfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT) and c:GetAttack()>0
end
-- 筛选可特殊召唤的「惊乐园的支配人 ＜∀丑角＞」卡片过滤器
function c31600845.spfilter(c,e,tp)
	return c:IsCode(94821366) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果发动时的处理条件
function c31600845.dhtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc~=c and c31600845.xfilter(chkc) end
	-- 检查此卡是否能送入墓地
	if chk==0 then return c:IsAbleToDeck() and Duel.GetMZoneCount(tp,c)>0
		-- 检查场上是否存在满足条件的效果怪兽
		and Duel.IsExistingTarget(c31600845.xfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c)
		-- 检查卡组中是否存在满足条件的「惊乐园的支配人 ＜∀丑角＞」
		and Duel.IsExistingMatchingCard(c31600845.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择场上满足条件的效果怪兽作为对象
	Duel.SelectTarget(tp,c31600845.xfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c)
	-- 设置效果处理时的特殊召唤操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	-- 设置效果处理时的送入卡组操作信息
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,0,0)
end
-- 将此卡送入卡组并特殊召唤「惊乐园的支配人 ＜∀丑角＞」
function c31600845.dhop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查此卡是否仍存在于场上且能被送入卡组
	if not c:IsRelateToEffect(e) or Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)==0 or c:GetLocation()~=LOCATION_DECK then return end
	-- 检索满足条件的「惊乐园的支配人 ＜∀丑角＞」卡片组
	local g=Duel.GetMatchingGroup(c31600845.spfilter,tp,LOCATION_DECK,0,nil,e,tp)
	if #g==0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=g:Select(tp,1,1,nil)
	-- 将选择的「惊乐园的支配人 ＜∀丑角＞」特殊召唤到场上
	if Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)==0
		or not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	-- 中断当前效果处理
	Duel.BreakEffect()
	-- 将对象怪兽的攻击力设为0
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetValue(0)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e1)
end

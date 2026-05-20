--破械神ラギア
-- 效果：
-- 包含「破械神」怪兽的怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方主要阶段，以对方场上1只特殊召唤的表侧表示怪兽为对象才能发动。只用那只对方怪兽和自己场上的这张卡为素材把「破械神 罗寂刹」以外的1只暗属性连接怪兽连接召唤。
-- ②：场上的这张卡被战斗·效果破坏的场合，以「破械神 罗寂刹」以外的自己墓地1只恶魔族怪兽为对象才能发动。那只怪兽加入手卡。
function c67680512.initial_effect(c)
	-- 设置连接召唤手续：需要2只怪兽作为素材，且必须包含「破械神」怪兽
	aux.AddLinkProcedure(c,nil,2,2,c67680512.lcheck)
	c:EnableReviveLimit()
	-- ①：对方主要阶段，以对方场上1只特殊召唤的表侧表示怪兽为对象才能发动。只用那只对方怪兽和自己场上的这张卡为素材把「破械神 罗寂刹」以外的1只暗属性连接怪兽连接召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(67680512,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,67680512)
	e1:SetCondition(c67680512.condition)
	e1:SetTarget(c67680512.target)
	e1:SetOperation(c67680512.operation)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡被战斗·效果破坏的场合，以「破械神 罗寂刹」以外的自己墓地1只恶魔族怪兽为对象才能发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(67680512,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,67680513)
	e2:SetCondition(c67680512.thcon)
	e2:SetTarget(c67680512.thtg)
	e2:SetOperation(c67680512.thop)
	c:RegisterEffect(e2)
end
-- 连接素材过滤：判定素材组中是否包含「破械神」怪兽
function c67680512.lcheck(g)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0x1130)
end
-- 效果①的发动条件函数：对方回合的主要阶段
function c67680512.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前是否为对方回合的主要阶段1或主要阶段2
	return Duel.GetTurnPlayer()~=tp and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2)
end
-- 效果①的对象过滤：对方场上表侧表示且是特殊召唤的怪兽，且能与自身作为素材连接召唤出额外卡组的暗属性连接怪兽
function c67680512.tgfilter(c,tp,ec)
	local mg=Group.FromCards(ec,c)
	-- 判定卡片是否为表侧表示、特殊召唤，且额外卡组中存在能以该卡和自身为素材进行连接召唤的怪兽
	return c:IsFaceup() and c:IsSummonType(SUMMON_TYPE_SPECIAL) and Duel.IsExistingMatchingCard(c67680512.lfilter,tp,LOCATION_EXTRA,0,1,nil,mg)
end
-- 额外卡组连接怪兽过滤：暗属性、卡名不是「破械神 罗寂刹」，且能以指定的素材组进行连接召唤
function c67680512.lfilter(c,mg)
	return c:IsAttribute(ATTRIBUTE_DARK) and not c:IsCode(67680512) and c:IsLinkSummonable(mg,nil,2,2)
end
-- 效果①的发动准备：选择对方场上1只表侧表示的特殊召唤怪兽作为对象，并声明特殊召唤的操作信息
function c67680512.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return false end
	-- 判定对方场上是否存在满足条件的表侧表示特殊召唤怪兽
	if chk==0 then return Duel.IsExistingTarget(c67680512.tgfilter,tp,0,LOCATION_MZONE,1,nil,tp,e:GetHandler()) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上1只满足条件的表侧表示特殊召唤怪兽作为效果对象
	Duel.SelectTarget(tp,c67680512.tgfilter,tp,0,LOCATION_MZONE,1,1,nil,tp,e:GetHandler())
	-- 设置效果处理的分类为从额外卡组特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果①的效果处理：使用自身和对象怪兽作为素材，将额外卡组的1只暗属性连接怪兽连接召唤
function c67680512.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果①选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsFaceup() and c:IsRelateToEffect(e) and c:IsControler(tp)
		and tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsControler(1-tp) and not tc:IsImmuneToEffect(e) then
		local mg=Group.FromCards(c,tc)
		-- 提示玩家选择要特殊召唤的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从额外卡组选择1只满足条件的暗属性连接怪兽
		local g=Duel.SelectMatchingCard(tp,c67680512.lfilter,tp,LOCATION_EXTRA,0,1,1,nil,mg)
		local lc=g:GetFirst()
		if lc then
			-- 以自身和对象怪兽为素材，将选择的怪兽进行连接召唤
			Duel.LinkSummon(tp,lc,mg,nil,2,2)
		end
	end
end
-- 效果②的发动条件：场上的这张卡被战斗或效果破坏
function c67680512.thcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0 and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 效果②的对象过滤：自己墓地中卡名不是「破械神 罗寂刹」的恶魔族怪兽，且能加入手卡
function c67680512.thfilter(c)
	return c:IsRace(RACE_FIEND) and not c:IsCode(67680512) and c:IsAbleToHand()
end
-- 效果②的发动准备：选择自己墓地1只满足条件的恶魔族怪兽作为对象，并声明加入手卡的操作信息
function c67680512.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c67680512.thfilter(chkc) end
	-- 判定自己墓地是否存在满足条件的恶魔族怪兽
	if chk==0 then return Duel.IsExistingTarget(c67680512.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只满足条件的恶魔族怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c67680512.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理的分类为将选中的卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果②的效果处理：将选中的墓地怪兽加入手卡
function c67680512.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果②选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽加入持有者的手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end

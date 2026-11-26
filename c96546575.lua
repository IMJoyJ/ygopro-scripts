--大要塞クジラ
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：场上有「海」存在的场合才能发动。这个回合，自己的水属性怪兽可以直接攻击。
-- ②：对方战斗阶段，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽破坏。
-- ③：场上的这张卡被战斗·效果破坏的场合才能发动。从自己的卡组·墓地选1只战士族·水属性怪兽加入手卡或特殊召唤。
function c96546575.initial_effect(c)
	-- 在卡上记述「海」的卡号，供相关效果检索与识别
	aux.AddCodeList(c,22702055)
	-- 这个卡名的①②③的效果1回合各能使用1次。 ①：场上有「海」存在的场合才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(96546575,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,96546575)
	e1:SetCondition(c96546575.dacon)
	e1:SetTarget(c96546575.datg)
	e1:SetOperation(c96546575.daop)
	c:RegisterEffect(e1)
	-- ②：对方战斗阶段，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(96546575,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMING_BATTLE_START)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,96546576)
	e2:SetCondition(c96546575.descon)
	e2:SetTarget(c96546575.destg)
	e2:SetOperation(c96546575.desop)
	c:RegisterEffect(e2)
	-- ③：场上的这张卡被战斗·效果破坏的场合才能发动。从自己的卡组·墓地选1只战士族·水属性怪兽加入手卡或特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(96546575,2))
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON+CATEGORY_GRAVE_SPSUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,96546577)
	e3:SetCondition(c96546575.spcon)
	e3:SetTarget(c96546575.sptg)
	e3:SetOperation(c96546575.spop)
	c:RegisterEffect(e3)
end
-- ①效果的发动条件检查：确认当前回合可进入战斗阶段，且场上存在场地环境「海」
function c96546575.dacon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查回合玩家是否能够进入战斗阶段且当前场上存在「海」
	return Duel.IsAbleToEnterBP() and Duel.IsEnvironment(22702055)
end
-- ①效果的发动检测：确认己方本回合尚未适用过此直接攻击增益标识
function c96546575.datg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：确认己方玩家本回合还没有注册本卡的直接攻击标识
	if chk==0 then return Duel.GetFlagEffect(tp,96546575)==0 end
end
-- ①效果的处理流程：为己方注册持续至回合结束的全局效果，使己方怪兽区的水属性怪兽可以直接攻击并记录本回合已适用标识
function c96546575.daop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合，自己的水属性怪兽可以直接攻击。 ②：对方战斗阶段，以对方场上1只表侧表示怪兽为对象才能发动。那只怪兽破坏。 ③：场上的这张卡被战斗·效果破坏的场合才能发动。从自己的卡组·墓地选1只战士族·水属性怪兽加入手卡或特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c96546575.target)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 为己方注册持续到回合结束时的直接攻击赋能效果
	Duel.RegisterEffect(e1,tp)
	-- 为己方注册持续至回合结束时的标识效果，标记本回合已适用水属性直接攻击
	Duel.RegisterFlagEffect(tp,96546575,RESET_PHASE+PHASE_END,0,1)
end
-- 直接攻击赋能过滤函数：仅对水属性怪兽生效
function c96546575.target(e,c)
	return c:IsAttribute(ATTRIBUTE_WATER)
end
-- ②效果的发动条件检查：确认当前处于对方回合的战斗阶段
function c96546575.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否在战斗阶段开始至结束之间，且当前回合玩家为对方
	return Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE and Duel.GetTurnPlayer()==1-tp
end
-- ②效果的发动检测、取对象及连锁信息设置：确认对方怪兽区存在表侧怪兽，选择1只作为对象并登记破坏操作信息
function c96546575.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 发动条件检查：确认对方怪兽区存在至少1只表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 向己方提示选择要破坏的对方怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让己方从对方怪兽区选择1只表侧表示怪兽作为连锁对象
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
	-- 登记连锁的破坏操作信息，预计破坏所选对方表侧怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ②效果的处理流程：确认对象怪兽仍与效果有联系后将其以效果破坏
function c96546575.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁所指定的对方表侧怪兽对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果将所选对方怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- ③效果的发动条件检查：确认这张卡是从场上被效果或战斗破坏
function c96546575.spcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0 and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 筛选条件：检查卡片是否为战士族·水属性怪兽，且可加入手卡或在有空位时可特殊召唤
function c96546575.spfilter(c,e,tp)
	-- 获取己方主要怪兽区的可用空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return c:IsRace(RACE_WARRIOR) and c:IsAttribute(ATTRIBUTE_WATER) and (c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
-- ③效果的发动检测与连锁信息设置：确认己方卡组·墓地存在满足条件的战士族·水属性怪兽，并登记特殊召唤操作信息
function c96546575.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：确认己方卡组或墓地存在至少1只可加入手卡或可特殊召唤的战士族·水属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c96546575.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 登记连锁的特殊召唤操作信息，预计从己方卡组·墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- ③效果的处理流程：从己方卡组·墓地选1只战士族·水属性怪兽，使其加入手卡并展示或特殊召唤到己方场上
function c96546575.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 向己方提示选择要从卡组·墓地操作的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让己方从卡组·墓地（经王家长眠之谷过滤）选择1只满足条件的战士族·水属性怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c96546575.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 获取当前己方主要怪兽区的可用空位数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local tc=g:GetFirst()
	if tc then
		-- 若该怪兽可加入手卡，且无法特召、无空位或己方选择加入手卡分支，则执行加入手卡
		if tc:IsAbleToHand() and (not tc:IsCanBeSpecialSummoned(e,0,tp,false,false) or ft<=0 or Duel.SelectOption(tp,1190,1152)==0) then
			-- 以效果将所选战士族·水属性怪兽加入己方手卡
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 向对方展示加入手卡的怪兽
			Duel.ConfirmCards(1-tp,tc)
		else
			-- 将所选战士族·水属性怪兽以表侧表示特殊召唤到己方场上
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end

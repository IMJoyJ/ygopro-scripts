--ネメシス・アンブレラ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以「星义伞护兽」以外的除外的1只自己怪兽为对象才能发动。这张卡从手卡特殊召唤，作为对象的怪兽回到卡组。
-- ②：以「星义伞护兽」以外的自己墓地1只「星义」怪兽为对象才能发动。那只怪兽加入手卡。
function c46606977.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：以「星义伞护兽」以外的除外的1只自己怪兽为对象才能发动。这张卡从手卡特殊召唤，作为对象的怪兽回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(46606977,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,46606977)
	e1:SetTarget(c46606977.sptg)
	e1:SetOperation(c46606977.spop)
	c:RegisterEffect(e1)
	-- ②：以「星义伞护兽」以外的自己墓地1只「星义」怪兽为对象才能发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(46606977,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,46606978)
	e2:SetTarget(c46606977.thtg)
	e2:SetOperation(c46606977.thop)
	c:RegisterEffect(e2)
end
-- ①效果的取对象过滤条件：对象必须是自己除外区的表侧表示怪兽，不能是本卡，且可以被效果返回卡组。
function c46606977.tdfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and not c:IsCode(46606977) and c:IsAbleToDeck()
end
-- ①效果的发动条件与目标合法性判定：确认对象为除外区的自己怪兽且满足tdfilter，同时自己场上存在可用怪兽区、手牌本卡可以特殊召唤，并存在符合条件的对象。
function c46606977.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c46606977.tdfilter(chkc) end
	-- 检查自己场上是否有可用的主要怪兽区，用于后续特殊召唤本卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查除外区是否存在至少1只满足tdfilter的自己怪兽可以作为效果对象。
		and Duel.IsExistingTarget(c46606977.tdfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 给玩家显示“请选择要返回卡组的卡”的提示，以便选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从自己除外区选择1只满足tdfilter的怪兽作为效果对象，并自动登记为取对象。
	local g=Duel.SelectTarget(tp,c46606977.tdfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 登记本次连锁包含特殊召唤本卡的操作信息，供后续处理及效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 登记本次连锁包含将选择的对象返回卡组的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- ①效果处理：若本卡仍与效果关联且能特殊召唤成功，则将对象怪兽返回持有者卡组并洗牌。
function c46606977.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得①效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 判断本卡与效果对象仍然与效果关联，且本卡特殊召唤成功；满足条件时继续执行返回卡组的处理。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 and tc:IsRelateToEffect(e) then
		-- 将对象怪兽以效果返回持有者卡组，并触发洗牌。
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- ②效果的取对象过滤条件：对象是自己墓地的「星义」怪兽，不能是本卡，且可以被效果加入手卡。
function c46606977.thfilter(c)
	return c:IsSetCard(0x13d) and c:IsType(TYPE_MONSTER) and not c:IsCode(46606977) and c:IsAbleToHand()
end
-- ②效果的发动条件与目标合法性判定：确认对象为自己墓地中满足thfilter的「星义」怪兽，并存在符合条件的对象。
function c46606977.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c46606977.thfilter(chkc) end
	-- 检查墓地是否存在至少1只满足thfilter的「星义」怪兽可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c46606977.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 给玩家显示“请选择要加入手牌的卡”的提示，以便选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1只满足thfilter的「星义」怪兽作为效果对象，并自动登记为取对象。
	local g=Duel.SelectTarget(tp,c46606977.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 登记本次连锁包含将选择的对象加入手卡的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果处理：若对象怪兽仍与效果关联，则将其加入持有者手卡。
function c46606977.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以效果送回持有者手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end

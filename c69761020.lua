--S－Force ショウダウン
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以从以下效果选择1个发动。
-- ●从手卡把1只「治安战警队」怪兽守备表示特殊召唤。
-- ●以自己墓地1只「治安战警队」怪兽为对象才能发动。那只怪兽加入手卡。
function c69761020.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：可以从以下效果选择1个发动。●从手卡把1只「治安战警队」怪兽守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(69761020,0))  --"从手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,69761020+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c69761020.sptg)
	e1:SetOperation(c69761020.spop)
	c:RegisterEffect(e1)
	-- 这个卡名的卡在1回合只能发动1张。①：可以从以下效果选择1个发动。●以自己墓地1只「治安战警队」怪兽为对象才能发动。那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(69761020,1))  --"从墓地加入手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,69761020+EFFECT_COUNT_CODE_OATH)
	e2:SetTarget(c69761020.thtg)
	e2:SetOperation(c69761020.thop)
	c:RegisterEffect(e2)
end
-- 过滤条件：手卡中可以表侧守备表示特殊召唤的「治安战警队」怪兽
function c69761020.spfilter(c,e,tp)
	return c:IsSetCard(0x156) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 特殊召唤效果的发动准备与合法性检测
function c69761020.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在至少1只满足特殊召唤条件的「治安战警队」怪兽
		and Duel.IsExistingMatchingCard(c69761020.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 向对方玩家提示选择发动了该效果（从手卡特殊召唤）
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置当前连锁的操作信息为：从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 特殊召唤效果的处理逻辑
function c69761020.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手卡选择1只满足条件的「治安战警队」怪兽
	local g=Duel.SelectMatchingCard(tp,c69761020.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧守备表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 过滤条件：墓地中可以加入手卡的「治安战警队」怪兽
function c69761020.thfilter(c)
	return c:IsSetCard(0x156) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 回收效果的发动准备、对象选择与合法性检测
function c69761020.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c69761020.thfilter(chkc) end
	-- 检查自己墓地是否存在至少1只满足条件的「治安战警队」怪兽
	if chk==0 then return Duel.IsExistingTarget(c69761020.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向对方玩家提示选择发动了该效果（从墓地加入手卡）
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家选择自己墓地1只「治安战警队」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c69761020.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置当前连锁的操作信息为：将选中的1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 回收效果的处理逻辑
function c69761020.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end

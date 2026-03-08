--ROMクラウディア
-- 效果：
-- ①：这张卡召唤成功时，以「ROM云雌羊」以外的自己墓地1只电子界族怪兽为对象才能发动。那只怪兽加入手卡。
-- ②：这张卡被战斗·效果破坏的场合才能发动。从卡组把「ROM云雌羊」以外的1只4星以下的电子界族怪兽特殊召唤。
function c44956694.initial_effect(c)
	-- 效果原文：①：这张卡召唤成功时，以「ROM云雌羊」以外的自己墓地1只电子界族怪兽为对象才能发动。那只怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44956694,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c44956694.thtg)
	e1:SetOperation(c44956694.thop)
	c:RegisterEffect(e1)
	-- 效果原文：②：这张卡被战斗·效果破坏的场合才能发动。从卡组把「ROM云雌羊」以外的1只4星以下的电子界族怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(44956694,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(c44956694.spcon)
	e2:SetTarget(c44956694.sptg)
	e2:SetOperation(c44956694.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数：检索满足条件的墓地电子界族怪兽（非ROM云雌羊）
function c44956694.thfilter(c)
	return c:IsRace(RACE_CYBERSE) and c:IsAbleToHand() and not c:IsCode(44956694)
end
-- 效果处理：选择目标怪兽（墓地，电子界族，可加入手牌，非ROM云雌羊）
function c44956694.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c44956694.thfilter(chkc) end
	-- 条件判断：确认场上是否存在满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c44956694.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示信息：提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择目标：从自己墓地选择1只满足条件的怪兽作为目标
	local g=Duel.SelectTarget(tp,c44956694.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：将要加入手牌的怪兽设置为效果处理对象
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理：将目标怪兽加入手牌
function c44956694.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取目标：获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 执行效果：将目标怪兽送入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 条件判断：确认该卡是否因战斗或效果被破坏
function c44956694.spcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- 过滤函数：检索满足条件的卡组电子界族怪兽（非ROM云雌羊，4星以下，可特殊召唤）
function c44956694.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_CYBERSE) and not c:IsCode(44956694) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理：判断是否可以发动特殊召唤效果
function c44956694.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 条件判断：确认自己场上是否有空位可特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 条件判断：确认卡组中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c44956694.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：将要特殊召唤的怪兽设置为效果处理对象
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组特殊召唤满足条件的怪兽
function c44956694.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 条件判断：确认自己场上是否有空位可特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示信息：提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标：从卡组选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c44956694.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 执行效果：将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

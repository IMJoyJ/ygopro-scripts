--臨時ダイヤ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己墓地1只攻击力3000以上的机械族怪兽为对象才能发动。那只机械族怪兽守备表示特殊召唤。
-- ②：盖放的这张卡被送去墓地的场合，以自己墓地1只机械族·10星怪兽为对象才能发动。那只机械族怪兽加入手卡。
function c97520701.initial_effect(c)
	-- ①：以自己墓地1只攻击力3000以上的机械族怪兽为对象才能发动。那只机械族怪兽守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,97520701+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c97520701.target)
	e1:SetOperation(c97520701.operation)
	c:RegisterEffect(e1)
	-- ②：盖放的这张卡被送去墓地的场合，以自己墓地1只机械族·10星怪兽为对象才能发动。那只机械族怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(97520701,0))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c97520701.thcon)
	e2:SetTarget(c97520701.thtg)
	e2:SetOperation(c97520701.thop)
	c:RegisterEffect(e2)
end
-- 过滤自己墓地中攻击力3000以上且可以守备表示特殊召唤的机械族怪兽
function c97520701.filter(c,e,tp)
	return c:IsRace(RACE_MACHINE) and c:IsAttackAbove(3000) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果①的发动准备与目标选择
function c97520701.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c97520701.filter(chkc,e,tp) end
	-- 判定自身场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判定自己墓地是否存在满足条件的怪兽
		and Duel.IsExistingTarget(c97520701.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的机械族怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c97520701.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁信息，包含特殊召唤分类和目标卡片
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的特殊召唤效果处理
function c97520701.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时作为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsRace(RACE_MACHINE) then
		-- 将目标怪兽以表侧守备表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 判定此卡是否在场上盖放的状态下被送去墓地
function c97520701.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) and e:GetHandler():IsPreviousPosition(POS_FACEDOWN)
end
-- 过滤自己墓地中可以加入手牌的10星机械族怪兽
function c97520701.thfilter(c)
	return c:IsLevel(10) and c:IsRace(RACE_MACHINE) and c:IsAbleToHand()
end
-- 效果②的发动准备与目标选择
function c97520701.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c97520701.thfilter(chkc) end
	-- 判定自己墓地是否存在满足条件的10星机械族怪兽
	if chk==0 then return Duel.IsExistingTarget(c97520701.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只满足条件的10星机械族怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c97520701.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁信息，包含加入手牌分类和目标卡片
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果②的加入手牌效果处理
function c97520701.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时作为对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsRace(RACE_MACHINE) then
		-- 将目标怪兽加入持有者的手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,tc)
	end
end

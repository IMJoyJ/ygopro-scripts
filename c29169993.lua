--EMギッタンバッタ
-- 效果：
-- 「娱乐伙伴 跷跷板蝗虫」的③的效果1回合只能使用1次。
-- ①：特殊召唤的这张卡1回合只有1次不会被战斗破坏。
-- ②：对方结束阶段以自己墓地1只3星以下的「娱乐伙伴」怪兽为对象才能发动。这张卡送去墓地，那只怪兽加入手卡。
-- ③：这张卡在墓地存在的状态，「娱乐伙伴」怪兽从手卡送去自己墓地的场合才能发动。这张卡从墓地特殊召唤。
function c29169993.initial_effect(c)
	-- 效果原文内容：①：特殊召唤的这张卡1回合只有1次不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetCountLimit(1)
	e1:SetValue(c29169993.valcon)
	c:RegisterEffect(e1)
	-- 效果原文内容：②：对方结束阶段以自己墓地1只3星以下的「娱乐伙伴」怪兽为对象才能发动。这张卡送去墓地，那只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(29169993,0))
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetCondition(c29169993.thcon)
	e2:SetTarget(c29169993.thtg)
	e2:SetOperation(c29169993.thop)
	c:RegisterEffect(e2)
	-- 效果原文内容：③：这张卡在墓地存在的状态，「娱乐伙伴」怪兽从手卡送去自己墓地的场合才能发动。这张卡从墓地特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(29169993,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,29169993)
	e3:SetCondition(c29169993.spcon)
	e3:SetTarget(c29169993.sptg)
	e3:SetOperation(c29169993.spop)
	c:RegisterEffect(e3)
end
-- 规则层面操作：判断是否为战斗破坏且此卡为特殊召唤 summoned
function c29169993.valcon(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0 and e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 规则层面操作：判断是否为对方结束阶段
function c29169993.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：判断是否为对方结束阶段
	return Duel.GetTurnPlayer()~=tp
end
-- 规则层面操作：筛选墓地里3星以下的娱乐伙伴怪兽
function c29169993.thfilter(c)
	return c:IsSetCard(0x9f) and c:IsLevelBelow(3) and c:IsAbleToHand()
end
-- 规则层面操作：设置效果目标为墓地的娱乐伙伴怪兽
function c29169993.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c29169993.thfilter(chkc) end
	if chk==0 then return e:GetHandler():IsAbleToGrave()
		-- 规则层面操作：确认是否有满足条件的墓地怪兽
		and Duel.IsExistingTarget(c29169993.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 规则层面操作：提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 规则层面操作：选择目标怪兽
	local g=Duel.SelectTarget(tp,c29169993.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 规则层面操作：设置将此卡送去墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler(),1,0,0)
	-- 规则层面操作：设置将目标怪兽加入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 规则层面操作：执行效果处理，将此卡送去墓地并将目标怪兽加入手牌
function c29169993.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：获取效果目标怪兽
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	-- 规则层面操作：判断此卡和目标怪兽是否仍存在于场上或墓地
	if c:IsRelateToEffect(e) and Duel.SendtoGrave(c,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_GRAVE) and tc:IsRelateToEffect(e) then
		-- 规则层面操作：将目标怪兽加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 规则层面操作：筛选从手卡送去墓地的娱乐伙伴怪兽
function c29169993.cfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x9f) and c:IsPreviousLocation(LOCATION_HAND) and c:IsControler(tp)
end
-- 规则层面操作：判断是否有从手卡送去墓地的娱乐伙伴怪兽
function c29169993.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c29169993.cfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- 规则层面操作：设置特殊召唤目标
function c29169993.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：确认是否有足够的召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 规则层面操作：设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 规则层面操作：执行特殊召唤
function c29169993.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 规则层面操作：将此卡特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

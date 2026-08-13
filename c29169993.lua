--EMギッタンバッタ
-- 效果：
-- 「娱乐伙伴 跷跷板蝗虫」的③的效果1回合只能使用1次。
-- ①：特殊召唤的这张卡1回合只有1次不会被战斗破坏。
-- ②：对方结束阶段以自己墓地1只3星以下的「娱乐伙伴」怪兽为对象才能发动。这张卡送去墓地，那只怪兽加入手卡。
-- ③：这张卡在墓地存在的状态，「娱乐伙伴」怪兽从手卡送去自己墓地的场合才能发动。这张卡从墓地特殊召唤。
function c29169993.initial_effect(c)
	-- ①：特殊召唤的这张卡1回合只有1次不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetCountLimit(1)
	e1:SetValue(c29169993.valcon)
	c:RegisterEffect(e1)
	-- ②：对方结束阶段以自己墓地1只3星以下的「娱乐伙伴」怪兽为对象才能发动。这张卡送去墓地，那只怪兽加入手卡。
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
	-- 「娱乐伙伴 跷跷板蝗虫」的③的效果1回合只能使用1次。③：这张卡在墓地存在的状态，「娱乐伙伴」怪兽从手卡送去自己墓地的场合才能发动。这张卡从墓地特殊召唤。
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
-- 该判定函数用于①效果的适用：当这张卡受到战斗破坏时，检查破坏原因是否为战斗以及这张卡是否为特殊召唤，若满足则本回合1次不会被战斗破坏。
function c29169993.valcon(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0 and e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 效果②的发动条件：当前回合玩家不是这张卡的控制者，即只有在对方回合才能发动。
function c29169993.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前回合玩家不是自己，以满足“对方结束阶段”的发动条件。
	return Duel.GetTurnPlayer()~=tp
end
-- 效果②的对象筛选条件：选择自己墓地中等级3以下、卡名属于「娱乐伙伴」且能够加入手卡的怪兽。
function c29169993.thfilter(c)
	return c:IsSetCard(0x9f) and c:IsLevelBelow(3) and c:IsAbleToHand()
end
-- 效果②发动时的目标合法性检查：这张卡自身能够送去墓地，并且自己墓地存在符合条件的「娱乐伙伴」怪兽；若指定对象则还需确认对象位于自己墓地且满足筛选条件。
function c29169993.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c29169993.thfilter(chkc) end
	if chk==0 then return e:GetHandler():IsAbleToGrave()
		-- 检查自己墓地是否存在至少1只满足条件的「娱乐伙伴」怪兽可以作为效果对象。
		and Duel.IsExistingTarget(c29169993.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向操作者显示“请选择要加入手牌的卡”的选择提示，用于选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 由自己从墓地选择1只满足条件的「娱乐伙伴」3星以下怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c29169993.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：本次效果处理包含将效果处理者（这张卡）送去墓地，用于连锁相关判定。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,e:GetHandler(),1,0,0)
	-- 设置操作信息：本次效果处理包含将选择的对象卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果②处理时：若这张卡仍与效果关联，先将其送去墓地；若成功送入墓地且对象仍与效果关联，则将对象加入手卡。
function c29169993.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动效果时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	-- 判断这张卡仍与效果关联、能通过效果送去墓地且实际送入墓地后仍存在于墓地，同时对象仍与效果关联，只有满足这些条件才执行加入手卡。
	if c:IsRelateToEffect(e) and Duel.SendtoGrave(c,REASON_EFFECT)~=0 and c:IsLocation(LOCATION_GRAVE) and tc:IsRelateToEffect(e) then
		-- 将对象怪兽加入其持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- ③的诱发条件筛选：被送去墓地的卡是「娱乐伙伴」怪兽、来自手牌且控制者是自己。
function c29169993.cfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x9f) and c:IsPreviousLocation(LOCATION_HAND) and c:IsControler(tp)
end
-- ③的发动条件：本次送去墓地的怪兽中存在从手牌送入自己墓地的「娱乐伙伴」怪兽，且其中不包括这张卡自身。
function c29169993.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c29169993.cfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- ③发动时的合法性检查：自己主要怪兽区有空位，且这张卡能够被特殊召唤。
function c29169993.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的主要怪兽区，以决定能否特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本次效果处理包含将这张卡特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ③效果处理时：若这张卡仍与效果关联，则将其特殊召唤。
function c29169993.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己的场上（不检查召唤条件，不检查苏生限制）。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

--銀河眼の煌星竜
-- 效果：
-- 包含攻击力2000以上的怪兽的光属性怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡连接召唤成功的场合，以自己墓地1只「光子」怪兽或者「银河」怪兽为对象才能发动。那只怪兽加入手卡。
-- ②：对方主要阶段，把「光子」卡和「银河」卡共2张或者「银河眼光子龙」1只从手卡丢弃，以对方场上1只特殊召唤的怪兽为对象才能发动。那只怪兽破坏。
function c3356494.initial_effect(c)
	-- 为这张卡添加连接召唤手续：需要2只光属性怪兽作为素材，且素材组中至少包含1只攻击力2000以上的怪兽（由lcheck额外检查）。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkAttribute,ATTRIBUTE_LIGHT),2,2,c3356494.lcheck)
	c:EnableReviveLimit()
	-- ①：这张卡连接召唤成功的场合，以自己墓地1只「光子」怪兽或者「银河」怪兽为对象才能发动。那只怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3356494,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,3356494)
	e1:SetCondition(c3356494.thcon)
	e1:SetTarget(c3356494.thtg)
	e1:SetOperation(c3356494.thop)
	c:RegisterEffect(e1)
	-- ②：对方主要阶段，把「光子」卡和「银河」卡共2张或者「银河眼光子龙」1只从手卡丢弃，以对方场上1只特殊召唤的怪兽为对象才能发动。那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(3356494,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,3356495)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCondition(c3356494.descon)
	e2:SetCost(c3356494.descost)
	e2:SetTarget(c3356494.destg)
	e2:SetOperation(c3356494.desop)
	c:RegisterEffect(e2)
end
-- 连接召唤素材追加检查：素材组g中必须存在至少1只攻击力2000以上的怪兽，以符合“包含攻击力2000以上的怪兽”的召唤条件。
function c3356494.lcheck(g,lc)
	return g:IsExists(Card.IsAttackAbove,1,nil,2000)
end
-- ①效果的发动条件：这张卡进行过连接召唤（以连接召唤的方式特殊召唤成功）。
function c3356494.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 墓地的检索/选择条件：是「光子」或「银河」字段的怪兽，且可以被加入手卡。
function c3356494.thfilter(c)
	return c:IsSetCard(0x55,0x7b) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ①效果的发动时处理：选择自己墓地1只符合条件的「光子」或「银河」怪兽作为对象；先检查是否存在对象，再选择目标并登记“加入手卡”的操作信息。
function c3356494.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c3356494.thfilter(chkc) end
	-- 发动合法性检查：自己墓地是否存在至少1只满足thfilter的怪兽，若没有则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c3356494.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 弹出选择提示，让玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己墓地选择1只符合条件的「光子」或「银河」怪兽，并将其登记为本连锁的对象（取对象效果）。
	local g=Duel.SelectTarget(tp,c3356494.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 登记操作信息：本效果将把1张对象卡加入手卡（CATEGORY_TOHAND），供其他卡/效果进行连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ①效果的实际处理：取出连锁对象，若对象仍与此效果关联，则将其加入手卡。
function c3356494.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本连锁的对象卡（即之前选择的那只墓地怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡加入其持有者的手卡（REASON_EFFECT）。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- ②效果的发动条件：当前是对方回合的主要阶段（对方主要阶段1或2），且这张卡的控制者不是当前回合玩家。
function c3356494.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前游戏阶段。
	local ph=Duel.GetCurrentPhase()
	-- 判断：当前回合玩家不是这张卡的控制者，且当前阶段为主要阶段1或主要阶段2——即满足“对方主要阶段”的发动时机。
	return Duel.GetTurnPlayer()~=tp and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
end
-- cost筛选函数：手卡中的「银河眼光子龙」（卡号93717133）且可以丢弃。
function c3356494.cfilter1(c)
	return c:IsCode(93717133) and c:IsDiscardable()
end
-- cost筛选函数：手卡中的「光子」字段卡且可以丢弃，并且手卡中还存在另一张「银河」字段可丢弃卡（用于组成2张的丢弃组合）。
function c3356494.cfilter2(c,tp)
	return c:IsSetCard(0x55) and c:IsDiscardable()
		-- 在cfilter2中追加判断：除了这张「光子」卡之外，手卡中还存在至少1张满足cfilter3的「银河」字段可丢弃卡。
		and Duel.IsExistingMatchingCard(c3356494.cfilter3,tp,LOCATION_HAND,0,1,c)
end
-- cost筛选函数：手卡中的「银河」字段卡且可以丢弃。
function c3356494.cfilter3(c)
	return c:IsSetCard(0x7b) and c:IsDiscardable()
end
-- ②效果的cost处理：选择并丢弃手牌作为发动代价。可丢弃1张「银河眼光子龙」，或丢弃「光子」卡和「银河」卡各1张（共2张）；若两种方式均可行，则让玩家选择；随后把所选卡丢弃（送入墓地）。
function c3356494.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在至少1张「银河眼光子龙」可丢弃（方式一是否可行）。
	local b1=Duel.IsExistingMatchingCard(c3356494.cfilter1,tp,LOCATION_HAND,0,1,nil)
	-- 检查手卡中是否存在至少1张「光子」卡，并且满足还能找到1张「银河」卡的组合（方式二是否可行）。
	local b2=Duel.IsExistingMatchingCard(c3356494.cfilter2,tp,LOCATION_HAND,0,1,nil,tp)
	if chk==0 then return b1 or b2 end
	-- 如果方式一可行，且（方式二不可行或玩家选择是）则执行方式一（丢弃「银河眼光子龙」）；否则执行方式二。该提示为“是否丢弃「银河眼光子龙」？”
	if b1 and (not b2 or Duel.SelectYesNo(tp,aux.Stringid(3356494,2))) then  --"是否丢弃「银河眼光子龙」？"
		-- 从手卡丢弃1张「银河眼光子龙」作为cost（REASON_COST+REASON_DISCARD）。
		Duel.DiscardHand(tp,c3356494.cfilter1,1,1,REASON_COST+REASON_DISCARD,nil)
	else
		-- 弹出选择提示，让玩家选择要丢弃的「光子」卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
		-- 选择1张「光子」字段且可丢弃的手卡，作为cost组合中的一部分。
		local g1=Duel.SelectMatchingCard(tp,c3356494.cfilter2,tp,LOCATION_HAND,0,1,1,nil,tp)
		-- 弹出选择提示，让玩家选择要丢弃的「银河」卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
		-- 在选择「光子」卡之后，选择1张「银河」字段且可丢弃的手卡（排除已选的「光子」卡），作为cost组合的另一部分。
		local g2=Duel.SelectMatchingCard(tp,c3356494.cfilter3,tp,LOCATION_HAND,0,1,1,g1)
		g1:Merge(g2)
		-- 将「光子」卡与「银河」卡合并后一起送入墓地（丢弃），完成cost支付。
		Duel.SendtoGrave(g1,REASON_COST+REASON_DISCARD)
	end
end
-- ②效果的目标选择：选择对方场上1只特殊召唤的怪兽作为对象；先检查是否存在这样的对象，再选择目标并登记“破坏”的操作信息。
function c3356494.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsSummonType(SUMMON_TYPE_SPECIAL) end
	-- 发动合法性检查：对方场上是否存在至少1只特殊召唤的怪兽，若没有则不能发动。
	if chk==0 then return Duel.IsExistingTarget(Card.IsSummonType,tp,0,LOCATION_MZONE,1,nil,SUMMON_TYPE_SPECIAL) end
	-- 弹出选择提示，让玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1只特殊召唤的怪兽，并将其登记为本连锁的对象（取对象效果）。
	local g=Duel.SelectTarget(tp,Card.IsSummonType,tp,0,LOCATION_MZONE,1,1,nil,SUMMON_TYPE_SPECIAL)
	-- 登记操作信息：本效果将破坏1张对象卡（CATEGORY_DESTROY）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ②效果的实际处理：取出连锁对象，若对象仍与此效果关联，则将其破坏。
function c3356494.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本连锁的对象卡（即之前选择的对方场上特殊召唤的怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 破坏该对象怪兽（REASON_EFFECT）。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

--相剣大師－赤霄
-- 效果：
-- 调整＋调整以外的幻龙族怪兽1只以上
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡同调召唤的场合才能发动。从卡组选1张「相剑」卡加入手卡或除外。
-- ②：自己·对方回合，从自己的手卡·墓地把1张「相剑」卡或者1只幻龙族怪兽除外，以场上1只其他的效果怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。
function c69248256.initial_effect(c)
	-- 设置同调召唤手续：调整＋调整以外的幻龙族怪兽1只以上。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsRace,RACE_WYRM),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤的场合才能发动。从卡组选1张「相剑」卡加入手卡或除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(69248256,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,69248256)
	e1:SetCondition(c69248256.thcon)
	e1:SetTarget(c69248256.thtg)
	e1:SetOperation(c69248256.thop)
	c:RegisterEffect(e1)
	-- ②：自己·对方回合，从自己的手卡·墓地把1张「相剑」卡或者1只幻龙族怪兽除外，以场上1只其他的效果怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(69248256,1))
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,69248256)
	e2:SetCost(c69248256.discost)
	e2:SetTarget(c69248256.distg)
	e2:SetOperation(c69248256.disop)
	c:RegisterEffect(e2)
end
-- 判定此卡是否成功进行同调召唤，作为效果①的发动条件。
function c69248256.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤卡组中可以加入手卡或除外的「相剑」卡。
function c69248256.filter(c)
	return c:IsSetCard(0x16b) and (c:IsAbleToHand() or c:IsAbleToRemove())
end
-- 效果①的发动准备，检查卡组中是否存在可检索或除外的「相剑」卡。
function c69248256.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足条件的「相剑」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c69248256.filter,tp,LOCATION_DECK,0,1,nil) end
end
-- 效果①的实际处理：从卡组选择1张「相剑」卡，选择将其加入手卡或除外。
function c69248256.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要操作的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的「相剑」卡。
	local g=Duel.SelectMatchingCard(tp,c69248256.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()<=0 then return end
	local tc=g:GetFirst()
	-- 判断卡片是否能加入手卡，并在可以除外的情况下让玩家选择是加入手卡还是除外。
	if tc:IsAbleToHand() and (not tc:IsAbleToRemove() or Duel.SelectOption(tp,1190,1192)==0) then
		-- 将选中的卡片加入手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡片。
		Duel.ConfirmCards(1-tp,tc)
	else
		-- 将选中的卡片表侧表示除外。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 过滤手卡或墓地中可以作为发动成本除外的「相剑」卡或幻龙族怪兽。
function c69248256.costfilter(c)
	return (c:IsSetCard(0x16b) or (c:IsRace(RACE_WYRM) and c:IsType(TYPE_MONSTER))) and c:IsAbleToRemoveAsCost()
end
-- 效果②的发动成本处理：从手卡或墓地将1张「相剑」卡或1只幻龙族怪兽除外。
function c69248256.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡或墓地中是否存在可作为成本除外的卡片。
	if chk==0 then return Duel.IsExistingMatchingCard(c69248256.costfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从手卡或墓地选择1张满足成本条件的卡片。
	local g=Duel.SelectMatchingCard(tp,c69248256.costfilter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil)
	-- 将选中的卡片表侧表示除外作为发动成本。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果②的发动准备与目标选择，确认场上是否存在可无效的效果怪兽并将其设为对象。
function c69248256.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 判定已选择的对象是否仍是场上的表侧表示效果怪兽。
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and aux.NegateEffectMonsterFilter(chkc) end
	-- 检查场上是否存在除自身以外的其他未被无效的效果怪兽。
	if chk==0 then return Duel.IsExistingTarget(aux.NegateEffectMonsterFilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,e:GetHandler()) end
	-- 提示玩家选择要无效效果的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择场上1只其他的效果怪兽作为效果对象。
	Duel.SelectTarget(tp,aux.NegateEffectMonsterFilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,e:GetHandler())
end
-- 效果②的实际处理：使作为对象的怪兽的效果直到回合结束时无效。
function c69248256.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本次效果所选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 使与该对象怪兽相关的连锁中已发动的效果无效化。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那只怪兽的效果直到回合结束时无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 那只怪兽的效果直到回合结束时无效。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end

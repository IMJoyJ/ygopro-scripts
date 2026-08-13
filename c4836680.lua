--EMオッドアイズ・プリースト
-- 效果：
-- ←1 【灵摆】 1→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：以自己墓地1张「娱乐伙伴」卡或者「异色眼」卡为对象才能发动。那张卡加入手卡。那之后，这张卡破坏。
-- 【怪兽效果】
-- 这个卡名的怪兽效果1回合只能使用1次。
-- ①：灵摆召唤的这张卡在自己主要阶段可以把表示形式的以下效果发动。
-- ●攻击表示：把这张卡除外，以自己墓地1只「娱乐伙伴」怪兽或者「异色眼」怪兽为对象才能发动。那只怪兽特殊召唤。
-- ●守备表示：从卡组选1只「娱乐伙伴」灵摆怪兽或者「异色眼」灵摆怪兽表侧表示加入自己的额外卡组或送去墓地。
function c4836680.initial_effect(c)
	-- 为这张卡启用灵摆怪兽属性，使其可以作为灵摆卡在灵摆区进行灵摆召唤和发动灵摆效果。
	aux.EnablePendulumAttribute(c)
	-- 这个卡名的灵摆效果1回合只能使用1次。①：以自己墓地1张「娱乐伙伴」卡或者「异色眼」卡为对象才能发动。那张卡加入手卡。那之后，这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,4836680)
	e1:SetTarget(c4836680.thtg)
	e1:SetOperation(c4836680.thop)
	c:RegisterEffect(e1)
	-- 这个卡名的怪兽效果1回合只能使用1次。①：灵摆召唤的这张卡在自己主要阶段可以把表示形式的以下效果发动。●攻击表示：把这张卡除外，以自己墓地1只「娱乐伙伴」怪兽或者「异色眼」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,4836681)
	e2:SetCondition(c4836680.spcon)
	e2:SetCost(c4836680.spcost)
	e2:SetTarget(c4836680.sptg)
	e2:SetOperation(c4836680.spop)
	c:RegisterEffect(e2)
	-- 这个卡名的怪兽效果1回合只能使用1次。①：灵摆召唤的这张卡在自己主要阶段可以把表示形式的以下效果发动。●守备表示：从卡组选1只「娱乐伙伴」灵摆怪兽或者「异色眼」灵摆怪兽表侧表示加入自己的额外卡组或送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOEXTRA+CATEGORY_TOGRAVE+CATEGORY_DECKDES)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,4836681)
	e3:SetCondition(c4836680.tgcon)
	e3:SetTarget(c4836680.tgtg)
	e3:SetOperation(c4836680.tgop)
	c:RegisterEffect(e3)
end
-- 过滤条件：选择自己墓地中持有「娱乐伙伴」或「异色眼」字段，且可以被加入手卡的卡片。
function c4836680.thfilter(c)
	return c:IsSetCard(0x9f,0x99) and c:IsAbleToHand()
end
-- 灵摆效果①的发动条件与对象选择：确认自己墓地存在可作为对象的卡片，让玩家选择1张，并设定回手与自身破坏的操作信息。
function c4836680.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c4836680.thfilter(chkc) end
	-- 效果发动合法性判定：检查自己墓地是否存在至少1张满足「娱乐伙伴/异色眼」且可加入手卡的卡片，可作为取对象目标。
	if chk==0 then return Duel.IsExistingTarget(c4836680.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 显示选择提示，提示玩家选择要加入手卡的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1张满足条件的卡片，并将其登记为当前连锁的取对象目标。
	local g=Duel.SelectTarget(tp,c4836680.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设定操作信息：该效果处理时会将所选的卡片加入手卡（回手效果）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 设定操作信息：该效果处理时会破坏这张卡自身（破坏效果）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 效果处理：若对象卡仍与效果关联，且成功加入手牌并位于手牌，则先中断效果连处理，再将这张卡自身破坏。
function c4836680.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	-- 判定对象卡仍未离场/仍与效果关联，并且加入手牌成功且现在位于手牌，满足条件才继续执行自身破坏。
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND) then
		-- 中断当前效果处理的连续性，使“对象加入手牌”和“这张卡破坏”作为不同时处理的事件，以正确对应“那之后”的时点。
		Duel.BreakEffect()
		-- 以效果处理的方式将这张卡自身破坏。
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end
-- 攻击表示效果的发动条件：这张卡是灵摆召唤成功且处于攻击表示。
function c4836680.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM) and e:GetHandler():IsAttackPos()
end
-- 攻击表示效果的代价处理：确认这张卡可以作为代价除外，且除外后自己场上还有可用的怪兽区；然后将其表侧除外作为发动代价。
function c4836680.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 代价合法性检查：这张卡能够作为代价除外，且除外后自己场上仍有至少1个可用怪兽区。
	if chk==0 then return c:IsAbleToRemoveAsCost() and Duel.GetMZoneCount(tp,c)>0 end
	-- 将这张卡自身以表侧表示除外，作为攻击表示效果发动的代价。
	Duel.Remove(c,POS_FACEUP,REASON_COST)
end
-- 特殊召唤对象的过滤条件：墓地中的「娱乐伙伴」或「异色眼」怪兽，且可以被当前效果特殊召唤。
function c4836680.spfilter(c,e,tp)
	return c:IsSetCard(0x9f,0x99) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 攻击表示效果发动时的对象选择：检查墓地存在可特殊召唤的对象，让玩家选择1只，并设定特殊召唤操作信息。
function c4836680.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c4836680.spfilter(chkc,e,tp) end
	-- 效果发动合法性判定：检查自己墓地是否存在至少1只满足条件且可作为对象的「娱乐伙伴/异色眼」怪兽。
	if chk==0 then return Duel.IsExistingTarget(c4836680.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 显示选择提示，提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只满足条件的怪兽，并将其登记为当前连锁的取对象目标。
	local g=Duel.SelectTarget(tp,c4836680.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设定操作信息：该效果处理时会将所选的怪兽特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：若对象怪兽仍与效果关联，则将其以表侧表示特殊召唤。
function c4836680.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到其持有者的场上，不检查召唤条件，也不受苏生限制。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 守备表示效果的发动条件：这张卡是灵摆召唤成功且处于守备表示。
function c4836680.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM) and e:GetHandler():IsDefensePos()
end
-- 从卡组选择卡的过滤条件：持有「娱乐伙伴」或「异色眼」字段的灵摆怪兽，且能够加入额外卡组或能够送去墓地。
function c4836680.tgfilter(c)
	return c:IsSetCard(0x9f,0x99) and c:IsType(TYPE_PENDULUM)
		and (c:IsAbleToExtra() or c:IsAbleToGrave())
end
-- 守备表示效果发动前的目标检查：确认卡组中存在至少1张符合条件的「娱乐伙伴/异色眼」灵摆怪兽。
function c4836680.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性判定：检查卡组中是否存在至少1张满足条件的「娱乐伙伴/异色眼」灵摆怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c4836680.tgfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 效果处理：从卡组选择1张符合条件的灵摆怪兽；如果该卡能送去墓地且（不能加入额外卡组或玩家选择了‘送去墓地’选项），则送去墓地，否则表侧加入额外卡组。
function c4836680.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示，提示玩家选择要操作的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从卡组中选择1张满足条件的灵摆怪兽作为处理对象。
	local g=Duel.SelectMatchingCard(tp,c4836680.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()<=0 then return end
	local tc=g:GetFirst()
	-- 判断所选卡片的处理去向：若其可以送去墓地，且（不能加入额外卡组或玩家选择了送去墓地），则执行送去墓地；否则执行加入额外卡组。
	if tc:IsAbleToGrave() and (not tc:IsAbleToExtra() or Duel.SelectOption(tp,aux.Stringid(4836680,0),1191)==1) then  --"加入额外卡组"
		-- 将所选灵摆怪兽以效果送去墓地。
		Duel.SendtoGrave(tc,REASON_EFFECT)
	else
		-- 将所选灵摆怪兽表侧表示以效果加入其持有者的额外卡组。
		Duel.SendtoExtraP(tc,nil,REASON_EFFECT)
	end
end

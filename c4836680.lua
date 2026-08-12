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
	-- 为卡片添加灵摆怪兽属性，使其可以进行灵摆召唤和灵摆卡的发动
	aux.EnablePendulumAttribute(c)
	-- ①：以自己墓地1张「娱乐伙伴」卡或者「异色眼」卡为对象才能发动。那张卡加入手卡。那之后，这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,4836680)
	e1:SetTarget(c4836680.thtg)
	e1:SetOperation(c4836680.thop)
	c:RegisterEffect(e1)
	-- ●攻击表示：把这张卡除外，以自己墓地1只「娱乐伙伴」怪兽或者「异色眼」怪兽为对象才能发动。那只怪兽特殊召唤。
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
	-- ●守备表示：从卡组选1只「娱乐伙伴」灵摆怪兽或者「异色眼」灵摆怪兽表侧表示加入自己的额外卡组或送去墓地。
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
-- 检索满足条件的卡片组，即自己墓地中的「娱乐伙伴」或「异色眼」卡且可以加入手牌
function c4836680.thfilter(c)
	return c:IsSetCard(0x9f,0x99) and c:IsAbleToHand()
end
-- 设置效果目标为满足条件的墓地中的「娱乐伙伴」或「异色眼」卡，并设定操作信息为将该卡加入手牌和破坏自身
function c4836680.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c4836680.thfilter(chkc) end
	-- 检查是否存在满足条件的墓地卡片作为效果对象
	if chk==0 then return Duel.IsExistingTarget(c4836680.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的墓地中的1张卡作为效果对象
	local g=Duel.SelectTarget(tp,c4836680.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息为将目标卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 设置操作信息为破坏自身
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 处理效果的执行逻辑，将目标卡加入手牌并破坏自身
function c4836680.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中的目标卡
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡是否有效且已成功加入手牌
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND) then
		-- 中断当前效果，使后续处理视为不同时处理
		Duel.BreakEffect()
		-- 以效果原因破坏自身
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end
-- 判断此卡是否为灵摆召唤且处于攻击表示
function c4836680.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM) and e:GetHandler():IsAttackPos()
end
-- 设置效果的费用为将自身除外，并检查场上是否有可用怪兽区
function c4836680.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查是否满足将自身除外作为费用的条件
	if chk==0 then return c:IsAbleToRemoveAsCost() and Duel.GetMZoneCount(tp,c)>0 end
	-- 以除外方式支付效果费用
	Duel.Remove(c,POS_FACEUP,REASON_COST)
end
-- 检索满足条件的卡片组，即自己墓地中的「娱乐伙伴」或「异色眼」怪兽且可以特殊召唤
function c4836680.spfilter(c,e,tp)
	return c:IsSetCard(0x9f,0x99) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果目标为满足条件的墓地中的「娱乐伙伴」或「异色眼」怪兽，并设定操作信息为特殊召唤该怪兽
function c4836680.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c4836680.spfilter(chkc,e,tp) end
	-- 检查是否存在满足条件的墓地卡片作为效果对象
	if chk==0 then return Duel.IsExistingTarget(c4836680.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地中的1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c4836680.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息为特殊召唤目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 处理效果的执行逻辑，将目标怪兽特殊召唤
function c4836680.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以0方式将目标怪兽特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断此卡是否为灵摆召唤且处于守备表示
function c4836680.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM) and e:GetHandler():IsDefensePos()
end
-- 检索满足条件的卡片组，即卡组中「娱乐伙伴」或「异色眼」灵摆怪兽且可以送去额外卡组或墓地
function c4836680.tgfilter(c)
	return c:IsSetCard(0x9f,0x99) and c:IsType(TYPE_PENDULUM)
		and (c:IsAbleToExtra() or c:IsAbleToGrave())
end
-- 设置效果目标为满足条件的卡组中的「娱乐伙伴」或「异色眼」灵摆怪兽，并设定操作信息为将该卡送去额外卡组或墓地
function c4836680.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足条件的卡组卡片作为效果对象
	if chk==0 then return Duel.IsExistingMatchingCard(c4836680.tgfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 处理效果的执行逻辑，从卡组选择1张「娱乐伙伴」或「异色眼」灵摆怪兽并将其送去额外卡组或墓地
function c4836680.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要操作的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 选择满足条件的卡组中的1张卡作为效果对象
	local g=Duel.SelectMatchingCard(tp,c4836680.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()<=0 then return end
	local tc=g:GetFirst()
	-- 判断目标卡是否可以送去墓地，并在可送去额外卡组时由玩家选择操作方式
	if tc:IsAbleToGrave() and (not tc:IsAbleToExtra() or Duel.SelectOption(tp,aux.Stringid(4836680,0),1191)==1) then  --"加入额外卡组"
		-- 以效果原因将目标卡送去墓地
		Duel.SendtoGrave(tc,REASON_EFFECT)
	else
		-- 以效果原因将目标卡表侧表示送去额外卡组
		Duel.SendtoExtraP(tc,nil,REASON_EFFECT)
	end
end

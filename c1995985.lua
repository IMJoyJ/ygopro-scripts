--サイレント・ソードマン LV3
-- 效果：
-- ①：只要这张卡在怪兽区域存在，这张卡为对象的对方的魔法卡的效果无效化。
-- ②：自己准备阶段把场上的这张卡送去墓地才能发动。从手卡·卡组把1只「沉默剑士 LV5」特殊召唤。这个效果在这张卡召唤·特殊召唤·反转的回合不能发动。
function c1995985.initial_effect(c)
	-- ①：只要这张卡在怪兽区域存在，这张卡为对象的对方的魔法卡的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(c1995985.disop)
	c:RegisterEffect(e1)
	-- ②：自己准备阶段把场上的这张卡送去墓地才能发动。从手卡·卡组把1只「沉默剑士 LV5」特殊召唤。这个效果在这张卡召唤·特殊召唤·反转的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1995985,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCondition(c1995985.spcon)
	e2:SetCost(c1995985.spcost)
	e2:SetTarget(c1995985.sptg)
	e2:SetOperation(c1995985.spop)
	c:RegisterEffect(e2)
	-- 这个效果在这张卡召唤·特殊召唤·反转的回合不能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetOperation(c1995985.regop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetCode(EVENT_FLIP)
	c:RegisterEffect(e5)
end
c1995985.lvup={74388798}
-- ①的无效化处理：检查连锁上的效果是否为对方发动的魔法卡、是否取对象、此卡是否仍与其对象关联；若此卡确实被取为对象，则将该魔法卡效果无效化。
function c1995985.disop(e,tp,eg,ep,ev,re,r,rp)
	if not re:GetHandler():IsType(TYPE_SPELL) or rp==tp then return end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return end
	if not e:GetHandler():IsRelateToEffect(re) then return end
	-- 从当前连锁信息中取出该魔法卡选取的对象卡集合，用于判断此卡是否在对象中。
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if g and g:IsContains(e:GetHandler()) then
		-- 将当前连锁（对方魔法卡）的效果无效化，使其效果处理时不再生效。
		Duel.NegateEffect(ev)
	end
end
-- 当此卡通常召唤成功时，给自身登记1个编号为1995985的flag，持续到结束阶段，作为本回合进行过召唤的标记；此flag用于禁止②在该回合发动。
function c1995985.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(1995985,RESET_EVENT+0x1ec0000+RESET_PHASE+PHASE_END,0,1)
end
-- ②的发动条件判定：必须是此卡控制者的准备阶段，且此卡本回合没有进行过召唤·特殊召唤·反转（flag为0）时才允许发动。
function c1995985.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回两个条件同时成立：当前阶段是回合玩家的准备阶段，且此卡没有本回合的召唤/特殊召唤/反转标记（GetFlagEffect返回0）。
	return tp==Duel.GetTurnPlayer() and e:GetHandler():GetFlagEffect(1995985)==0
end
-- ②的代价函数：先检查此卡能否作为代价送去墓地；若能，则把场上的此卡送去墓地作为发动代价。
function c1995985.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将此卡从场上送去墓地，reason设为REASON_COST，表示这是发动②所支付的代价。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 过滤出符合条件的特殊召唤目标：卡号必须是74388798（沉默剑士 LV5），并且该卡可以被效果特殊召唤（不检查召唤条件、不检查苏生限制）。
function c1995985.spfilter(c,e,tp)
	return c:IsCode(74388798) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
-- ②的发动目标判定：若自己场上存在可用的怪兽区域，且手卡·卡组中有符合条件的「沉默剑士 LV5」，则发动有效，并设置特殊召唤的操作信息。
function c1995985.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区域有没有可用空格；这里用 > -1 表示即使当前没有空格也允许发动（因为此卡自身会作为代价送墓，可能腾出格子），实际空格数在处理时再确认。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查自己的手卡·卡组中是否存在至少1只满足spfilter条件的「沉默剑士 LV5」。
		and Duel.IsExistingMatchingCard(c1995985.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 把当前连锁的操作信息更新为：将玩家tp手卡·卡组中的1只怪兽特殊召唤（CATEGORY_SPECIAL_SUMMON），用于后续效果处理和相关卡片的连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- ②的效果处理：确认场上仍有空格后，让发动者从手卡·卡组选择1只「沉默剑士 LV5」，并将其特殊召唤到自己场上。
function c1995985.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认自己主要怪兽区域还有空格；若已无空格则本次效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示选择提示『请选择要特殊召唤的卡』，使接下来的选择操作有相应提示文字。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己的手卡·卡组中选出1只满足spfilter的「沉默剑士 LV5」（可特殊召唤），选择结果保存在g中。
	local g=Duel.SelectMatchingCard(tp,c1995985.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的「沉默剑士 LV5」以表侧表示特殊召唤到自己的怪兽区域；不检查召唤条件、不检查苏生限制。
		Duel.SpecialSummon(tc,0,tp,tp,true,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end

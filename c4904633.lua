--影依の原核
-- 效果：
-- ①：这张卡发动后变成效果怪兽（魔法师族·暗·9星·攻1450/守1950）在怪兽区域特殊召唤。把这个效果特殊召唤的这张卡作为「影依」融合怪兽的融合素材的场合，可以作为那张卡记述的属性的融合素材怪兽的代替。这张卡也当作陷阱卡使用。
-- ②：这张卡被效果送去墓地的场合，以「影依的原核」以外的自己墓地1张「影依」魔法·陷阱卡为对象才能发动。那张卡加入手卡。
function c4904633.initial_effect(c)
	-- ①：这张卡发动后变成效果怪兽（魔法师族·暗·9星·攻1450/守1950）在怪兽区域特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c4904633.target)
	e1:SetOperation(c4904633.activate)
	c:RegisterEffect(e1)
	-- 把这个效果特殊召唤的这张卡作为「影依」融合怪兽的融合素材的场合，可以作为那张卡记述的属性的融合素材怪兽的代替。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetCode(4904633)
	e0:SetRange(LOCATION_MZONE)
	e0:SetCondition(c4904633.condition)
	c:RegisterEffect(e0)
	-- 这张卡也当作陷阱卡使用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(4904633,0))  --"加入手卡"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCondition(c4904633.thcon)
	e2:SetTarget(c4904633.thtg)
	e2:SetOperation(c4904633.thop)
	c:RegisterEffect(e2)
end
-- 判断是否满足特殊召唤条件：检查是否已支付费用、场上是否有空位、是否能特殊召唤该怪兽。
function c4904633.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查玩家场上主怪兽区域是否有空位。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家是否可以特殊召唤指定参数的怪兽。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,4904633,0,TYPES_EFFECT_TRAP_MONSTER,1450,1950,9,RACE_SPELLCASTER,ATTRIBUTE_DARK) end
	-- 设置连锁处理信息，表示将要特殊召唤此卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行发动效果，将此卡变为效果怪兽并特殊召唤到场上。
function c4904633.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 再次确认玩家是否可以特殊召唤该怪兽。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,4904633,0,TYPES_EFFECT_TRAP_MONSTER,1450,1950,9,RACE_SPELLCASTER,ATTRIBUTE_DARK) then return end
	c:AddMonsterAttribute(TYPE_EFFECT+TYPE_TRAP)
	-- 将此卡以特殊召唤方式送入场上。
	Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,true,false,POS_FACEUP)
end
-- 判断此卡是否为特殊召唤（自身效果）入场。
function c4904633.condition(e)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 判断此卡是否因效果而进入墓地。
function c4904633.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- 过滤墓地中符合条件的「影依」魔法·陷阱卡。
function c4904633.thfilter(c)
	return c:IsSetCard(0x9d) and c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsCode(4904633) and c:IsAbleToHand()
end
-- 设置发动效果的目标选择逻辑，选择一张墓地中的「影依」魔法·陷阱卡。
function c4904633.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c4904633.thfilter(chkc) end
	-- 检查场上是否存在满足条件的墓地目标。
	if chk==0 then return Duel.IsExistingTarget(c4904633.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择一张符合条件的墓地卡片作为目标。
	local g=Duel.SelectTarget(tp,c4904633.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁处理信息，表示将要将目标卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 执行效果处理，将选中的卡加入手牌。
function c4904633.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡以效果原因送入手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end

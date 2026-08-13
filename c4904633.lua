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
	-- 把这个效果特殊召唤的这张卡作为「影依」融合怪兽的融合素材的场合，可以作为那张卡记述的属性的融合素材怪兽的代替。这张卡也当作陷阱卡使用。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetCode(4904633)
	e0:SetRange(LOCATION_MZONE)
	e0:SetCondition(c4904633.condition)
	c:RegisterEffect(e0)
	-- ②：这张卡被效果送去墓地的场合，以「影依的原核」以外的自己墓地1张「影依」魔法·陷阱卡为对象才能发动。那张卡加入手卡。
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
-- 发动条件判定：确认该效果没有额外发动代价、自己场上怪兽区域有空位，且自己能够将这张卡以效果怪兽形式特殊召唤。
function c4904633.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查自己场上主要怪兽区域是否存在空格，用于特殊召唤这张卡。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查当前玩家是否可以将这张卡按指定参数（魔法师族·暗·9星·攻1450/守1950）特殊召唤到场上。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,4904633,0,TYPES_EFFECT_TRAP_MONSTER,1450,1950,9,RACE_SPELLCASTER,ATTRIBUTE_DARK) end
	-- 将本次效果处理登记为特殊召唤这张卡的操作信息，供其他卡进行时点响应检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理时：若仍然满足特殊召唤条件，则把这张卡变成效果怪兽并特殊召唤。
function c4904633.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理时再次确认能否特殊召唤，若不能则直接结束处理。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,4904633,0,TYPES_EFFECT_TRAP_MONSTER,1450,1950,9,RACE_SPELLCASTER,ATTRIBUTE_DARK) then return end
	c:AddMonsterAttribute(TYPE_EFFECT+TYPE_TRAP)
	-- 将这张卡以表侧表示特殊召唤到自己场上，召唤类型标记为“自身效果特殊召唤”，且不检查召唤条件。
	Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,true,false,POS_FACEUP)
end
-- e0效果的适用条件：这张卡是通过自身效果特殊召唤成功（召唤类型为特殊召唤+自身效果）时，该效果才适用。
function c4904633.condition(e)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- ②效果的发动条件：这张卡是被卡片效果送进墓地的场合。
function c4904633.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- 检索对象的过滤条件：必须是「影依」卡片、魔法·陷阱卡、不是「影依的原核」本身、且能够加入手卡。
function c4904633.thfilter(c)
	return c:IsSetCard(0x9d) and c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsCode(4904633) and c:IsAbleToHand()
end
-- ②效果的发动处理：从自己墓地选择1张满足条件的「影依」魔法·陷阱卡作为对象。
function c4904633.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c4904633.thfilter(chkc) end
	-- 发动时判断自己墓地是否存在至少1张满足条件的「影依」魔法·陷阱卡，保证可以取对象。
	if chk==0 then return Duel.IsExistingTarget(c4904633.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家弹出“请选择要加入手牌的卡”的对象选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己墓地的符合条件的卡片中选择1张，并将其设为本次效果的对象。
	local g=Duel.SelectTarget(tp,c4904633.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 登记本次操作信息为对象卡片加入手卡，供相关时点或效果检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果处理时，取回对象卡，若仍与本次效果关联则将其加入手卡。
function c4904633.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本次效果选择的对象卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡片以效果原因送回其持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end

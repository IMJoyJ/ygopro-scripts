--RUM－レイド・フォース
-- 效果：
-- ①：以自己场上1只超量怪兽为对象才能发动。比那只怪兽阶级高1阶的1只「急袭猛禽」怪兽在作为对象的自己怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
-- ②：把墓地的这张卡和手卡1张「急袭猛禽」卡除外，以「升阶魔法-急袭之力」以外的自己墓地1张「升阶魔法」魔法卡为对象才能发动。那张卡加入手卡。
function c41201386.initial_effect(c)
	-- ①：以自己场上1只超量怪兽为对象才能发动。比那只怪兽阶级高1阶的1只「急袭猛禽」怪兽在作为对象的自己怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41201386,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c41201386.target)
	e1:SetOperation(c41201386.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡和手卡1张「急袭猛禽」卡除外，以「升阶魔法-急袭之力」以外的自己墓地1张「升阶魔法」魔法卡为对象才能发动。那张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(41201386,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(c41201386.thcost)
	e2:SetTarget(c41201386.thtg)
	e2:SetOperation(c41201386.thop)
	c:RegisterEffect(e2)
end
-- 作为①效果的取对象筛选条件：选择自己场上1只表侧表示的超量怪兽，要求其阶级+1的额外卡组中存在可特殊召唤的「急袭猛禽」超量怪兽，且该怪兽未被“必须作为超量素材”限制。
function c41201386.filter1(c,e,tp)
	local rk=c:GetRank()
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
		-- 检查额外卡组是否存在阶级为对象怪兽阶级+1、满足filter2的「急袭猛禽」超量怪兽。
		and Duel.IsExistingMatchingCard(c41201386.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,rk+1)
		-- 确认对象怪兽没有被“必须作为超量素材”的制约效果（EFFECT_MUST_BE_XMATERIAL）限制。
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
end
-- 筛选额外卡组中符合升阶目标的「急袭猛禽」超量怪兽：阶级等于指定阶级、属于「急袭猛禽」系列、对象怪兽可作为其超量素材、自身满足超量召唤条件且额外怪兽区/场上空格足够。
function c41201386.filter2(c,e,tp,mc,rk)
	return c:IsRank(rk) and c:IsSetCard(0xba) and mc:IsCanBeXyzMaterial(c)
		-- 确认该额外怪兽能够以超量召唤方式被特殊召唤，且把对象怪兽作为素材后仍有足够的可用区域从额外卡组出场。
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- ①效果发动时的目标选择与操作信息登记：确认存在合法对象后，选择自己场上1只超量怪兽为对象，并将连锁操作信息登记为从额外卡组特殊召唤1只怪兽。
function c41201386.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c41201386.filter1(chkc,e,tp) end
	-- 在效果发动检查（chk==0）时，判断自己场上是否存在满足filter1的取对象候选。
	if chk==0 then return Duel.IsExistingTarget(c41201386.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 给玩家显示“请选择效果的对象”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从自己场上选择1只满足filter1的超量怪兽，并登记为本次连锁的对象。
	Duel.SelectTarget(tp,c41201386.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 登记本次连锁将进行“从额外卡组特殊召唤1只怪兽”的操作信息（数量1，位置额外卡组）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ①效果处理流程：确认对象仍然合法后，从额外卡组选择1只符合条件的「急袭猛禽」超量怪兽，将其叠放在对象怪兽上，继承原素材并完成超量召唤。
function c41201386.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 处理时再次检查对象怪兽是否仍未被“必须作为超量素材”限制，若被限制则终止处理。
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
	-- 给玩家显示“请选择要特殊召唤的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只阶级为对象怪兽阶级+1且满足filter2的「急袭猛禽」超量怪兽。
	local g=Duel.SelectMatchingCard(tp,c41201386.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetRank()+1)
	local sc=g:GetFirst()
	if sc then
		local mg=tc:GetOverlayGroup()
		if mg:GetCount()~=0 then
			-- 将对象怪兽原有的超量素材全部转移叠放到新召唤的怪兽下方。
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(tc))
		-- 将对象怪兽自身作为超量素材叠放在新怪兽下方，完成升阶召唤的素材叠加。
		Duel.Overlay(sc,Group.FromCards(tc))
		-- 将选择的「急袭猛禽」怪兽以超量召唤方式表侧攻击表示特殊召唤到己方场上。
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end
-- ②效果代价的筛选函数：选择手卡中1张「急袭猛禽」系列卡，且该卡可被除外作为代价。
function c41201386.cfilter(c)
	return c:IsSetCard(0xba) and c:IsAbleToRemoveAsCost()
end
-- 发动代价检查：确认墓地中的这张卡自身和手卡中的「急袭猛禽」卡都可以作为除外代价。
function c41201386.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost()
		-- 检查手卡中是否存在至少1张可作为代价除外的「急袭猛禽」卡。
		and Duel.IsExistingMatchingCard(c41201386.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 给玩家显示“请选择要除外的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从手卡选择1张「急袭猛禽」卡作为发动代价。
	local g=Duel.SelectMatchingCard(tp,c41201386.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	g:AddCard(e:GetHandler())
	-- 将选出的手卡「急袭猛禽」卡与墓地中的这张卡一起表侧表示除外，作为发动②效果的代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ②效果取对象的筛选：自己墓地中「升阶魔法」魔法卡，并且不是「升阶魔法-急袭之力」自身，且能被加入手卡。
function c41201386.thfilter(c)
	return c:IsSetCard(0x95) and not c:IsCode(41201386) and c:IsAbleToHand()
end
-- ②效果发动时的目标选择与操作信息登记：确认墓地存在合法对象后，选择1张满足条件的「升阶魔法」卡为对象，并登记将其加入手牌的操作信息。
function c41201386.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c41201386.thfilter(chkc) end
	-- 发动合法性检查：确认自己墓地存在除本卡外的「升阶魔法」魔法卡可作为取对象候选。
	if chk==0 then return Duel.IsExistingTarget(c41201386.thfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 给玩家显示“请选择要加入手牌的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1张满足thfilter的「升阶魔法」魔法卡作为效果对象。
	local g=Duel.SelectTarget(tp,c41201386.thfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	-- 登记本次连锁将把对象卡加入手牌的操作信息（1张）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果处理流程：获取对象卡，若其仍与效果关联，则将其加入持有者手牌。
function c41201386.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取②效果取对象的目标卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡送去持有者的手牌（因效果处理）。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end

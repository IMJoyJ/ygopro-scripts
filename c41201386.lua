--RUM－レイド・フォース
-- 效果：
-- ①：以自己场上1只超量怪兽为对象才能发动。比那只怪兽阶级高1阶的1只「急袭猛禽」怪兽在作为对象的自己怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
-- ②：把墓地的这张卡和手卡1张「急袭猛禽」卡除外，以「升阶魔法-急袭之力」以外的自己墓地1张「升阶魔法」魔法卡为对象才能发动。那张卡加入手卡。
function c41201386.initial_effect(c)
	-- 效果原文内容：①：以自己场上1只超量怪兽为对象才能发动。比那只怪兽阶级高1阶的1只「急袭猛禽」怪兽在作为对象的自己怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41201386,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c41201386.target)
	e1:SetOperation(c41201386.activate)
	c:RegisterEffect(e1)
	-- 效果原文内容：②：把墓地的这张卡和手卡1张「急袭猛禽」卡除外，以「升阶魔法-急袭之力」以外的自己墓地1张「升阶魔法」魔法卡为对象才能发动。那张卡加入手卡。
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
-- 规则层面作用：检查目标怪兽是否满足作为超量怪兽的条件，并且能作为超量素材，以及额外卡组是否存在满足条件的「急袭猛禽」怪兽。
function c41201386.filter1(c,e,tp)
	local rk=c:GetRank()
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
		-- 规则层面作用：检查在额外卡组是否存在阶级比目标怪兽高1阶的「急袭猛禽」怪兽。
		and Duel.IsExistingMatchingCard(c41201386.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,rk+1)
		-- 规则层面作用：检查目标怪兽是否必须作为超量素材。
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
end
-- 规则层面作用：检查目标怪兽是否满足作为超量召唤的条件，包括阶级、种族、能否特殊召唤以及是否有足够的召唤位置。
function c41201386.filter2(c,e,tp,mc,rk)
	return c:IsRank(rk) and c:IsSetCard(0xba) and mc:IsCanBeXyzMaterial(c)
		-- 规则层面作用：检查目标怪兽是否可以被特殊召唤，并且在额外卡组有足够召唤位置。
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 规则层面作用：设置效果目标为满足条件的自己场上的超量怪兽。
function c41201386.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c41201386.filter1(chkc,e,tp) end
	-- 规则层面作用：检查是否存在满足条件的自己场上的超量怪兽。
	if chk==0 then return Duel.IsExistingTarget(c41201386.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 规则层面作用：提示玩家选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 规则层面作用：选择满足条件的自己场上的超量怪兽作为效果对象。
	Duel.SelectTarget(tp,c41201386.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 规则层面作用：设置操作信息，表示将要特殊召唤一张来自额外卡组的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 规则层面作用：处理效果的发动，包括检查目标怪兽是否满足条件并选择额外卡组中的怪兽进行特殊召唤。
function c41201386.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取当前连锁的效果对象。
	local tc=Duel.GetFirstTarget()
	-- 规则层面作用：检查目标怪兽是否必须作为超量素材。
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
	-- 规则层面作用：提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面作用：从额外卡组中选择满足条件的「急袭猛禽」怪兽。
	local g=Duel.SelectMatchingCard(tp,c41201386.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetRank()+1)
	local sc=g:GetFirst()
	if sc then
		local mg=tc:GetOverlayGroup()
		if mg:GetCount()~=0 then
			-- 规则层面作用：将目标怪兽的叠放卡叠放到特殊召唤的怪兽上。
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(tc))
		-- 规则层面作用：将目标怪兽叠放到特殊召唤的怪兽上。
		Duel.Overlay(sc,Group.FromCards(tc))
		-- 规则层面作用：将特殊召唤的怪兽以超量召唤方式特殊召唤到场上。
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end
-- 规则层面作用：检查手牌中是否存在「急袭猛禽」卡。
function c41201386.cfilter(c)
	return c:IsSetCard(0xba) and c:IsAbleToRemoveAsCost()
end
-- 规则层面作用：设置效果发动的费用，需要除外墓地的这张卡和手牌中的一张「急袭猛禽」卡。
function c41201386.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost()
		-- 规则层面作用：检查手牌中是否存在「急袭猛禽」卡。
		and Duel.IsExistingMatchingCard(c41201386.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 规则层面作用：提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 规则层面作用：选择手牌中的一张「急袭猛禽」卡。
	local g=Duel.SelectMatchingCard(tp,c41201386.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	g:AddCard(e:GetHandler())
	-- 规则层面作用：将选择的卡除外作为发动费用。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 规则层面作用：检查墓地中是否存在满足条件的「升阶魔法」魔法卡。
function c41201386.thfilter(c)
	return c:IsSetCard(0x95) and not c:IsCode(41201386) and c:IsAbleToHand()
end
-- 规则层面作用：设置效果目标为满足条件的自己墓地的「升阶魔法」魔法卡。
function c41201386.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c41201386.thfilter(chkc) end
	-- 规则层面作用：检查是否存在满足条件的自己墓地的「升阶魔法」魔法卡。
	if chk==0 then return Duel.IsExistingTarget(c41201386.thfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 规则层面作用：提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 规则层面作用：选择满足条件的自己墓地的「升阶魔法」魔法卡。
	local g=Duel.SelectTarget(tp,c41201386.thfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	-- 规则层面作用：设置操作信息，表示将要将一张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 规则层面作用：处理效果的发动，将选择的卡加入手牌。
function c41201386.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取当前连锁的效果对象。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 规则层面作用：将目标卡加入手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end

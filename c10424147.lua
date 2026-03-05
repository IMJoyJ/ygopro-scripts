--超量機艦マグナキャリア
-- 效果：
-- ①：丢弃1张手卡，以自己场上1只「超级量子战士」怪兽为对象才能把这个效果发动。和那只自己怪兽相同属性的1只「超级量子机兽」超量怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
-- ②：把场地区域的这张卡送去墓地，以自己的场上·墓地的「超级量子机兽」超量怪兽3种类各1只为对象才能发动。从额外卡组把1只「超级量子机神王 大磁炎」特殊召唤，那下面把作为对象的怪兽和那些超量素材全部重叠作为超量素材。
function c10424147.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：丢弃1张手卡，以自己场上1只「超级量子战士」怪兽为对象才能把这个效果发动。和那只自己怪兽相同属性的1只「超级量子机兽」超量怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(10424147,0))  --"丢弃手卡"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCost(c10424147.spcost1)
	e2:SetTarget(c10424147.sptg1)
	e2:SetOperation(c10424147.spop1)
	c:RegisterEffect(e2)
	-- ②：把场地区域的这张卡送去墓地，以自己的场上·墓地的「超级量子机兽」超量怪兽3种类各1只为对象才能发动。从额外卡组把1只「超级量子机神王 大磁炎」特殊召唤，那下面把作为对象的怪兽和那些超量素材全部重叠作为超量素材。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(10424147,1))  --"送去墓地"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCost(c10424147.spcost2)
	e3:SetTarget(c10424147.sptg2)
	e3:SetOperation(c10424147.spop2)
	c:RegisterEffect(e3)
end
-- 检索满足条件的1张手卡并丢弃，作为效果发动的代价。
function c10424147.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足丢弃手卡的条件。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 执行丢弃手卡的操作。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 筛选满足条件的「超级量子战士」怪兽，作为效果发动的对象。
function c10424147.spfilter1(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x10dc)
		-- 判断是否满足在额外卡组检索符合条件的「超级量子机兽」超量怪兽的条件。
		and Duel.IsExistingMatchingCard(c10424147.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,c:GetAttribute())
		-- 判断目标怪兽是否满足作为超量素材的条件。
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
end
-- 筛选满足条件的「超级量子机兽」超量怪兽，作为特殊召唤的对象。
function c10424147.spfilter2(c,e,tp,mc,att)
	return c:IsType(TYPE_XYZ) and c:IsSetCard(0x20dc) and c:IsAttribute(att) and mc:IsCanBeXyzMaterial(c)
		-- 判断目标怪兽是否满足特殊召唤的条件。
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 设置效果的目标怪兽并准备特殊召唤。
function c10424147.sptg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c10424147.spfilter1(chkc,e,tp) end
	-- 判断是否满足选择目标怪兽的条件。
	if chk==0 then return Duel.IsExistingTarget(c10424147.spfilter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择目标怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	-- 选择目标怪兽。
	Duel.SelectTarget(tp,c10424147.spfilter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置效果操作信息，表示将特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 处理效果的执行过程，包括特殊召唤和叠放素材。
function c10424147.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽。
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否满足作为超量素材的条件。
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 从额外卡组选择符合条件的「超级量子机兽」超量怪兽。
	local g=Duel.SelectMatchingCard(tp,c10424147.spfilter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetAttribute())
	local sc=g:GetFirst()
	if sc then
		local mg=tc:GetOverlayGroup()
		if mg:GetCount()~=0 then
			-- 将目标怪兽的叠放素材叠放到新召唤的怪兽上。
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(tc))
		-- 将目标怪兽叠放到新召唤的怪兽上。
		Duel.Overlay(sc,Group.FromCards(tc))
		-- 将符合条件的怪兽特殊召唤到场上。
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end
-- 筛选满足条件的「超级量子机兽」超量怪兽，作为效果的目标。
function c10424147.spfilter3(c,e)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsSetCard(0x20dc) and c:IsType(TYPE_XYZ) and c:IsCanBeEffectTarget(e) and c:IsCanOverlay()
end
-- 筛选满足条件的「超级量子机神王 大磁炎」，作为特殊召唤的对象。
function c10424147.spfilter4(c,e,tp)
	-- 判断目标怪兽是否满足特殊召唤的条件。
	return c:IsCode(84025439) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 判断是否满足将场地卡送去墓地的条件。
function c10424147.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将场地卡送去墓地，作为效果发动的代价。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 设置效果的目标怪兽并准备特殊召唤。
function c10424147.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检索满足条件的「超级量子机兽」超量怪兽。
	local g=Duel.GetMatchingGroup(c10424147.spfilter3,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil,e)
	if chk==0 then return g:GetClassCount(Card.GetCode)>=3
		-- 判断是否满足在额外卡组检索符合条件的「超级量子机神王 大磁炎」的条件。
		and Duel.IsExistingMatchingCard(c10424147.spfilter4,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 提示玩家选择要作为超量素材的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	-- 选择3种类不同的「超级量子机兽」超量怪兽作为目标。
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,3,3)
	-- 设置当前效果的目标怪兽。
	Duel.SetTargetCard(sg)
	-- 设置效果操作信息，表示将特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 筛选满足条件的怪兽，作为叠放素材的条件。
function c10424147.mtfilter(c,e)
	return c:IsRelateToEffect(e) and not c:IsImmuneToEffect(e) and c:IsCanOverlay()
end
-- 处理效果的执行过程，包括特殊召唤和叠放素材。
function c10424147.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 从额外卡组选择符合条件的「超级量子机神王 大磁炎」。
	local sg=Duel.SelectMatchingCard(tp,c10424147.spfilter4,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local sc=sg:GetFirst()
	-- 执行特殊召唤操作。
	if sc and Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取当前效果的目标怪兽。
		local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
		local g=tg:Filter(c10424147.mtfilter,nil,e)
		local tc=g:GetFirst()
		while tc do
			local mg=tc:GetOverlayGroup()
			if mg:GetCount()~=0 then
				-- 将目标怪兽的叠放素材叠放到新召唤的怪兽上。
				Duel.Overlay(sc,mg)
			end
			-- 将目标怪兽叠放到新召唤的怪兽上。
			Duel.Overlay(sc,Group.FromCards(tc))
			tc=g:GetNext()
		end
	end
end

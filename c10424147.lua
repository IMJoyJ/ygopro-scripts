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
-- ①效果的发动Cost：丢弃1张手卡
function c10424147.spcost1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在可丢弃的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 从手卡选择并以Cost原因丢弃1张卡
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤场上符合①效果特殊召唤条件的「超级量子战士」怪兽的条件函数
function c10424147.spfilter1(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x10dc)
		-- 检查额外卡组中是否存在满足与该战士相同属性、能进行重叠超量召唤的「超级量子机兽」超量怪兽
		and Duel.IsExistingMatchingCard(c10424147.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,c:GetAttribute())
		-- 检查该战士怪兽是否满足必须作为超量素材的限制规则
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
end
-- 过滤额外卡组中能将选定的战士怪兽作为素材重叠超量召唤的、相同属性的「超级量子机兽」的条件函数
function c10424147.spfilter2(c,e,tp,mc,att)
	return c:IsType(TYPE_XYZ) and c:IsSetCard(0x20dc) and c:IsAttribute(att) and mc:IsCanBeXyzMaterial(c)
		-- 检查该机兽是否可以被特殊召唤，且场上有能够容纳来自额外卡组怪兽出场的区域
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- ①效果的Target函数：以自己场上1只「超级量子战士」怪兽为对象发动
function c10424147.sptg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c10424147.spfilter1(chkc,e,tp) end
	-- 检查场上是否存在可以作为效果对象的「超级量子战士」
	if chk==0 then return Duel.IsExistingTarget(c10424147.spfilter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择效果的指向对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上的1只「超级量子战士」怪兽作为效果的对象
	Duel.SelectTarget(tp,c10424147.spfilter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置特殊召唤的超量怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ①效果的Operation函数：在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤对应的「超级量子机兽」
function c10424147.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为超量素材对象的「超级量子战士」怪兽
	local tc=Duel.GetFirstTarget()
	-- 如果目标怪兽此时不满足必须作为超量素材的限制，则不能继续处理
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只相同属性的「超级量子机兽」
	local g=Duel.SelectMatchingCard(tp,c10424147.spfilter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetAttribute())
	local sc=g:GetFirst()
	if sc then
		local mg=tc:GetOverlayGroup()
		if mg:GetCount()~=0 then
			-- 将原本被叠放的超量素材重叠转移给新特殊召唤的超量怪兽
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(tc))
		-- 把作为对象的怪兽重叠作为新超量怪兽的超量素材
		Duel.Overlay(sc,Group.FromCards(tc))
		-- 将该「超级量子机兽」超量怪兽在作为对象的怪兽上面重叠当作超量召唤特殊召唤
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end
-- 过滤自己场上或墓地中，可以重叠作为大磁炎素材的「超级量子机兽」超量怪兽的条件函数
function c10424147.spfilter3(c,e)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsSetCard(0x20dc) and c:IsType(TYPE_XYZ) and c:IsCanBeEffectTarget(e) and c:IsCanOverlay()
end
-- 检查额外卡组的「超级量子机神王 大磁炎」是否可以被特殊召唤的条件函数
function c10424147.spfilter4(c,e,tp)
	-- 检查该怪兽是大磁炎，且能够从额外卡组特殊召唤到场上
	return c:IsCode(84025439) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- ②效果的Cost：把场地区域的这张卡送去墓地
function c10424147.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将作为场地卡的此卡送去墓地支付发动代价
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- ②效果的Target函数：以自己的场上·墓地的「超级量子机兽」超量怪兽3种类各1只为对象发动
function c10424147.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取场上与墓地中所有符合条件的「超级量子机兽」超量怪兽
	local g=Duel.GetMatchingGroup(c10424147.spfilter3,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil,e)
	if chk==0 then return g:GetClassCount(Card.GetCode)>=3
		-- 检查额外卡组中必须存在可特殊召唤的「超级量子机神王 大磁炎」
		and Duel.IsExistingMatchingCard(c10424147.spfilter4,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 提示选择要作为超量素材的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 从符合条件的卡中选择3种类卡名互不相同的怪兽
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,3,3)
	-- 以这3只怪兽作为效果的对象
	Duel.SetTargetCard(sg)
	-- 设置操作信息为从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 过滤依然在场/墓地、与该连锁相关且未对效果免疫的可重叠素材卡的条件函数
function c10424147.mtfilter(c,e)
	return c:IsRelateToEffect(e) and not c:IsImmuneToEffect(e) and c:IsCanOverlay()
end
-- ②效果的Operation函数：从额外卡组把1只「超级量子机神王 大磁炎」特殊召唤，并将对象怪兽及其超量素材全部重叠作为超量素材
function c10424147.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只「超级量子机神王 大磁炎」
	local sg=Duel.SelectMatchingCard(tp,c10424147.spfilter4,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	local sc=sg:GetFirst()
	-- 若成功将「超级量子机神王 大磁炎」特殊召唤
	if sc and Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取作为发动效果对象的3只「超级量子机兽」
		local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
		local g=tg:Filter(c10424147.mtfilter,nil,e)
		local tc=g:GetFirst()
		while tc do
			local mg=tc:GetOverlayGroup()
			if mg:GetCount()~=0 then
				-- 将被重叠的机兽原本拥有的全部超量素材重叠到大磁炎下面
				Duel.Overlay(sc,mg)
			end
			-- 把该「超级量子机兽」重叠作为大磁炎的超量素材
			Duel.Overlay(sc,Group.FromCards(tc))
			tc=g:GetNext()
		end
	end
end

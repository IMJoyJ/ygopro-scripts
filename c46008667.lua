--聖剣 EX－カリバーン
-- 效果：
-- 「圣骑士」怪兽才能装备。「圣剑 断钢湖中剑」的②的效果1回合只能使用1次。
-- ①：装备怪兽不会成为对方的效果的对象。
-- ②：自己主要阶段把墓地的这张卡除外，以自己场上1只「圣骑士」超量怪兽为对象才能发动。和那只自己怪兽卡名不同的1只「圣骑士」超量怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。这个效果在这张卡送去墓地的回合不能发动。
function c46008667.initial_effect(c)
	-- 「圣骑士」怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c46008667.target)
	e1:SetOperation(c46008667.operation)
	c:RegisterEffect(e1)
	-- 「圣剑 断钢湖中剑」的②的效果1回合只能使用1次。②：自己主要阶段把墓地的这张卡除外，以自己场上1只「圣骑士」超量怪兽为对象才能发动。和那只自己怪兽卡名不同的1只「圣骑士」超量怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(46008667,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,46008667)
	-- 设置②效果的发动条件：这张卡不能在被送去墓地的回合发动（除非是卡从场上返回等情况，以aux.exccon判定）。
	e2:SetCondition(aux.exccon)
	-- 设置②效果的发动代价：把墓地中的这张卡除外作为发动COST。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c46008667.sptg)
	e2:SetOperation(c46008667.spop)
	c:RegisterEffect(e2)
	-- ①：装备怪兽不会成为对方的效果的对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	-- 设置“不能成为效果对象”的判定值，使装备怪兽只不会成为对方（而非自己）的效果的对象。
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	-- 「圣骑士」怪兽才能装备。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_EQUIP_LIMIT)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetValue(c46008667.eqlimit)
	c:RegisterEffect(e4)
end
-- 定义装备限制：只有持有「圣骑士」字段的怪兽才能装备这张卡。
function c46008667.eqlimit(e,c)
	return c:IsSetCard(0x107a)
end
-- 过滤条件：表侧表示且持有「圣骑士」字段的怪兽。
function c46008667.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x107a)
end
-- 装备魔法的发动处理：检查存在合法对象，选择1只表侧「圣骑士」怪兽作为装备对象，并登记装备操作信息。
function c46008667.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c46008667.filter(chkc) end
	-- 发动合法性检查：场上存在至少1只满足条件的表侧「圣骑士」怪兽时才能发动。
	if chk==0 then return Duel.IsExistingTarget(c46008667.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择1只双方场上的表侧「圣骑士」怪兽作为装备对象。
	Duel.SelectTarget(tp,c46008667.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 登记本次操作包含装备效果，目标为这张装备卡，数量1。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理时，若这张卡和目标怪兽均与效果关联且目标表侧，则将这张卡装备给目标怪兽。
function c46008667.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得发动时选择的装备对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张装备卡装备给目标怪兽。
		Duel.Equip(tp,c,tc)
	end
end
-- 定义②效果可选对象：自己场上的表侧「圣骑士」超量怪兽，且额外卡组存在可与其进行超量叠放的不同卡名「圣骑士」超量怪兽，并满足超量素材限制。
function c46008667.filter1(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(0x107a)
		-- 确认额外卡组存在可叠放在该对象上进行超量召唤的、卡名不同的「圣骑士」超量怪兽。
		and Duel.IsExistingMatchingCard(c46008667.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,c:GetCode())
		-- 确认对象怪兽没有被“必须作为超量素材”等效果限制，可以作为超量素材使用。
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
end
-- 定义额外卡组中可被选为特殊召唤对象的怪兽：必须是「圣骑士」超量怪兽、与对象卡名不同、可叠放在对象上，且能将其作为素材进行超量召唤。
function c46008667.filter2(c,e,tp,mc,code)
	return c:IsType(TYPE_XYZ) and c:IsSetCard(0x107a) and not c:IsCode(code) and mc:IsCanBeXyzMaterial(c)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
		-- 确认将对象作为素材后，额外怪兽区/主怪兽区有足够空位可以特殊召唤额外卡组的怪兽。
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- ②效果发动处理：先选择自己场上1只符合条件的「圣骑士」超量怪兽为对象，并登记从额外卡组特殊召唤的操作信息。
function c46008667.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c46008667.filter1(chkc,e,tp) end
	-- 发动合法性检查：自己场上存在至少1只符合条件的「圣骑士」超量怪兽。
	if chk==0 then return Duel.IsExistingTarget(c46008667.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择效果对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只符合条件的「圣骑士」超量怪兽作为效果对象。
	Duel.SelectTarget(tp,c46008667.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 登记②效果将从额外卡组特殊召唤怪兽，预计处理1只。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ②效果处理：验证对象仍合法后，从额外卡组选择1只不同卡名的「圣骑士」超量怪兽，将对象及其素材全部叠放其上，以超量召唤方式特殊召唤。
function c46008667.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果选择的超量对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 处理前再次确认对象仍可作为超量素材，否则终止处理。
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只满足条件的「圣骑士」超量怪兽作为要特殊召唤的怪兽。
	local g=Duel.SelectMatchingCard(tp,c46008667.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetCode())
	local sc=g:GetFirst()
	if sc then
		local mg=tc:GetOverlayGroup()
		if mg:GetCount()~=0 then
			-- 将对象超量怪兽原有的超量素材全部叠放到新召唤的怪兽下方。
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(tc))
		-- 将对象超量怪兽本身叠放到新怪兽下方，作为超量素材。
		Duel.Overlay(sc,Group.FromCards(tc))
		-- 将选择的新超量怪兽以超量召唤形式特殊召唤到己方场上。
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end

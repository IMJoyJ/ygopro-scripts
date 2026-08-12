--法典の大賢者クロウリー
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：从手卡以及自己场上的表侧表示怪兽之中把1只魔法师族怪兽送去墓地才能发动。这张卡从手卡特殊召唤。
-- ②：宣言1个属性才能发动。这张卡直到回合结束时变成宣言的属性。
-- ③：把墓地的这张卡除外，以自己场上1只「大贤者」怪兽为对象才能发动。从自己墓地选1只4星以外的「大贤者」怪兽当作装备卡使用给作为对象的怪兽装备。
function c9505425.initial_effect(c)
	-- ①：从手卡以及自己场上的表侧表示怪兽之中把1只魔法师族怪兽送去墓地才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(9505425,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,9505425)
	e1:SetCost(c9505425.spcost)
	e1:SetTarget(c9505425.sptg)
	e1:SetOperation(c9505425.spop)
	c:RegisterEffect(e1)
	-- ②：宣言1个属性才能发动。这张卡直到回合结束时变成宣言的属性。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(9505425,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,9505426)
	e2:SetTarget(c9505425.atttg)
	e2:SetOperation(c9505425.attop)
	c:RegisterEffect(e2)
	-- ③：把墓地的这张卡除外，以自己场上1只「大贤者」怪兽为对象才能发动。从自己墓地选1只4星以外的「大贤者」怪兽当作装备卡使用给作为对象的怪兽装备。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(9505425,2))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,9505427)
	-- 将墓地的这张卡除外作为发动的代价
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c9505425.eqtg)
	e3:SetOperation(c9505425.eqop)
	c:RegisterEffect(e3)
end
-- 过滤条件：手卡或自己场上表侧表示的魔法师族怪兽，且能送去墓地，并且其离开后能留出可用的怪兽区域
function c9505425.costfilter(c,tp)
	return (c:IsFaceup() or c:IsLocation(LOCATION_HAND)) and c:IsRace(RACE_SPELLCASTER)
		-- 检查卡片是否能作为代价送去墓地，且该卡送去墓地后自己场上是否有可用的怪兽区域
		and c:IsAbleToGraveAsCost() and Duel.GetMZoneCount(tp,c)>0
end
-- 效果①的代价处理：从手卡或自己场上表侧表示的怪兽中，选择1只魔法师族怪兽送去墓地
function c9505425.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡或自己场上是否存在满足送墓条件的魔法师族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c9505425.costfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,e:GetHandler(),tp) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家选择1张手卡或自己场上表侧表示的魔法师族怪兽
	local g=Duel.SelectMatchingCard(tp,c9505425.costfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,e:GetHandler(),tp)
	-- 将选择的怪兽作为代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果①的靶向处理：检查自身是否能特殊召唤，并设置特殊召唤的操作信息
function c9505425.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，包含自身1张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理：将这张卡从手卡特殊召唤
function c9505425.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 效果②的靶向处理：让玩家宣言1个与自身当前不同的属性，并将宣言的属性保存在效果标签中
function c9505425.atttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 提示玩家选择要宣言的属性
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
	-- 让玩家从除自身当前属性以外的所有属性中宣言1个属性
	local aat=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL&~e:GetHandler():GetAttribute())
	e:SetLabel(aat)
end
-- 效果②的效果处理：使这张卡直到回合结束时变成宣言的属性
function c9505425.attop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡直到回合结束时变成宣言的属性。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 过滤条件：自己场上表侧表示的「大贤者」怪兽
function c9505425.tgfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x150)
end
-- 过滤条件：墓地中4星以外的「大贤者」怪兽
function c9505425.eqfilter(c)
	return c:IsSetCard(0x150) and c:IsType(TYPE_MONSTER) and not c:IsLevel(4)
end
-- 效果③的靶向处理：检查魔法与陷阱区域是否有空位，并选择自己场上1只表侧表示的「大贤者」怪兽作为对象
function c9505425.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c9505425.tgfilter(chkc) end
	-- 检查自己场上的魔法与陷阱区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己场上是否存在可以作为效果对象的表侧表示「大贤者」怪兽
		and Duel.IsExistingTarget(c9505425.tgfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查自己墓地是否存在4星以外的「大贤者」怪兽
		and Duel.IsExistingMatchingCard(c9505425.eqfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只表侧表示的「大贤者」怪兽作为效果对象
	Duel.SelectTarget(tp,c9505425.tgfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果③的效果处理：从自己墓地选1只4星以外的「大贤者」怪兽，当作装备卡装备给作为对象的怪兽，并添加装备限制
function c9505425.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍存在于场上且表侧表示，以及魔法与陷阱区域是否有空位
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		-- 提示玩家选择要装备的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		-- 从自己墓地选择1只不受「王家之谷」影响的、4星以外的「大贤者」怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c9505425.eqfilter),tp,LOCATION_GRAVE,0,1,1,nil)
		local ec=g:GetFirst()
		if ec then
			-- 将选择的墓地怪兽作为装备卡装备给对象怪兽，若装备失败则结束处理
			if not Duel.Equip(tp,ec,tc) then return end
			-- 当作装备卡使用给作为对象的怪兽装备。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EQUIP_LIMIT)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetLabelObject(tc)
			e1:SetValue(c9505425.eqlimit)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			ec:RegisterEffect(e1)
		end
	end
end
-- 装备限制：该装备卡只能装备给作为对象的那只怪兽
function c9505425.eqlimit(e,c)
	return c==e:GetLabelObject()
end

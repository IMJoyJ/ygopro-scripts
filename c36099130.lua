--絶火の大賢者ゾロア
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1只「大贤者」怪兽为对象才能发动。从额外卡组把1只「大贤者」怪兽当作装备魔法卡使用给作为对象的怪兽装备。
-- ②：让这张卡把「大贤者」怪兽卡装备的场合才能发动。从自己的手卡·墓地把「绝火之大贤者 琐罗亚」以外的1只魔法师族·4星怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
function c36099130.initial_effect(c)
	-- ①：以自己场上1只「大贤者」怪兽为对象才能发动。从额外卡组把1只「大贤者」怪兽当作装备魔法卡使用给作为对象的怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(36099130,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,36099130)
	e1:SetTarget(c36099130.eqtg)
	e1:SetOperation(c36099130.eqop)
	c:RegisterEffect(e1)
	-- ②：让这张卡把「大贤者」怪兽卡装备的场合才能发动。从自己的手卡·墓地把「绝火之大贤者 琐罗亚」以外的1只魔法师族·4星怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(36099130,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_EQUIP)
	e2:SetCountLimit(1,36099131)
	e2:SetCondition(c36099130.spcon)
	e2:SetTarget(c36099130.sptg)
	e2:SetOperation(c36099130.spop)
	c:RegisterEffect(e2)
end
-- 过滤条件：选择额外卡组中满足「大贤者」字段、未被禁止且不造成场上同名卡重复的怪兽卡（tp用于检查场上唯一性）。
function c36099130.eqfilter(c,tp)
	return c:IsSetCard(0x150) and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- 过滤条件：表侧表示且具有「大贤者」字段的怪兽。
function c36099130.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x150)
end
-- ①效果的发动条件与对象合法性判定：若检查对象则验证对象在我方主要怪兽区且表侧·「大贤者」；发动时需魔陷区有空位、场上存在可对象「大贤者」怪兽且额外卡组有可装备的「大贤者」怪兽。
function c36099130.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c36099130.cfilter(chkc) end
	-- 判定魔陷区是否有空位，用于确保装备卡能放置。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判定场上是否存在表侧表示「大贤者」怪兽可作为装备对象。
		and Duel.IsExistingTarget(c36099130.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 判定额外卡组是否存在可作为装备卡的「大贤者」怪兽。
		and Duel.IsExistingMatchingCard(c36099130.eqfilter,tp,LOCATION_EXTRA,0,1,nil,tp) end
	-- 给出选择提示，提示玩家选择要装备的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择我方场上1只表侧表示「大贤者」怪兽作为①效果的对象。
	Duel.SelectTarget(tp,c36099130.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ①效果处理：取得对象怪兽，确认魔陷区有空位且对象仍合法后，从额外卡组选择1只「大贤者」怪兽作为装备卡装备给对象，并给该装备卡设置仅能装备给该对象怪兽的限制。
function c36099130.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得①效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 若魔陷区没有空位，则无法进行装备，结束处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 给出选择提示，提示玩家选择要装备的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		-- 从额外卡组选择1只满足eqfilter的「大贤者」怪兽作为装备卡。
		local g=Duel.SelectMatchingCard(tp,c36099130.eqfilter,tp,LOCATION_EXTRA,0,1,1,nil,tp)
		local sc=g:GetFirst()
		-- 若未选择到装备卡或装备失败（例如对象不再合法），则结束处理。
		if not sc or not Duel.Equip(tp,sc,tc) then return end
		-- 给作为对象的怪兽装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetLabelObject(tc)
		e1:SetValue(c36099130.eqlimit)
		sc:RegisterEffect(e1)
	end
end
-- 装备限制判定：该装备卡只能装备给效果处理时指定的对象怪兽。
function c36099130.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 过滤条件：原始种类为怪兽且具有「大贤者」字段（用于识别装备的怪兽卡是否为大贤者怪兽卡）。
function c36099130.cfilter2(c)
	return c:GetOriginalType()&TYPE_MONSTER==TYPE_MONSTER and c:IsSetCard(0x150)
end
-- ②效果的发动条件：本卡装备了「大贤者」怪兽卡（eg中存在原始种类为怪兽且「大贤者」字段的卡），即‘让这张卡把「大贤者」怪兽卡装备的场合’。
function c36099130.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c36099130.cfilter2,1,nil)
end
-- 过滤条件：手卡·墓地中满足等级4、魔法师族、不是「绝火之大贤者 琐罗亚」、且可以表侧守备表示特殊召唤的怪兽。
function c36099130.spfilter(c,e,tp)
	return c:IsLevel(4) and c:IsRace(RACE_SPELLCASTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) and not c:IsCode(36099130)
end
-- ②效果的发动检查：主要怪兽区有空位，且手卡·墓地存在满足特殊召唤条件的怪兽。
function c36099130.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定主要怪兽区是否有空位，用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判定手卡·墓地是否存在满足条件的可特殊召唤的怪兽。
		and Duel.IsExistingMatchingCard(c36099130.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：本次效果为特殊召唤，数量为1，来源为手卡·墓地，操作玩家为tp。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- ②效果处理：若主要怪兽区有空位，从手卡·墓地选择1只满足条件的怪兽以表侧守备表示特殊召唤，并赋予其‘效果无效化’状态（怪兽效果无效+效果无效化），最后完成特殊召唤处理。
function c36099130.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判定主要怪兽区是否有空位，没有空位则不能特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 给出选择提示，提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手卡·墓地选择1只满足spfilter且不受王家长眠之谷影响的怪兽（使用NecroValleyFilter过滤）。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c36099130.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
		if #g<1 then return end
		local tc=g:GetFirst()
		-- 以表侧守备表示将选择的怪兽特殊召唤（分解步骤），若成功则继续赋予无效化效果。
		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
			-- 这个效果特殊召唤的怪兽的效果无效化。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 这个效果特殊召唤的怪兽的效果无效化。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
		end
		-- 完成特殊召唤处理（配合SpecialSummonStep完成整个特殊召唤过程）。
		Duel.SpecialSummonComplete()
	end
end

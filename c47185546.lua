--光虫信号
-- 效果：
-- 「光虫信号」在1回合只能发动1张。
-- ①：以自己场上1只昆虫族超量怪兽为对象才能发动。比那只自己怪兽阶级高2阶或者阶级低2阶的1只昆虫族超量怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
function c47185546.initial_effect(c)
	-- 效果原文内容：「光虫信号」在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,47185546+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c47185546.target)
	e1:SetOperation(c47185546.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：检查对象怪兽是否满足作为效果对象的条件，包括是昆虫族超量怪兽且场上正面表示存在，并且额外卡组存在符合条件的超量怪兽可特殊召唤。
function c47185546.filter1(c,e,tp)
	local rk=c:GetRank()
	return c:IsFaceup() and c:IsRace(RACE_INSECT) and c:IsType(TYPE_XYZ)
		-- 效果作用：判断在额外卡组中是否存在阶级比目标怪兽高2阶或低2阶的昆虫族超量怪兽。
		and Duel.IsExistingMatchingCard(c47185546.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,rk)
		-- 效果作用：检查目标怪兽是否必须作为超量素材。
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
end
-- 效果原文内容：①：以自己场上1只昆虫族超量怪兽为对象才能发动。比那只自己怪兽阶级高2阶或者阶级低2阶的1只昆虫族超量怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
function c47185546.filter2(c,e,tp,mc,rk)
	return c:IsType(TYPE_XYZ) and (c:IsRank(rk+2) or c:IsRank(rk-2)) and c:IsRace(RACE_INSECT) and mc:IsCanBeXyzMaterial(c)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
		-- 效果作用：判断目标怪兽所在位置是否能特殊召唤额外卡组中的超量怪兽。
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 效果原文内容：①：以自己场上1只昆虫族超量怪兽为对象才能发动。比那只自己怪兽阶级高2阶或者阶级低2阶的1只昆虫族超量怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
function c47185546.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c47185546.filter1(chkc,e,tp) end
	-- 效果作用：判断是否场上存在满足条件的昆虫族超量怪兽作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c47185546.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 效果作用：提示玩家选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 效果作用：选择满足条件的昆虫族超量怪兽作为效果对象。
	Duel.SelectTarget(tp,c47185546.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 效果作用：设置连锁操作信息，表示将要特殊召唤一张来自额外卡组的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果原文内容：①：以自己场上1只昆虫族超量怪兽为对象才能发动。比那只自己怪兽阶级高2阶或者阶级低2阶的1只昆虫族超量怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
function c47185546.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前连锁中被选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	-- 效果作用：再次检查目标怪兽是否满足成为超量素材的要求。
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
	-- 效果作用：提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 效果作用：从额外卡组中选择一张阶级比目标怪兽高2阶或低2阶的昆虫族超量怪兽。
	local g=Duel.SelectMatchingCard(tp,c47185546.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetRank())
	local sc=g:GetFirst()
	if sc then
		local mg=tc:GetOverlayGroup()
		if mg:GetCount()~=0 then
			-- 效果作用：将目标怪兽上的叠放卡转移到新召唤的怪兽上。
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(tc))
		-- 效果作用：将目标怪兽作为新召唤怪兽的素材进行叠放。
		Duel.Overlay(sc,Group.FromCards(tc))
		-- 效果作用：以超量召唤方式将符合条件的怪兽从额外卡组特殊召唤到场上。
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end

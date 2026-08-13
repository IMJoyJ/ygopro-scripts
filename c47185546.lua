--光虫信号
-- 效果：
-- 「光虫信号」在1回合只能发动1张。
-- ①：以自己场上1只昆虫族超量怪兽为对象才能发动。比那只自己怪兽阶级高2阶或者阶级低2阶的1只昆虫族超量怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
function c47185546.initial_effect(c)
	-- 「光虫信号」在1回合只能发动1张。①：以自己场上1只昆虫族超量怪兽为对象才能发动。比那只自己怪兽阶级高2阶或者阶级低2阶的1只昆虫族超量怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
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
-- 判断某只怪兽是否能作为这张卡的对象：必须是表侧表示、昆虫族、超量怪兽，且额外卡组中存在满足filter2条件的可特殊召唤的昆虫族超量怪兽，并且该怪兽没有受到“必须作为超量素材”的效果制约。
function c47185546.filter1(c,e,tp)
	local rk=c:GetRank()
	return c:IsFaceup() and c:IsRace(RACE_INSECT) and c:IsType(TYPE_XYZ)
		-- 检查额外卡组是否存在至少1只满足filter2条件的昆虫族超量怪兽，以确保后续可以选择并特殊召唤符合条件的怪兽。
		and Duel.IsExistingMatchingCard(c47185546.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,rk)
		-- 检查对象怪兽是否受到EFFECT_MUST_BE_XMATERIAL（必须作为超量素材）的效果影响；如果受到该影响则不能作为这次特殊召唤的超量素材。
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
end
-- 筛选额外卡组中可作为特殊召唤候选的昆虫族超量怪兽：必须是昆虫族超量怪兽，阶级等于对象怪兽阶级+2或-2，对象怪兽能够作为其超量素材，该怪兽可以以超量召唤方式特殊召唤，并且场上有足够的额外卡组怪兽可用区域。
function c47185546.filter2(c,e,tp,mc,rk)
	return c:IsType(TYPE_XYZ) and (c:IsRank(rk+2) or c:IsRank(rk-2)) and c:IsRace(RACE_INSECT) and mc:IsCanBeXyzMaterial(c)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false)
		-- 确认从额外卡组特殊召唤候选怪兽时，在对象怪兽作为素材被叠放离场后，场上是否仍有可用的区域来放置额外卡组怪兽。
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 发动时的目标选择处理：检查是否存在合法对象，提示玩家选择自己场上1只符合条件的昆虫族超量怪兽作为对象，并设置本次操作包含从额外卡组特殊召唤1只怪兽的信息。
function c47185546.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c47185546.filter1(chkc,e,tp) end
	-- 发动条件判定：确认自己场上是否存在至少1只满足filter1条件的昆虫族超量怪兽；若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c47185546.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 向操作玩家发送“请选择效果的对象”的提示，用于选择卡片时的UI提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从自己场上选择1只满足filter1条件的昆虫族超量怪兽作为这张卡的对象，并自动将该卡登记为当前连锁的对象。
	Duel.SelectTarget(tp,c47185546.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置本次连锁的操作信息：包含从额外卡组特殊召唤1只怪兽的分类，数量为1，位置为额外卡组。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：取对象怪兽，确认其仍可作为素材且未被无效/离场/控制权转移；选择额外卡组符合条件的昆虫族超量怪兽；先将对象原有的超量素材转移给新怪兽，再把对象怪兽本身叠放在新怪兽下面，最后以超量召唤形式特殊召唤新怪兽并完成召唤手续。
function c47185546.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的那1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 效果处理时再次确认对象怪兽没有受到“必须作为超量素材”的效果制约，若受到制约则效果不处理。
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
	-- 向操作玩家发送“请选择要特殊召唤的卡”的提示，用于选择额外卡组怪兽时的UI提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组选择1只满足filter2条件的昆虫族超量怪兽（阶级为对象怪兽阶级±2且可作为对象素材），并兼顾特殊召唤可行性与区域空格。
	local g=Duel.SelectMatchingCard(tp,c47185546.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetRank())
	local sc=g:GetFirst()
	if sc then
		local mg=tc:GetOverlayGroup()
		if mg:GetCount()~=0 then
			-- 把对象怪兽原本持有的全部超量素材叠放到新选择怪兽下面，转移素材。
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(tc))
		-- 将作为对象的怪兽本身作为超量素材叠放到新怪兽下面，实现“在作为对象的怪兽上面重叠”的规则行为。
		Duel.Overlay(sc,Group.FromCards(tc))
		-- 将新选择怪兽以超量召唤（SUMMON_TYPE_XYZ）形式正面表示特殊召唤到当前玩家场上，不额外检查召唤条件与苏生限制，使其作为超量召唤处理。
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end

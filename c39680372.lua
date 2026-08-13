--創造の聖刻印
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：以自己场上1只龙族超量怪兽为对象才能发动。原本卡名和那只自己怪兽不同的1只「圣刻」超量怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
-- ②：把墓地的这张卡除外，以自己墓地1只「圣刻」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
function c39680372.initial_effect(c)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。①：以自己场上1只龙族超量怪兽为对象才能发动。原本卡名和那只自己怪兽不同的1只「圣刻」超量怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39680372,0))  --"超量召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,39680372)
	e1:SetTarget(c39680372.target)
	e1:SetOperation(c39680372.operation)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。②：把墓地的这张卡除外，以自己墓地1只「圣刻」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(39680372,1))  --"墓地苏生"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,39680372)
	-- 设置②效果的发动COST：把墓地的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c39680372.sptg)
	e2:SetOperation(c39680372.spop)
	c:RegisterEffect(e2)
end
-- 选择对象的过滤条件：自己场上的表侧表示龙族超量怪兽，且额外卡组存在可将其作为素材的「圣刻」超量怪兽，且该怪兽未受到必须作为超量素材的效果限制。
function c39680372.filter1(c,e,tp)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsType(TYPE_XYZ)
		-- 额外卡组存在至少1只满足filter2条件的「圣刻」超量怪兽。
		and Duel.IsExistingMatchingCard(c39680372.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c)
		-- 验证对象怪兽未受到必须作为超量素材的效果限制，确保其可作为超量素材使用。
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
end
-- 额外卡组候选怪兽的过滤条件：必须是「圣刻」超量怪兽，卡名与作为素材的对象不同，且对象可作为其超量素材；自身能够以超量召唤方式特殊召唤，并从额外卡组特殊召唤时有可用区域。
function c39680372.filter2(c,e,tp,mc)
	return c:IsSetCard(0x69) and c:IsType(TYPE_XYZ) and not c:IsCode(mc:GetOriginalCode()) and mc:IsCanBeXyzMaterial(c)
		-- 该「圣刻」超量怪兽能够以超量召唤的形式特殊召唤，且从额外卡组特殊召唤时有可用区域（对象离场后腾出格子足够）。
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- ①效果发动时的目标处理：选择自己场上1只表侧表示龙族超量怪兽为对象，并设置将从额外卡组特殊召唤1只「圣刻」超量怪兽的操作信息。
function c39680372.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c39680372.filter1(chkc,e,tp) end
	-- 效果发动条件检查：自己场上是否存在1只满足filter1的龙族超量怪兽作为对象。
	if chk==0 then return Duel.IsExistingTarget(c39680372.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 向玩家发送选择效果对象的提示信息（“请选择效果的对象”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家选择1只满足filter1的龙族超量怪兽作为效果对象，并登记为当前连锁的对象。
	Duel.SelectTarget(tp,c39680372.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置操作信息：本连锁将从额外卡组特殊召唤1只怪兽（具体怪兽在处理时选择），分类为特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ①效果处理：若对象仍然有效，选择额外卡组的「圣刻」超量怪兽，把对象原本持有的超量素材和对象自身一并叠放在其下，以超量召唤方式特殊召唤，并完成超量召唤手续。
function c39680372.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 处理时再次确认对象未被必须作为超量素材的效果限制，否则效果不处理。
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
	-- 向玩家发送选择特殊召唤卡片的提示信息（“请选择要特殊召唤的卡”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只满足filter2（以对象为素材、可超量召唤）的「圣刻」超量怪兽。
	local g=Duel.SelectMatchingCard(tp,c39680372.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc)
	local sc=g:GetFirst()
	if sc then
		local mg=tc:GetOverlayGroup()
		if mg:GetCount()~=0 then
			-- 将对象怪兽原本持有的超量素材全部叠放到新选择的「圣刻」超量怪兽下方。
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(tc))
		-- 将作为对象的怪兽自身叠放到新选择的「圣刻」超量怪兽下方作为超量素材。
		Duel.Overlay(sc,Group.FromCards(tc))
		-- 将新选择的「圣刻」超量怪兽以超量召唤的方式正面表示特殊召唤到自己的场上。
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end
-- ②效果选择墓地「圣刻」怪兽的过滤条件：该卡属于「圣刻」且可以表侧守备表示特殊召唤。
function c39680372.spfilter(c,e,tp)
	return c:IsSetCard(0x69) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ②效果发动时的目标处理：确认自己主要怪兽区有空位，且自己墓地存在可特殊召唤的「圣刻」怪兽（排除自身），然后选择其中1只为对象。
function c39680372.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c39680372.spfilter(chkc,e,tp) end
	-- 发动条件检查：自己场上的主要怪兽区存在空位，可以进行特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且自己墓地存在至少1只满足spfilter的「圣刻」怪兽可作为对象（排除自身）。
		and Duel.IsExistingTarget(c39680372.spfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	-- 向玩家发送选择特殊召唤卡片的提示信息（“请选择要特殊召唤的卡”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家选择自己墓地1只满足spfilter的「圣刻」怪兽作为效果对象并登记。
	local g=Duel.SelectTarget(tp,c39680372.spfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler(),e,tp)
	-- 设置操作信息：本连锁将特殊召唤所选择的墓地「圣刻」怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果处理：若对象仍然有效，将其以表侧守备表示特殊召唤到自己的场上。
function c39680372.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧守备表示特殊召唤（普通特殊召唤，不视为超量召唤）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end

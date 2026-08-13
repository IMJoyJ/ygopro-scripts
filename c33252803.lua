--RUM－クイック・カオス
-- 效果：
-- ①：以「混沌No.」怪兽以外的自己场上1只「No.」超量怪兽为对象才能发动。比那只自己怪兽阶级高1阶并持有相同「No.」数字的1只「混沌No.」怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
function c33252803.initial_effect(c)
	-- ①：以「混沌No.」怪兽以外的自己场上1只「No.」超量怪兽为对象才能发动。比那只自己怪兽阶级高1阶并持有相同「No.」数字的1只「混沌No.」怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c33252803.target)
	e1:SetOperation(c33252803.activate)
	c:RegisterEffect(e1)
end
-- 定义选择对象的过滤条件：对象必须是自己场上表侧表示的「No.」超量怪兽，且不是「混沌No.」怪兽，持有No.编号，不受“必须作为超量素材”的限制，并且额外卡组存在满足条件的可特殊召唤的混沌No.怪兽。
function c33252803.filter1(c,e,tp)
	-- 获取该卡的No.编号，用于后续确定混沌No.怪兽需持有的相同No.数字。
	local no=aux.GetXyzNumber(c)
	return c:IsFaceup() and c:IsSetCard(0x48) and not c:IsSetCard(0x1048) and no
		-- 检查该对象是否受到“必须作为超量素材”的效果限制，若受到限制则不能作为本次超量召唤的素材。
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
		-- 检查额外卡组是否存在一只符合filter2条件的混沌No.怪兽：阶级为对象阶级+1、持有相同No.编号、可作为超量素材且能特殊召唤到空位。
		and Duel.IsExistingMatchingCard(c33252803.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,c:GetRank()+1,no)
end
-- 定义额外卡组中可特殊召唤的「混沌No.」怪兽的过滤条件：满足指定阶级、属于混沌No.、与对象持有相同No.编号、能作为超量素材，且能以超量召唤方式特殊召唤并有可用区域。
function c33252803.filter2(c,e,tp,mc,rk,no)
	-- 检查该混沌No.怪兽的阶级是否等于对象阶级+1、是否为「混沌No.」、No.编号是否与对象相同，以及能否以该对象为超量素材。
	return c:IsRank(rk) and c:IsSetCard(0x1048) and aux.GetXyzNumber(c)==no and mc:IsCanBeXyzMaterial(c)
		-- 检查该混沌No.怪兽是否满足超量召唤的特殊召唤条件（不跳过召唤条件、不无视苏生限制），且额外卡组怪兽特殊召唤区域有空位。
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 效果发动的目标处理：选取自己场上1只符合filter1的「No.」超量怪兽作为对象，并设置从额外卡组特殊召唤1只混沌No.怪兽的操作信息。
function c33252803.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c33252803.filter1(chkc,e,tp) end
	-- 在发动合法性检查时，确认自己场上是否存在至少1只符合filter1的怪兽可作为对象。
	if chk==0 then return Duel.IsExistingTarget(c33252803.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp)end
	-- 向操作者发送选择对象的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让操作者从自己场上选择1只符合条件的「No.」超量怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c33252803.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置本次连锁的操作信息：预定从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理时的初始步骤：取得对象卡并验证其是否仍然满足条件、与效果关联且未被免疫等，若不合格则直接终止处理。
function c33252803.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 获取对象怪兽的No.编号，作为检索对应混沌No.怪兽的依据。
	local no=aux.GetXyzNumber(tc)
	-- 再次确认对象是否不受“必须作为超量素材”等限制，若受限制则效果不处理。
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL)
		or tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) or not no then return end
	-- 向操作者发送选择要特殊召唤的混沌No.怪兽的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组中选择1只符合条件的混沌No.怪兽（阶级为对象+1、No.编号相同且可超量召唤）。
	local g=Duel.SelectMatchingCard(tp,c33252803.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetRank()+1,no)
	local sc=g:GetFirst()
	if sc then
		local mg=tc:GetOverlayGroup()
		if mg:GetCount()~=0 then
			-- 将原对象怪兽的叠放卡（超量素材）全部转移给新特殊召唤的混沌No.怪兽。
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(tc))
		-- 将原对象怪兽自身叠放在新特殊召唤的混沌No.怪兽下方，作为超量素材。
		Duel.Overlay(sc,Group.FromCards(tc))
		-- 将选择的混沌No.怪兽以超量召唤方式特殊召唤到场上，表示形式为表侧攻击表示。
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end

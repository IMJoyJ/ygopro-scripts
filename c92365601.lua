--RUM－リミテッド・バリアンズ・フォース
-- 效果：
-- 选择自己场上1只4阶的超量怪兽才能发动。比选择的怪兽阶级高1阶的1只名字带有「混沌No.」的怪兽在选择的自己怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
function c92365601.initial_effect(c)
	-- 选择自己场上1只4阶的超量怪兽才能发动。比选择的怪兽阶级高1阶的1只名字带有「混沌No.」的怪兽在选择的自己怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c92365601.target)
	e1:SetOperation(c92365601.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己场上表侧表示的4阶超量怪兽，且该怪兽存在可重叠召唤的额外卡组怪兽，并满足必须作为超量素材的限制
function c92365601.filter1(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsRank(4)
		-- 检查额外卡组是否存在满足条件的、比该怪兽阶级高1阶的「混沌No.」超量怪兽
		and Duel.IsExistingMatchingCard(c92365601.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,c:GetRank()+1)
		-- 检查该怪兽是否满足必须作为超量素材的规则限制
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
end
-- 过滤额外卡组中阶级比素材高1阶的名字带有「混沌No.」且可以特殊召唤的超量怪兽（包含对特定卡片「CNo.5 亡胧龙 混沌嵌合龙」的特殊兼容判定）
function c92365601.filter2(c,e,tp,mc,rk)
	if c:GetOriginalCode()==6165656 and not mc:IsCode(48995978) then return false end
	return c:IsRank(rk) and c:IsSetCard(0x1048) and mc:IsCanBeXyzMaterial(c)
		-- 检查该怪兽是否可以超量召唤方式特殊召唤，且在将素材怪兽重叠后额外卡组怪兽出场的区域有空位
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 效果发动时的目标选择与操作信息设置阶段
function c92365601.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c92365601.filter1(chkc,e,tp) end
	-- 检查自己场上是否存在可以作为此效果对象的4阶超量怪兽
	if chk==0 then return Duel.IsExistingTarget(c92365601.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只表侧表示的4阶超量怪兽作为效果的对象
	Duel.SelectTarget(tp,c92365601.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息，表示将从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理阶段，将选择的怪兽作为素材，重叠特殊召唤对应的「混沌No.」超量怪兽
function c92365601.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的作为超量素材的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 再次检查该对象怪兽在效果处理时是否仍满足必须作为超量素材的规则限制
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组选择1只比对象怪兽阶级高1阶的名字带有「混沌No.」的超量怪兽
	local g=Duel.SelectMatchingCard(tp,c92365601.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetRank()+1)
	local sc=g:GetFirst()
	if sc then
		local mg=tc:GetOverlayGroup()
		if mg:GetCount()~=0 then
			-- 将作为素材的怪兽原本持有的超量素材也重叠到新召唤的怪兽下面
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(tc))
		-- 将作为素材的对象怪兽重叠到新召唤的怪兽下面
		Duel.Overlay(sc,Group.FromCards(tc))
		-- 将新超量怪兽以超量召唤的方式表侧表示特殊召唤到场上
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end

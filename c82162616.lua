--永遠なる銀河
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有「光子」怪兽或「银河」怪兽存在的场合，以自己场上1只超量怪兽为对象才能发动。比那只自己怪兽阶级高4阶的1只「光子」超量怪兽或「银河」超量怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
function c82162616.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上有「光子」怪兽或「银河」怪兽存在的场合，以自己场上1只超量怪兽为对象才能发动。比那只自己怪兽阶级高4阶的1只「光子」超量怪兽或「银河」超量怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(82162616,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,82162616+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c82162616.condition)
	e1:SetTarget(c82162616.target)
	e1:SetOperation(c82162616.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的「光子」或「银河」怪兽
function c82162616.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x55,0x7b)
end
-- 发动条件：自己场上有「光子」怪兽或「银河」怪兽存在
function c82162616.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「光子」或「银河」怪兽
	return Duel.IsExistingMatchingCard(c82162616.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：自己场上表侧表示、且能作为素材重叠召唤高4阶「光子」或「银河」超量怪兽的超量怪兽
function c82162616.filter1(c,e,tp)
	local rk=c:GetRank()
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
		-- 检查额外卡组是否存在阶级高4阶的「光子」或「银河」超量怪兽
		and Duel.IsExistingMatchingCard(c82162616.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,rk+4)
		-- 检查该怪兽是否满足必须作为超量素材的规则限制
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
end
-- 过滤条件：额外卡组中阶级符合、属于「光子」或「银河」系列、且能以目标怪兽为素材进行超量召唤的怪兽
function c82162616.filter2(c,e,tp,mc,rk)
	return c:IsRank(rk) and c:IsSetCard(0x55,0x7b) and mc:IsCanBeXyzMaterial(c)
		-- 检查该怪兽是否能以超量召唤方式特殊召唤，且额外怪兽区域有可用位置
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 效果发动时的对象选择与特殊召唤准备
function c82162616.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c82162616.filter1(chkc,e,tp) end
	-- 在发动阶段，检查自己场上是否存在符合条件的可作为对象的超量怪兽
	if chk==0 then return Duel.IsExistingTarget(c82162616.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只符合条件的超量怪兽作为对象
	Duel.SelectTarget(tp,c82162616.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置效果处理信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：将高4阶的「光子」或「银河」超量怪兽重叠在对象怪兽上进行超量召唤
function c82162616.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否满足必须作为超量素材的规则限制，若不满足则结束处理
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只比对象怪兽阶级高4阶的「光子」或「银河」超量怪兽
	local g=Duel.SelectMatchingCard(tp,c82162616.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetRank()+4)
	local sc=g:GetFirst()
	if sc then
		local mg=tc:GetOverlayGroup()
		if mg:GetCount()~=0 then
			-- 将对象怪兽原本持有的超量素材转移重叠到新召唤的怪兽下面
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(tc))
		-- 将作为对象的怪兽重叠在新召唤的怪兽下面作为超量素材
		Duel.Overlay(sc,Group.FromCards(tc))
		-- 将新超量怪兽以表侧表示特殊召唤（当作超量召唤）
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end

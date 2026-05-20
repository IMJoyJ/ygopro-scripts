--武神－ヒルコ
-- 效果：
-- ←3 【灵摆】 3→
-- ①：把自己的灵摆区域的这张卡除外，以自己场上1只「武神」超量怪兽为对象才能发动。和那只自己怪兽卡名不同的1只「武神」超量怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
-- 【怪兽描述】
-- 遥远的太古过去赌上主神的宝座跟「武神-日孁」战斗，在死斗之后被封印起来的恶神。为使自己的封印解开而操纵了「日孁」，产生出不祥的「天照」给世界带来了黑暗，但他的野心在「倭」等年轻武神的活跃之下最终破灭了。
function c70026064.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性（注册灵摆召唤及灵摆卡的发动）
	aux.EnablePendulumAttribute(c)
	-- ①：把自己的灵摆区域的这张卡除外，以自己场上1只「武神」超量怪兽为对象才能发动。和那只自己怪兽卡名不同的1只「武神」超量怪兽在作为对象的怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCost(c70026064.spcost)
	e2:SetTarget(c70026064.sptg)
	e2:SetOperation(c70026064.spop)
	c:RegisterEffect(e2)
end
-- 发动代价（Cost）判定与处理函数
function c70026064.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	-- 将灵摆区域的这张卡除外
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
-- 作为对象的「武神」超量怪兽的过滤条件
function c70026064.filter1(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(0x88)
		-- 检查额外卡组是否存在可以重叠特殊召唤的、卡名不同的「武神」超量怪兽
		and Duel.IsExistingMatchingCard(c70026064.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,c:GetCode())
		-- 检查该怪兽是否满足必须作为超量素材的限制
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
end
-- 额外卡组中用于重叠特殊召唤的「武神」超量怪兽的过滤条件
function c70026064.filter2(c,e,tp,mc,code)
	return c:IsType(TYPE_XYZ) and c:IsSetCard(0x88) and not c:IsCode(code) and mc:IsCanBeXyzMaterial(c)
		-- 检查该怪兽是否可以当作超量召唤特殊召唤，并检查额外卡组特殊召唤的可用区域
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 效果发动时的目标选择与操作信息注册函数
function c70026064.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c70026064.filter1(chkc,e,tp) end
	-- 在发动阶段，检查场上是否存在可以作为对象的「武神」超量怪兽
	if chk==0 then return Duel.IsExistingTarget(c70026064.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只「武神」超量怪兽作为效果对象
	Duel.SelectTarget(tp,c70026064.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置特殊召唤的操作信息（从额外卡组特殊召唤1只怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理（Operation）函数
function c70026064.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 再次检查该怪兽是否满足必须作为超量素材的限制
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只卡名不同的「武神」超量怪兽
	local g=Duel.SelectMatchingCard(tp,c70026064.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetCode())
	local sc=g:GetFirst()
	if sc then
		local mg=tc:GetOverlayGroup()
		if mg:GetCount()~=0 then
			-- 将作为对象的怪兽持有的超量素材转移给新特殊召唤的怪兽
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(tc))
		-- 将作为对象的怪兽重叠作为新怪兽的超量素材
		Duel.Overlay(sc,Group.FromCards(tc))
		-- 将新怪兽当作超量召唤从额外卡组特殊召唤
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end

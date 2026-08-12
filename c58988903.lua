--RUM－スキップ・フォース
-- 效果：
-- ①：以自己场上1只「急袭猛禽」超量怪兽为对象才能发动。比那只怪兽阶级高2阶的1只「急袭猛禽」怪兽在作为对象的自己怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
-- ②：从自己墓地把这张卡和1只「急袭猛禽」怪兽除外，以自己墓地1只「急袭猛禽」超量怪兽为对象才能发动。那只怪兽特殊召唤。这个效果在这张卡送去墓地的回合不能发动。
function c58988903.initial_effect(c)
	-- ①：以自己场上1只「急袭猛禽」超量怪兽为对象才能发动。比那只怪兽阶级高2阶的1只「急袭猛禽」怪兽在作为对象的自己怪兽上面重叠当作超量召唤从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(58988903,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c58988903.target)
	e1:SetOperation(c58988903.activate)
	c:RegisterEffect(e1)
	-- ②：从自己墓地把这张卡和1只「急袭猛禽」怪兽除外，以自己墓地1只「急袭猛禽」超量怪兽为对象才能发动。那只怪兽特殊召唤。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(58988903,1))  --"把这张卡和1只「急袭猛禽」怪兽除外"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- 设置这张卡送去墓地的回合不能发动该效果的限制条件
	e2:SetCondition(aux.exccon)
	e2:SetCost(c58988903.spcost)
	e2:SetTarget(c58988903.sptg)
	e2:SetOperation(c58988903.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数：自己场上表侧表示的「急袭猛禽」超量怪兽，且额外卡组存在可重叠召唤的、高2阶的「急袭猛禽」超量怪兽
function c58988903.filter1(c,e,tp)
	local rk=c:GetRank()
	return c:IsFaceup() and c:IsSetCard(0xba) and c:IsType(TYPE_XYZ)
		-- 检查额外卡组是否存在满足条件的、比该怪兽阶级高2阶的「急袭猛禽」怪兽
		and Duel.IsExistingMatchingCard(c58988903.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,c,rk+2)
		-- 检查该怪兽是否满足必须作为超量素材的限制
		and aux.MustMaterialCheck(c,tp,EFFECT_MUST_BE_XMATERIAL)
end
-- 过滤函数：额外卡组中阶级高2阶的「急袭猛禽」超量怪兽，且能以目标怪兽为素材进行超量召唤，并且额外怪兽区域或主要怪兽区域有空位
function c58988903.filter2(c,e,tp,mc,rk)
	return c:IsRank(rk) and c:IsSetCard(0xba) and mc:IsCanBeXyzMaterial(c)
		-- 检查该怪兽是否可以特殊召唤，以及额外卡组特殊召唤的可用怪兽区域是否大于0
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_XYZ,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 效果①的发动准备与目标选择
function c58988903.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c58988903.filter1(chkc,e,tp) end
	-- 步骤1：检查自己场上是否存在满足条件的「急袭猛禽」超量怪兽
	if chk==0 then return Duel.IsExistingTarget(c58988903.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择作为效果对象（重叠素材）的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只满足条件的「急袭猛禽」超量怪兽作为效果对象
	Duel.SelectTarget(tp,c58988903.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置效果处理信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果①的效果处理（重叠超量召唤）
function c58988903.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查作为对象的怪兽是否满足必须作为超量素材的限制，若不满足则结束处理
	if not aux.MustMaterialCheck(tc,tp,EFFECT_MUST_BE_XMATERIAL) then return end
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsControler(1-tp) or tc:IsImmuneToEffect(e) then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只比对象怪兽阶级高2阶的「急袭猛禽」超量怪兽
	local g=Duel.SelectMatchingCard(tp,c58988903.filter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc,tc:GetRank()+2)
	local sc=g:GetFirst()
	if sc then
		local mg=tc:GetOverlayGroup()
		if mg:GetCount()~=0 then
			-- 将作为对象的怪兽持有的超量素材转移给新召唤的超量怪兽
			Duel.Overlay(sc,mg)
		end
		sc:SetMaterial(Group.FromCards(tc))
		-- 将作为对象的怪兽重叠作为新召唤怪兽的超量素材
		Duel.Overlay(sc,Group.FromCards(tc))
		-- 将新超量怪兽当作超量召唤特殊召唤到场上
		Duel.SpecialSummon(sc,SUMMON_TYPE_XYZ,tp,tp,false,false,POS_FACEUP)
		sc:CompleteProcedure()
	end
end
-- 过滤函数：墓地中用于作为除外Cost的「急袭猛禽」怪兽，且墓地中存在其他可特殊召唤的「急袭猛禽」超量怪兽
function c58988903.cfilter(c,e,tp)
	return c:IsSetCard(0xba) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
		-- 检查墓地中是否存在除该卡以外的、可作为特殊召唤对象的「急袭猛禽」超量怪兽
		and Duel.IsExistingTarget(c58988903.spfilter,tp,LOCATION_GRAVE,0,1,c,e,tp)
end
-- 过滤函数：墓地中可以特殊召唤的「急袭猛禽」超量怪兽
function c58988903.spfilter(c,e,tp)
	return c:IsSetCard(0xba) and c:IsType(TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动代价（Cost）处理
function c58988903.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost()
		-- 检查墓地中是否存在可作为除外Cost的「急袭猛禽」怪兽
		and Duel.IsExistingMatchingCard(c58988903.cfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从墓地选择1只「急袭猛禽」怪兽
	local g=Duel.SelectMatchingCard(tp,c58988903.cfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	g:AddCard(e:GetHandler())
	-- 将这张卡和选择的「急袭猛禽」怪兽除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果②的发动准备与目标选择
function c58988903.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c58988903.spfilter(chkc,e,tp) end
	-- 步骤1：检查自己场上的主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只「急袭猛禽」超量怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c58988903.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息：特殊召唤选择的墓地怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②的效果处理（特殊召唤墓地怪兽）
function c58988903.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的墓地怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽在自己场上特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

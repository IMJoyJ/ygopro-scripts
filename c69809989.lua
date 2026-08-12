--ゴーストリック・ショット
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从自己的手卡·墓地选1只「鬼计」怪兽特殊召唤。那之后，可以选自己场上1只里侧表示的「鬼计」怪兽变成表侧攻击表示。
-- ②：把墓地的这张卡除外，以自己场上1只「鬼计」超量怪兽为对象才能发动。从自己墓地选1张「鬼计」卡在作为对象的怪兽下面重叠作为超量素材。
function c69809989.initial_effect(c)
	-- ①：从自己的手卡·墓地选1只「鬼计」怪兽特殊召唤。那之后，可以选自己场上1只里侧表示的「鬼计」怪兽变成表侧攻击表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(69809989,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,69809989)
	e1:SetTarget(c69809989.sptg)
	e1:SetOperation(c69809989.spop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己场上1只「鬼计」超量怪兽为对象才能发动。从自己墓地选1张「鬼计」卡在作为对象的怪兽下面重叠作为超量素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(69809989,1))  --"补充超量素材"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,69809990)
	-- 把墓地的这张卡除外作为发动成本
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c69809989.mattg)
	e2:SetOperation(c69809989.matop)
	c:RegisterEffect(e2)
end
-- 过滤条件：手卡·墓地中可以特殊召唤的「鬼计」怪兽
function c69809989.spfilter(c,e,tp)
	return c:IsSetCard(0x8d) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①号效果的发动准备（检查怪兽区域空位及手卡·墓地是否存在可特召的「鬼计」怪兽）
function c69809989.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的手卡或墓地是否存在满足特召条件的「鬼计」怪兽
		and Duel.IsExistingMatchingCard(c69809989.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息（从手卡·墓地特召1只怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 过滤条件：自己场上里侧表示且可以改变表示形式的「鬼计」怪兽
function c69809989.cfilter(c)
	return c:IsSetCard(0x8d) and c:IsFacedown() and c:IsCanChangePosition()
end
-- ①号效果的处理（特殊召唤，并可选里侧「鬼计」怪兽变成表侧攻击表示）
function c69809989.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若没有空余的怪兽区域则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·墓地选择1只满足条件的「鬼计」怪兽（受王家长眠之谷影响）
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c69809989.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 若成功将选中的怪兽以表侧表示特殊召唤
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0
		-- 且自己场上存在里侧表示的「鬼计」怪兽
		and Duel.IsExistingMatchingCard(c69809989.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 且玩家选择进行后续的表示形式变更处理
		and Duel.SelectYesNo(tp,aux.Stringid(69809989,2)) then  --"是否选怪兽变成表侧攻击表示？"
		-- 中断当前效果处理，使后续的表示形式变更不与特殊召唤同时处理
		Duel.BreakEffect()
		-- 提示玩家选择要改变表示形式的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
		-- 选择自己场上1只里侧表示的「鬼计」怪兽
		local sg=Duel.SelectMatchingCard(tp,c69809989.cfilter,tp,LOCATION_MZONE,0,1,1,nil)
		-- 将选中的怪兽变成表侧攻击表示
		Duel.ChangePosition(sg,POS_FACEUP_ATTACK)
	end
end
-- 过滤条件：自己场上表侧表示的「鬼计」超量怪兽
function c69809989.xyzfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(0x8d)
end
-- 过滤条件：墓地中可以作为超量素材的「鬼计」卡
function c69809989.mfilter(c)
	return c:IsSetCard(0x8d) and c:IsCanOverlay()
end
-- ②号效果的发动准备（选择自己场上1只「鬼计」超量怪兽为对象，并检查墓地是否有可作为素材的「鬼计」卡）
function c69809989.mattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsPosition(LOCATION_MZONE) and c69809989.xyzfilter(chkc) end
	-- 检查自己场上是否存在可作为对象的「鬼计」超量怪兽
	if chk==0 then return Duel.IsExistingTarget(c69809989.xyzfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 且自己墓地存在可作为超量素材的「鬼计」卡（不含此卡自身）
		and Duel.IsExistingMatchingCard(c69809989.mfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 提示玩家选择表侧表示的卡（作为效果对象）
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只「鬼计」超量怪兽作为效果对象
	Duel.SelectTarget(tp,c69809989.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ②号效果的处理（将墓地的「鬼计」卡重叠在对象怪兽下作为超量素材）
function c69809989.matop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的超量怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		-- 提示玩家选择要作为超量素材的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
		-- 从自己墓地选择1张「鬼计」卡（受王家长眠之谷影响）
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c69809989.mfilter),tp,LOCATION_GRAVE,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的卡重叠在对象怪兽下面作为超量素材
			Duel.Overlay(tc,g)
		end
	end
end

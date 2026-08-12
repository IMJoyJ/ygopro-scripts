--グローリアス・ナンバーズ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上没有怪兽存在的场合，以自己墓地1只「No.」超量怪兽为对象才能发动。那只怪兽特殊召唤。那之后，自己从卡组抽1张。
-- ②：把墓地的这张卡除外，以自己场上1只「No.」超量怪兽为对象才能发动。把1张手卡在那只怪兽下面重叠作为超量素材。
function c60944809.initial_effect(c)
	-- ①：自己场上没有怪兽存在的场合，以自己墓地1只「No.」超量怪兽为对象才能发动。那只怪兽特殊召唤。那之后，自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,60944809)
	e1:SetCondition(c60944809.condition)
	e1:SetTarget(c60944809.target)
	e1:SetOperation(c60944809.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己场上1只「No.」超量怪兽为对象才能发动。把1张手卡在那只怪兽下面重叠作为超量素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(60944809,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,60944810)
	-- 把墓地的这张卡除外作为发动成本
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c60944809.mattg)
	e2:SetOperation(c60944809.matop)
	c:RegisterEffect(e2)
end
-- ①号效果的发动条件：自己场上没有怪兽存在
function c60944809.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上的怪兽数量是否为0
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 过滤函数：自己墓地的「No.」超量怪兽且可以特殊召唤
function c60944809.filter(c,e,tp)
	return c:IsSetCard(0x48) and c:IsType(TYPE_XYZ) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①号效果的发动准备（检查及选择对象）
function c60944809.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c60944809.filter(chkc,e,tp) end
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在满足条件的「No.」超量怪兽
		and Duel.IsExistingTarget(c60944809.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 检查自己是否可以抽卡
		and Duel.IsPlayerCanDraw(tp,1) end
	-- 设置提示信息：请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的「No.」超量怪兽作为对象
	local g=Duel.SelectTarget(tp,c60944809.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：特殊召唤选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 设置操作信息：抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ①号效果的处理（特殊召唤并抽卡）
function c60944809.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍适用，则将其特殊召唤，若特殊召唤成功
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 中断效果处理，使后续的抽卡处理不与特殊召唤同时进行
		Duel.BreakEffect()
		-- 自己从卡组抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
-- 过滤函数：自己场上表侧表示的「No.」超量怪兽
function c60944809.matfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x48) and c:IsType(TYPE_XYZ)
end
-- ②号效果的发动准备（检查及选择对象）
function c60944809.mattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c60944809.matfilter(chkc) end
	-- 检查自己场上是否存在表侧表示的「No.」超量怪兽
	if chk==0 then return Duel.IsExistingTarget(c60944809.matfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查自己手牌中是否存在可以作为超量素材的卡
		and Duel.IsExistingMatchingCard(Card.IsCanOverlay,tp,LOCATION_HAND,0,1,nil) end
	-- 设置提示信息：请选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的「No.」超量怪兽作为对象
	Duel.SelectTarget(tp,c60944809.matfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ②号效果的处理（重叠超量素材）
function c60944809.matop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsType(TYPE_MONSTER) and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		-- 设置提示信息：请选择要作为超量素材的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
		-- 从手牌选择1张可以作为超量素材的卡
		local g=Duel.SelectMatchingCard(tp,Card.IsCanOverlay,tp,LOCATION_HAND,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的手牌重叠在对象怪兽下面作为超量素材
			Duel.Overlay(tc,g)
		end
	end
end

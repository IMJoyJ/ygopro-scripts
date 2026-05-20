--マグネット・コンバージョン
-- 效果：
-- ①：以自己墓地最多3只4星以下的「磁石战士」怪兽为对象才能发动。那些怪兽加入手卡。
-- ②：把墓地的这张卡除外，以除外的1只自己的4星以下的「磁石战士」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果在这张卡送去墓地的回合不能发动。
function c77133792.initial_effect(c)
	-- ①：以自己墓地最多3只4星以下的「磁石战士」怪兽为对象才能发动。那些怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c77133792.target)
	e1:SetOperation(c77133792.operation)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以除外的1只自己的4星以下的「磁石战士」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- 设置该效果在这张卡送去墓地的回合不能发动
	e2:SetCondition(aux.exccon)
	-- 设置发动成本为将墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c77133792.sptg)
	e2:SetOperation(c77133792.spop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己墓地4星以下的「磁石战士」怪兽且能加入手卡
function c77133792.filter(c)
	return c:IsSetCard(0x2066) and c:IsLevelBelow(4) and c:IsAbleToHand()
end
-- ①号效果的发动准备（检查墓地是否存在符合条件的卡、选择对象并设置操作信息）
function c77133792.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c77133792.filter(chkc) end
	-- 检查自己墓地是否存在至少1只符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c77133792.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1到3只符合条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c77133792.filter,tp,LOCATION_GRAVE,0,1,3,nil)
	-- 设置效果处理信息为将选中的卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- ①号效果的处理（获取对象，将仍符合条件的卡加入手牌）
function c77133792.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为效果对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 将这些卡因效果加入持有者的手牌
	Duel.SendtoHand(sg,nil,REASON_EFFECT)
end
-- 过滤条件：除外区表侧表示的、4星以下的「磁石战士」怪兽且能特殊召唤
function c77133792.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x2066) and c:IsLevelBelow(4)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②号效果的发动准备（检查怪兽区域空位、除外区是否存在符合条件的卡、选择对象并设置操作信息）
function c77133792.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and c77133792.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查自己除外区是否存在至少1只符合条件的怪兽
		and Duel.IsExistingTarget(c77133792.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己除外区1只符合条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c77133792.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置效果处理信息为将选中的1张卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②号效果的处理（获取对象，将仍符合条件的卡特殊召唤）
function c77133792.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为效果对象的第一个卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将该怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

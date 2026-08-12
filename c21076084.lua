--トリックスター・リンカーネイション
-- 效果：
-- ①：对方手卡全部除外，对方抽出那个数量。
-- ②：把墓地的这张卡除外，以自己墓地1只「淘气仙星」怪兽为对象才能发动。那只怪兽特殊召唤。
function c21076084.initial_effect(c)
	-- ①：对方手卡全部除外，对方抽出那个数量。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c21076084.target)
	e1:SetOperation(c21076084.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己墓地1只「淘气仙星」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21076084,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	-- 效果发动时将此卡除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c21076084.sptg)
	e2:SetOperation(c21076084.spop)
	c:RegisterEffect(e2)
end
-- 效果处理时判断是否满足条件并设置操作信息
function c21076084.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方手牌组
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	local gc=g:GetCount()
	-- 判断是否可以发动效果
	if chk==0 then return gc>0 and g:FilterCount(Card.IsAbleToRemove,nil)==gc and Duel.IsPlayerCanDraw(1-tp,gc) end
	-- 设置除外操作信息
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,gc,0,0)
	-- 设置抽卡操作信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,gc)
end
-- 效果处理时执行除外和抽卡操作
function c21076084.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方手牌组
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	local gc=g:GetCount()
	if gc>0 and g:FilterCount(Card.IsAbleToRemove,nil)==gc then
		-- 将对方手牌全部除外
		local oc=Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		if oc>0 then
			-- 让对方抽取除外数量的卡
			Duel.Draw(1-tp,oc,REASON_EFFECT)
		end
	end
end
-- 判断墓地的怪兽是否为淘气仙星族且可特殊召唤
function c21076084.spfilter(c,e,tp)
	return c:IsSetCard(0xfb) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理时判断是否满足条件并设置操作信息
function c21076084.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c21076084.spfilter(chkc,e,tp) end
	-- 判断自己场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断墓地是否存在符合条件的怪兽
		and Duel.IsExistingTarget(c21076084.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,c21076084.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置特殊召唤操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理时执行特殊召唤操作
function c21076084.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

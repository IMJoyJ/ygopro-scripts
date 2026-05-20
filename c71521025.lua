--カクリヨノチザクラ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在的场合，从自己以及对方的墓地各以1张魔法·陷阱卡为对象才能发动。那些卡除外，这张卡特殊召唤。
-- ②：把这张卡解放，以自己或者对方的墓地1只融合·同调·超量·连接怪兽为对象才能发动。那只怪兽除外，从自己墓地选和那只怪兽种类（融合·同调·超量·连接）不同的1只怪兽特殊召唤。
function c71521025.initial_effect(c)
	-- ①：这张卡在手卡存在的场合，从自己以及对方的墓地各以1张魔法·陷阱卡为对象才能发动。那些卡除外，这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(71521025,0))
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,71521025)
	e1:SetTarget(c71521025.sptg1)
	e1:SetOperation(c71521025.spop1)
	c:RegisterEffect(e1)
	-- ②：把这张卡解放，以自己或者对方的墓地1只融合·同调·超量·连接怪兽为对象才能发动。那只怪兽除外，从自己墓地选和那只怪兽种类（融合·同调·超量·连接）不同的1只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(71521025,1))
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,71521026)
	e2:SetCost(c71521025.spcost2)
	e2:SetTarget(c71521025.sptg2)
	e2:SetOperation(c71521025.spop2)
	c:RegisterEffect(e2)
end
-- 过滤条件：魔法·陷阱卡且可以被除外
function c71521025.rmfilter1(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemove()
end
-- 效果①的发动准备与条件判定
function c71521025.sptg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查自己墓地是否存在可以除外的魔法·陷阱卡
		and Duel.IsExistingTarget(c71521025.rmfilter1,tp,LOCATION_GRAVE,0,1,nil)
		-- 检查对方墓地是否存在可以除外的魔法·陷阱卡
		and Duel.IsExistingTarget(c71521025.rmfilter1,tp,0,LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择自己墓地1张魔法·陷阱卡作为对象
	local g1=Duel.SelectTarget(tp,c71521025.rmfilter1,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方墓地1张魔法·陷阱卡作为对象
	local g2=Duel.SelectTarget(tp,c71521025.rmfilter1,tp,0,LOCATION_GRAVE,1,1,nil)
	g1:Merge(g2)
	-- 设置效果处理信息：除外墓地的2张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g1,2,1-tp,LOCATION_GRAVE)
	-- 设置效果处理信息：特殊召唤手牌中的这张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理（除外并特殊召唤）
function c71521025.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取仍与效果相关的对象卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 成功除外对象卡且这张卡仍与效果相关时
	if g:GetCount()>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)~=0 and c:IsRelateToEffect(e) then
		-- 将这张卡特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②的发动代价（解放这张卡）
function c71521025.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤条件：墓地的融合·同调·超量·连接怪兽，且自己墓地存在与其种类不同的可特召怪兽
function c71521025.rmfilter2(c,e,tp)
	local type=bit.band(c:GetType(),TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK)
	return c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK) and c:IsAbleToRemove()
		-- 检查自己墓地是否存在与该怪兽种类不同的可特殊召唤怪兽
		and Duel.IsExistingMatchingCard(c71521025.spfilter,tp,LOCATION_GRAVE,0,1,c,e,tp,type)
end
-- 过滤条件：自己墓地的融合·同调·超量·连接怪兽，且不属于指定的种类，并且可以特殊召唤
function c71521025.spfilter(c,e,tp,type)
	return c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK) and not c:IsType(type) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备与条件判定
function c71521025.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c71521025.rmfilter2(chkc,e,tp) end
	-- 检查解放这张卡后，自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 检查双方墓地是否存在满足条件的融合·同调·超量·连接怪兽
		and Duel.IsExistingTarget(c71521025.rmfilter2,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择双方墓地1只融合·同调·超量·连接怪兽作为对象
	local g=Duel.SelectTarget(tp,c71521025.rmfilter2,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 设置效果处理信息：除外墓地的1张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,g:GetFirst():GetControler(),LOCATION_GRAVE)
	-- 设置效果处理信息：从自己墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果②的效果处理（除外并从墓地特殊召唤不同种类的怪兽）
function c71521025.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	local type=bit.band(tc:GetType(),TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK)
	-- 成功将对象怪兽除外时
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_REMOVED) then
		-- 检查自己场上是否有空余的怪兽区域，若无则结束处理
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从自己墓地选择1只与除外怪兽种类不同的怪兽
		local g=Duel.SelectMatchingCard(tp,c71521025.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,type)
		if g:GetCount()>0 then
			-- 将选择的怪兽特殊召唤
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end

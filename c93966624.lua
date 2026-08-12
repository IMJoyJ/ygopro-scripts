--マジック・ストライダー
-- 效果：
-- ①：这张卡在手卡存在的场合，以自己以及对方场上的表侧表示的魔法卡各1张为对象才能发动。那些卡除外，这张卡从手卡特殊召唤。
function c93966624.initial_effect(c)
	-- ①：这张卡在手卡存在的场合，以自己以及对方场上的表侧表示的魔法卡各1张为对象才能发动。那些卡除外，这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(93966624,0))  --"卡片除外"
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetTarget(c93966624.rmtg)
	e1:SetOperation(c93966624.rmop)
	c:RegisterEffect(e1)
end
-- 过滤场上表侧表示且可以除外的魔法卡
function c93966624.rmfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL) and c:IsAbleToRemove()
end
-- 效果发动的对象选择与可行性检测
function c93966624.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否存在可以除外的表侧表示魔法卡
	if chk==0 then return Duel.IsExistingTarget(c93966624.rmfilter,tp,LOCATION_ONFIELD,0,1,nil)
		-- 检查对方场上是否存在可以除外的表侧表示魔法卡
		and Duel.IsExistingTarget(c93966624.rmfilter,tp,0,LOCATION_ONFIELD,1,nil)
		-- 检查自己场上是否有可用的怪兽区域空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择自己场上1张表侧表示的魔法卡作为效果对象
	local g1=Duel.SelectTarget(tp,c93966624.rmfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方场上1张表侧表示的魔法卡作为效果对象
	local g2=Duel.SelectTarget(tp,c93966624.rmfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	g1:Merge(g2)
	-- 设置操作信息，表示该效果包含除外2张卡的操作
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g1,2,0,0)
	-- 设置操作信息，表示该效果包含特殊召唤自身的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理，将作为对象的卡除外，并特殊召唤自身
function c93966624.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与效果有关联的对象卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 将对象卡片表侧表示除外，并检查是否成功除外
	if g:GetCount()>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)~=0 then
		local c=e:GetHandler()
		if not c:IsRelateToEffect(e) then return end
		-- 将这张卡从手卡特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

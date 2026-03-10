--闇黒の魔王ディアボロス
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡在手卡·墓地存在，自己场上的暗属性怪兽被解放的场合才能发动。这张卡特殊召唤。
-- ②：只要这张卡在怪兽区域存在，对方不能把这张卡解放，也不能作为效果的对象。
-- ③：把自己场上1只暗属性怪兽解放才能发动。对方选自身1张手卡回到卡组最上面或最下面。
function c50383626.initial_effect(c)
	-- 效果原文内容：②：只要这张卡在怪兽区域存在，对方不能把这张卡解放，也不能作为效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_RELEASE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,1)
	e1:SetTarget(c50383626.rellimit)
	c:RegisterEffect(e1)
	-- 效果原文内容：②：只要这张卡在怪兽区域存在，对方不能把这张卡解放，也不能作为效果的对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	-- 规则层面作用：设置该效果为无法成为对方效果的对象的过滤函数
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	-- 效果原文内容：①：这张卡在手卡·墓地存在，自己场上的暗属性怪兽被解放的场合才能发动。这张卡特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(50383626,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_RELEASE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e4:SetCountLimit(1,50383626)
	e4:SetCondition(c50383626.spcon)
	e4:SetTarget(c50383626.sptg)
	e4:SetOperation(c50383626.spop)
	c:RegisterEffect(e4)
	-- 效果原文内容：③：把自己场上1只暗属性怪兽解放才能发动。对方选自身1张手卡回到卡组最上面或最下面。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(50383626,1))
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,50383627)
	e5:SetCost(c50383626.tdcost)
	e5:SetTarget(c50383626.tdtg)
	e5:SetOperation(c50383626.tdop)
	c:RegisterEffect(e5)
end
-- 规则层面作用：判断目标卡片是否为该效果的持有者（即本卡）
function c50383626.rellimit(e,c,tp)
	return c==e:GetHandler()
end
-- 规则层面作用：过滤出上一个位置在场上的、控制者为自己、属性为暗的怪兽
function c50383626.spcfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousControler(tp) and bit.band(c:GetPreviousAttributeOnField(),ATTRIBUTE_DARK)~=0
end
-- 规则层面作用：判断解放的怪兽中是否存在满足条件的暗属性怪兽且不包含本卡
function c50383626.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c50383626.spcfilter,1,nil,tp)
end
-- 规则层面作用：检查是否可以将本卡特殊召唤
function c50383626.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 规则层面作用：检查场上是否有足够的位置进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 规则层面作用：设置连锁操作信息，表示将要特殊召唤本卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 规则层面作用：执行特殊召唤操作
function c50383626.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 规则层面作用：将本卡以正面表示形式特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 规则层面作用：支付效果的解放费用
function c50383626.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：检查是否可以解放一只暗属性怪兽作为代价
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsAttribute,1,nil,ATTRIBUTE_DARK) end
	-- 规则层面作用：选择一只暗属性怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,Card.IsAttribute,1,1,nil,ATTRIBUTE_DARK)
	-- 规则层面作用：将选中的怪兽解放并扣除召唤次数
	Duel.Release(g,REASON_COST)
end
-- 规则层面作用：检查对方手牌中是否存在可送回卡组的卡片
function c50383626.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面作用：检查对方手牌中是否存在可送回卡组的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_HAND,1,nil) end
end
-- 规则层面作用：执行将对方手牌送回卡组的操作
function c50383626.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：提示玩家选择要送回卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 规则层面作用：选择对方的一张手牌作为目标
	local g=Duel.SelectMatchingCard(1-tp,Card.IsAbleToDeck,1-tp,LOCATION_HAND,0,1,1,nil)
	if g:GetCount()>0 then
		-- 规则层面作用：让对方选择将卡片放回卡组顶部或底部
		if Duel.SelectOption(1-tp,aux.Stringid(50383626,2),aux.Stringid(50383626,3))==0 then  --"卡组最上面/卡组最下面"
			-- 规则层面作用：将选中的卡片送回卡组顶部
			Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_EFFECT)
		else
			-- 规则层面作用：将选中的卡片送回卡组底部
			Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
		end
	end
end

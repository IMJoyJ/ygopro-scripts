--闇黒の魔王ディアボロス
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡在手卡·墓地存在，自己场上的暗属性怪兽被解放的场合才能发动。这张卡特殊召唤。
-- ②：只要这张卡在怪兽区域存在，对方不能把这张卡解放，也不能作为效果的对象。
-- ③：把自己场上1只暗属性怪兽解放才能发动。对方选自身1张手卡回到卡组最上面或最下面。
function c50383626.initial_effect(c)
	-- ②：对方不能把这张卡解放
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_RELEASE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,1)
	e1:SetTarget(c50383626.rellimit)
	c:RegisterEffect(e1)
	-- ②：也不能作为效果的对象
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	-- 设置效果值为aux.tgoval，表示只有对方玩家发动的效果不能以这张卡为对象（即不能成为对方的效果对象）
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	-- 这个卡名的①③的效果1回合各能使用1次。①：这张卡在手卡·墓地存在，自己场上的暗属性怪兽被解放的场合才能发动。这张卡特殊召唤。
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
	-- 这个卡名的①③的效果1回合各能使用1次。③：把自己场上1只暗属性怪兽解放才能发动。对方选自身1张手卡回到卡组最上面或最下面。
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
-- e1的Target过滤函数：仅当尝试被解放的卡是这张卡自身时返回true，从而把限制对象限定为本卡
function c50383626.rellimit(e,c,tp)
	return c==e:GetHandler()
end
-- 触发判断辅助过滤条件：被解放的怪兽之前在我方场上且其场上属性为暗属性，即判断是否为我方场上的暗属性怪兽被解放
function c50383626.spcfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousControler(tp) and bit.band(c:GetPreviousAttributeOnField(),ATTRIBUTE_DARK)~=0
end
-- ①的发动条件：本次解放事件中不包含这张卡自身，且至少存在1只满足上述条件（我方场上暗属性怪兽被解放）的卡
function c50383626.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c50383626.spcfilter,1,nil,tp)
end
-- ①的目标检查：自己场上有可用的怪兽区空格，且这张卡能够被特殊召唤
function c50383626.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否存在可用的主要怪兽区空格（大于0）
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 将本次操作信息登记为特殊召唤这张卡，数量为1，供连锁处理等检测
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①的效果处理：若这张卡仍与效果关联，则将其特殊召唤
function c50383626.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到我方场上，不检查召唤条件与苏生限制
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ③的代价：从我方场上选择并解放1只暗属性怪兽作为发动代价
function c50383626.tdcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：我方场上是否存在至少1只可解放的暗属性怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsAttribute,1,nil,ATTRIBUTE_DARK) end
	-- 选择1只我方场上可解放的暗属性怪兽作为解放代价
	local g=Duel.SelectReleaseGroup(tp,Card.IsAttribute,1,1,nil,ATTRIBUTE_DARK)
	-- 将选择的怪兽解放，原因标记为COST（代价），因此不受不能解放等效果影响
	Duel.Release(g,REASON_COST)
end
-- ③的目标检查：对方手牌中是否存在至少1张可以返回卡组的卡（效果处理时由对方选择）
function c50383626.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方手牌中是否存在至少1张可以返回卡组的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_HAND,1,nil) end
end
-- ③的效果处理：由对方选择自己1张手卡，并选择将其返回卡组最上面或最下面
function c50383626.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 发送提示消息：请选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让对方玩家从自身手牌中选择1张可以返回卡组的卡
	local g=Duel.SelectMatchingCard(1-tp,Card.IsAbleToDeck,1-tp,LOCATION_HAND,0,1,1,nil)
	if g:GetCount()>0 then
		-- 让对方玩家在‘卡组最上面’和‘卡组最下面’两个选项中选择，选择0则返回最上面
		if Duel.SelectOption(1-tp,aux.Stringid(50383626,2),aux.Stringid(50383626,3))==0 then  --"卡组最上面/卡组最下面"
			-- 将选择的卡返回持有者卡组最上面，原因标记为效果
			Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_EFFECT)
		else
			-- 将选择的卡返回持有者卡组最下面，原因标记为效果
			Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
		end
	end
end

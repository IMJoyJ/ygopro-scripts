--占い魔女 エンちゃん
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡抽到时，把这张卡给对方观看才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡从手卡的特殊召唤成功的场合，以对方场上盖放的1张卡为对象才能发动。那张卡破坏。
function c32305461.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：把这张卡抽到时，把这张卡给对方观看才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(32305461,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_DRAW)
	e1:SetCountLimit(1,32305461)
	e1:SetCost(c32305461.spcost)
	e1:SetTarget(c32305461.sptg)
	e1:SetOperation(c32305461.spop)
	c:RegisterEffect(e1)
	-- 这个卡名的①②的效果1回合各能使用1次。②：这张卡从手卡的特殊召唤成功的场合，以对方场上盖放的1张卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(32305461,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,32305462)
	e2:SetCondition(c32305461.descon)
	e2:SetTarget(c32305461.destg)
	e2:SetOperation(c32305461.desop)
	c:RegisterEffect(e2)
end
-- ①效果的发动代价判定：确认这张卡在手卡处于非公开状态，即需要向对方展示手卡的这张卡才能发动。
function c32305461.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- ①效果的发动合法性判定：自己主要怪兽区有空余区域，且这张卡能够被效果特殊召唤。
function c32305461.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上主要怪兽区是否有可用的空格，以决定是否满足特殊召唤条件。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记操作信息：此效果将特殊召唤这张卡（数量1），供连锁处理和相关效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果处理时：若这张卡仍与发动效果关联，则将其从手卡特殊召唤到自己场上。
function c32305461.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到自己场上（由自己控制）。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- ②效果的发动条件：这张卡是从手卡特殊召唤成功的，即其特殊召唤前所在位置为手牌。
function c32305461.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND)
end
-- ②效果发动时的取对象处理：从对方场上选择1张里侧表示的卡作为对象；选择时需要确认存在符合条件的对象。
function c32305461.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsFacedown() end
	-- 检查对方场上是否存在里侧表示的卡，作为②效果能否发动的条件之一。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFacedown,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向操作玩家显示“请选择要破坏的卡”的选择提示，供选择对象时使用。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从对方场上选择1张里侧表示的卡，并将其登记为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,Card.IsFacedown,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 登记操作信息：此效果将破坏所选的对象卡（数量1），供连锁处理和相关效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ②效果处理时：取得选择的对象卡，若该卡仍与效果关联，则将其破坏。
function c32305461.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取②效果发动时选择作为对象的卡（这里只有一张）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因破坏该对象卡。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

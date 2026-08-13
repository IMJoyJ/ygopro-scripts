--白き霊龍
-- 效果：
-- 这个卡名在规则上也当作「青眼」卡使用。
-- ①：这张卡只要在手卡·墓地存在，当作通常怪兽使用。
-- ②：这张卡召唤·特殊召唤时，以对方场上1张魔法·陷阱卡为对象才能发动。那张卡除外。
-- ③：自己·对方回合，对方场上有怪兽存在的场合，把这张卡解放才能发动。从手卡把1只「青眼白龙」特殊召唤。
function c45467446.initial_effect(c)
	-- 登记卡号89631139，使此卡在规则上也作为「青眼」卡使用，可被「青眼」相关检索/效果支持。
	aux.AddCodeList(c,89631139)
	-- ①：这张卡只要在手卡·墓地存在，当作通常怪兽使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_ADD_TYPE)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetValue(TYPE_NORMAL)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_REMOVE_TYPE)
	e2:SetValue(TYPE_EFFECT)
	c:RegisterEffect(e2)
	-- ②：这张卡召唤·特殊召唤时，以对方场上1张魔法·陷阱卡为对象才能发动。那张卡除外。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetTarget(c45467446.rmtg)
	e3:SetOperation(c45467446.rmop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
	-- ③：自己·对方回合，对方场上有怪兽存在的场合，把这张卡解放才能发动。从手卡把1只「青眼白龙」特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetHintTiming(0,TIMING_END_PHASE)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(c45467446.spcon)
	e5:SetCost(c45467446.spcost)
	e5:SetTarget(c45467446.sptg)
	e5:SetOperation(c45467446.spop)
	c:RegisterEffect(e5)
end
-- 筛选可作为对象的卡：满足魔法·陷阱卡且能够被除外（用于②效果选择对象）。
function c45467446.rmfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemove()
end
-- ②效果的发动时点处理：先检查能否以对方场上1张魔法·陷阱卡为对象；可以时提示玩家选择要除外的卡，将其设为效果对象，并登记除外1张卡的操作信息。
function c45467446.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c45467446.rmfilter(chkc) end
	-- 效果发动时检查对方场上是否存在1张能成为对象的魔法·陷阱卡，以此决定②效果能否发动。
	if chk==0 then return Duel.IsExistingTarget(c45467446.rmfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 给玩家显示“请选择要除外的卡”的选择提示，用于选择界面。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从对方场上选择1张符合条件的魔法·陷阱卡，并登记为本次连锁的取对象。
	local g=Duel.SelectTarget(tp,c45467446.rmfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设定本次效果处理将除外1张卡（对象组g），供其他效果进行发动检测。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- ②效果实际处理：取得之前选择的对象卡，若仍与效果关联则将其表侧表示除外。
function c45467446.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本次连锁中登记的第1张对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以表侧表示、效果原因将对象卡除外。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- ③效果的发动条件判断：对方场上是否有怪兽存在。
function c45467446.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断对方场上怪兽区怪兽数量是否大于0（即对方场上有怪兽），作为③效果的发动先决条件。
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
-- ③效果的代价处理：检查这张卡自身是否可解放；可发动时以解放自身作为代价。
function c45467446.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将效果持有者（这张卡）解放，作为发动③效果的代价（REASON_COST）。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 筛选手卡中可作为特殊召唤对象的「青眼白龙」：卡号是89631139且满足特殊召唤条件。
function c45467446.spfilter(c,e,tp)
	return c:IsCode(89631139) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③效果的发动目标选择：检查场上是否有足够空位以及手卡是否存在符合条件的「青眼白龙」，并登记特殊召唤的操作信息。
function c45467446.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查自己场上是否留有可用的主要怪兽区域（因解放自身会空出1格，故当前可用格数只需大于-1）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查手卡是否存在1只符合条件的「青眼白龙」（卡号89631139且可特殊召唤），作为③效果发动的前提。
		and Duel.IsExistingMatchingCard(c45467446.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 登记本次连锁的操作信息：将从手卡特殊召唤1只怪兽，供相关效果进行对应。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ③效果实际处理：若场上仍有空位，则从手卡选择1只「青眼白龙」以表侧表示特殊召唤。
function c45467446.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己主要怪兽区是否有空位，若无空位则停止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1张符合条件的「青眼白龙」（卡号89631139且可特殊召唤）。
	local g=Duel.SelectMatchingCard(tp,c45467446.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的「青眼白龙」以表侧表示特殊召唤到自己的主要怪兽区。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

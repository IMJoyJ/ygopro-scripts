--マジカル・ハウンド
-- 效果：
-- 这个卡名的效果在决斗中只能使用1次。
-- ①：这张卡在手卡·墓地存在的场合，以对方场上1张表侧表示的魔法·陷阱卡为对象才能发动。那张卡回到持有者手卡，这张卡特殊召唤。
function c51916853.initial_effect(c)
	-- 这个卡名的效果在决斗中只能使用1次。①：这张卡在手卡·墓地存在的场合，以对方场上1张表侧表示的魔法·陷阱卡为对象才能发动。那张卡回到持有者手卡，这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51916853,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,51916853+EFFECT_COUNT_CODE_DUEL)
	e1:SetTarget(c51916853.sptg)
	e1:SetOperation(c51916853.spop)
	c:RegisterEffect(e1)
end
-- 定义效果对象筛选条件：选择对方场上表侧表示且能够返回手卡的魔法·陷阱卡。
function c51916853.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果发动时的目标检查与选择：验证对象合法性，确认场上存在符合条件的对象且满足特殊召唤条件后才可发动。
function c51916853.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c51916853.cfilter(chkc) end
	-- 检查我方主要怪兽区是否有可用的空格，以准备特殊召唤此卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查对方场上是否存在1张符合条件的表侧魔法·陷阱卡，可以将其作为效果对象。
		and Duel.IsExistingTarget(c51916853.cfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向玩家发出选择提示，提示内容为“请选择要返回手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家从对方场上选择1张符合条件的表侧魔法·陷阱卡，并将其登记为效果对象。
	local g=Duel.SelectTarget(tp,c51916853.cfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：预定将选择的对象卡返回持有者手卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 设置操作信息：预定将此卡特殊召唤，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理时的实际操作：若对象卡仍与效果相关且成功返回手卡，并且此卡仍与效果相关，则将此卡特殊召唤。
function c51916853.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	-- 确认对象卡仍与效果相关、能够成功返回手卡且返回后位于手卡，同时此卡仍与效果相关，满足这些条件才继续后续特殊召唤处理。
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND)
		and c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到持有者场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

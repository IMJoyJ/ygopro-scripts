--礫岩の霊長－コングレード
-- 效果：
-- 这张卡不能通常召唤，用卡的效果才能特殊召唤。
-- ①：从对方的手卡·卡组有怪兽被送去墓地的场合才能发动。这张卡从手卡里侧守备表示特殊召唤。
-- ②：这张卡反转的场合，以场上最多2张卡为对象才能发动。那些卡破坏。
function c49729312.initial_effect(c)
	-- ①：从对方的手卡·卡组有怪兽被送去墓地的场合才能发动。这张卡从手卡里侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c49729312.splimit)
	c:RegisterEffect(e1)
	-- 这张卡不能通常召唤，用卡的效果才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(49729312,0))  --"这张卡特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c49729312.spcon)
	e2:SetTarget(c49729312.sptg)
	e2:SetOperation(c49729312.spop)
	c:RegisterEffect(e2)
	-- ②：这张卡反转的场合，以场上最多2张卡为对象才能发动。那些卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(49729312,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_FLIP)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetTarget(c49729312.destg)
	e3:SetOperation(c49729312.desop)
	c:RegisterEffect(e3)
end
-- 设置此卡不能通常召唤，只能通过效果特殊召唤。
function c49729312.splimit(e,se,sp,st)
	return se:IsHasType(EFFECT_TYPE_ACTIONS)
end
-- 判断被送入墓地的卡是否来自对方手卡或卡组且为怪兽。
function c49729312.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_DECK+LOCATION_HAND) and c:IsType(TYPE_MONSTER) and c:IsPreviousControler(tp)
end
-- 检测是否有对方怪兽被送入墓地。
function c49729312.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c49729312.cfilter,1,nil,1-tp)
end
-- 判断是否满足特殊召唤条件。
function c49729312.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的召唤区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE) end
	-- 设置特殊召唤的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作并确认对方看到该卡。
function c49729312.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡以里侧守备表示特殊召唤到场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 向对方玩家展示特殊召唤的卡片。
		Duel.ConfirmCards(1-tp,c)
	end
end
-- 设置破坏效果的目标选择逻辑。
function c49729312.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 判断场上是否存在可破坏的卡片。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示选择要破坏的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择最多2张场上卡片作为破坏对象。
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,2,nil)
	-- 设置破坏操作的信息。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 执行破坏效果。
function c49729312.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 筛选出与当前连锁相关的可破坏卡片。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 以效果原因将目标卡片破坏。
		Duel.Destroy(g,REASON_EFFECT)
	end
end

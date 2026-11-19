--R－ACEイントルーダー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1张「救援ACE队」陷阱卡加入手卡。
-- ②：对方把场上的怪兽的效果发动时，把手卡·场上的这张卡解放，以「救援ACE队 双脉冲炮灭火员」以外的自己墓地1只「救援ACE队」怪兽为对象才能发动。那只怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化「救援ACE队 双脉冲炮灭火员」的效果：注册召唤·特召检索陷阱的①效果与二速解放自身苏生墓地同字段怪兽的②效果。
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1张「救援ACE队」陷阱卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- 这个卡名的①②的效果1回合各能使用1次。②：对方把场上的怪兽的效果发动时，把手卡·场上的这张卡解放，以「救援ACE队 双脉冲炮灭火员」以外的自己墓地1只「救援ACE队」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.spcon)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 定义①效果检索过滤函数：检查卡片是否属于「救援ACE队」(0x18b)字段、为陷阱卡且可以加入手卡。
function s.thfilter(c)
	return c:IsSetCard(0x18b) and c:IsType(TYPE_TRAP) and c:IsAbleToHand()
end
-- ①效果发动检查与信息登记函数：确认卡组存在可检索的「救援ACE队」陷阱卡，并登记从卡组将1张卡加入手卡的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在检查能否发动时，确认自己卡组中存在至少1张符合条件的「救援ACE队」陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向引擎登记本次连锁预计从自己卡组将1张卡加入手卡的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理函数：让玩家从卡组选择1张「救援ACE队」陷阱卡加入手卡，并向对方展示确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送选择要加入手卡的卡片提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己卡组选择1张满足条件的「救援ACE队」陷阱卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 以效果原因将选中的「救援ACE队」陷阱卡加入发动玩家手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示确认加入手卡的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②效果发动条件函数：检查触发连锁的是对方玩家，且发动的效果为场上怪兽区域怪兽的效果。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER) and re:GetActivateLocation()==LOCATION_MZONE
end
-- ②效果Cost函数：检查手卡或场上的这张卡能否解放且离场后自己怪兽区有空位，并在发动时将这张卡作为Cost解放。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在检查能否发动时，确认手卡或场上的这张卡可以被解放且解放后自己怪兽区至少有1个空位。
	if chk==0 then return c:IsReleasable() and Duel.GetMZoneCount(tp,c)>0 end
	-- 将手卡或场上的这张卡自身作为Cost解放。
	Duel.Release(c,REASON_COST)
end
-- 定义②效果特殊召唤对象过滤函数：检查墓地怪兽是否属于「救援ACE队」、卡名不是「救援ACE队 双脉冲炮灭火员」且可以正规特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x18b) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果发动对象检查与选择函数：验证墓地存在符合条件的苏生对象，选择其中1只作为对象并登记特殊召唤操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 在检查能否发动时，确认自己墓地存在至少1只满足条件且可成为效果对象的「救援ACE队」怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家发送选择要特殊召唤的墓地怪兽提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只符合条件的「救援ACE队」怪兽作为当前连锁的对象。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 向引擎登记本次连锁确定将对象怪兽特殊召唤的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果处理函数：确认对象怪兽仍与效果关联且不受「王家长眠之谷」影响后，将其以表侧表示特殊召唤到自己场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的当前连锁的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍与效果保持联系且未受到「王家长眠之谷」效果的限制。
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) then
		-- 将对象怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

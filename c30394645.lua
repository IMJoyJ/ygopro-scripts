--教導の死徒
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡在手卡存在，从额外卡组特殊召唤的怪兽在场上存在的场合才能发动。这张卡特殊召唤。
-- ②：这张卡从手卡特殊召唤的场合才能发动。双方各自从自身的额外卡组把1只怪兽送去墓地。
-- ③：这张卡被送去墓地的场合，以「教导的死徒」以外的自己墓地1张「教导」卡为对象才能发动。那张卡加入手卡。
local s,id,o=GetID()
-- 初始化函数：为这张卡注册①手卡起动特殊召唤自身、②从手卡特殊召唤成功时双方从额外卡组各送墓1只怪兽、③被送去墓地时回收墓地的「教导」卡三个效果，并分别设定1回合1次的发动限制。
function s.initial_effect(c)
	-- ①：这张卡在手卡存在，从额外卡组特殊召唤的怪兽在场上存在的场合才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡从手卡特殊召唤的场合才能发动。双方各自从自身的额外卡组把1只怪兽送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"送墓"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.tgcon)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
	-- ③：这张卡被送去墓地的场合，以「教导的死徒」以外的自己墓地1张「教导」卡为对象才能发动。那张卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"回收"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,id+o*2)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- 过滤函数：判断一张怪兽是否是从额外卡组特殊召唤的怪兽。
function s.cfilter(c)
	return c:IsSummonLocation(LOCATION_EXTRA)
end
-- ①效果的发动条件：检查双方场上是否存在至少1只从额外卡组特殊召唤的怪兽。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回场上是否存在满足条件的从额外卡组特殊召唤的怪兽。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- ①效果的发动合法性检查：自己场上有主要怪兽区空位，且这张卡能够被特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主要怪兽区空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记效果处理信息：将特殊召唤这张卡作为本次效果处理的内容。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：这张卡仍与连锁相关时将其特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 以表侧表示将这张卡特殊召唤到发动者（tp）的场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的发动条件：这张卡从手卡被特殊召唤。
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonLocation(LOCATION_HAND)
end
-- ②效果发动时检查：双方额外卡组中都至少存在1张可以送去墓地的怪兽。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己额外卡组中所有可以送去墓地的怪兽。
	local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,LOCATION_EXTRA,0,nil)
	-- 获取对方额外卡组中所有可以送去墓地的怪兽。
	local g2=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,0,LOCATION_EXTRA,nil)
	if chk==0 then return g:GetCount()>0 and g2:GetCount()>0 end
end
-- ②效果处理时确认双方额外卡组仍各有至少1张可送墓的卡，否则终止处理。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己额外卡组不存在可送墓的卡，则终止处理。
	if not Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_EXTRA,0,1,nil)
		-- 若对方额外卡组不存在可送墓的卡，也终止处理。
		or not Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,0,LOCATION_EXTRA,1,nil) then return end
	-- 取得当前回合玩家，作为先选择并处理送墓的一方。
	local p=Duel.GetTurnPlayer()
	-- 获取当前回合玩家的额外卡组中所有可以送去墓地的怪兽。
	local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,p,LOCATION_EXTRA,0,nil)
	-- 向当前回合玩家显示选择要送去墓地的卡的提示信息。
	Duel.Hint(HINT_SELECTMSG,p,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=g:Select(p,1,1,nil)
	if sg:GetCount()>0 then
		-- 将当前回合玩家选择的卡以效果原因送去墓地。
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
	-- 获取当前回合玩家的对手的额外卡组中所有可以送去墓地的怪兽。
	local g2=Duel.GetMatchingGroup(Card.IsAbleToGrave,p,0,LOCATION_EXTRA,nil)
	-- 向对手显示选择要送去墓地的卡的提示信息。
	Duel.Hint(HINT_SELECTMSG,1-p,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg2=g2:Select(1-p,1,1,nil)
	if sg2:GetCount()>0 then
		-- 将对手选择的卡以效果原因送去墓地。
		Duel.SendtoGrave(sg2,REASON_EFFECT)
	end
end
-- 过滤函数：选择自己墓地的「教导」卡时，要求卡名不是「教导的死徒」、属于「教导」系列、且可以加入手卡。
function s.thfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x145) and c:IsAbleToHand()
end
-- ③效果的发动目标处理：从自己墓地选择1张符合条件的「教导」卡作为效果对象。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	-- 检查自己墓地是否存在至少1张符合条件的「教导」卡可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家显示选择要加入手牌的卡的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1张符合条件的卡，并将其登记为效果对象。
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 登记效果处理信息：将选择的对象卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ③效果处理：将对象卡加入手卡，并考虑「王家长眠之谷」等对墓地卡移动的限制。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取③效果处理时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	-- 确认对象卡仍与当前连锁相关，且不受「王家长眠之谷」等效果影响。
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 将对象卡加入其持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end

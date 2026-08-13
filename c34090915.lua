--復烙印
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次，②的效果在同一连锁上只能发动1次。
-- ①：光·暗属性怪兽被表侧除外的场合，以那之内的1只为对象才能发动。那只怪兽回到卡组最下面，自己抽1张。
-- ②：1回合1次，对方把怪兽召唤·特殊召唤的场合，以自己墓地1只「深渊之兽」怪兽为对象才能发动。那只怪兽特殊召唤。
local s,id=GetID()
-- 初始化「复烙印」的效果：先注册魔陷发动所需的ACTIVATE空效果；再注册①效果（光·暗怪兽表侧除外时回卡组抽卡）与②效果（对方召唤/特殊召唤时从墓地特召深渊之兽），其中②用两个效果分别监听通常召唤和特殊召唤。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	-- 为「复烙印」注册一个合并的延迟事件，将表侧除外事件合并后触发，用于①效果在除外发生时能够统一处理，并防止同一连锁重复触发。
	local custom_code=aux.RegisterMergedDelayedEvent_ToSingleCard(c,id,EVENT_REMOVE)
	-- ①：光·暗属性怪兽被表侧除外的场合，以那之内的1只为对象才能发动。那只怪兽回到卡组最下面，自己抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"回收除外的怪兽并抽卡"
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(custom_code)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(s.tdtg)
	e1:SetOperation(s.tdop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，对方把怪兽召唤·特殊召唤的场合，以自己墓地1只「深渊之兽」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤墓地的怪兽"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 定义①效果的过滤条件：被表侧除外的光·暗属性怪兽，且满足可回卡组、可成为效果对象、位于除外区。
function s.cfilter(c,e)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK+ATTRIBUTE_LIGHT) and c:IsAbleToDeck()
		and c:IsCanBeEffectTarget(e) and c:IsLocation(LOCATION_REMOVED)
end
-- ①效果发动时，检查诱发事件组中是否存在满足过滤条件的怪兽，且自己可以抽1张卡；若连锁处理到选择对象时，则校验所选对象是否属于该事件组。
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return eg:IsContains(chkc) end
	if chk==0 then return eg:IsExists(s.cfilter,1,nil,e)
		-- 额外检查自己是否能够抽1张卡，避免无法抽卡时仍可发动。
		and Duel.IsPlayerCanDraw(tp,1) end
	-- 给发动玩家显示“请选择要返回卡组的卡”的提示，并准备从符合条件的除外怪兽中选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	local g=eg:FilterSelect(tp,s.cfilter,1,1,nil,e)
	-- 将选择的除外怪兽设置为当前连锁的处理对象（取对象）。
	Duel.SetTargetCard(g)
	-- 向系统登记本连锁将进行“把对象卡返回卡组”的操作，并记录对象及数量。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	-- 向系统登记本连锁之后将抽1张卡的操作信息，供相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ①效果的结算处理：将取对象的除外怪兽返回持有者卡组最下面，若成功则自己抽1张卡。
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中记录的对象卡（即被选择返回卡组的怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 确认对象仍与该效果关联后，将其送去持有者卡组最下面，并确认操作成功（>0）。
	if tc:IsRelateToEffect(e) and Duel.SendtoDeck(tc,nil,SEQ_DECKBOTTOM,REASON_EFFECT)>0 then
		-- 对象返回卡组成功后，自己抽1张卡。
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
-- ②效果的发动条件：对方玩家成功召唤了怪兽（eg中存在召唤玩家是对方的怪兽）。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp)
end
-- 定义②效果可选择墓地怪兽的条件：必须是「深渊之兽」怪兽，且能够被当前效果特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x188) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果发动时，检查自己场上是否有空位、本回合还没有使用过②效果（通过flag标记），以及墓地存在满足条件的「深渊之兽」怪兽；若连锁处理到选择对象时，则校验所选对象在墓地且属于己方并满足特召条件。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 确认自己怪兽区有空位，且同一连锁上尚未发动过②效果。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetFlagEffect(tp,id)==0
		-- 确认墓地存在1只满足条件的「深渊之兽」怪兽可以作为对象。
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 为发动玩家注册一个连锁结束后重置的标记，用于保证②效果在同一连锁上只能发动1次。
	Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
	-- 给发动玩家显示“请选择要特殊召唤的卡”的提示，并准备从墓地中选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让发动玩家从自己墓地选择1只符合条件的「深渊之兽」怪兽作为特殊召唤对象，并同时将其设为连锁对象。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 向系统登记本连锁将进行“特殊召唤”的操作，记录对象及数量。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果的结算处理：将取对象墓地怪兽特殊召唤到己方场上表侧表示。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中记录的对象卡（即墓地中要被特殊召唤的怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 确认对象仍与该效果关联后，将其以表侧表示特殊召唤到自己场上。
	if tc:IsRelateToEffect(e) then Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) end
end

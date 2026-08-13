--M∀LICE＜P＞March Hare
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡在手卡存在的场合，自己·对方的主要阶段才能发动。从自己的手卡·墓地把这张卡以外的1张「码丽丝」卡除外，这张卡特殊召唤。
-- ②：对方不能把有这张卡位于所连接区的「码丽丝」连接怪兽作为效果的对象。
-- ③：这张卡被除外的场合，支付300基本分，以自己的除外状态的1只「码丽丝」怪兽为对象才能发动。那只怪兽加入手卡。
local s,id,o=GetID()
-- 注册三个效果：①为手牌诱发即时效果，主要阶段除外码丽丝卡并特殊召唤自身；②为永续抗性效果，使所连接区的码丽丝连接怪兽不受对方效果对象；③为被除外时的诱发选发效果，支付300LP回收1只码丽丝怪兽。
function s.initial_effect(c)
	-- ①：这张卡在手卡存在的场合，自己·对方的主要阶段才能发动。从自己的手卡·墓地把这张卡以外的1张「码丽丝」卡除外，这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：对方不能把有这张卡位于所连接区的「码丽丝」连接怪兽作为效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	-- 设置该抗性效果的价值函数为aux.tgoval，使具有此抗性的卡不会成为对方效果的对象。
	e2:SetValue(aux.tgoval)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.immtg)
	c:RegisterEffect(e2)
	-- ③：这张卡被除外的场合，支付300基本分，以自己的除外状态的1只「码丽丝」怪兽为对象才能发动。那只怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"加入手卡"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_REMOVE)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,id+o)
	e3:SetCost(s.thcost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- ①效果的发动条件判断：仅在当前为主要阶段且满足发动时点时允许发动。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为主要阶段，是则返回true，满足发动条件。
	return Duel.IsMainPhase()
end
-- 过滤条件：卡片可以被除外且卡名含有「码丽丝」字段（0x1bf），用于选择要除外的卡。
function s.cfilter(c)
	return c:IsAbleToRemove() and c:IsSetCard(0x1bf)
end
-- ①效果的发动时点检测：检查己方怪兽区域有空位、自身可以特殊召唤、并且手牌·墓地存在符合条件的「码丽丝」卡。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方主要怪兽区是否有空闲位置（特殊召唤所需）。若没有则无法发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查手牌·墓地是否至少存在1张满足“可除外且是码丽丝卡”的卡，且排除自身（因为要除外这张卡以外的卡）。
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 设定操作信息：本次效果处理将把e:GetHandler()（这张卡自身）特殊召唤，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 设定操作信息：本次效果处理将把手牌·墓地的1张卡除外（具体卡在效果处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- ①效果的实际处理：让玩家选择1张可除外的码丽丝卡（受王家长眠之谷影响不能除外则不可选），将其除外后，若成功且自身仍与效果关联，则将自身特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 显示选择提示，提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择符合条件的1张卡（用NecroValleyFilter过滤受王家长眠之谷影响的卡，并排除自身），作为除外对象。
	local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.cfilter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,aux.ExceptThisCard(e))
	-- 若成功选到卡并除外成功，且自身与当前效果仍有关联（未被其他效果移动/离场），则继续特殊召唤。
	if sg:GetCount()>0 and Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)~=0 and c:IsRelateToEffect(e) then
		-- 将自身以表侧表示特殊召唤到己方场上（不检查召唤条件、苏生限制）。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的免疫对象筛选：这张卡（码丽丝连接怪兽）需表侧表示、是连接怪兽、具有码丽丝字段、并且其连接区域中有本卡（e:GetHandler()），且本卡未被战斗破坏确定。
function s.immtg(e,c)
	local lg=c:GetLinkedGroup()
	return c:IsFaceup() and c:IsType(TYPE_LINK) and c:IsSetCard(0x1bf)
		and lg and lg:IsContains(e:GetHandler()) and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
-- ③效果的发动代价：检查并支付300基本分。
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时点检查支付代价：能否支付300LP。若不能则无法发动。
	if chk==0 then return Duel.CheckLPCost(tp,300) end
	-- 实际扣除300LP作为发动代价。
	Duel.PayLPCost(tp,300)
end
-- ③回收目标过滤：除外状态的表侧表示的码丽丝怪兽，且可以被加入手卡。
function s.thfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x1bf) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ③效果的取对象发动流程：先检查对象是否合法，再提示玩家选择1只除外状态符合条件的码丽丝怪兽作为目标，并设定操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.thfilter(chkc) end
	-- 检查是否存在至少1只符合条件的除外状态码丽丝怪兽（可作为对象）。若没有则无法发动。
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 显示选择提示，提示玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从自己除外状态的卡中选择1只符合条件的码丽丝怪兽作为效果对象（同时设定为连锁对象）。
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设定操作信息：确认要将选中的对象加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ③效果处理：取得对象，若对象仍与效果关联，将其加入持有者手卡并向对方展示。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中选定的对象卡（第1个目标）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将该对象卡加入其持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,tc)
	end
end

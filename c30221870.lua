--機皇帝ワイゼル∞－S・アブソープション
-- 效果：
-- 这张卡不能通常召唤，用这张卡的效果才能特殊召唤。这个卡名的①的效果1回合只能使用1次。
-- ①：对方回合，把自己场上1只表侧表示的「机皇」怪兽送去墓地才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡特殊召唤成功的场合，以对方场上1只怪兽为对象才能发动。这个回合，那只怪兽不能攻击。
-- ③：要让场上的卡破坏的效果发动时，把这张卡解放才能发动。那个发动无效并破坏。
function c30221870.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤，用这张卡的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- ①：对方回合，把自己场上1只表侧表示的「机皇」怪兽送去墓地才能发动。这张卡从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(30221870,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_HAND)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,30221870)
	e2:SetCost(c30221870.spcost)
	e2:SetCondition(c30221870.spcon)
	e2:SetTarget(c30221870.sptg)
	e2:SetOperation(c30221870.spop)
	c:RegisterEffect(e2)
	-- ②：这张卡特殊召唤成功的场合，以对方场上1只怪兽为对象才能发动。这个回合，那只怪兽不能攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(30221870,1))  --"对方怪兽不能攻击"
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetTarget(c30221870.atktg)
	e3:SetOperation(c30221870.atkop)
	c:RegisterEffect(e3)
	-- ③：要让场上的卡破坏的效果发动时，把这张卡解放才能发动。那个发动无效并破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(30221870,2))  --"发动无效并破坏"
	e4:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c30221870.negcon)
	e4:SetCost(c30221870.negcost)
	e4:SetTarget(c30221870.negtg)
	e4:SetOperation(c30221870.negop)
	c:RegisterEffect(e4)
end
-- 定义「机皇」怪兽作为COST的筛选条件：需表侧表示、属于「机皇」字段、可作为COST送去墓地，且该卡离场后我方仍有可用的怪兽区域。
function c30221870.cfilter(c,tp)
	-- 筛选条件：表侧表示、属于「机皇」字段、可作为COST送去墓地，且该卡离场后我方存在可用怪兽区。
	return c:IsFaceup() and c:IsSetCard(0x13) and c:IsAbleToGraveAsCost() and Duel.GetMZoneCount(tp,c)>0
end
-- ①效果的COST处理：从自己场上选择1只符合条件的表侧表示「机皇」怪兽送去墓地，并确保特殊召唤所需空位。
function c30221870.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- COST合法性检查：确认自己场上是否存在至少1张满足条件的「机皇」怪兽可作为COST。
	if chk==0 then return Duel.IsExistingMatchingCard(c30221870.cfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 弹出选择提示，提示玩家选择要送去墓地的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己场上选择1只符合条件的「机皇」怪兽作为COST。
	local g=Duel.SelectMatchingCard(tp,c30221870.cfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 将选择的卡作为COST送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- ①效果的发动条件：仅在对方回合才能发动。
function c30221870.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家不是自己，即满足对方回合条件。
	return Duel.GetTurnPlayer()~=tp
end
-- ①效果的目标设定：确认这张卡能够被特殊召唤，并登记特殊召唤的操作信息。
function c30221870.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,false) end
	-- 将本次连锁的操作信息标记为“特殊召唤”这张卡1张，供后续效果检测与响应。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：将这张卡从手卡特殊召唤，并完成特殊召唤手续。
function c30221870.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍与效果关联后，以表侧表示特殊召唤这张卡；若成功则继续完成特殊召唤手续。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP)~=0 then
		c:CompleteProcedure()
	end
end
-- ②效果的目标处理：选择对方场上1只表侧表示怪兽作为对象。
function c30221870.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() end
	-- 目标合法性检查：确认对方场上有表侧表示怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 弹出选择提示，提示玩家选择表侧表示的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家选择对方场上1只表侧表示怪兽作为效果对象，并登记为当前连锁的对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- ②效果处理：为对象怪兽赋予“这个回合不能攻击”的永续效果。
function c30221870.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得这个效果选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 这个回合，那只怪兽不能攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- ③效果的发动条件判断：排除此卡已战斗破坏、目标连锁不可被无效，以及被连锁效果属于魔法·陷阱卡的发动且带无效分类的情况。
function c30221870.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 如果这张卡已确定被战斗破坏，或当前连锁不能被无效，则③效果不能发动。
	if e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) or not Duel.IsChainNegatable(ev) then return false end
	if re:IsHasCategory(CATEGORY_NEGATE)
		-- 如果被连锁效果的前一个连锁是魔法·陷阱卡的发动，且被连锁效果本身带无效分类，则③效果不能发动。
		and Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_EFFECT):IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	-- 获取该连锁中“破坏”相关的操作信息，用于确认该效果包含破坏场上卡片的操作。
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	return ex and tg~=nil and tc+tg:FilterCount(Card.IsOnField,nil)-tg:GetCount()>0
end
-- ③效果的COST处理：解放这张卡自身作为发动代价。
function c30221870.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将这张卡自身解放作为COST。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- ③效果的目标设定：登记无效并破坏当前连锁中的卡；若该卡可破坏且与效果关联，则一并登记破坏操作。
function c30221870.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将操作信息登记为无效当前连锁中的卡。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 将操作信息登记为破坏当前连锁中的卡。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- ③效果处理：无效该效果的发动，并将对应的卡破坏。
function c30221870.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 执行无效发动，并确认被无效的卡仍与效果关联，以决定是否进行后续破坏。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏被无效的卡。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end

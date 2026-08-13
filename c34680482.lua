--マドルチェ・エンジェリー
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：把这张卡解放才能发动。从卡组把1只「魔偶甜点」怪兽特殊召唤。这个效果特殊召唤的怪兽不会被战斗破坏，下次的自己回合的结束阶段回到卡组。
-- ②：这张卡被对方破坏送去墓地的场合发动。这张卡回到卡组。
function c34680482.initial_effect(c)
	-- ②：这张卡被对方破坏送去墓地的场合发动。这张卡回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(34680482,0))  --"返回卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c34680482.retcon)
	e1:SetTarget(c34680482.rettg)
	e1:SetOperation(c34680482.retop)
	c:RegisterEffect(e1)
	-- 这个卡名的①的效果1回合只能使用1次。①：把这张卡解放才能发动。从卡组把1只「魔偶甜点」怪兽特殊召唤。这个效果特殊召唤的怪兽不会被战斗破坏，下次的自己回合的结束阶段回到卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(34680482,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,34680482)
	e2:SetCost(c34680482.spcost)
	e2:SetTarget(c34680482.sptg)
	e2:SetOperation(c34680482.spop)
	c:RegisterEffect(e2)
end
-- 判断②效果能否发动：这张卡以被破坏原因送去墓地，且破坏原因是对方造成的（reason player为对方），并且被破坏前由自己控制。
function c34680482.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY) and e:GetHandler():GetReasonPlayer()==1-tp
		and e:GetHandler():IsPreviousControler(tp)
end
-- ②效果发动时无取对象目标，直接允许发动；同时设置操作信息为将该卡返回卡组。
function c34680482.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：该效果会将这张卡返回持有者卡组，用于连锁处理和相关检测。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- ②效果处理：若这张卡仍与该效果关联（未被移除等），则将其返回持有者卡组并洗牌。
function c34680482.retop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将这张卡以效果原因返回持有者卡组并洗牌（洗牌前暂放在卡组底端）。
		Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- ①效果的代价处理：检查这张卡是否可以解放；若可以则将该卡解放作为发动代价。
function c34680482.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 以代价原因解放这张卡，完成COST支付。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 定义特殊召唤的候选条件：卡名属于「魔偶甜点」系列，且能够被当前效果特殊召唤（不无视召唤条件和苏生限制）。
function c34680482.filter(c,e,tp)
	return c:IsSetCard(0x71) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果发动条件判断：检查我方主要怪兽区是否有可用格位（此处允许当前为0，因为解放自身后可腾出）以及卡组中是否存在符合条件的「魔偶甜点」怪兽。
function c34680482.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查我方主要怪兽区是否仍有可用格位（允许为0，因发动后以解放自身为代价可腾出格子）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 检查卡组中是否存在至少1只满足filter的可特殊召唤的「魔偶甜点」怪兽。
		and Duel.IsExistingMatchingCard(c34680482.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：该效果会从卡组特殊召唤1只怪兽（对象不取对象，目标玩家为自己，区域为卡组）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：再次确认有可用格位后，提示选择卡组中的「魔偶甜点」怪兽并特殊召唤；给该怪兽记录当前回合数；赋予其“不会被战斗破坏”的效果，并注册一个在下次自己回合结束阶段将其返回卡组的效果。
function c34680482.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时若我方主要怪兽区没有空位则直接结束，不进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送选择提示，提示内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己卡组选择1张满足filter的「魔偶甜点」怪兽作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c34680482.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	local c=e:GetHandler()
	if tc then
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上（不无视召唤条件及苏生限制，视为无特殊召唤方式限制）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 给特殊召唤的怪兽注册一个标记，记录当前回合数，用于判断“下次自己回合”的结束阶段；该标记随怪兽离场等标准重置而消失。
		tc:RegisterFlagEffect(34680482,RESET_EVENT+RESETS_STANDARD,0,1,Duel.GetTurnCount())
		-- 这个效果特殊召唤的怪兽不会被战斗破坏
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(34680482,2))  --"「魔偶甜点·果冻天使」效果适用中"
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 下次的自己回合的结束阶段回到卡组。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		-- 把当前回合数记录进效果Label，作为判断“下次自己回合”的基准。
		e2:SetLabel(Duel.GetTurnCount())
		e2:SetLabelObject(tc)
		e2:SetCondition(c34680482.tdcon)
		e2:SetOperation(c34680482.tdop)
		e2:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,2)
		e2:SetCountLimit(1)
		-- 将该结束阶段回卡组的效果注册到决斗中（属于场地持续效果），并由tp控制其生命周期。
		Duel.RegisterEffect(e2,tp)
	end
end
-- 判断回卡组时机：已进入之后的自己回合（回合数已变化且当前回合玩家为tp），且该怪兽仍带有本次特殊召唤的标记。
function c34680482.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 条件成立时：当前回合数已不是发动时的回合数，当前回合玩家为原控制者tp，且怪兽身上的标记回合数等于记录的回合数。
	return Duel.GetTurnCount()~=e:GetLabel() and Duel.GetTurnPlayer()==tp and tc:GetFlagEffectLabel(34680482)==e:GetLabel()
end
-- 将特殊召唤的怪兽返回持有者卡组的效果处理。
function c34680482.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 给双方显示卡图动画，提示现在正在处理该卡的效果。
	Duel.Hint(HINT_CARD,0,34680482)
	-- 将目标怪兽返回持有者卡组并洗牌（以效果原因）。
	Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end

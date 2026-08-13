--ブースター・ドラゴン
-- 效果：
-- 「弹丸」怪兽2只
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：1回合1次，以场上1只其他的表侧表示怪兽为对象才能发动（对方不能对应这个效果的发动把卡的效果发动）。那只怪兽的攻击力·守备力上升500。
-- ②：连接召唤的这张卡被战斗·效果破坏送去墓地的场合，以自己墓地1只其他的龙族怪兽为对象才能发动。那只怪兽特殊召唤。
function c12023931.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡注册连接召唤手续，要求素材为2只「弹丸」怪兽（卡名含有弹丸字段的怪兽），对应素材条件『「弹丸」怪兽2只』。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x102),2,2)
	-- ①：1回合1次，以场上1只其他的表侧表示怪兽为对象才能发动（对方不能对应这个效果的发动把卡的效果发动）。那只怪兽的攻击力·守备力上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12023931,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c12023931.atktg)
	e1:SetOperation(c12023931.atkop)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：连接召唤的这张卡被战斗·效果破坏送去墓地的场合，以自己墓地1只其他的龙族怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(12023931,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,12023931)
	e2:SetCondition(c12023931.spcon)
	e2:SetTarget(c12023931.sptg)
	e2:SetOperation(c12023931.spop)
	c:RegisterEffect(e2)
end
-- ①效果的发动前处理：判定场上是否存在可选的表侧表示怪兽，让玩家选择1只本卡以外的表侧表示怪兽作为对象，并设置对方不能对应本次效果发动的连锁限制。
function c12023931.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() and chkc~=c end
	-- 效果发动合法性检查：从双方场上检查是否存在1只除本卡以外的表侧表示怪兽，若有则效果可以发动。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,c) end
	-- 向发动玩家发出选择表侧表示怪兽的提示，用于选择对象时的界面引导。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从双方主要怪兽区选择1只除本卡以外的表侧表示怪兽，并将其登记为当前连锁的效果对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c)
	-- 设置连锁限制：此效果发动后，对方不能连锁此效果发动卡的效果，对应原文括号内的限制。
	Duel.SetChainLimit(c12023931.chlimit)
end
-- 连锁限制函数：仅允许效果发动者（tp）自己连锁此效果，对方玩家（ep）不能连锁，从而实现对方不能对应发动效果。
function c12023931.chlimit(e,ep,tp)
	return tp==ep
end
-- ①效果处理：若对象怪兽仍表侧表示且与效果关联，则给它注册攻击力上升500的效果，并复制同一效果使其守备力也上升500。
function c12023931.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的那1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那只怪兽的攻击力·守备力上升500。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
	end
end
-- ②效果的发动条件：这张卡是连接召唤的场合，被战斗或效果破坏送去墓地，且破坏前位于主要怪兽区，满足这些条件才能发动。
function c12023931.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_LINK)
end
-- 特殊召唤对象的过滤函数：选择自己墓地1只其他的龙族怪兽，且该怪兽可以被玩家tp以效果方式特殊召唤（满足召唤条件和苏生限制）。
function c12023931.spfilter(c,e,tp)
	return c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动判定与选对象：检查自己场上是否有空余的主要怪兽区，且墓地是否存在可特殊召唤的龙族怪兽（本卡以外）；若存在则让玩家选择1只作为对象，并登记特殊召唤操作信息。
function c12023931.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c12023931.spfilter(chkc,e,tp) and chkc~=c end
	-- 效果发动合法性检查：必须自己场上主要怪兽区有至少1个空位才能发动②效果。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时墓地中必须存在1只满足特殊召唤条件的龙族怪兽（本卡以外）可以作为对象。
		and Duel.IsExistingTarget(c12023931.spfilter,tp,LOCATION_GRAVE,0,1,c,e,tp) end
	-- 向玩家显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只除本卡以外的符合条件的龙族怪兽作为特殊召唤对象，并登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c12023931.spfilter,tp,LOCATION_GRAVE,0,1,1,c,e,tp)
	-- 设置本次连锁的操作信息，标明该效果包含特殊召唤，处理时预计特殊召唤g中的1张卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果处理：取出对象怪兽，若对象仍与效果关联，则将其以表侧表示特殊召唤到发动者自己场上。
function c12023931.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得特殊召唤的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到玩家tp的场上，且不检查召唤条件和苏生限制（已经过滤过）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

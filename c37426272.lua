--マテリアクトル・エクサレプト
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：把手卡的这张卡给对方观看，从手卡丢弃1张其他卡才能发动。丢弃的卡以外的1只3星通常怪兽从自己的卡组·墓地加入手卡。那之后，可以把这张卡守备表示特殊召唤。
-- ②：自己·对方回合，把这张卡从手卡丢弃，以自己场上1只3阶超量怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升1500。
local s,id,o=GetID()
-- 初始化并注册卡片的两个效果：e1为手牌发动的①起动效果（检索3星通常怪兽并可特殊召唤），e2为手牌发动的②诱发即时效果（丢弃自身使3阶超量怪兽攻击力上升）。
function s.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：把手卡的这张卡给对方观看，从手卡丢弃1张其他卡才能发动。丢弃的卡以外的1只3星通常怪兽从自己的卡组·墓地加入手卡。那之后，可以把这张卡守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"加入手卡"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：自己·对方回合，把这张卡从手卡丢弃，以自己场上1只3阶超量怪兽为对象才能发动。那只怪兽的攻击力直到回合结束时上升1500。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"攻击力上升"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_HAND)
	e2:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置②效果可在伤害步骤中伤害计算前发动（满足伤害步骤条件限制）。
	e2:SetCondition(aux.dscon)
	e2:SetCost(s.atkcost)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
-- 发动代价检查：这张卡未处于公开状态，且自己手牌中存在可丢弃的其他卡。
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic()
		-- 检查自己手牌中是否存在这张卡以外可丢弃的卡。
		and Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 从手卡丢弃1张这张卡以外可丢弃的卡作为发动代价（丢弃理由为代价+丢弃）。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD,e:GetHandler())
	-- 获取因丢弃代价实际被送去墓地的卡。
	local g=Duel.GetOperatedGroup()
	-- 将丢弃的卡设置为效果关联对象，用于处理检索时排除丢弃的卡。
	Duel.SetTargetCard(g)
end
-- 定义检索过滤条件：等级3的通常怪兽，且可以被加入手卡。
function s.thfilter(c)
	return c:IsLevel(3) and c:IsType(TYPE_NORMAL) and c:IsAbleToHand()
end
-- ①效果的目标判定与发动信息设置：确认卡组·墓地存在符合条件的3星通常怪兽，并设置操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组·墓地是否存在1只符合条件的3星通常怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置本效果将执行从卡组·墓地选1张卡加入手卡的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果处理：从卡组·墓地选1只3星通常怪兽加入手卡（排除已丢弃的卡），让对方确认；若加入成功且这张卡仍可特殊召唤，由玩家选择是否将其守备表示特殊召唤。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得作为排除参考的已丢弃卡。
	local tc=Duel.GetFirstTarget()
	local ec=nil
	if tc:IsRelateToEffect(e) then ec=tc end
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己卡组·墓地选择1只3星通常怪兽加入手卡，排除丢弃卡，并应用王家长眠之谷的效果过滤。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,ec)
	local hc=g:GetFirst()
	-- 将选择的卡加入手卡；若加入操作成功且该卡确实在手牌，才继续后续处理。
	if hc and Duel.SendtoHand(hc,nil,REASON_EFFECT)~=0 and hc:IsLocation(LOCATION_HAND) then
		-- 让对方玩家确认加入手卡的卡。
		Duel.ConfirmCards(1-tp,g)
		-- 检查自己场上是否有可用怪兽区域，且这张卡仍与效果关联。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsRelateToEffect(e)
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
			-- 询问玩家是否将这张卡守备表示特殊召唤。
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把这张卡特殊召唤？"
			-- 中断当前效果处理，使后续特殊召唤与之前的处理分开，对应效果原文的“那之后”。
			Duel.BreakEffect()
			-- 将这张卡以守备表示特殊召唤到自己场上。
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	end
end
-- ②效果发动代价：确认这张卡可以丢弃，并将其丢弃。
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将这张卡从手牌丢弃送去墓地作为发动代价。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 定义②效果的对象过滤条件：表侧表示且阶级为3的超量怪兽。
function s.atkfilter(c)
	return c:IsFaceup() and c:IsRank(3)
end
-- 连锁处理时校验对象仍为场上表侧表示且阶级3的超量怪兽（按此处代码控制者条件为~=tp，与原文“自己场上”不一致，疑为笔误）。
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.atkfilter(chkc)
		and chkc:GetControler()~=tp end
	-- 检查自己场上是否存在表侧表示3阶超量怪兽可作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(s.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要作为效果对象的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 从自己场上选择1只表侧表示3阶超量怪兽作为效果对象并登记。
	Duel.SelectTarget(tp,s.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：获取对象，若对象仍与效果关联且表侧表示，则使其攻击力直到回合结束时上升1500。
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽的攻击力直到回合结束时上升1500。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end

--まどろみの神碑
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以从以下效果选择1个发动。这张卡的发动后，下次的自己战斗阶段跳过。
-- ●以场上1只表侧表示怪兽为对象才能发动。这个回合，那只怪兽只有1次不会被战斗·效果破坏，不能攻击。那之后，从对方卡组上面把3张卡除外。
-- ●从额外卡组把1只「神碑」怪兽在额外怪兽区域特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，分别注册了“破坏抗性+除外”和“特殊召唤”两个可选择发动的效果。
function s.initial_effect(c)
	-- ●以场上1只表侧表示怪兽为对象才能发动。这个回合，那只怪兽只有1次不会被战斗·效果破坏，不能攻击。那之后，从对方卡组上面把3张卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"破坏抗性"
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_DISABLE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ●从额外卡组把1只「神碑」怪兽在额外怪兽区域特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 效果1的靶向/发动条件判定函数，检查场上是否存在表侧表示怪兽，以及对方卡组上方是否有3张卡可以除外。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查场上是否存在可以作为效果对象的表侧表示怪兽。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		-- 检查对方卡组最上方的3张卡是否都能被除外。
		and Duel.GetDecktopGroup(1-tp,3):FilterCount(Card.IsAbleToRemove,nil)==3 end
	-- 向对方玩家提示当前选择发动的是“破坏抗性”效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 提示玩家选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 玩家选择场上1只表侧表示怪兽作为效果对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息：从对方卡组除外3张卡。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,3,1-tp,LOCATION_DECK)
end
-- 效果1的处理函数，为目标怪兽赋予1次破坏抗性并限制攻击，之后除外对方卡组最上方的3张卡，最后适用跳过下次战斗阶段的效果。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的第一个（也是唯一一个）对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		-- 这个回合，那只怪兽只有1次不会被战斗·效果破坏
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCountLimit(1)
		e1:SetValue(s.valcon)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 不能攻击
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CANNOT_ATTACK)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		-- 获取对方卡组最上方的3张卡。
		local g=Duel.GetDecktopGroup(1-tp,3)
		if #g>0 then
			-- 中断当前效果处理，用于连接“那之后”的除外处理（使前后处理不同时进行，避免错时点）。
			Duel.BreakEffect()
			-- 禁用接下来的洗牌检测，防止在从卡组顶端除外卡片时自动洗牌。
			Duel.DisableShuffleCheck()
			-- 将获取到的对方卡组顶端的3张卡以表侧表示除外。
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	end
	s.skipop(e,tp)
end
-- 破坏抗性的过滤条件函数，判定破坏原因是否为战斗或效果。
function s.valcon(e,re,r,rp)
	return bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0
end
-- 额外卡组特殊召唤的过滤条件函数，筛选可以特殊召唤到额外怪兽区域的「神碑」怪兽。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x17f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查玩家在额外怪兽区域（Zone 0x60，即第5、6格）是否有可用的空位来特殊召唤该怪兽。
		and Duel.GetLocationCountFromEx(tp,tp,nil,c,0x60)>0
end
-- 效果2的靶向/发动条件判定函数，检查额外卡组是否存在可特殊召唤的「神碑」怪兽并设置特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组是否存在至少1只满足特殊召唤条件的「神碑」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 向对方玩家提示当前选择发动的是“特殊召唤”效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置效果处理信息：从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果2的处理函数，从额外卡组选择1只「神碑」怪兽在额外怪兽区域特殊召唤，最后适用跳过下次战斗阶段的效果。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从额外卡组选择1只满足条件的「神碑」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到额外怪兽区域（Zone 0x60）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP,0x60)
	end
	s.skipop(e,tp)
end
-- 注册跳过下次自己战斗阶段效果的辅助函数。
function s.skipop(e,tp)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 获取当前的游戏阶段。
		local ph=Duel.GetCurrentPhase()
		-- 这张卡的发动后，下次的自己战斗阶段跳过。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_SKIP_BP)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
		e1:SetTargetRange(1,0)
		-- 判定当前是否为自己的回合，且处于战斗阶段或主要阶段1之后、主要阶段2之前（即战斗阶段中或刚结束战斗阶段）。
		if Duel.GetTurnPlayer()==tp and ph>PHASE_MAIN1 and ph<PHASE_MAIN2 then
			-- 将当前回合数记录在效果的Label中，用于后续判定是否在当前回合跳过。
			e1:SetLabel(Duel.GetTurnCount())
			e1:SetCondition(s.skipcon)
			e1:SetReset(RESET_PHASE+PHASE_BATTLE+RESET_SELF_TURN,2)
		else
			e1:SetReset(RESET_PHASE+PHASE_BATTLE+RESET_SELF_TURN,1)
		end
		-- 将跳过战斗阶段的全局效果注册给发动卡片的玩家。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 跳过战斗阶段效果的适用条件函数，用于确保不会在已经过了战斗阶段的当前回合错误地再次触发跳过。
function s.skipcon(e)
	-- 判定当前回合数不等于记录的回合数时，跳过战斗阶段的效果才生效（即在下一次自己的回合生效）。
	return Duel.GetTurnCount()~=e:GetLabel()
end

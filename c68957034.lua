--輝く炎の神碑
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以从以下效果选择1个发动。这张卡的发动后，下次的自己战斗阶段跳过。
-- ●以特殊召唤的对方场上1只怪兽为对象才能发动。那只怪兽破坏。那之后，从对方卡组上面把2张卡除外。
-- ●从额外卡组把1只「神碑」怪兽在额外怪兽区域特殊召唤。
local s,id,o=GetID()
-- 初始化函数，注册该卡片发动的两个可选效果（破坏并除外、特殊召唤额外怪兽）
function s.initial_effect(c)
	-- ●以特殊召唤的对方场上1只怪兽为对象才能发动。那只怪兽破坏。那之后，从对方卡组上面把2张卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"怪兽破坏"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_REMOVE)
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
-- 效果①（破坏并除外）的发动准备与合法性检测函数
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsSummonType(SUMMON_TYPE_SPECIAL) end
	-- 检查对方场上是否存在可以作为对象的特殊召唤的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsSummonType,tp,0,LOCATION_MZONE,1,nil,SUMMON_TYPE_SPECIAL)
		-- 并且检查对方卡组最上方的2张卡是否都能被除外
		and Duel.GetDecktopGroup(1-tp,2):FilterCount(Card.IsAbleToRemove,nil)==2 end
	-- 向对方玩家提示当前选择发动的是“怪兽破坏”效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置选择卡片时的提示信息为“请选择要破坏的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择对方场上1只特殊召唤的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsSummonType,tp,0,LOCATION_MZONE,1,1,nil,SUMMON_TYPE_SPECIAL)
	-- 设置连锁信息，表明此效果包含破坏该对象怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置连锁信息，表明此效果包含从对方卡组除外2张卡的操作
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,2,1-tp,LOCATION_DECK)
end
-- 效果①（破坏并除外）的效果处理函数
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍在该效果的连锁中，则将其因效果破坏，并确认是否破坏成功
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0 then
		-- 获取对方卡组最上方的2张卡
		local g=Duel.GetDecktopGroup(1-tp,2)
		if #g>0 then
			-- 中断当前效果处理，使后续的除外处理与破坏处理不视为同时进行
			Duel.BreakEffect()
			-- 禁用接下来的洗牌检测，防止因从卡组除外卡片而导致系统自动洗牌
			Duel.DisableShuffleCheck()
			-- 将获取到的对方卡组最上方的2张卡表侧表示除外
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	end
	s.skipop(e,tp)
end
-- 过滤额外卡组中可以特殊召唤到额外怪兽区域的「神碑」怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x17f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 并且检查额外怪兽区域（Zone 0x60）是否有可用的空位
		and Duel.GetLocationCountFromEx(tp,tp,nil,c,0x60)>0
end
-- 效果②（特殊召唤）的发动准备与合法性检测函数
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自身额外卡组是否存在满足特殊召唤条件的「神碑」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 向对方玩家提示当前选择发动的是“特殊召唤”效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置连锁信息，表明此效果包含从额外卡组特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果②（特殊召唤）的效果处理函数
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 设置选择卡片时的提示信息为“请选择要特殊召唤的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组选择1只满足条件的「神碑」怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽在额外怪兽区域（Zone 0x60）表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP,0x60)
	end
	s.skipop(e,tp)
end
-- 注册跳过下次自己战斗阶段效果的辅助函数
function s.skipop(e,tp)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 获取当前的游戏阶段
		local ph=Duel.GetCurrentPhase()
		-- 这张卡的发动后，下次的自己战斗阶段跳过。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_SKIP_BP)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
		e1:SetTargetRange(1,0)
		-- 判定当前是否为自己的战斗阶段（若在战斗阶段中发动，则需要特殊处理跳过下一次）
		if Duel.GetTurnPlayer()==tp and ph>PHASE_MAIN1 and ph<PHASE_MAIN2 then
			-- 将当前回合数记录在效果的Label中，用于后续判定
			e1:SetLabel(Duel.GetTurnCount())
			e1:SetCondition(s.skipcon)
			e1:SetReset(RESET_PHASE+PHASE_BATTLE+RESET_SELF_TURN,2)
		else
			e1:SetReset(RESET_PHASE+PHASE_BATTLE+RESET_SELF_TURN,1)
		end
		-- 将跳过战斗阶段的全局效果注册给发动玩家
		Duel.RegisterEffect(e1,tp)
	end
end
-- 跳过战斗阶段效果的生效条件函数
function s.skipcon(e)
	-- 确保跳过战斗阶段的效果不会在当前回合（即发动该效果的当前战斗阶段）立即生效，而是跳过下一次
	return Duel.GetTurnCount()~=e:GetLabel()
end

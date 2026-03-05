--黄金の雫の神碑
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以从以下效果选择1个发动。这张卡的发动后，下次的自己战斗阶段跳过。
-- ●对方从卡组抽1张。那之后，从对方卡组上面把4张卡除外。
-- ●从额外卡组把1只「神碑」怪兽在额外怪兽区域特殊召唤。
local s,id,o=GetID()
-- 创建两个效果，分别对应两种发动效果：对方抽卡和特殊召唤
function s.initial_effect(c)
	-- ●对方从卡组抽1张。那之后，从对方卡组上面把4张卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"对方抽卡"
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_REMOVE)
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
-- 检查是否满足对方抽卡效果的发动条件
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方是否可以抽1张卡
	if chk==0 then return Duel.IsPlayerCanDraw(1-tp,1) and Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>=5
		-- 检查对方卡组顶部是否有4张可除外的卡
		and Duel.GetDecktopGroup(1-tp,4):FilterCount(Card.IsAbleToRemove,nil)==4 end
	-- 向对方提示选择了效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息：对方抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,1-tp,1)
	-- 设置操作信息：从对方卡组除外4张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,4,1-tp,LOCATION_DECK)
end
-- 执行对方抽卡并除外卡组顶部4张卡的效果
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 对方抽1张卡，若成功则继续处理
	if Duel.Draw(1-tp,1,REASON_EFFECT)~=0 then
		-- 获取对方卡组顶部4张卡
		local g=Duel.GetDecktopGroup(1-tp,4)
		if #g>0 then
			-- 中断当前效果处理，使后续处理视为不同时处理
			Duel.BreakEffect()
			-- 禁止接下来的操作进行洗切卡组检查
			Duel.DisableShuffleCheck()
			-- 将对方卡组顶部4张卡除外
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	end
	s.skipop(e,tp)
end
-- 定义特殊召唤的过滤条件：是神碑卡组、可特殊召唤、且有召唤位置
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x17f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查是否有足够的额外怪兽区域进行特殊召唤
		and Duel.GetLocationCountFromEx(tp,tp,nil,c,0x60)>0
end
-- 设置特殊召唤效果的发动条件
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的额外卡组怪兽可特殊召唤
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 向对方提示选择了效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息：特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 执行特殊召唤效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的1只额外卡组怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP,0x60)
	end
	s.skipop(e,tp)
end
-- 设置跳过下次自己战斗阶段的效果
function s.skipop(e,tp)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 获取当前阶段
		local ph=Duel.GetCurrentPhase()
		-- 创建跳过战斗阶段的效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_SKIP_BP)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
		e1:SetTargetRange(1,0)
		-- 判断是否在自己的回合且处于主要阶段1到主要阶段2之间
		if Duel.GetTurnPlayer()==tp and ph>PHASE_MAIN1 and ph<PHASE_MAIN2 then
			-- 记录当前回合数用于条件判断
			e1:SetLabel(Duel.GetTurnCount())
			e1:SetCondition(s.skipcon)
			e1:SetReset(RESET_PHASE+PHASE_BATTLE+RESET_SELF_TURN,2)
		else
			e1:SetReset(RESET_PHASE+PHASE_BATTLE+RESET_SELF_TURN,1)
		end
		-- 注册跳过战斗阶段的效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 跳过战斗阶段效果的条件函数
function s.skipcon(e)
	-- 若当前回合数不等于记录的回合数，则跳过战斗阶段
	return Duel.GetTurnCount()~=e:GetLabel()
end

--破壊の神碑
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以从以下效果选择1个发动。这张卡的发动后，下次的自己战斗阶段跳过。
-- ●以对方场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。那之后，从对方卡组上面把4张卡除外。
-- ●从额外卡组把1只「神碑」怪兽在额外怪兽区域特殊召唤。
local s,id,o=GetID()
-- 初始化函数，注册卡片的两个可选发动的效果分支
function s.initial_effect(c)
	-- ●以对方场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。那之后，从对方卡组上面把4张卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"魔陷破坏"
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
-- 过滤对方场上魔法·陷阱卡的条件函数
function s.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果①分支一（破坏魔陷并除外卡组）的发动准备与合法性检测函数
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.desfilter(chkc) and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在可以作为对象的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,0,LOCATION_ONFIELD,1,nil)
		-- 检查对方卡组最上方4张卡是否都能被除外
		and Duel.GetDecktopGroup(1-tp,4):FilterCount(Card.IsAbleToRemove,nil)==4 end
	-- 向对方玩家提示本卡选择发动的分支效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择对方场上1张魔法·陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,s.desfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置破坏操作的信息，表示将破坏选中的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置除外操作的信息，表示将除外对方卡组上方的4张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,4,1-tp,LOCATION_DECK)
end
-- 效果①分支一（破坏魔陷并除外卡组）的效果处理函数
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取在发动时选择的魔法·陷阱卡对象
	local tc=Duel.GetFirstTarget()
	-- 若对象卡仍存在于场上，则将其因效果破坏，并判断是否破坏成功
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0 then
		-- 获取对方卡组最上方的4张卡
		local g=Duel.GetDecktopGroup(1-tp,4)
		if #g>0 then
			-- 中断当前效果处理，使后续的除外处理与破坏处理不视为同时进行
			Duel.BreakEffect()
			-- 禁用接下来的洗牌检测，防止在除外卡组顶端卡片时自动洗牌
			Duel.DisableShuffleCheck()
			-- 将获取到的对方卡组最上方的4张卡表侧表示除外
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	end
	s.skipop(e,tp)
end
-- 过滤额外卡组中可以特殊召唤的「神碑」怪兽的条件函数
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x17f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查额外怪兽区域（0x60）是否有可用的空格用于特殊召唤该怪兽
		and Duel.GetLocationCountFromEx(tp,tp,nil,c,0x60)>0
end
-- 效果①分支二（特殊召唤神碑怪兽）的发动准备与合法性检测函数
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组是否存在可以特殊召唤的「神碑」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 向对方玩家提示本卡选择发动的分支效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置特殊召唤操作的信息，表示将从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果①分支二（特殊召唤神碑怪兽）的效果处理函数
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从额外卡组选择1只满足条件的「神碑」怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的「神碑」怪兽在额外怪兽区域表侧表示特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP,0x60)
	end
	s.skipop(e,tp)
end
-- 注册跳过下次自己战斗阶段效果的函数
function s.skipop(e,tp)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 获取当前所处的阶段
		local ph=Duel.GetCurrentPhase()
		-- 这张卡的发动后，下次的自己战斗阶段跳过。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_SKIP_BP)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
		e1:SetTargetRange(1,0)
		-- 判断当前是否为自己的回合且处于战斗阶段中（若在战斗阶段中发动，则需要跳过下个回合的战斗阶段，即持续2个回合的重置判定）
		if Duel.GetTurnPlayer()==tp and ph>PHASE_MAIN1 and ph<PHASE_MAIN2 then
			-- 将当前回合数记录在效果的Label中，用于后续判断是否为同一回合
			e1:SetLabel(Duel.GetTurnCount())
			e1:SetCondition(s.skipcon)
			e1:SetReset(RESET_PHASE+PHASE_BATTLE+RESET_SELF_TURN,2)
		else
			e1:SetReset(RESET_PHASE+PHASE_BATTLE+RESET_SELF_TURN,1)
		end
		-- 将跳过战斗阶段的全局效果注册给发动卡片的玩家
		Duel.RegisterEffect(e1,tp)
	end
end
-- 判定跳过战斗阶段效果是否生效的条件函数
function s.skipcon(e)
	-- 确保在当前回合（即发动卡片的回合）不适用跳过战斗阶段的效果（因为已经在战斗阶段中，跳过的是“下次”战斗阶段）
	return Duel.GetTurnCount()~=e:GetLabel()
end

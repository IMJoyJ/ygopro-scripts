--怒れる嵐の神碑
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以从以下效果选择1个发动。这张卡的发动后，下次的自己战斗阶段跳过。
-- ●把最多有对方场上的卡数量的卡从对方卡组上面除外。
-- ●从额外卡组把1只「神碑」怪兽在额外怪兽区域特殊召唤。
local s,id,o=GetID()
-- 注册卡片初始效果（包含两个可选的发动效果，分别对应卡组除外和特殊召唤）
function s.initial_effect(c)
	-- ●把最多有对方场上的卡数量的卡从对方卡组上面除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"卡组除外"
	e1:SetCategory(CATEGORY_REMOVE)
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
-- 效果1（卡组除外）的发动准备与合法性检测函数
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在卡片
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)>0
		-- 并且对方卡组最上方至少有1张卡可以被除外
		and Duel.GetDecktopGroup(1-tp,1):FilterCount(Card.IsAbleToRemove,nil)>0 end
	-- 向对方玩家提示当前发动的效果（卡组除外）
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息，表示此效果会从对方卡组除外卡片
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_DECK)
end
-- 效果1（卡组除外）的处理函数
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的卡片数量
	local ct1=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)
	-- 获取对方卡组最上方对应数量的卡片中，可以被除外的卡片数量
	local ct2=Duel.GetDecktopGroup(1-tp,ct1):FilterCount(Card.IsAbleToRemove,nil)
	if ct1>0 and ct2>0 then
		local num={}
		local i=1
		while i<=ct1 and i<=ct2 do
			num[i]=i
			i=i+1
		end
		-- 提示玩家选择要除外的卡片数量
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))  --"请选择要除外的卡的数量"
		-- 让玩家宣言一个要除外的卡片数量
		local ct=Duel.AnnounceNumber(tp,table.unpack(num))
		-- 获取对方卡组最上方对应宣言数量的卡片组
		local g=Duel.GetDecktopGroup(1-tp,ct)
		-- 使得接下来的除外操作不触发卡组洗牌检测
		Duel.DisableShuffleCheck()
		-- 将获取的卡片组以表侧表示因效果除外
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
	s.skipop(e,tp)
end
-- 过滤额外卡组中可以特殊召唤到额外怪兽区域的「神碑」怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x17f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 并且额外怪兽区域有可用的空位
		and Duel.GetLocationCountFromEx(tp,tp,nil,c,0x60)>0
end
-- 效果2（特殊召唤）的发动准备与合法性检测函数
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组是否存在满足特殊召唤条件的「神碑」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 向对方玩家提示当前发动的效果（特殊召唤）
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息，表示此效果会从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果2（特殊召唤）的处理函数
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从额外卡组选择1只满足条件的「神碑」怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽在额外怪兽区域以表侧表示特殊召唤
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
		-- 判断当前是否为自己的战斗阶段中
		if Duel.GetTurnPlayer()==tp and ph>PHASE_MAIN1 and ph<PHASE_MAIN2 then
			-- 将当前回合数记录在效果的Label中
			e1:SetLabel(Duel.GetTurnCount())
			e1:SetCondition(s.skipcon)
			e1:SetReset(RESET_PHASE+PHASE_BATTLE+RESET_SELF_TURN,2)
		else
			e1:SetReset(RESET_PHASE+PHASE_BATTLE+RESET_SELF_TURN,1)
		end
		-- 给玩家注册跳过战斗阶段的全局效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 跳过战斗阶段效果的生效条件函数
function s.skipcon(e)
	-- 确保跳过效果不会在发动此卡的当前回合的战斗阶段立即生效
	return Duel.GetTurnCount()~=e:GetLabel()
end

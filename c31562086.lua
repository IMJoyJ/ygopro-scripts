--神碑の穂先
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以从以下效果选择1个发动。这张卡的发动后，下次的自己战斗阶段跳过。
-- ●从卡组把「神碑的锋芒」以外的1张「神碑」卡加入手卡。那之后，从对方卡组上面把1张卡除外。
-- ●从额外卡组把1只「神碑」怪兽在额外怪兽区域特殊召唤。
local s,id,o=GetID()
-- 创建两个效果，分别对应两种发动效果：卡组检索和特殊召唤
function s.initial_effect(c)
	-- 创建第一个效果，用于卡组检索，设置发动次数限制为1次
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 创建第二个效果，用于特殊召唤，设置发动次数限制为1次
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
-- 定义过滤函数，用于检索满足条件的「神碑」卡
function s.thfilter(c)
	return c:IsSetCard(0x17f) and not c:IsCode(id) and c:IsAbleToHand()
end
-- 判断是否满足检索条件，即卡组中存在「神碑」卡且对方卡组顶有可除外的卡
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断卡组中是否存在满足条件的「神碑」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		-- 判断对方卡组顶是否存在可除外的卡
		and Duel.GetDecktopGroup(1-tp,1):FilterCount(Card.IsAbleToRemove,nil)==1 end
	-- 向对方玩家提示发动了效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息，表示将从卡组检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息，表示将从对方卡组顶除外1张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_DECK)
end
-- 执行卡组检索效果，选择卡加入手牌并除外对方卡组顶的卡
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡加入手牌
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 判断是否成功将卡加入手牌
	if #g>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		-- 确认对方卡组顶的卡
		Duel.ConfirmCards(1-tp,g)
		-- 洗切自己的卡组
		Duel.ShuffleDeck(tp)
		-- 获取对方卡组顶的卡
		local g1=Duel.GetDecktopGroup(1-tp,1)
		if #g1>0 then
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 禁止接下来的操作进行洗卡检测
			Duel.DisableShuffleCheck()
			-- 将对方卡组顶的卡除外
			Duel.Remove(g1,POS_FACEUP,REASON_EFFECT)
		end
	end
	s.skipop(e,tp)
end
-- 定义过滤函数，用于检索满足条件的额外卡组「神碑」怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x17f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 判断额外卡组是否有足够的召唤位置
		and Duel.GetLocationCountFromEx(tp,tp,nil,c,0x60)>0
end
-- 设置特殊召唤效果的目标函数，判断是否存在满足条件的怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断额外卡组中是否存在满足条件的「神碑」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 向对方玩家提示发动了效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息，表示将从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 执行特殊召唤效果，选择怪兽特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽进行特殊召唤
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP,0x60)
	end
	s.skipop(e,tp)
end
-- 设置跳过下次自己战斗阶段的效果
function s.skipop(e,tp)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 获取当前阶段
		local ph=Duel.GetCurrentPhase()
		-- 创建跳过战斗阶段的效果，根据当前阶段设置重置条件
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_SKIP_BP)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
		e1:SetTargetRange(1,0)
		-- 判断是否为自己的回合且当前阶段在主要阶段1和主要阶段2之间
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
	-- 判断当前回合数是否与记录的回合数不同
	return Duel.GetTurnCount()~=e:GetLabel()
end

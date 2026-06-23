--ハネクリボー・サバティエル LV１０
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把手卡的这张卡给对方观看，把基本分支付一半才能发动。从卡组把1张「融合」魔法卡加入手卡，这张卡回到卡组。这个回合，自己不是「英雄」怪兽不能从额外卡组特殊召唤。
-- ②：对方回合，自己基本分是1000以下的场合才能发动。这张卡从手卡特殊召唤。那之后，可以给与对方为对方场上的怪兽的最高攻击力数值的伤害。
local s,id,o=GetID()
-- 注册卡片效果的函数
function s.initial_effect(c)
	-- 把手卡的这张卡给对方观看，把基本分支付一半才能发动。从卡组把1张「融合」魔法卡加入手卡，这张卡回到卡组。这个回合，自己不是「英雄」怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索效果"
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- 对方回合，自己基本分是1000以下的场合才能发动。这张卡从手卡特殊召唤。那之后，可以给与对方为对方场上的怪兽的最高攻击力数值的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 检索效果的发动代价与准备函数
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
	-- 玩家支付一半的生命值作为发动代价
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
-- 过滤函数：卡组中可以加入手牌的「融合」魔法卡
function s.thfilter(c)
	return c:IsSetCard(0x46) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 检索效果的发动准备与合法性检测函数
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检测自己卡组是否存在可以检索的「融合」魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		and c:IsAbleToDeck() end
	-- 设置连锁操作信息：包含从卡组将卡加入手牌的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的效果处理函数
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 给玩家提示：选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择卡组中1张满足条件的「融合」魔法卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认检索到的卡
		Duel.ConfirmCards(1-tp,g)
		if c:IsRelateToChain() then
			-- 将这张卡回到持有者的卡组并洗切
			Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
	-- 这个回合，自己不是「英雄」怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 向玩家注册直到回合结束前自己不能特殊召唤「英雄」以外的额外卡组怪兽的效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤额外卡组非「英雄」怪兽的过滤函数
function s.splimit(e,c)
	return not c:IsSetCard(0x8) and c:IsLocation(LOCATION_EXTRA)
end
-- 特殊召唤效果的发动条件判定函数
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为对方回合，且自己基本分是否在1000以下
	return Duel.GetTurnPlayer()==1-tp and Duel.GetLP(tp)<=1000
end
-- 特殊召唤效果的发动准备与合法性检测函数
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP) end
	-- 设置连锁操作信息：包含特殊召唤这张卡的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 过滤函数：对方场上表侧表示且攻击力不为0的怪兽
function s.atkfilter(c)
	return c:IsFaceup() and not c:IsAttack(0)
end
-- 特殊召唤效果的效果处理函数
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断这张卡是否仍与连锁相关并特殊召唤，确认是否特殊召唤成功
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 检测对方场上是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(s.atkfilter,tp,0,LOCATION_MZONE,1,nil)
		-- 选择是否给与对方伤害
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否给与伤害？"
		-- 获取对方场上表侧表示的怪兽组
		local g=Duel.GetMatchingGroup(s.atkfilter,tp,0,LOCATION_MZONE,nil)
		local tc=g:GetMaxGroup(Card.GetAttack):GetFirst()
		-- 中断效果处理，使之后的效果处理视为不同时处理
		Duel.BreakEffect()
		-- 给与对方为对方场上的怪兽的最高攻击力数值的伤害
		Duel.Damage(1-tp,tc:GetAttack(),REASON_EFFECT)
	end
end

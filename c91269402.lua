--サイバース・ビーコン
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：战斗或者对方的效果让自己受到伤害的回合才能发动。从卡组把1只4星以下的电子界族怪兽加入手卡。
function c91269402.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：战斗或者对方的效果让自己受到伤害的回合才能发动。从卡组把1只4星以下的电子界族怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_END_PHASE)
	e1:SetCountLimit(1,91269402+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c91269402.condition)
	e1:SetTarget(c91269402.target)
	e1:SetOperation(c91269402.activate)
	c:RegisterEffect(e1)
	if not c91269402.global_check then
		c91269402.global_check=true
		-- 战斗或者对方的效果让自己受到伤害的回合才能发动。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DAMAGE)
		ge1:SetOperation(c91269402.checkop)
		-- 将用于监测伤害事件的全局效果注册给系统环境
		Duel.RegisterEffect(ge1,0)
	end
end
-- 伤害事件发生时的处理函数，用于判断是否满足战斗伤害或对方造成的效果伤害，并为受伤害玩家注册标识
function c91269402.checkop(e,tp,eg,ep,ev,re,r,rp)
	if (bit.band(r,REASON_EFFECT)~=0 and rp==1-ep) or bit.band(r,REASON_BATTLE)~=0 then
		-- 为受到伤害的玩家注册一个持续到回合结束的标识效果，用于记录该回合受过伤害
		Duel.RegisterFlagEffect(ep,91269402,RESET_PHASE+PHASE_END,0,1)
	end
end
-- 效果的发动条件函数，判断当前回合自己是否受到过伤害
function c91269402.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前玩家是否拥有受伤害的标识，若数量不为0则允许发动
	return Duel.GetFlagEffect(tp,91269402)~=0
end
-- 过滤函数，筛选卡组中可以加入手牌的4星以下的电子界族怪兽
function c91269402.filter(c)
	return c:IsAbleToHand() and c:IsRace(RACE_CYBERSE) and c:IsLevelBelow(4)
end
-- 效果的发动准备与检测函数，确认卡组中存在可检索的怪兽并设置操作信息
function c91269402.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查卡组中是否存在至少1张满足过滤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c91269402.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，声明该效果的处理包含将卡组中的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果的处理函数，执行从卡组将怪兽加入手牌的具体操作
function c91269402.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 向发动效果的玩家发送提示信息，要求其选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c91269402.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡因效果加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡给对方玩家进行确认
		Duel.ConfirmCards(1-tp,g)
	end
end

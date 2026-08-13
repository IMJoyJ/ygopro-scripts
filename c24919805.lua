--無頼特急バトレイン
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：1回合1次，自己主要阶段才能发动。给与对方500伤害。这个效果发动的回合，自己不能进行战斗阶段。
-- ②：这张卡被送去墓地的回合的结束阶段才能发动。从卡组把1只机械族·地属性·10星怪兽加入手卡。
function c24919805.initial_effect(c)
	-- ①：1回合1次，自己主要阶段才能发动。给与对方500伤害。这个效果发动的回合，自己不能进行战斗阶段。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(24919805,0))  --"LP伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c24919805.damcost)
	e1:SetTarget(c24919805.damtg)
	e1:SetOperation(c24919805.damop)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡被送去墓地的回合的结束阶段才能发动。从卡组把1只机械族·地属性·10星怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(c24919805.regop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件与代价：仅在主要阶段1可发动，成功后为发动者附加该回合不能进行战斗阶段的誓约效果。
function c24919805.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查：当前必须处于主要阶段1，否则不能发动。
	if chk==0 then return Duel.GetCurrentPhase()==PHASE_MAIN1 end
	-- ①：给与对方500伤害。这个效果发动的回合，自己不能进行战斗阶段。②：这张卡被送去墓地的回合的结束阶段才能发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将不能进行战斗阶段的誓约效果注册给当前玩家tp，该效果持续到结束阶段。
	Duel.RegisterEffect(e1,tp)
end
-- 设置①效果的对象与数值：对象为对方玩家，伤害为500，并写入连锁操作信息。
function c24919805.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设为对方玩家。
	Duel.SetTargetPlayer(1-tp)
	-- 将当前连锁的对象参数设为500，即伤害数值。
	Duel.SetTargetParam(500)
	-- 设置连锁操作信息：本次效果会给予对方玩家500点伤害，用于时点判定。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- ①效果处理：读取连锁记录的对象玩家和伤害数值，实际执行伤害。
function c24919805.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中保存的对象玩家和伤害参数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 给予对象玩家500点效果伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 这张卡被送去墓地时的辅助效果：为当前卡片注册一个结束阶段才能发动的检索效果（②效果），并设置卡名次数限制、对象与操作。
function c24919805.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡被送去墓地的回合的结束阶段才能发动。从卡组把1只机械族·地属性·10星怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(24919805,1))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,24919805)
	e1:SetTarget(c24919805.thtg)
	e1:SetOperation(c24919805.thop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
-- 检索/加入手卡的过滤条件：10星、机械族、地属性且可以被加入手卡的怪兽。
function c24919805.filter(c)
	return c:IsLevel(10) and c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsAbleToHand()
end
-- ②效果的发动条件判定：卡组中存在符合条件的怪兽；并设置操作信息为将卡组1只怪兽加入手卡。
function c24919805.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在至少1只满足条件的机械族·地属性·10星怪兽，作为能否发动的条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c24919805.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本连锁的操作信息：从卡组将1张卡加入手卡，用于触发相关卡片的判定。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：玩家从卡组选择1只符合条件的怪兽加入手卡，并展示给对方确认。
function c24919805.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示消息，要求玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组中选出1只满足过滤条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c24919805.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡片内容展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end

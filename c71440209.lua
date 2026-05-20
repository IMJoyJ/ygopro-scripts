--黒魔術の護符
-- 效果：
-- 这张卡也能把手卡1只魔法师族怪兽给对方观看，在盖放的回合发动。
-- ①：连锁有「黑魔术师」的卡名记述的卡的效果的发动让怪兽的效果发动时才能发动。那个效果无效，这个回合，原本卡名和那只怪兽相同的怪兽发动的效果无效化。
-- ②：这张卡在墓地存在的状态，自己把「黑魔术师」特殊召唤的场合，支付2500基本分才能发动。这张卡在自己场上盖放。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含盖放回合发动、无效怪兽效果、墓地自我盖放三个效果。
function s.initial_effect(c)
	-- 注册卡片关联密码，表明这张卡记述了「黑魔术师」（卡号46986414）。
	aux.AddCodeList(c,46986414)
	-- 这张卡也能把手卡1只魔法师族怪兽给对方观看，在盖放的回合发动。
	local e0=Effect.CreateEffect(c)
	e0:SetDescription(aux.Stringid(id,0))  --"适用「黑魔术的护符」的效果来发动"
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetValue(id)
	e0:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
	e0:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCondition(s.condition)
	e0:SetCost(s.cost)
	c:RegisterEffect(e0)
	-- ①：连锁有「黑魔术师」的卡名记述的卡的效果的发动让怪兽的效果发动时才能发动。那个效果无效，这个回合，原本卡名和那只怪兽相同的怪兽发动的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))  --"无效"
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.discon)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，自己把「黑魔术师」特殊召唤的场合，支付2500基本分才能发动。这张卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))  --"盖放"
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(s.setcon)
	e2:SetCost(s.setcost)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
-- 盖放回合发动的条件：卡片处于场上且是盖放的回合。
function s.condition(e)
	return e:GetHandler():IsStatus(STATUS_SET_TURN) and e:GetHandler():IsLocation(LOCATION_ONFIELD)
end
-- 过滤手卡中未公开的魔法师族怪兽。
function s.costfilter(c)
	return c:IsRace(RACE_SPELLCASTER) and not c:IsPublic()
end
-- 盖放回合发动的Cost：展示手卡中1只魔法师族怪兽。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在至少1只未公开的魔法师族怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要确认（展示）的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 玩家选择手卡中1只满足条件的魔法师族怪兽。
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 向对方玩家展示所选的怪兽。
	Duel.ConfirmCards(1-tp,g)
	-- 重新洗切手卡。
	Duel.ShuffleHand(tp)
end
-- 效果①的发动条件：连锁2以上，前一个连锁是记述有「黑魔术师」的卡的效果发动，当前连锁是怪兽效果的发动。
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前连锁的效果是否可以被无效，若不能则返回false。
	if not Duel.IsChainDisablable(ev) then return false end
	-- 获取前一个连锁的发动效果。
	local te=Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_EFFECT)
	-- 检查当前连锁数是否大于等于2（确保存在前一个连锁）。
	return Duel.GetCurrentChain()>=2
		-- 检查前一个连锁的效果来源卡片是否记述了「黑魔术师」，且当前连锁的效果是怪兽效果。
		and te and aux.IsCodeListed(te:GetHandler(),46986414) and re:IsActiveType(TYPE_MONSTER)
end
-- 效果①的靶向处理：设置效果无效的操作信息。
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使当前连锁的怪兽效果无效。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 效果①的效果处理：无效该怪兽效果，并注册一个本回合内使同名怪兽发动的效果无效的全局效果。
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	-- 如果成功无效了该连锁的效果，且该效果的来源卡片存在。
	if Duel.NegateEffect(ev) and rc then
		-- 这个回合，原本卡名和那只怪兽相同的怪兽发动的效果无效化。②：这张卡在墓地存在的状态，自己把「黑魔术师」特殊召唤的场合，支付2500基本分才能发动。这张卡在自己场上盖放。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAIN_SOLVING)
		e1:SetCondition(s.discon1)
		e1:SetOperation(s.disop1)
		e1:SetLabel(rc:GetOriginalCodeRule())
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册该回合内使同名怪兽效果无效的全局效果。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 检查发动的怪兽效果的卡片原本密码是否与被无效的怪兽相同。
function s.discon1(e,tp,eg,ep,ev,re,r,rp)
	local code=e:GetLabel()
	return re:GetHandler():IsOriginalCodeRule(code) and re:IsActiveType(TYPE_MONSTER)
end
-- 无效该怪兽效果。
function s.disop1(e,tp,eg,ep,ev,re,r,rp)
	-- 无效该连锁的效果。
	Duel.NegateEffect(ev)
end
-- 过滤自己特殊召唤的表侧表示的「黑魔术师」。
function s.setfilter(c,tp)
	return c:IsFaceup() and c:IsCode(46986414) and c:IsSummonPlayer(tp)
end
-- 检查特殊召唤的怪兽中是否存在自己特殊召唤的「黑魔术师」。
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.setfilter,1,nil,tp)
end
-- 效果②的Cost：检查并支付2500基本分。
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能支付2500基本分。
	if chk==0 then return Duel.CheckLPCost(tp,2500) end
	-- 扣除玩家2500基本分。
	Duel.PayLPCost(tp,2500)
end
-- 效果②的靶向处理：检查自身是否可以盖放，并设置从墓地离开的操作信息。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	-- 设置操作信息：此卡从墓地离开。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 效果②的效果处理：将墓地的这张卡在自己场上盖放。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否仍存在于墓地，且不受「王家长眠之谷」的影响。
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将此卡在自己场上盖放。
		Duel.SSet(tp,c)
	end
end

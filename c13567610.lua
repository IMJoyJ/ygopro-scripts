--無窮機竜カルノール
-- 效果：
-- 这张卡不能通常召唤。对方是这次决斗中有把手卡或墓地的怪兽的效果发动过的场合可以从手卡·墓地特殊召唤。自己对「无穷机龙 卡诺循环龙」1回合只能有1次特殊召唤。
-- ①：1回合1次，对方把怪兽的效果发动的场合才能发动。这张卡的攻击力上升1000。
-- ②：这张卡从手卡·卡组以外送去墓地的场合发动。这张卡回到卡组。
local s,id,o=GetID()
-- 初始化卡的各项效果：设定「无穷机龙 卡诺循环龙」1回合只能有1次特殊召唤并启用召唤限制；创建特殊召唤手续效果，使这张卡不能通常召唤，在对方本决斗中发动过手卡或墓地的怪兽效果时从手卡·墓地特殊召唤；注册活动计数器以记录对方发动手卡/墓地怪兽效果的事实；注册①效果（1回合1次，对方发动怪兽效果时攻击力上升1000）；注册②效果（从手卡·卡组以外送去墓地时回到卡组）。
function s.initial_effect(c)
	c:SetSPSummonOnce(id)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。对方是这次决斗中有把手卡或墓地的怪兽的效果发动过的场合可以从手卡·墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	-- 注册一个活动计数器（ACTIVITY_CHAIN），通过s.chainfilter过滤并记录对方是否发动过手卡或墓地的怪兽效果，为特殊召唤条件提供依据。
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,s.chainfilter)
	-- ①：1回合1次，对方把怪兽的效果发动的场合才能发动。这张卡的攻击力上升1000。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"攻击力上升"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.aucon)
	e2:SetTarget(s.autarget)
	e2:SetOperation(s.auop)
	c:RegisterEffect(e2)
	-- ②：这张卡从手卡·卡组以外送去墓地的场合发动。这张卡回到卡组。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"回到卡组"
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(s.tdcon)
	e3:SetTarget(s.tdtg)
	e3:SetOperation(s.tdop)
	c:RegisterEffect(e3)
end
-- 作为活动计数器的过滤函数：获取当前连锁效果发动的位置，若该效果是由对方从手卡或墓地发动的怪兽效果，则为发动者的对方（1-tp）注册特殊召唤条件标记，并返回false以计入该次活动；否则返回true。
function s.chainfilter(re,tp,cid)
	-- 获取当前连锁中触发效果的发动位置（如手卡、墓地等），用于判断是否属于“手卡或墓地的怪兽效果”。
	local loc=Duel.GetChainInfo(cid,CHAININFO_TRIGGERING_LOCATION)
	if re:IsActiveType(TYPE_MONSTER) and loc&(LOCATION_HAND|LOCATION_GRAVE)>0 then
		-- 给发动效果的玩家的对方（1-tp）注册一个id标记，表示该玩家在本决斗中已经发动过手卡或墓地的怪兽效果，以满足「无穷机龙 卡诺循环龙」的特殊召唤条件。
		Duel.RegisterFlagEffect(1-tp,id,0,0,0)
	end
	return not (re:IsActiveType(TYPE_MONSTER) and loc&(LOCATION_HAND|LOCATION_GRAVE)>0)
end
-- 特殊召唤手续的条件函数：若c为空则返回true（规则查询用）；否则检查控制者tp是否有对方发动过手卡/墓地怪兽效果的标记，以及tp场上是否有可用的主要怪兽区。
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 返回特殊召唤条件是否成立：控制者tp持有该标记且其场上存在可用的主要怪兽区域。
	return Duel.GetFlagEffect(tp,id)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
-- ①效果的发动条件：当前连锁由对方玩家（rp==1-tp）发动的怪兽效果时满足。
function s.aucon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER)
end
-- 效果发动时无取对象，仅在发动合法性检查（chk==0）时确认是对方发动怪兽效果，以允许该效果进入连锁。
function s.autarget(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return rp==1-tp end
end
-- ①效果处理：若这张卡仍与效果相关，则为自身注册一个攻击力上升1000的效果，该效果会随卡牌离场、重置等被清除。
function s.auop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 这张卡的攻击力上升1000。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- ②效果的发动条件：判定这张卡送去墓地前所在位置不是手牌或卡组（即从手卡·卡组以外送去墓地）。
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local loc=e:GetHandler():GetPreviousLocation()
	return loc&(LOCATION_HAND|LOCATION_DECK)==0
end
-- ②效果发动时无取对象，直接返回可发动，并设置将这张卡返回卡组的操作信息。
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的处理信息：处理类别为回卡组（CATEGORY_TODECK），对象为这张卡自身，数量为1，用于回卡组效果的结算。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- ②效果处理：若这张卡仍与效果相关，则将其返回持有者卡组并洗切。
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将这张卡以效果原因送回持有者卡组，并标记洗切卡组。
		Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end

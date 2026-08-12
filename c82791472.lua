--戦華の叛－呂奉
-- 效果：
-- 这张卡不能通常召唤。「战华之叛-吕奉」1回合1次在场上的「战华」怪兽之内攻击力最高的怪兽在自己场上存在的场合才能特殊召唤。
-- ①：双方的主要阶段才能发动1次。对方场上1只攻击力最高的怪兽破坏。这个效果发动的回合，自己不能把「战华」怪兽以外的怪兽效果发动。
-- ②：结束阶段，场上的攻击力最高的怪兽在对方场上存在的场合发动。这个控制权移给对方。
function c82791472.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 「战华之叛-吕奉」1回合1次在场上的「战华」怪兽之内攻击力最高的怪兽在自己场上存在的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,82791472+EFFECT_COUNT_CODE_OATH)
	e2:SetCondition(c82791472.spcon)
	c:RegisterEffect(e2)
	-- ①：双方的主要阶段才能发动1次。对方场上1只攻击力最高的怪兽破坏。这个效果发动的回合，自己不能把「战华」怪兽以外的怪兽效果发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(82791472,0))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMING_MAIN_END)
	e3:SetCost(c82791472.descost)
	e3:SetCondition(c82791472.descon)
	e3:SetTarget(c82791472.destg)
	e3:SetOperation(c82791472.desop)
	c:RegisterEffect(e3)
	-- ②：结束阶段，场上的攻击力最高的怪兽在对方场上存在的场合发动。这个控制权移给对方。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(82791472,1))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCategory(CATEGORY_CONTROL)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c82791472.ctlcon)
	e4:SetTarget(c82791472.ctltg)
	e4:SetOperation(c82791472.ctlop)
	c:RegisterEffect(e4)
	-- 添加自定义活动计数器，用于监控玩家发动的效果，以配合「不能把「战华」怪兽以外的怪兽效果发动」的限制
	Duel.AddCustomActivityCounter(82791472,ACTIVITY_CHAIN,c82791472.chainfilter)
end
-- 过滤函数：检查发动的效果是否为「战华」怪兽的效果或非怪兽效果
function c82791472.chainfilter(re,tp,cid)
	local rc=re:GetHandler()
	return rc:IsSetCard(0x137) or not re:IsActiveType(TYPE_MONSTER)
end
-- 过滤函数：检查是否为场上表侧表示的「战华」怪兽
function c82791472.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x137)
end
-- 特殊召唤规则的条件函数：检查场上攻击力最高的「战华」怪兽是否在自己场上存在
function c82791472.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取双方场上所有表侧表示的「战华」怪兽
	local g=Duel.GetMatchingGroup(c82791472.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()==0 then return false end
	local tg=g:GetMaxGroup(Card.GetAttack)
	-- 返回自己场上有可用怪兽区域，且攻击力最高的「战华」怪兽中至少有1只在自己场上存在
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tg:IsExists(Card.IsControler,1,nil,tp)
end
-- 破坏效果的Cost函数：检查本回合是否未发动过「战华」以外的怪兽效果，并注册本回合不能发动「战华」以外怪兽效果的限制
function c82791472.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查本回合自己是否未发动过「战华」怪兽以外的怪兽效果
	if chk==0 then return Duel.GetCustomActivityCount(82791472,tp,ACTIVITY_CHAIN)==0 end
	-- ①：双方的主要阶段才能发动1次。对方场上1只攻击力最高的怪兽破坏。这个效果发动的回合，自己不能把「战华」怪兽以外的怪兽效果发动。②：结束阶段，场上的攻击力最高的怪兽在对方场上存在的场合发动。这个控制权移给对方。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(c82791472.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 给玩家注册限制效果，使其在回合结束前不能发动「战华」以外的怪兽效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制发动效果的过滤函数：不能发动非「战华」怪兽的效果
function c82791472.aclimit(e,re,tp)
	return not re:GetHandler():IsSetCard(0x137) and re:IsActiveType(TYPE_MONSTER)
end
-- 破坏效果的条件函数：必须在双方的主要阶段才能发动
function c82791472.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前是否为主要阶段，且自身仍具有「战华」字段（防止被改变字段）
	return Duel.IsMainPhase() and e:GetHandler():IsSetCard(0x137)
end
-- 破坏效果的目标函数：检查对方场上是否有表侧表示怪兽，并确定攻击力最高的怪兽作为破坏目标
function c82791472.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备时，检查对方场上是否存在至少1只表侧表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有表侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local tg=g:GetMaxGroup(Card.GetAttack)
	-- 设置破坏操作的信息，目标为对方场上攻击力最高的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg,1,0,0)
end
-- 破坏效果的执行函数：选出对方场上攻击力最高的怪兽并将其破坏
function c82791472.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时，重新获取对方场上所有表侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if #g>0 then
		local tg=g:GetMaxGroup(Card.GetAttack)
		if #tg>1 then
			-- 提示玩家选择要破坏的卡片
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local sg=tg:Select(tp,1,1,nil)
			-- 对选中的怪兽进行闪烁提示，告知对方玩家
			Duel.HintSelection(sg)
			-- 因效果破坏选中的怪兽
			Duel.Destroy(sg,REASON_EFFECT)
		-- 若攻击力最高的怪兽只有1只，则直接将其破坏
		else Duel.Destroy(tg,REASON_EFFECT) end
	end
end
-- 控制权转移效果的条件函数：检查场上攻击力最高的怪兽是否在对方场上存在
function c82791472.ctlcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方场上所有表侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()==0 then return false end
	local tg=g:GetMaxGroup(Card.GetAttack)
	return tg:IsExists(Card.IsControler,1,nil,1-tp)
end
-- 控制权转移效果的目标函数：设置控制权转移的操作信息，目标为自身
function c82791472.ctltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置控制权转移的操作信息，目标为这张卡自身
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,e:GetHandler(),1,0,0)
end
-- 控制权转移效果的执行函数：将这张卡的控制权移给对方
function c82791472.ctlop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡的控制权转移给对方玩家
		Duel.GetControl(c,1-tp)
	end
end

--DDD制覇王カイゼル
-- 效果：
-- ①：这张卡灵摆召唤成功的场合发动。对方场上的表侧表示的卡的效果直到回合结束时无效。
-- ②：这张卡灵摆召唤成功的回合的主要阶段1次，以自己的魔法与陷阱区域最多2张卡为对象才能发动。那些卡破坏。这个回合，这张卡在同1次的战斗阶段中在通常攻击外加上可以作出最多有这个效果破坏的卡数量的攻击。
function c44186624.initial_effect(c)
	-- ①：这张卡灵摆召唤成功的场合发动。对方场上的表侧表示的卡的效果直到回合结束时无效。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c44186624.effcon)
	e1:SetTarget(c44186624.distg)
	e1:SetOperation(c44186624.disop)
	c:RegisterEffect(e1)
	-- ②：这张卡灵摆召唤成功的回合的主要阶段1次，以自己的魔法与陷阱区域最多2张卡为对象才能发动。那些卡破坏。这个回合，这张卡在同1次的战斗阶段中在通常攻击外加上可以作出最多有这个效果破坏的卡数量的攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCondition(c44186624.effcon)
	e2:SetOperation(c44186624.regop)
	c:RegisterEffect(e2)
	-- ②：这张卡灵摆召唤成功的回合的主要阶段1次，以自己的魔法与陷阱区域最多2张卡为对象才能发动。那些卡破坏。这个回合，这张卡在同1次的战斗阶段中在通常攻击外加上可以作出最多有这个效果破坏的卡数量的攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c44186624.descon)
	e3:SetTarget(c44186624.destg)
	e3:SetOperation(c44186624.desop)
	c:RegisterEffect(e3)
end
-- 判断此卡是否为灵摆召唤
function c44186624.effcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM)
end
-- 准备发动效果①，检查对方场上是否存在表侧表示的卡
function c44186624.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在表侧表示的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,nil) end
end
-- 将对方场上所有表侧表示的卡的效果无效化
function c44186624.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有表侧表示的卡
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_ONFIELD,nil)
	local tc=g:GetFirst()
	while tc do
		-- 使目标卡的效果无效
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 使目标卡的效果无效化
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
end
-- 为该卡注册一个标记，表示其已灵摆召唤成功
function c44186624.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(44186624,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 判断此卡是否已灵摆召唤成功
function c44186624.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(44186624)~=0
end
-- 过滤函数，用于筛选自己魔法与陷阱区域的卡
function c44186624.filter(c)
	return c:GetSequence()<5
end
-- 准备发动效果②，选择自己魔法与陷阱区域的卡作为对象
function c44186624.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and c44186624.filter(chkc) end
	-- 检查自己魔法与陷阱区域是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingTarget(c44186624.filter,tp,LOCATION_SZONE,0,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己魔法与陷阱区域的卡作为对象
	local g=Duel.SelectTarget(tp,c44186624.filter,tp,LOCATION_SZONE,0,1,2,nil)
	-- 设置操作信息，表示将要破坏这些卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 执行效果②，破坏选中的卡并增加攻击次数
function c44186624.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取连锁中被选中的卡，并筛选出与当前效果相关的卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 以效果原因破坏选中的卡
	local ct=Duel.Destroy(g,REASON_EFFECT)
	if ct>0 and c:IsRelateToEffect(e) then
		-- 使此卡在同1次的战斗阶段中可以额外攻击
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(ct)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end

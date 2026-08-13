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
	-- ②：这张卡灵摆召唤成功的回合
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
-- 判断“这张卡灵摆召唤成功”的条件：特殊召唤成功时，检查召唤类型是否为灵摆召唤。
function c44186624.effcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM)
end
-- ①效果的发动条件判定：检查对方场上是否存在表侧表示的卡（有1张以上）。
function c44186624.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若在发动前检查（chk==0），返回是否存在至少1张对方场上的表侧表示的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,nil) end
end
-- ①效果处理：获取对方场上所有表侧表示的卡，各自赋予“效果无效化”和“效果的效果无效化”状态，直到回合结束时。
function c44186624.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得对方场上的所有表侧表示的卡（不取对象）。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_ONFIELD,nil)
	local tc=g:GetFirst()
	while tc do
		-- 对方场上的表侧表示的卡的效果直到回合结束时无效。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 对方场上的表侧表示的卡的效果直到回合结束时无效。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
end
-- 灵摆召唤成功时，给这张卡注册一个表示“本回合灵摆召唤成功”的标记（结束阶段重置）。
function c44186624.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(44186624,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- ②的发动条件：自身存在“本回合灵摆召唤成功”的标记。
function c44186624.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(44186624)~=0
end
-- 过滤函数：选择魔法与陷阱区域中主怪兽区对应的通常魔法陷阱区域（序列0~4），排除场地魔法区域。
function c44186624.filter(c)
	return c:GetSequence()<5
end
-- ②的发动处理：选择自己魔法与陷阱区域的1~2张卡为对象（最多2张），并设置破坏信息。
function c44186624.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and c44186624.filter(chkc) end
	-- 检查自己魔法与陷阱区域中是否存在至少1张符合条件可以作为对象的卡（取对象）。
	if chk==0 then return Duel.IsExistingTarget(c44186624.filter,tp,LOCATION_SZONE,0,1,nil) end
	-- 显示“请选择要破坏的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择自己魔法与陷阱区域的1~2张卡作为效果对象。
	local g=Duel.SelectTarget(tp,c44186624.filter,tp,LOCATION_SZONE,0,1,2,nil)
	-- 设置本次连锁的操作信息为破坏这些对象卡，数量为对象数。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- ②效果处理：破坏对象卡，若破坏数量>0且这张卡仍在场上，则给这张卡赋予追加攻击次数。
function c44186624.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 从连锁信息中取出发动时选择的对象卡，并筛选出仍然与该效果相关的卡。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 破坏筛选出的对象卡（原因：效果），返回实际破坏数量。
	local ct=Duel.Destroy(g,REASON_EFFECT)
	if ct>0 and c:IsRelateToEffect(e) then
		-- 这个回合，这张卡在同1次的战斗阶段中在通常攻击外加上可以作出最多有这个效果破坏的卡数量的攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(ct)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end

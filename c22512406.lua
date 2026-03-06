--覆面忍者ヱビス
-- 效果：
-- 1回合1次，自己场上有「覆面忍者 惠比寿」以外的名字带有「忍者」的怪兽存在的场合才能发动。自己场上的名字带有「忍者」的怪兽数量的对方魔法·陷阱卡回到持有者手卡。这个效果适用的回合，自己场上的「忍者义贼 五卫五卫」可以直接攻击对方玩家。
function c22512406.initial_effect(c)
	-- 效果原文内容：1回合1次，自己场上有「覆面忍者 惠比寿」以外的名字带有「忍者」的怪兽存在的场合才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(22512406,0))  --"返回手牌"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c22512406.thcon)
	e1:SetTarget(c22512406.thtg)
	e1:SetOperation(c22512406.thop)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查场上是否存在名字带有「忍者」且不是惠比寿的表侧怪兽
function c22512406.cfilter1(c)
	return c:IsFaceup() and c:IsSetCard(0x2b) and not c:IsCode(22512406)
end
-- 过滤函数：检查场上是否存在名字带有「忍者」的表侧怪兽
function c22512406.cfilter2(c)
	return c:IsFaceup() and c:IsSetCard(0x2b)
end
-- 效果条件函数：判断自己场上是否存在名字带有「忍者」且不是惠比寿的怪兽
function c22512406.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：检查自己场上是否存在至少1张满足cfilter1条件的怪兽
	return Duel.IsExistingMatchingCard(c22512406.cfilter1,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤函数：检查场上是否存在可送回手牌的魔法·陷阱卡
function c22512406.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果目标函数：计算自己场上「忍者」怪兽数量，并确认对方场上魔法·陷阱卡数量是否足够
function c22512406.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 规则层面操作：获取自己场上名字带有「忍者」的怪兽数量
		local ct=Duel.GetMatchingGroupCount(c22512406.cfilter2,tp,LOCATION_MZONE,0,nil)
		-- 规则层面操作：获取对方场上满足filter条件的魔法·陷阱卡数量
		local dt=Duel.GetMatchingGroupCount(c22512406.filter,tp,0,LOCATION_ONFIELD,nil)
		e:SetLabel(ct)
		return dt>=ct
	end
	-- 规则层面操作：获取对方场上满足filter条件的魔法·陷阱卡组
	local g=Duel.GetMatchingGroup(c22512406.filter,tp,0,LOCATION_ONFIELD,nil)
	-- 规则层面操作：设置效果处理信息，指定将要送回手牌的卡组和数量
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,e:GetLabel(),0,0)
end
-- 效果处理函数：执行效果处理，包括检索并送回手牌、设置直接攻击效果
function c22512406.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：获取自己场上名字带有「忍者」的怪兽数量
	local ct=Duel.GetMatchingGroupCount(c22512406.cfilter2,tp,LOCATION_MZONE,0,nil)
	-- 规则层面操作：获取对方场上满足filter条件的魔法·陷阱卡组
	local g=Duel.GetMatchingGroup(c22512406.filter,tp,0,LOCATION_ONFIELD,nil)
	if ct>g:GetCount() then return end
	-- 规则层面操作：向玩家提示选择要送回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	local sg=g:Select(tp,ct,ct,nil)
	-- 规则层面操作：将选定的卡送回持有者手牌
	Duel.SendtoHand(sg,nil,REASON_EFFECT)
	-- 效果原文内容：这个效果适用的回合，自己场上的「忍者义贼 五卫五卫」可以直接攻击对方玩家。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	-- 规则层面操作：设置效果目标为名字为「忍者义贼 五卫五卫」的怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsCode,10236520))
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 规则层面操作：将效果注册给玩家，使其生效至结束阶段
	Duel.RegisterEffect(e1,tp)
end

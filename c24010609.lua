--閃刀機関－マルチロール
-- 效果：
-- ①：1回合1次，以这张卡以外的自己场上1张卡为对象才能发动。这个回合，对方不能对应自己的魔法卡的发动把魔法·陷阱·怪兽的效果发动。并且，再把作为对象的卡送去墓地。
-- ②：自己·对方的结束阶段才能发动。选最多有这个回合这张卡表侧表示存在期间自己发动的「闪刀」魔法卡数量的自己墓地的「闪刀」魔法卡在自己场上盖放（同名卡最多1张）。这个效果盖放的卡从场上离开的场合除外。
function c24010609.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 效果原文：①：1回合1次，以这张卡以外的自己场上1张卡为对象才能发动。这个回合，对方不能对应自己的魔法卡的发动把魔法·陷阱·怪兽的效果发动。并且，再把作为对象的卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(24010609,0))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c24010609.tgtg)
	e2:SetOperation(c24010609.tgop)
	c:RegisterEffect(e2)
	-- 效果原文：②：自己·对方的结束阶段才能发动。选最多有这个回合这张卡表侧表示存在期间自己发动的「闪刀」魔法卡数量的自己墓地的「闪刀」魔法卡在自己场上盖放（同名卡最多1张）。这个效果盖放的卡从场上离开的场合除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(24010609,1))
	e3:SetCategory(CATEGORY_LEAVE_GRAVE+CATEGORY_SSET)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c24010609.settg)
	e3:SetOperation(c24010609.setop)
	c:RegisterEffect(e3)
	-- 效果原文：①：1回合1次，以这张卡以外的自己场上1张卡为对象才能发动。这个回合，对方不能对应自己的魔法卡的发动把魔法·陷阱·怪兽的效果发动。并且，再把作为对象的卡送去墓地。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_CHAINING)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetOperation(c24010609.regop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_CHAIN_NEGATED)
	e5:SetOperation(c24010609.regop2)
	c:RegisterEffect(e5)
end
-- 检查是否满足效果发动条件，即确认该回合未发动过此效果且场上存在满足条件的目标卡
function c24010609.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and chkc~=c end
	-- 检查是否满足效果发动条件，即确认该回合未发动过此效果且场上存在满足条件的目标卡
	if chk==0 then return Duel.GetFlagEffect(tp,24010610)==0 and Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,0,1,c) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的目标卡
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,0,1,1,c)
	-- 设置效果处理信息，表明将要将目标卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
-- 效果处理函数，注册连锁限制效果并记录flag，然后将目标卡送去墓地
function c24010609.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果原文：①：1回合1次，以这张卡以外的自己场上1张卡为对象才能发动。这个回合，对方不能对应自己的魔法卡的发动把魔法·陷阱·怪兽的效果发动。并且，再把作为对象的卡送去墓地。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAINING)
	e1:SetOperation(c24010609.actop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册到玩家的全局环境，使该效果生效
	Duel.RegisterEffect(e1,tp)
	-- 为玩家注册一个flag，用于记录该回合是否已发动过此效果
	Duel.RegisterFlagEffect(tp,24010610,RESET_PHASE+PHASE_END,0,1)
	-- 获取当前效果的目标卡
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 中断当前效果，使之后的效果处理视为不同时处理
	Duel.BreakEffect()
	-- 将目标卡送去墓地
	Duel.SendtoGrave(tc,REASON_EFFECT)
end
-- 当对方发动魔法卡时，设置连锁限制，使对方不能响应
function c24010609.actop(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) then
		-- 设置连锁限制，使对方不能响应
		Duel.SetChainLimit(c24010609.chainlm)
	end
end
-- 连锁限制函数，仅允许自己发动的魔法卡被连锁
function c24010609.chainlm(e,rp,tp)
	return tp==rp
end
-- 当玩家发动「闪刀」魔法卡时，记录该魔法卡数量
function c24010609.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if re:GetHandler():IsSetCard(0x115) and re:IsActiveType(TYPE_SPELL) and rp==tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) then
		local flag=c:GetFlagEffectLabel(24010609)
		if flag then
			c:SetFlagEffectLabel(24010609,flag+1)
		else
			c:RegisterFlagEffect(24010609,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,1)
		end
	end
end
-- 当玩家发动「闪刀」魔法卡被无效时，减少该魔法卡数量记录
function c24010609.regop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if re:GetHandler():IsSetCard(0x115) and re:IsActiveType(TYPE_SPELL) and rp==tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) then
		local flag=c:GetFlagEffectLabel(24010609)
		if flag and flag>0 then
			c:SetFlagEffectLabel(24010609,flag-1)
		end
	end
end
-- 过滤函数，筛选出「闪刀」魔法卡
function c24010609.setfilter(c)
	return c:IsSetCard(0x115) and c:IsType(TYPE_SPELL) and c:IsSSetable()
end
-- 效果处理函数，检查是否满足发动条件并设置操作信息
function c24010609.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetHandler():GetFlagEffectLabel(24010609)
	-- 检查是否满足发动条件，即该回合发动的「闪刀」魔法卡数量大于0且墓地存在满足条件的卡
	if chk==0 then return ct and ct>0 and Duel.IsExistingMatchingCard(c24010609.setfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息，表明将要从墓地盖放卡
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,0)
end
-- 选择子组函数，用于筛选满足条件的卡组
function c24010609.gselect(g,ft)
	local fc=g:FilterCount(Card.IsType,nil,TYPE_FIELD)
	-- 返回值为true表示所选卡组满足条件：最多一张场地卡、卡名各不相同、数量不超过可用格子数
	return fc<=1 and aux.dncheck(g) and #g-fc<=ft
end
-- 效果处理函数，从墓地选择卡并盖放
function c24010609.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取满足条件的墓地魔法卡组
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c24010609.setfilter),tp,LOCATION_GRAVE,0,nil)
	local ct=e:GetHandler():GetFlagEffectLabel(24010609) or 0
	-- 获取玩家场上可用的魔陷区格子数
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if #g==0 or ct==0 then return end
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	local tg=g:SelectSubGroup(tp,c24010609.gselect,false,1,math.min(ct,ft+1),ft)
	-- 执行盖放操作，若失败则返回
	if Duel.SSet(tp,tg)==0 then return end
	local tc=tg:GetFirst()
	while tc do
		-- 效果原文：②：自己·对方的结束阶段才能发动。选最多有这个回合这张卡表侧表示存在期间自己发动的「闪刀」魔法卡数量的自己墓地的「闪刀」魔法卡在自己场上盖放（同名卡最多1张）。这个效果盖放的卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(LOCATION_REMOVED)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		tc:RegisterEffect(e1)
		tc=tg:GetNext()
	end
end

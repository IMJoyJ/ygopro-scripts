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
	-- ①：1回合1次，以这张卡以外的自己场上1张卡为对象才能发动。这个回合，对方不能对应自己的魔法卡的发动把魔法·陷阱·怪兽的效果发动。并且，再把作为对象的卡送去墓地。
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
	-- ②：自己·对方的结束阶段才能发动。选最多有这个回合这张卡表侧表示存在期间自己发动的「闪刀」魔法卡数量的自己墓地的「闪刀」魔法卡在自己场上盖放（同名卡最多1张）。这个效果盖放的卡从场上离开的场合除外。
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
	-- 这个回合这张卡表侧表示存在期间自己发动的「闪刀」魔法卡数量
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
-- ①效果的发动条件与取对象处理：确认本回合尚未发动过此效果，选择这张卡以外的自己场上1张卡作为对象，并登记该卡将送去墓地。
function c24010609.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and chkc~=c end
	-- 在效果发动合法性检查时，确认本回合此效果尚未使用（flag为0），且自己场上存在这张卡以外的卡可以作为对象。
	if chk==0 then return Duel.GetFlagEffect(tp,24010610)==0 and Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,0,1,c) end
	-- 弹出提示信息，引导玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从自己场上选择1张这张卡以外的卡作为效果对象，并建立连锁对象关联。
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,0,1,1,c)
	-- 设置本次连锁的操作信息，声明后续将进行“送去墓地”处理，对象为已选择的卡片。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
-- 处理①效果：先注册一个本回合内持续监视连锁的辅助效果，再给自己登记已发动标识；若对象卡仍与效果关联，则将其送去墓地。
function c24010609.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- ①：1回合1次，以这张卡以外的自己场上1张卡为对象才能发动。这个回合，对方不能对应自己的魔法卡的发动把魔法·陷阱·怪兽的效果发动。并且，再把作为对象的卡送去墓地。②：自己·对方的结束阶段才能发动。选最多有这个回合这张卡表侧表示存在期间自己发动的「闪刀」魔法卡数量的自己墓地的「闪刀」魔法卡在自己场上盖放（同名卡最多1张）。这个效果盖放的卡从场上离开的场合除外。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAINING)
	e1:SetOperation(c24010609.actop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将创建的持续监视连锁的辅助效果注册给玩家tp，该效果在结束阶段重置。
	Duel.RegisterEffect(e1,tp)
	-- 给玩家tp注册一个flag标识，记录本回合已经发动过①效果，用于限制1回合1次，结束阶段重置。
	Duel.RegisterFlagEffect(tp,24010610,RESET_PHASE+PHASE_END,0,1)
	-- 获取发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 中断当前效果处理，使后续的送去墓地效果与前面的限制效果不视为同时处理，避免时点问题。
	Duel.BreakEffect()
	-- 将对象卡以效果原因送去墓地。
	Duel.SendtoGrave(tc,REASON_EFFECT)
end
-- 连锁监视处理：每当自己发动魔法卡的“卡的发动”时，设置连锁限制，禁止对方连锁该魔法卡发动效果。
function c24010609.actop(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) then
		-- 设置连锁限制条件，使后续所有连锁必须通过chainlm函数的验证。
		Duel.SetChainLimit(c24010609.chainlm)
	end
end
-- 连锁限制判定：只允许效果发动者本人进行连锁，即对方不能对应自己的魔法卡发动来发动魔法·陷阱·怪兽效果。
function c24010609.chainlm(e,rp,tp)
	return tp==rp
end
-- 持续效果处理：每当自己发动「闪刀」魔法卡的“卡的发动”时，给本卡累加一个计数，记录本回合表侧表示期间发动的「闪刀」魔法卡数量。
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
-- 连锁被无效时的回调：如果自己发动的「闪刀」魔法卡被无效，则将已累计的计数减一，保持数量准确。
function c24010609.regop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if re:GetHandler():IsSetCard(0x115) and re:IsActiveType(TYPE_SPELL) and rp==tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) then
		local flag=c:GetFlagEffectLabel(24010609)
		if flag and flag>0 then
			c:SetFlagEffectLabel(24010609,flag-1)
		end
	end
end
-- 墓地筛选条件：卡名含有「闪刀」、是魔法卡、并且可以盖放。
function c24010609.setfilter(c)
	return c:IsSetCard(0x115) and c:IsType(TYPE_SPELL) and c:IsSSetable()
end
-- ②效果的发动条件处理：确认本卡有计数标记且计数大于0，墓地存在符合条件的「闪刀」魔法卡；并登记涉及墓地的操作信息。
function c24010609.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=e:GetHandler():GetFlagEffectLabel(24010609)
	-- 合法性检查：计数标记存在且大于0，且墓地存在至少1张符合条件的「闪刀」魔法卡可选。
	if chk==0 then return ct and ct>0 and Duel.IsExistingMatchingCard(c24010609.setfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息，声明要处理的是涉及墓地移动的盖放效果，预计处理1张，目标为自己。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,0)
end
-- 盖放选择约束函数：所选卡中场地魔法最多1张、卡名互不相同，且非场地魔法卡数量不超过可用魔陷区空格数。
function c24010609.gselect(g,ft)
	local fc=g:FilterCount(Card.IsType,nil,TYPE_FIELD)
	-- 返回选择约束条件：场地魔法卡数≤1、卡名均不同、非场地魔法卡数≤可用魔陷区空格数。
	return fc<=1 and aux.dncheck(g) and #g-fc<=ft
end
-- ②效果处理：从墓地选出符合条件的「闪刀」魔法卡（排除王家长眠之谷影响），数量不超过本回合累计且不超过可用格子，盖放到自己场上；每张被盖放的卡附加“离场时除外”的效果。
function c24010609.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取墓地中满足条件的「闪刀」魔法卡，并通过王家长眠之谷过滤器排除适用墓地封锁的卡。
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c24010609.setfilter),tp,LOCATION_GRAVE,0,nil)
	local ct=e:GetHandler():GetFlagEffectLabel(24010609) or 0
	-- 计算自己魔陷区当前可用的空格数。
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if #g==0 or ct==0 then return end
	-- 弹出提示信息，引导玩家选择要盖放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	local tg=g:SelectSubGroup(tp,c24010609.gselect,false,1,math.min(ct,ft+1),ft)
	-- 执行盖放操作；若实际盖放数量为0（全部失败或无法盖放），则中止后续为盖放卡附加除外效果的处理。
	if Duel.SSet(tp,tg)==0 then return end
	local tc=tg:GetFirst()
	while tc do
		-- 这个效果盖放的卡从场上离开的场合除外。
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

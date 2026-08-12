--Thundercrash Snarecrow
-- 效果：
-- 这张卡在怪兽区域存在的状态，每次雷族以外的怪兽表侧表示特殊召唤：那些怪兽这个回合不能攻击，结束阶段破坏。
-- 这张卡在墓地存在的场合：可以以自己场上1张表侧表示卡为对象；那张卡破坏，这张卡加入手卡。
-- 「设陷雷轰稻草人」的这个效果1回合只能使用1次。
local s,id,o=GetID()
-- 初始化函数：注册特殊召唤成功时的合并延迟事件，创建并注册效果e1（怪兽区域存在的必发诱发效果：那些怪兽这个回合不能攻击，结束阶段破坏）和效果e2（墓地的起动效果：破坏自己场上1张卡后这张卡加入手卡，1回合只能使用1次）
function s.initial_effect(c)
	-- 为这张卡注册对特殊召唤成功事件的合并延迟监听，使同一连锁中多次特殊召唤只触发一次自身诱发效果，返回自定义事件编号code
	local code=aux.RegisterMergedDelayedEvent_ToSingleCard(c,id,EVENT_SPSUMMON_SUCCESS)
	-- 这张卡在怪兽区域存在的状态，每次雷族以外的怪兽表侧表示特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"限制攻击"
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(code)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.descon)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	-- 这张卡在墓地存在的场合：可以以自己场上1张表侧表示卡为对象；那张卡破坏，这张卡加入手卡。「设陷雷轰稻草人」的这个效果1回合只能使用1次
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回收"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_DESTROY)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数：筛选雷族以外的表侧表示怪兽
function s.cfilter(c)
	return not c:IsRace(RACE_THUNDER) and c:IsFaceup() and c:IsType(TYPE_MONSTER)
end
-- 发动条件：本次特殊召唤的怪兽组中不包含这张卡自身，且其中存在至少1只雷族以外的表侧表示怪兽
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(s.cfilter,1,nil)
end
-- 对象设定：从本次特殊召唤的怪兽中筛选出仍在怪兽区域且满足条件的雷族以外的表侧表示怪兽，作为效果处理的对象
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=eg:Filter(Card.IsLocation,nil,LOCATION_MZONE):Filter(s.cfilter,nil)
	-- 把筛选出的怪兽组设置为当前正在处理的连锁的对象
	Duel.SetTargetCard(g)
end
-- 过滤函数：筛选不免疫这个效果的卡
function s.desfilter(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 效果处理：取出与当前连锁关联且不免疫效果的怪兽，逐个赋予这个回合不能攻击的效果并注册标记，再注册一个在结束阶段破坏这些怪兽的持续效果
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 从与当前连锁关联的对象卡中筛选出不免疫这个效果的卡，组成卡片组
	local g=Duel.GetTargetsRelateToChain():Filter(s.desfilter,nil,e)
	if g:GetCount()>0 then
		-- 遍历卡片组中的每一张怪兽，逐张进行处理
		for tc in aux.Next(g) do
			-- 那些怪兽这个回合不能攻击
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(id,2))  --"「设陷雷轰稻草人」效果适用中"
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_ATTACK)
			e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		end
		g:KeepAlive()
		-- 结束阶段破坏；这张卡在墓地存在的场合：可以以自己场上1张表侧表示卡为对象；那张卡破坏，这张卡加入手卡
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCountLimit(1)
		e1:SetLabelObject(g)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetCondition(s.descon2)
		e1:SetOperation(s.desop2)
		-- 把这个结束阶段破坏的持续效果注册为玩家tp的全局效果，使其在结束阶段自动检测并执行
		Duel.RegisterEffect(e1,tp)
	end
end
-- 过滤函数：筛选带有这张卡标记效果（即被赋予不能攻击效果）的卡
function s.desfilter2(c)
	return c:GetFlagEffect(id)~=0
end
-- 结束阶段效果的执行条件：记录的卡片组中仍存在带有标记的卡
function s.descon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():IsExists(s.desfilter2,1,nil)
end
-- 结束阶段处理：取出记录的卡片组，筛选出仍带标记的卡并将其破坏，最后清除该卡片组
function s.desop2(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(s.desfilter2,nil)
	-- 以效果原因破坏那些带标记的怪兽
	Duel.Destroy(tg,REASON_EFFECT)
	g:DeleteGroup()
end
-- 过滤函数：筛选表侧表示的卡
function s.tfilter(c)
	return c:IsFaceup()
end
-- 取对象及发动条件：这张卡可以回到手卡，且自己场上存在可成为对象的表侧表示的卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return s.tfilter(chkc) and chkc:IsOnField() and chkc:IsControler(tp) end
	if chk==0 then return c:IsAbleToHand()
		-- 自己场上存在至少1张可成为这个效果对象的表侧表示的卡
		and Duel.IsExistingTarget(s.tfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 向玩家显示「请选择要破坏的卡」的选卡提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1张表侧表示的卡作为破坏对象，并设为当前连锁的对象
	local g=Duel.SelectTarget(tp,s.tfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 设置连锁的操作信息：将以效果破坏1张作为对象的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置连锁的操作信息：这张卡将加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
-- 效果处理：对象卡仍与连锁关联时将其破坏，若破坏成功且这张卡仍在墓地（不受王家长眠之谷影响），则把这张卡加入手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得当前连锁的对象卡
	local tc=Duel.GetFirstTarget()
	-- 若对象卡仍与连锁关联，则以效果原因将其破坏，并确认确实被破坏
	if tc:IsRelateToChain() and Duel.Destroy(tc,REASON_EFFECT)~=0
		-- 确认这张卡仍与连锁关联，且不受王家长眠之谷的影响
		and c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 以效果原因把这张卡加入持有者的手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end

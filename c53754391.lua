--Thundercrash Snarecrow
local s,id,o=GetID()
-- 初始化效果函数，注册两个效果，一个触发效果和一个起动效果
function s.initial_effect(c)
	-- 为单张卡片注册合并的延迟事件监听，以限制其自身特殊召唤或状态改变诱发效果在一连锁中只响应一次
	local code=aux.RegisterMergedDelayedEvent_ToSingleCard(c,id,EVENT_SPSUMMON_SUCCESS)
	-- 创建并注册一个触发效果，当有怪兽特殊召唤成功时发动，条件是召唤的怪兽中存在非雷族的表侧怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(code)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.descon)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	-- 创建并注册一个起动效果，可以在墓地发动，将自身送入手牌并破坏场上一张卡
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_DESTROY)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 过滤器函数，用于判断是否为非雷族、表侧、怪兽类型的卡
function s.cfilter(c)
	return not c:IsRace(RACE_THUNDER) and c:IsFaceup() and c:IsType(TYPE_MONSTER)
end
-- 触发效果的发动条件，确保召唤列表中不包含自身，并且存在至少一张非雷族的表侧怪兽
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(s.cfilter,1,nil)
end
-- 设置触发效果的目标，筛选出召唤列表中位于主要怪兽区的非雷族表侧怪兽作为目标
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=eg:Filter(Card.IsLocation,nil,LOCATION_MZONE):Filter(s.cfilter,nil)
	-- 将筛选出的怪兽设置为当前连锁的效果对象
	Duel.SetTargetCard(g)
end
-- 破坏效果的过滤器函数，用于判断卡是否未免疫该效果
function s.desfilter(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 触发效果的处理函数，对符合条件的目标怪兽施加不能攻击的效果，并在回合结束时将其破坏
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取与当前连锁相关的对象卡组，并筛选出未免疫该效果的卡
	local g=Duel.GetTargetsRelateToChain():Filter(s.desfilter,nil,e)
	if g:GetCount()>0 then
		-- 遍历卡组中的每张卡
		for tc in aux.Next(g) do
			-- 为每张目标怪兽添加不能攻击的效果，持续到回合结束
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(id,2))
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_ATTACK)
			e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		end
		g:KeepAlive()
		-- 创建一个回合结束时触发的持续效果，在回合结束时破坏所有标记了flag的怪兽
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCountLimit(1)
		e1:SetLabelObject(g)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetCondition(s.descon2)
		e1:SetOperation(s.desop2)
		-- 将创建的持续效果注册到游戏环境
		Duel.RegisterEffect(e1,tp)
	end
end
-- 用于判断卡是否被标记了特定flag的过滤器函数
function s.desfilter2(c)
	return c:GetFlagEffect(id)~=0
end
-- 持续效果的发动条件，检查是否有标记了flag的卡存在
function s.descon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():IsExists(s.desfilter2,1,nil)
end
-- 持续效果的处理函数，对所有标记了flag的卡进行破坏
function s.desop2(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(s.desfilter2,nil)
	-- 将符合条件的卡破坏
	Duel.Destroy(tg,REASON_EFFECT)
	g:DeleteGroup()
end
-- 用于判断卡是否为表侧表示的过滤器函数
function s.tfilter(c)
	return c:IsFaceup()
end
-- 起动效果的目标设定函数，检查自身能否送入手牌并确认场上是否存在一张表侧怪兽作为目标
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return s.tfilter(chkc) and chkc:IsOnField() and chkc:IsControler(tp) end
	if chk==0 then return c:IsAbleToHand()
		-- 检查场上是否存在一张表侧怪兽作为目标
		and Duel.IsExistingTarget(s.tfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 向玩家发送提示信息，提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上一张表侧怪兽作为目标
	local g=Duel.SelectTarget(tp,s.tfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 设置操作信息，说明本次效果会破坏一张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息，说明本次效果会将自身送入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
-- 起动效果的处理函数，将目标怪兽破坏并把自身送入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡是否与当前连锁相关，并将其破坏
	if tc:IsRelateToChain() and Duel.Destroy(tc,REASON_EFFECT)~=0
		-- 判断自身是否与当前连锁相关且未被王家长眠之谷影响
		and c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将自身送入手牌
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end

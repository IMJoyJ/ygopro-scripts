--時の魔導士
-- 效果：
-- 「时间魔术师」＋效果怪兽
-- ①：1回合1次，这张卡是已融合召唤的场合才能发动。进行1次投掷硬币，对里表作猜测。猜中的场合，场上的怪兽全部破坏，对方受到表侧表示破坏的怪兽的原本攻击力合计数值一半的伤害。猜错的场合，场上的怪兽全部破坏，自己受到表侧表示破坏的怪兽的原本攻击力合计数值一半的伤害。
function c26273196.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加融合召唤手续，使用卡号71625222的怪兽和1个效果怪兽作为融合素材
	aux.AddFusionProcCodeFun(c,71625222,aux.FilterBoolFunction(Card.IsFusionType,TYPE_EFFECT),1,true,true)
	-- ①：1回合1次，这张卡是已融合召唤的场合才能发动。进行1次投掷硬币，对里表作猜测。猜中的场合，场上的怪兽全部破坏，对方受到表侧表示破坏的怪兽的原本攻击力合计数值一半的伤害。猜错的场合，场上的怪兽全部破坏，自己受到表侧表示破坏的怪兽的原本攻击力合计数值一半的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(26273196,0))
	e1:SetCategory(CATEGORY_COIN+CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c26273196.descon)
	e1:SetTarget(c26273196.destg)
	e1:SetOperation(c26273196.desop)
	c:RegisterEffect(e1)
	-- 融合召唤成功时触发，为该卡注册一个标记flag，表示该卡已融合召唤
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCondition(c26273196.matcon)
	e2:SetOperation(c26273196.matop)
	c:RegisterEffect(e2)
end
-- 判断该卡是否为融合召唤
function c26273196.matcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 为该卡注册一个标记flag，表示该卡已融合召唤
function c26273196.matop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(26273196,RESET_EVENT+0xd6c0000,0,1)
end
-- 判断该卡是否已融合召唤（通过flag标记）
function c26273196.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(26273196)>0
end
-- 设置连锁处理信息，包括投掷硬币和破坏场上所有怪兽
function c26273196.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取场上所有怪兽作为破坏目标
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if chk==0 then return g:GetCount()>0 end
	-- 设置连锁处理信息，提示玩家进行硬币投掷
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
	-- 设置连锁处理信息，设置要破坏的怪兽数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 定义伤害计算过滤器，用于获取表侧表示怪兽的攻击力
function c26273196.damfilter(c)
	if c:IsPreviousPosition(POS_FACEUP) then
		return math.max(c:GetTextAttack(),0)
	else
		return 0
	end
end
-- 执行效果处理，包括投掷硬币、破坏怪兽并造成伤害
function c26273196.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取场上所有怪兽作为破坏目标
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 提示玩家选择硬币正反面
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COIN)  --"请选择硬币的正反面"
		-- 让玩家宣言硬币正反面
		local coin=Duel.AnnounceCoin(tp)
		-- 投掷1次硬币
		local res=Duel.TossCoin(tp,1)
		local damp=0
		if coin~=res then
			damp=1-tp
		else
			damp=tp
		end
		-- 破坏场上所有怪兽
		if Duel.Destroy(g,REASON_EFFECT)~=0 then
			-- 获取实际被破坏的怪兽组
			local og=Duel.GetOperatedGroup()
			local atk=math.ceil((og:GetSum(c26273196.damfilter))/2)
			-- 根据破坏怪兽的攻击力总和对玩家造成伤害
			Duel.Damage(damp,atk,REASON_EFFECT)
		end
	end
end

--時の魔導士
-- 效果：
-- 「时间魔术师」＋效果怪兽
-- ①：1回合1次，这张卡是已融合召唤的场合才能发动。进行1次投掷硬币，对里表作猜测。猜中的场合，场上的怪兽全部破坏，对方受到表侧表示破坏的怪兽的原本攻击力合计数值一半的伤害。猜错的场合，场上的怪兽全部破坏，自己受到表侧表示破坏的怪兽的原本攻击力合计数值一半的伤害。
function c26273196.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置该卡的融合召唤手续：需要「时间魔术师」＋1只效果怪兽作为融合素材。
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
	-- 这张卡是已融合召唤的场合才能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCondition(c26273196.matcon)
	e2:SetOperation(c26273196.matop)
	c:RegisterEffect(e2)
end
-- 判断该卡的召唤方式是否为融合召唤（即是否满足“已融合召唤”的前提）。
function c26273196.matcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 融合召唤成功时，给这张卡自身注册一个专用的flag标记，用于记录其已通过融合召唤出场。
function c26273196.matop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(26273196,RESET_EVENT+0xd6c0000,0,1)
end
-- 发动条件：检测这张卡是否拥有融合召唤成功时注册的flag标记（即确认其为融合召唤出场）。
function c26273196.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(26273196)>0
end
-- 效果发动时的目标处理：取场上所有怪兽，若存在则设置本次连锁包含硬币与破坏的操作信息。
function c26273196.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 取得场上所有怪兽（包含双方怪兽区的所有表侧/里侧怪兽），用作可能被破坏的对象群。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if chk==0 then return g:GetCount()>0 end
	-- 设置操作信息：本次连锁包含投掷硬币的效果（1次硬币）。
	Duel.SetOperationInfo(0,CATEGORY_COIN,nil,0,tp,1)
	-- 设置操作信息：本次连锁会破坏场上所有怪兽，并传递目标群体g和数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 计算伤害用的过滤函数：若该怪兽被破坏前是表侧表示，则返回其原本攻击力（攻击力为?时按0），否则返回0。
function c26273196.damfilter(c)
	if c:IsPreviousPosition(POS_FACEUP) then
		return math.max(c:GetTextAttack(),0)
	else
		return 0
	end
end
-- 效果处理：宣言硬币正反面并投掷硬币，根据猜测是否正确决定伤害对象，然后破坏场上所有怪兽并按其中表侧表示怪兽的原本攻击力合计一半给对应玩家造成伤害。
function c26273196.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果处理时重新获取当前场上所有怪兽（以处理时场上的实际状态为准）。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 提示玩家选择硬币的正反面，并将选择消息缓存供AnnounceCoin使用。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COIN)  --"请选择硬币的正反面"
		-- 玩家宣言硬币的正反面（0=正面，1=反面），作为自己的猜测。
		local coin=Duel.AnnounceCoin(tp)
		-- 投掷1次硬币，获得实际结果（1=正面，0=反面）。
		local res=Duel.TossCoin(tp,1)
		local damp=0
		if coin~=res then
			damp=1-tp
		else
			damp=tp
		end
		-- 以效果破坏场上所有怪兽；若至少破坏了1只怪兽，则继续执行后续伤害处理。
		if Duel.Destroy(g,REASON_EFFECT)~=0 then
			-- 取得刚才被效果破坏的怪兽组，用于累计原本攻击力。
			local og=Duel.GetOperatedGroup()
			local atk=math.ceil((og:GetSum(c26273196.damfilter))/2)
			-- 根据猜测结果向对应的玩家（猜中给对方，猜错给自己）造成表侧表示破坏怪兽原本攻击力合计一半数值的伤害。
			Duel.Damage(damp,atk,REASON_EFFECT)
		end
	end
end

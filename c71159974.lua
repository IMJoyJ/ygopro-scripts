--魔鍵召竜－アンドラビムス
-- 效果：
-- 「魔键」效果怪兽＋衍生物以外的通常怪兽
-- ①：在这张卡的融合召唤成功时对方不能把效果发动。
-- ②：1回合1次，以自己墓地1只通常怪兽或者「魔键」怪兽为对象才能发动。持有和那只怪兽相同属性的对方场上的怪兽全部破坏。
-- ③：作为这张卡的融合素材的怪兽的属性是2种类的场合，1回合1次，持有和自己墓地的其中任意种的怪兽相同属性的对方怪兽被战斗·效果破坏的场合才能发动。自己从卡组抽1张。
function c71159974.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合召唤素材为：1只满足mtfilter过滤条件的怪兽（「魔键」效果怪兽）和1只满足mtfilter2过滤条件的怪兽（衍生物以外的通常怪兽）。
	aux.AddFusionProcFun2(c,c71159974.mtfilter,c71159974.mtfilter2,true)
	-- 作为这张卡的融合素材的怪兽的属性是2种类的场合
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(c71159974.valcheck)
	c:RegisterEffect(e0)
	-- ①：在这张卡的融合召唤成功时对方不能把效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c71159974.limcon)
	e1:SetOperation(c71159974.limop)
	c:RegisterEffect(e1)
	-- ①：在这张卡的融合召唤成功时对方不能把效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_CHAIN_END)
	e2:SetOperation(c71159974.limop2)
	c:RegisterEffect(e2)
	-- ②：1回合1次，以自己墓地1只通常怪兽或者「魔键」怪兽为对象才能发动。持有和那只怪兽相同属性的对方场上的怪兽全部破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(71159974,0))  --"相同属性的对方怪兽全部破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c71159974.destg)
	e3:SetOperation(c71159974.desop)
	c:RegisterEffect(e3)
	-- ③：作为这张卡的融合素材的怪兽的属性是2种类的场合，1回合1次，持有和自己墓地的其中任意种的怪兽相同属性的对方怪兽被战斗·效果破坏的场合才能发动。自己从卡组抽1张。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(71159974,1))  --"抽卡"
	e4:SetCategory(CATEGORY_DRAW)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c71159974.drcon)
	e4:SetTarget(c71159974.drtg)
	e4:SetOperation(c71159974.drop)
	c:RegisterEffect(e4)
	-- 作为这张卡的融合素材的怪兽的属性是2种类的场合
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	e5:SetCondition(c71159974.matcon)
	e5:SetOperation(c71159974.matop)
	c:RegisterEffect(e5)
	e0:SetLabelObject(e5)
end
-- 融合素材过滤条件1：卡名含有「魔键」的效果怪兽。
function c71159974.mtfilter(c)
	return c:IsFusionSetCard(0x165) and c:IsFusionType(TYPE_EFFECT)
end
-- 融合素材过滤条件2：通常怪兽且不能是衍生物。
function c71159974.mtfilter2(c)
	return c:IsFusionType(TYPE_NORMAL) and not c:IsType(TYPE_TOKEN)
end
-- 过滤具有属性的怪兽。
function c71159974.attfilter(c,rc)
	return c:GetAttribute()>0
end
-- 检查融合素材的属性种类是否为2种，若是则将标签值设为1。
function c71159974.valcheck(e,c)
	local mg=c:GetMaterial()
	local fg=mg:Filter(c71159974.attfilter,nil,c)
	if fg:GetClassCount(Card.GetAttribute)==2 then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- 限制效果发动时点：此卡融合召唤成功时。
function c71159974.limcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 融合召唤成功时，若当前连锁为0则直接限制对方不能发动效果；若当前连锁为1，则注册临时效果在连锁结束时限制对方发动效果。
function c71159974.limop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前连锁数是否为0（即融合召唤成功后没有其他卡片发动效果）。
	if Duel.GetCurrentChain()==0 then
		-- 设定连锁限制直到连锁结束，使得对方不能对应发动效果。
		Duel.SetChainLimitTillChainEnd(c71159974.chlimit)
	-- 判断当前连锁数是否为1（即融合召唤成功时有诱发效果发动，进入了连锁1）。
	elseif Duel.GetCurrentChain()==1 then
		e:GetHandler():RegisterFlagEffect(71159974,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		-- ①：在这张卡的融合召唤成功时对方不能把效果发动。②：1回合1次，以自己墓地1只通常怪兽或者「魔键」怪兽为对象才能发动。持有和那只怪兽相同属性的对方场上的怪兽全部破坏。③：作为这张卡的融合素材的怪兽的属性是2种类的场合，1回合1次，持有和自己墓地的其中任意种的怪兽相同属性的对方怪兽被战斗·效果破坏的场合才能发动。自己从卡组抽1张。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAINING)
		e1:SetOperation(c71159974.resetop)
		-- 注册全局效果e1，用于在有新连锁发动时重置限制标记。
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EVENT_BREAK_EFFECT)
		e2:SetReset(RESET_CHAIN)
		-- 注册全局效果e2，用于在效果处理被中断时重置限制标记。
		Duel.RegisterEffect(e2,tp)
	end
end
-- 重置限制标记并使该重置效果自身失效。
function c71159974.resetop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():ResetFlagEffect(71159974)
	e:Reset()
end
-- 在连锁结束时，若存在限制标记，则设定连锁限制使对方不能发动效果，并重置标记。
function c71159974.limop2(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetFlagEffect(71159974)~=0 then
		-- 设定连锁限制直到连锁结束，使得对方不能对应发动效果。
		Duel.SetChainLimitTillChainEnd(c71159974.chlimit)
	end
	e:GetHandler():ResetFlagEffect(71159974)
end
-- 连锁限制条件：发动效果的玩家必须与当前玩家相同（即对方不能发动效果）。
function c71159974.chlimit(e,ep,tp)
	return tp==ep
end
-- 墓地目标怪兽过滤条件：自己墓地的通常怪兽或「魔键」怪兽，且对方场上存在持有相同属性的怪兽。
function c71159974.ckfilter(c,tp)
	return (c:IsType(TYPE_NORMAL) or c:IsSetCard(0x165) and c:IsType(TYPE_MONSTER))
		-- 检查对方场上是否存在至少1只与该墓地怪兽属性相同的表侧表示怪兽。
		and Duel.IsExistingMatchingCard(c71159974.desfilter,tp,0,LOCATION_MZONE,1,nil,c:GetAttribute())
end
-- 破坏目标过滤条件：对方场上表侧表示且属性与指定属性相同的怪兽。
function c71159974.desfilter(c,at)
	return c:IsFaceup() and c:IsAttribute(at)
end
-- 破坏效果的Target函数：选择自己墓地1只通常怪兽或「魔键」怪兽为对象，并设置破坏对方场上相同属性怪兽的操作信息。
function c71159974.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c71159974.ckfilter(chkc,tp) end
	-- 检查自己墓地是否存在满足条件的通常怪兽或「魔键」怪兽作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c71159974.ckfilter,tp,LOCATION_GRAVE,0,1,nil,tp) end
	-- 给玩家发送提示信息，提示选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己墓地1只满足条件的怪兽作为效果的对象并设为效果对象。
	local g=Duel.SelectTarget(tp,c71159974.ckfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	local tc=g:GetFirst()
	-- 获取对方场上所有与对象怪兽属性相同的表侧表示怪兽。
	local tg=Duel.GetMatchingGroup(c71159974.desfilter,tp,0,LOCATION_MZONE,nil,tc:GetAttribute())
	-- 设置当前连锁的操作信息为破坏这些相同属性的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg,tg:GetCount(),0,0)
end
-- 破坏效果的Operation函数：破坏对方场上所有与对象怪兽属性相同的表侧表示怪兽。
function c71159974.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 获取对方场上所有与对象怪兽属性相同的表侧表示怪兽。
		local g=Duel.GetMatchingGroup(c71159974.desfilter,tp,0,LOCATION_MZONE,nil,tc:GetAttribute())
		-- 因效果破坏这些怪兽。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 触发抽卡效果的破坏怪兽过滤条件：被战斗或效果破坏送去墓地的对方怪兽，且其属性与自己墓地的怪兽相同。
function c71159974.drfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and c:IsPreviousLocation(LOCATION_MZONE) and c:GetPreviousControler()==tp
		-- 检查自己墓地是否存在与被破坏怪兽属性相同的怪兽。
		and Duel.IsExistingMatchingCard(Card.IsAttribute,tp,0,LOCATION_GRAVE,1,nil,c:GetAttribute())
end
-- 抽卡效果的发动条件：持有和自己墓地相同属性的对方怪兽被破坏，且此卡具有融合素材属性为2种类的标记。
function c71159974.drcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c71159974.drfilter,1,nil,1-tp) and e:GetHandler():GetFlagEffect(71159975)~=0
end
-- 抽卡效果的Target函数：检查自己是否能抽卡，并设置抽1张卡的操作信息。
function c71159974.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家当前是否可以从卡组抽1张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置效果处理的对象玩家为自己。
	Duel.SetTargetPlayer(tp)
	-- 设置效果处理的参数为1（抽1张卡）。
	Duel.SetTargetParam(1)
	-- 设置当前连锁的操作信息为玩家抽1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 抽卡效果的Operation函数：自己从卡组抽1张卡。
function c71159974.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的目标玩家和抽卡张数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定张数的卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 融合素材检查效果的发动条件：此卡融合召唤成功，且融合素材的属性为2种类。
function c71159974.matcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) and e:GetLabel()==1
end
-- 融合素材检查效果的Operation函数：给此卡注册一个表示“融合素材的怪兽的属性是2种类”的标记。
function c71159974.matop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(71159975,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(71159974,2))  --"融合素材的怪兽的属性是2种类"
end

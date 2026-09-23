--超電導波サンダーフォース
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。这张卡的发动和效果不会被无效化。
-- ①：自己场上有原本卡名是「奥西里斯之天空龙」的怪兽存在的场合才能发动。对方场上的表侧表示怪兽全部破坏。这张卡在自己主要阶段发动的场合，可以再让以下效果适用。
-- ●自己从卡组抽出这个效果破坏送去对方墓地的怪兽的数量。这个回合，自己只能用1只怪兽攻击。
function c42469671.initial_effect(c)
	-- 将「奥西里斯之天空龙」记入该卡所记载的卡名列表中
	aux.AddCodeList(c,10000020)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上有原本卡名是「奥西里斯之天空龙」的怪兽存在的场合才能发动。对方场上的表侧表示怪兽全部破坏。这张卡在自己主要阶段发动的场合，可以再让以下效果适用。●自己从卡组抽出这个效果破坏送去对方墓地的怪兽的数量。这个回合，自己只能用1只怪兽攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CANNOT_INACTIVATE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCountLimit(1,42469671+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c42469671.descon)
	e1:SetTarget(c42469671.destg)
	e1:SetOperation(c42469671.desop)
	c:RegisterEffect(e1)
	-- 这张卡的发动和效果不会被无效化。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CANNOT_DISABLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	c:RegisterEffect(e0)
end
-- 过滤自己场上表侧表示、原本卡名为「奥西里斯之天空龙」的怪兽
function c42469671.actfilter(c)
	return c:IsFaceup() and c:IsOriginalCodeRule(10000020)
end
-- 效果发动条件：自己场上有原本卡名为「奥西里斯之天空龙」的怪兽存在
function c42469671.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在原本卡名为「奥西里斯之天空龙」的怪兽
	return Duel.IsExistingMatchingCard(c42469671.actfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 效果发动目标检查
function c42469671.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在表侧表示怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有的表侧表示怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	-- 设置操作信息：破坏对方场上全部表侧表示怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	if g:GetCount()~=0 then
		-- 设置操作信息：抽卡
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,g:GetCount())
	end
end
-- 过滤送入对方墓地的卡片
function c42469671.sgfilter(c,p)
	return c:IsLocation(LOCATION_GRAVE) and c:IsControler(p)
end
-- 效果处理：破坏对方场上全部表侧表示怪兽，若在主要阶段发动可适用抽卡及限制攻击效果
function c42469671.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有的表侧表示怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	-- 破坏对方场上全部表侧表示怪兽
	Duel.Destroy(g,REASON_EFFECT)
	-- 统计被破坏并送去对方墓地的怪兽数量
	local dc=Duel.GetOperatedGroup():FilterCount(c42469671.sgfilter,nil,1-tp)
	-- 检查是否在自己回合的主要阶段且有怪兽送墓并能抽卡
	if dc~=0 and Duel.IsTurnPlayer(tp) and Duel.IsMainPhase() and Duel.IsPlayerCanDraw(tp,dc)
		-- 询问是否适用抽卡及限制攻击效果
		and Duel.SelectYesNo(tp,aux.Stringid(42469671,0)) then  --"是否抽卡？"
		-- 中断效果处理
		Duel.BreakEffect()
		-- 抽被破坏送去对方墓地的怪兽数量的卡
		Duel.Draw(tp,dc,REASON_EFFECT)
		-- 这个回合，自己只能用1只怪兽攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetCondition(c42469671.atkcon)
		e1:SetTarget(c42469671.atktg)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册本回合只能用1只怪兽攻击的限制效果
		Duel.RegisterEffect(e1,tp)
		-- 这个回合，自己只能用1只怪兽攻击。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EVENT_ATTACK_ANNOUNCE)
		e2:SetReset(RESET_PHASE+PHASE_END)
		e2:SetOperation(c42469671.checkop)
		e2:SetLabelObject(e1)
		-- 注册攻击宣言检测效果
		Duel.RegisterEffect(e2,tp)
	end
end
-- 攻击宣言时记录首个进行攻击的怪兽并施加限制标记
function c42469671.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否已有怪兽进行过攻击宣言
	if Duel.GetFlagEffect(tp,42469671)~=0 then return end
	local fid=eg:GetFirst():GetFieldID()
	-- 注册本回合已有怪兽进行攻击的标记
	Duel.RegisterFlagEffect(tp,42469671,RESET_PHASE+PHASE_END,0,1)
	e:GetLabelObject():SetLabel(fid)
end
-- 攻击限制效果的适用条件：本回合已有怪兽进行攻击
function c42469671.atkcon(e)
	-- 检查玩家是否已存在攻击标记
	return Duel.GetFlagEffect(e:GetHandlerPlayer(),42469671)~=0
end
-- 限制目标：除首个进行攻击的怪兽以外的其他怪兽不能攻击
function c42469671.atktg(e,c)
	return c:GetFieldID()~=e:GetLabel()
end

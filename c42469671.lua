--超電導波サンダーフォース
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。这张卡的发动和效果不会被无效化。
-- ①：自己场上有原本卡名是「奥西里斯之天空龙」的怪兽存在的场合才能发动。对方场上的表侧表示怪兽全部破坏。这张卡在自己主要阶段发动的场合，可以再让以下效果适用。
-- ●自己从卡组抽出这个效果破坏送去对方墓地的怪兽的数量。这个回合，自己只能用1只怪兽攻击。
function c42469671.initial_effect(c)
	-- 记录此卡与「奥西里斯之天空龙」的关联，用于效果判定
	aux.AddCodeList(c,10000020)
	-- ①：自己场上有原本卡名是「奥西里斯之天空龙」的怪兽存在的场合才能发动。对方场上的表侧表示怪兽全部破坏。这张卡在自己主要阶段发动的场合，可以再让以下效果适用。
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
end
-- 过滤函数：检查场上是否存在表侧表示的「奥西里斯之天空龙」怪兽
function c42469671.actfilter(c)
	return c:IsFaceup() and c:IsOriginalCodeRule(10000020)
end
-- 效果发动条件：确认自己场上存在表侧表示的「奥西里斯之天空龙」怪兽
function c42469671.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只表侧表示的「奥西里斯之天空龙」怪兽
	return Duel.IsExistingMatchingCard(c42469671.actfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 效果处理目标：设置破坏对方场上所有表侧表示怪兽及可能抽卡的效果信息
function c42469671.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足发动条件：确认对方场上存在至少1只表侧表示怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有表侧表示怪兽的卡片组
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	-- 设置破坏效果的操作信息，目标为对方场上所有表侧表示怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	if g:GetCount()~=0 then
		-- 设置抽卡效果的操作信息，数量为被破坏怪兽数量
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,g:GetCount())
	end
end
-- 过滤函数：检查卡片是否在墓地且为指定玩家控制
function c42469671.sgfilter(c,p)
	return c:IsLocation(LOCATION_GRAVE) and c:IsControler(p)
end
-- 效果处理操作：破坏对方场上所有表侧表示怪兽并计算被破坏怪兽数量
function c42469671.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有表侧表示怪兽的卡片组
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	-- 以效果原因破坏对方场上所有表侧表示怪兽
	Duel.Destroy(g,REASON_EFFECT)
	-- 统计被破坏并送入对方墓地的怪兽数量
	local dc=Duel.GetOperatedGroup():FilterCount(c42469671.sgfilter,nil,1-tp)
	-- 判断是否满足抽卡条件：回合为使用者回合、处于主要阶段、可以抽卡
	if dc~=0 and Duel.IsTurnPlayer(tp) and Duel.IsMainPhase() and Duel.IsPlayerCanDraw(tp,dc)
		-- 询问使用者是否选择抽卡
		and Duel.SelectYesNo(tp,aux.Stringid(42469671,0)) then  --"是否抽卡？"
		-- 中断当前效果处理，使后续效果视为错时处理
		Duel.BreakEffect()
		-- 让使用者从卡组抽指定数量的卡
		Duel.Draw(tp,dc,REASON_EFFECT)
		-- ●自己从卡组抽出这个效果破坏送去对方墓地的怪兽的数量。这个回合，自己只能用1只怪兽攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetCondition(c42469671.atkcon)
		e1:SetTarget(c42469671.atktg)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册攻击禁止效果，使使用者在本回合只能用1只怪兽攻击
		Duel.RegisterEffect(e1,tp)
		-- 注册攻击宣言时触发的持续效果，用于记录攻击怪兽的FieldID
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EVENT_ATTACK_ANNOUNCE)
		e2:SetReset(RESET_PHASE+PHASE_END)
		e2:SetOperation(c42469671.checkop)
		e2:SetLabelObject(e1)
		-- 注册攻击宣言时触发的持续效果，用于记录攻击怪兽的FieldID
		Duel.RegisterEffect(e2,tp)
	end
end
-- 处理攻击宣言时的效果，记录攻击怪兽的FieldID
function c42469671.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否已注册标识效果，避免重复注册
	if Duel.GetFlagEffect(tp,42469671)~=0 then return end
	local fid=eg:GetFirst():GetFieldID()
	-- 注册标识效果，用于记录本回合已使用过该效果
	Duel.RegisterFlagEffect(tp,42469671,RESET_PHASE+PHASE_END,0,1)
	e:GetLabelObject():SetLabel(fid)
end
-- 判断是否已注册标识效果，用于判断是否可以使用攻击限制效果
function c42469671.atkcon(e)
	-- 检查使用者是否已注册标识效果
	return Duel.GetFlagEffect(e:GetHandlerPlayer(),42469671)~=0
end
-- 设置攻击禁止效果的目标，禁止FieldID与记录值相同的怪兽攻击
function c42469671.atktg(e,c)
	return c:GetFieldID()~=e:GetLabel()
end

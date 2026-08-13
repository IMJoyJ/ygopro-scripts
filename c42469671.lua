--超電導波サンダーフォース
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。这张卡的发动和效果不会被无效化。
-- ①：自己场上有原本卡名是「奥西里斯之天空龙」的怪兽存在的场合才能发动。对方场上的表侧表示怪兽全部破坏。这张卡在自己主要阶段发动的场合，可以再让以下效果适用。
-- ●自己从卡组抽出这个效果破坏送去对方墓地的怪兽的数量。这个回合，自己只能用1只怪兽攻击。
function c42469671.initial_effect(c)
	-- 将本卡上记载的「奥西里斯之天空龙」（卡片密码10000020）加入代码列表，使该卡名在规则上被视为本卡记载的卡名，用于满足「原本卡名是「奥西里斯之天空龙」」的判定条件。
	aux.AddCodeList(c,10000020)
	-- 这个卡名的卡在1回合只能发动1张。这张卡的发动和效果不会被无效化。①：自己场上有原本卡名是「奥西里斯之天空龙」的怪兽存在的场合才能发动。对方场上的表侧表示怪兽全部破坏。这张卡在自己主要阶段发动的场合，可以再让以下效果适用。●自己从卡组抽出这个效果破坏送去对方墓地的怪兽的数量。这个回合，自己只能用1只怪兽攻击。
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
-- 过滤函数：判定卡片为表侧表示怪兽，且其原本卡名在规则上等同于「奥西里斯之天空龙」（代码10000020）。用于检查是否有符合条件的天空龙在场。
function c42469671.actfilter(c)
	return c:IsFaceup() and c:IsOriginalCodeRule(10000020)
end
-- 发动条件判断：检查效果持有者的场上（LOCATION_MZONE）是否存在至少1只满足actfilter（表侧表示且原本卡名为「奥西里斯之天空龙」）的怪兽。
function c42469671.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回是否存在至少1只表侧表示且原本卡名为「奥西里斯之天空龙」的怪兽，位置为效果发动者自己的主要怪兽区。
	return Duel.IsExistingMatchingCard(c42469671.actfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
-- 效果发动时的目标判定与操作信息设定：若为发动合法性检查（chk==0）则确认对方场上有表侧表示怪兽；然后获取对方场上全部表侧表示怪兽，设置破坏操作信息；若数量非0，再设置抽卡操作信息，以用于后续处理与连锁反应。
function c42469671.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：确认对方场上（tp的对方，位置LOCATION_MZONE）至少存在1只表侧表示怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上的全部表侧表示怪兽，作为准备破坏的对象组，用于统计数量和设置操作信息。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	-- 设置本次效果的破坏操作信息：将获取到的表侧表示怪兽组g全部作为将被效果破坏的对象，数量为g中的卡数。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	if g:GetCount()~=0 then
		-- 设置抽卡操作信息：若破坏对象不为0，则设置后续可能进行的抽卡，目标玩家为tp，预计抽卡数为g中的卡数，用于让抽卡相关效果正确响应。
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,g:GetCount())
	end
end
-- 过滤函数：判定卡片位于墓地且控制者为指定玩家p。用于统计被破坏后进入对方墓地的怪兽数量。
function c42469671.sgfilter(c,p)
	return c:IsLocation(LOCATION_GRAVE) and c:IsControler(p)
end
-- 效果处理：获取对方场上全部表侧表示怪兽并全部破坏；统计被破坏后送去对方墓地的怪兽数dc；若dc不为0、当前为tp的回合的主要阶段、tp可以抽dc张卡且tp选择“是”，则中断当前效果链，让tp抽dc张卡，并给自己场上的怪兽附加本回合只能用1只怪兽攻击的限制。
function c42469671.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的全部表侧表示怪兽，作为本次破坏处理的对象。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	-- 将对方场上的全部表侧表示怪兽以效果原因（REASON_EFFECT）破坏，不取对象。
	Duel.Destroy(g,REASON_EFFECT)
	-- 从本次破坏实际操作的卡片中，筛选出位于墓地且控制者为对方（1-tp）的卡的数量，即被这个效果破坏并送去对方墓地的怪兽数量dc。
	local dc=Duel.GetOperatedGroup():FilterCount(c42469671.sgfilter,nil,1-tp)
	-- 判断追加强化效果的条件是否满足：dc不为0（确有怪兽被破坏进对方墓地）、当前是tp的回合、当前是主要阶段、且tp可以抽dc张卡。
	if dc~=0 and Duel.IsTurnPlayer(tp) and Duel.IsMainPhase() and Duel.IsPlayerCanDraw(tp,dc)
		-- 询问tp是否适用抽卡效果（显示“是否抽卡？”），只有选择“是”才继续后续的抽卡和攻击限制。
		and Duel.SelectYesNo(tp,aux.Stringid(42469671,0)) then  --"是否抽卡？"
		-- 中断当前效果链，将后续的抽卡与攻击限制视为与之前破坏不同时处理，错开时点以避免错过触发时机。
		Duel.BreakEffect()
		-- 让tp以效果原因抽取dc张卡，对应“自己从卡组抽出这个效果破坏送去对方墓地的怪兽的数量”。
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
		-- 将攻击限制效果e1注册到玩家tp，使其作用于tp场上的怪兽，开始限制本回合后续的攻击宣言。
		Duel.RegisterEffect(e1,tp)
		-- 这个回合，自己只能用1只怪兽攻击。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EVENT_ATTACK_ANNOUNCE)
		e2:SetReset(RESET_PHASE+PHASE_END)
		e2:SetOperation(c42469671.checkop)
		e2:SetLabelObject(e1)
		-- 将攻击宣言监测效果e2注册到tp，使e2在攻击宣言时触发，以记录第一只攻击的怪兽。
		Duel.RegisterEffect(e2,tp)
	end
end
-- 攻击宣言时的处理：若本回合已记录过第一只攻击怪兽则不再处理；否则记录当前攻击宣言的怪兽的FieldID到限制效果的标签中，并给tp设置flag，标记已记录过一次攻击宣言。
function c42469671.checkop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查tp是否存在42469671标识效果，若已存在说明本回合已经记录过第一只攻击怪兽，则直接返回，防止重复记录。
	if Duel.GetFlagEffect(tp,42469671)~=0 then return end
	local fid=eg:GetFirst():GetFieldID()
	-- 给tp注册一个名为42469671的标识效果，该效果在结束阶段重置，用于标记本回合已经进行过第一只怪兽攻击宣言。
	Duel.RegisterFlagEffect(tp,42469671,RESET_PHASE+PHASE_END,0,1)
	e:GetLabelObject():SetLabel(fid)
end
-- 攻击限制效果的生效条件：只有在tp已有42469671标识（即发生过第一次攻击宣言）时，限制效果才适用，从而保证第一只怪兽可以攻击，后续怪兽不能攻击。
function c42469671.atkcon(e)
	-- 判断tp是否存在42469671标识，若存在则攻击限制效果开始生效。
	return Duel.GetFlagEffect(e:GetHandlerPlayer(),42469671)~=0
end
-- 攻击限制的目标判定：如果怪兽的FieldID不等于限制效果记录的标签（即不是第一只攻击宣言的怪兽），则禁止其攻击宣言；第一只攻击宣言的怪兽不受限制。
function c42469671.atktg(e,c)
	return c:GetFieldID()~=e:GetLabel()
end

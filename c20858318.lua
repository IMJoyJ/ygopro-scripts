--必殺！黒蠍コンビネーション
-- 效果：
-- 当自己场上存在表侧表示的「首领 扎鲁格」「黑蝎-拆除陷阱的克里夫」「黑蝎-飞速逃跑的齐克」「黑蝎-强力的高戈」「黑蝎-荆棘的美奈」时这张卡才能发动。这张卡发动的回合，这些怪兽可以对对方进行直接攻击，每只怪兽对对方造成的战斗伤害数值在此时都变成400点。
function c20858318.initial_effect(c)
	-- 将五只黑蝎怪兽的卡号（首领扎鲁格、黑蝎-拆除陷阱的克里夫、黑蝎-飞速逃跑的齐克、黑蝎-强力的高戈、黑蝎-荆棘的美奈）登记为这张卡上记载的卡名，用于效果文关联识别。
	aux.AddCodeList(c,76922029,6967870,61587183,48768179,74153887)
	-- 创建并注册本卡的启动效果（魔法卡发动），设定发动条件、发动时的对象记录和发动后的处理，对应效果原文：“当自己场上存在表侧表示的「首领 扎鲁格」「黑蝎-拆除陷阱的克里夫」「黑蝎-飞速逃跑的齐克」「黑蝎-强力的高戈」「黑蝎-荆棘的美奈」时这张卡才能发动。这张卡发动的回合，这些怪兽可以对对方进行直接攻击，每只怪兽对对方造成的战斗伤害数值在此时都变成400点。”
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c20858318.con)
	e1:SetTarget(c20858318.tg)
	e1:SetOperation(c20858318.op)
	c:RegisterEffect(e1)
end
-- 过滤器：判断一张卡是否为表侧表示且卡号等于指定代码，用于检查五只黑蝎怪兽是否在场。
function c20858318.cfilter(c,code)
	return c:IsFaceup() and c:IsCode(code)
end
-- 发动条件判定：己方主要怪兽区必须同时存在表侧表示的首领扎鲁格、黑蝎-拆除陷阱的克里夫、黑蝎-飞速逃跑的齐克、黑蝎-强力的高戈、黑蝎-荆棘的美奈各至少1张，该卡才能发动。
function c20858318.con(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方场上是否存在表侧表示的「首领 扎鲁格」（卡号76922029）至少1张。
	return Duel.IsExistingMatchingCard(c20858318.cfilter,tp,LOCATION_MZONE,0,1,nil,76922029)
		-- 检查己方场上是否存在表侧表示的「黑蝎-拆除陷阱的克里夫」（卡号6967870）至少1张。
		and Duel.IsExistingMatchingCard(c20858318.cfilter,tp,LOCATION_MZONE,0,1,nil,6967870)
		-- 检查己方场上是否存在表侧表示的「黑蝎-飞速逃跑的齐克」（卡号61587183）至少1张。
		and Duel.IsExistingMatchingCard(c20858318.cfilter,tp,LOCATION_MZONE,0,1,nil,61587183)
		-- 检查己方场上是否存在表侧表示的「黑蝎-强力的高戈」（卡号48768179）至少1张。
		and Duel.IsExistingMatchingCard(c20858318.cfilter,tp,LOCATION_MZONE,0,1,nil,48768179)
		-- 检查己方场上是否存在表侧表示的「黑蝎-荆棘的美奈」（卡号74153887）至少1张。
		and Duel.IsExistingMatchingCard(c20858318.cfilter,tp,LOCATION_MZONE,0,1,nil,74153887)
end
-- 发动时处理：效果发动时必须为通常魔法卡的发动（ACTIVATE），并将己方场上所有怪兽记录为本连锁的处理对象，以便后续判断哪些怪兽受到本回合效果影响。
function c20858318.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsHasType(EFFECT_TYPE_ACTIVATE) end
	-- 取得己方场上主要怪兽区的全部怪兽，作为可能受本回合效果影响的怪兽集合。
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	-- 将己方场上全部怪兽设置为当前连锁的处理对象，使这些怪兽与本次效果建立关联，效果处理时可通过连锁信息获取。
	Duel.SetTargetCard(g)
end
-- 效果处理：给发动时记录的怪兽逐一打上本卡标记；然后对己方怪兽区域赋予可直接攻击的效果，并对对方玩家赋予战斗伤害变为400的效果。
function c20858318.op(e,tp,eg,ep,ev,re,r,rp)
	-- 从连锁信息中取出发动时记录的对象怪兽组，并筛选出仍然与本次效果相关（未离场、未被无效等）的怪兽，用于后续打标记。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	local tc=g:GetFirst()
	while tc do
		tc:RegisterFlagEffect(20858318,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		tc=g:GetNext()
	end
	-- 创建并设置直接攻击的永续效果（EFFECT_DIRECT_ATTACK），使被标记的己方怪兽可以对对方进行直接攻击，对应效果原文：“这些怪兽可以对对方进行直接攻击”
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c20858318.affected)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将直接攻击效果注册到场上，持续到结束阶段，使所有带有标记的己方怪兽获得直接攻击能力。
	Duel.RegisterEffect(e1,tp)
	-- 创建并设置战斗伤害变更效果（EFFECT_CHANGE_BATTLE_DAMAGE），使被标记怪兽直接攻击造成的战斗伤害变成400，对应效果原文：“每只怪兽对对方造成的战斗伤害数值在此时都变成400点。”
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(0,1)
	e2:SetCondition(c20858318.rdcon)
	e2:SetValue(400)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将伤害变更效果注册到场上，持续到结束阶段，以对方玩家为对象，改变其受到的来自被标记怪兽的战斗伤害。
	Duel.RegisterEffect(e2,tp)
end
-- 判断怪兽是否带有本回合效果标记（20858318），用于限定直接攻击效果只适用于发动时记录的这些黑蝎怪兽。
function c20858318.affected(e,c)
	return c:GetFlagEffect(20858318)~=0
end
-- 伤害变更效果的发动条件：当前攻击怪兽带有标记且攻击对象为空（即正在直接攻击），此时才适用伤害变成400。
function c20858318.rdcon(e)
	-- 返回攻击者带有本效果标记且没有攻击对象（直接攻击）的判定结果，作为伤害变更是否生效的依据。
	return Duel.GetAttacker():GetFlagEffect(20858318)~=0 and Duel.GetAttackTarget()==nil
end

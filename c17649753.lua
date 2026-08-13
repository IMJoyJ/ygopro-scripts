--ワーム・ルクイエ
-- 效果：
-- 这张卡若不在这张卡反转的回合则不能攻击宣言。这张卡攻击的场合，战斗阶段结束时变成里侧守备表示。
function c17649753.initial_effect(c)
	-- 对应效果原文：“这张卡若不在这张卡反转的回合则不能攻击宣言。”（反转时记录该回合已反转的标记）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_FLIP)
	e1:SetOperation(c17649753.flipop)
	c:RegisterEffect(e1)
	-- 对应效果原文：“这张卡若不在这张卡反转的回合则不能攻击宣言。”（反转的回合以外不能攻击宣言的限制）
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e2:SetCondition(c17649753.atkcon)
	c:RegisterEffect(e2)
	-- 对应效果原文：“这张卡攻击的场合，战斗阶段结束时变成里侧守备表示。”
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c17649753.poscon)
	e3:SetOperation(c17649753.posop)
	c:RegisterEffect(e3)
end
-- 当这张卡反转成功时，为其注册一个编号为17649753的标记效果，持续到结束阶段或卡片离场、回手、回卡组、除外、送墓等标准重置时机，用于标识“这张卡已在本回合反转过”。
function c17649753.flipop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(17649753,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 当这张卡没有“本回合已反转过”的标记时，禁止其进行攻击宣言；换言之，只有反转过的那个回合才允许攻击宣言。
function c17649753.atkcon(e)
	return e:GetHandler():GetFlagEffect(17649753)==0
end
-- 检测这张卡本回合是否进行过攻击（攻击次数大于0），若是则满足发动条件，在战斗阶段结束时触发将自身变成里侧守备表示的效果。
function c17649753.poscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetAttackedCount()>0
end
-- 效果处理时，若这张卡仍以表侧表示存在于场上，则将其变成里侧守备表示。
function c17649753.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() then
		-- 将这张卡的表示形式改变为里侧守备表示。
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end

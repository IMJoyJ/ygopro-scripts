--E-HERO マリシャス・ベイン
-- 效果：
-- 「邪心英雄」怪兽＋5星以上的怪兽
-- 这张卡用「暗黑融合」的效果才能特殊召唤。这个卡名的②的效果1回合只能使用1次。
-- ①：场上的这张卡不会被战斗·效果破坏。
-- ②：自己主要阶段才能发动。持有这张卡的攻击力以下的攻击力的对方场上的怪兽全部破坏，这张卡的攻击力上升破坏的怪兽数量×200。这个效果的发动后，直到回合结束时自己不用「英雄」怪兽不能攻击宣言。
function c86165817.initial_effect(c)
	-- 注册该卡在卡片效果中记载了「暗黑融合」的卡片密码
	aux.AddCodeList(c,94820406)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，融合素材为满足过滤条件的怪兽（5星以上怪兽）与「邪心英雄」怪兽各1只
	aux.AddFusionProcFun2(c,c86165817.matfilter,aux.FilterBoolFunction(Card.IsFusionSetCard,0x6008),true)
	-- 这张卡用「暗黑融合」的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤限制为只能通过「暗黑融合」或「暗黑神召」的效果进行特殊召唤
	e1:SetValue(aux.DarkFusionLimit)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。持有这张卡的攻击力以下的攻击力的对方场上的怪兽全部破坏，这张卡的攻击力上升破坏的怪兽数量×200。这个效果的发动后，直到回合结束时自己不用「英雄」怪兽不能攻击宣言。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,86165817)
	e2:SetTarget(c86165817.destg)
	e2:SetOperation(c86165817.desop)
	c:RegisterEffect(e2)
	-- ①：场上的这张卡不会被战斗·效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e4)
end
c86165817.material_setcode=0x8
c86165817.dark_calling=true
-- 融合素材过滤条件：5星以上的怪兽
function c86165817.matfilter(c)
	return c:IsLevelAbove(5) and c:IsFusionType(TYPE_MONSTER)
end
-- 过滤对方场上表侧表示且攻击力在指定数值（此卡攻击力）以下的怪兽
function c86165817.filter(c,atk)
	return c:IsFaceup() and c:IsAttackBelow(atk)
end
-- 破坏效果的发动准备（检查是否存在可破坏的怪兽，并设置破坏的操作信息）
function c86165817.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查对方场上是否存在至少1只攻击力在此卡以下的表侧表示怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c86165817.filter,tp,0,LOCATION_MZONE,1,nil,c:GetAttack()) end
	-- 获取对方场上所有攻击力在此卡以下的表侧表示怪兽
	local g=Duel.GetMatchingGroup(c86165817.filter,tp,0,LOCATION_MZONE,nil,c:GetAttack())
	-- 设置破坏操作的信息，包含预计破坏的怪兽组及其数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏效果的处理（破坏符合条件的怪兽，根据破坏数量上升攻击力，并限制本回合的攻击宣言）
function c86165817.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 在效果处理时，重新获取对方场上所有攻击力在此卡以下的表侧表示怪兽
		local g=Duel.GetMatchingGroup(c86165817.filter,tp,0,LOCATION_MZONE,nil,c:GetAttack())
		-- 破坏获取到的怪兽组，并返回实际被破坏的怪兽数量
		local ct=Duel.Destroy(g,REASON_EFFECT)
		if ct>0 then
			-- 这张卡的攻击力上升破坏的怪兽数量×200
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			e1:SetValue(ct*200)
			c:RegisterEffect(e1)
		end
	end
	-- 这个效果的发动后，直到回合结束时自己不用「英雄」怪兽不能攻击宣言。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c86165817.atktg)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将不能用「英雄」怪兽以外的怪兽进行攻击宣言的限制效果注册给发动效果的玩家
	Duel.RegisterEffect(e2,tp)
end
-- 攻击限制的过滤条件：非「英雄」怪兽（即不能进行攻击宣言的怪兽）
function c86165817.atktg(e,c)
	return not c:IsSetCard(0x8)
end

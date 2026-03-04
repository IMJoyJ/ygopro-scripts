--幻銃士
-- 效果：
-- ①：这张卡召唤·反转召唤成功时才能发动。把最多有自己场上的怪兽数量的「铳士衍生物」（恶魔族·暗·4星·攻/守500）在自己场上特殊召唤。
-- ②：自己准备阶段才能发动。给与对方为自己场上的「铳士」怪兽数量×300伤害。这个效果发动的回合，自己的「铳士」怪兽不能攻击宣言。
function c12958919.initial_effect(c)
	-- 效果原文：①：这张卡召唤·反转召唤成功时才能发动。把最多有自己场上的怪兽数量的「铳士衍生物」（恶魔族·暗·4星·攻/守500）在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12958919,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c12958919.sptg)
	e1:SetOperation(c12958919.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- 效果原文：②：自己准备阶段才能发动。给与对方为自己场上的「铳士」怪兽数量×300伤害。这个效果发动的回合，自己的「铳士」怪兽不能攻击宣言。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(12958919,1))  --"伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c12958919.damcon)
	e2:SetCost(c12958919.damcost)
	e2:SetTarget(c12958919.damtg)
	e2:SetOperation(c12958919.damop)
	c:RegisterEffect(e2)
	if not c12958919.global_check then
		c12958919.global_check=true
		-- 全局效果：当有「铳士」怪兽攻击时，记录该玩家已发动过效果
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_ATTACK_ANNOUNCE)
		ge1:SetOperation(c12958919.checkop)
		-- 注册全局效果，用于记录攻击宣言时的玩家状态
		Duel.RegisterEffect(ge1,0)
	end
end
-- 攻击宣言时的处理函数
function c12958919.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	if tc:IsSetCard(0x49) then
		-- 为攻击玩家注册标识效果，标记其已发动过效果
		Duel.RegisterFlagEffect(tc:GetControler(),12958919,RESET_PHASE+PHASE_END,0,1)
	end
end
-- 特殊召唤效果的处理函数
function c12958919.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足特殊召唤的条件：场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否可以特殊召唤衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,12958920,0x49,TYPES_TOKEN_MONSTER,500,500,4,RACE_FIEND,ATTRIBUTE_DARK) end
	-- 设置操作信息：将要特殊召唤衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息：将要特殊召唤衍生物
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 特殊召唤效果的执行函数
function c12958919.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取玩家场上怪兽数量
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
	if ft>ct then ft=ct end
	if ft<=0 then return end
	-- 若玩家受到效果影响，则限制只能召唤一张衍生物
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 判断是否可以特殊召唤衍生物
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,12958920,0x49,TYPES_TOKEN_MONSTER,500,500,4,RACE_FIEND,ATTRIBUTE_DARK) then return end
	local ctn=true
	while ft>0 and ctn do
		-- 创建一张衍生物
		local token=Duel.CreateToken(tp,12958920)
		-- 将衍生物特殊召唤到场上
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
		ft=ft-1
		-- 询问玩家是否继续特殊召唤衍生物
		if ft<=0 or not Duel.SelectYesNo(tp,aux.Stringid(12958919,2)) then ctn=false end  --"是否还要特殊召唤Token？"
	end
	-- 完成所有特殊召唤步骤
	Duel.SpecialSummonComplete()
end
-- 伤害效果的触发条件函数
function c12958919.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为当前回合玩家
	return tp==Duel.GetTurnPlayer()
end
-- 伤害效果的费用函数
function c12958919.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断玩家是否已发动过此效果
	if chk==0 then return Duel.GetFlagEffect(tp,12958919)==0 end
	-- 效果原文：②：自己准备阶段才能发动。给与对方为自己场上的「铳士」怪兽数量×300伤害。这个效果发动的回合，自己的「铳士」怪兽不能攻击宣言。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_OATH)
	-- 设置效果目标为所有「铳士」怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x49))
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册效果，使「铳士」怪兽不能攻击宣言
	Duel.RegisterEffect(e1,tp)
end
-- 伤害计算的过滤函数
function c12958919.damfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x49)
end
-- 伤害效果的目标函数
function c12958919.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 计算场上「铳士」怪兽数量
	local ct=Duel.GetMatchingGroupCount(c12958919.damfilter,tp,LOCATION_MZONE,0,nil)
	-- 设置伤害对象为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置操作信息：将要造成伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*300)
end
-- 伤害效果的执行函数
function c12958919.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中目标玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 计算场上「铳士」怪兽数量
	local ct=Duel.GetMatchingGroupCount(c12958919.damfilter,tp,LOCATION_MZONE,0,nil)
	-- 对目标玩家造成伤害
	Duel.Damage(p,ct*300,REASON_EFFECT)
end

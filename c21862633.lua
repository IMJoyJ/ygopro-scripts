--切り裂かれし闇
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己对衍生物以外的通常怪兽的召唤·特殊召唤成功的场合才能发动。自己从卡组抽1张。
-- ②：以下其中任意种的自己怪兽在和对方怪兽进行战斗的攻击宣言时才能发动。那只自己怪兽的攻击力直到回合结束时上升那只对方怪兽的攻击力数值。
-- ●5星以上的通常怪兽
-- ●使用通常怪兽作仪式召唤的怪兽
-- ●通常怪兽为素材作融合·同调·超量召唤的怪兽
function c21862633.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己对衍生物以外的通常怪兽的召唤·特殊召唤成功的场合才能发动。自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21862633,0))  --"抽1张卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,21862633)
	e2:SetCondition(c21862633.drcon)
	e2:SetTarget(c21862633.drtg)
	e2:SetOperation(c21862633.drop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ②：以下其中任意种的自己怪兽在和对方怪兽进行战斗的攻击宣言时才能发动。那只自己怪兽的攻击力直到回合结束时上升那只对方怪兽的攻击力数值。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(21862633,1))
	e4:SetCategory(CATEGORY_ATKCHANGE)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCountLimit(1,21862634)
	e4:SetCondition(c21862633.atkcon)
	e4:SetOperation(c21862633.atkop)
	c:RegisterEffect(e4)
	if not c21862633.global_check then
		c21862633.global_check=true
		-- ●5星以上的通常怪兽
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE)
		ge1:SetCode(EFFECT_MATERIAL_CHECK)
		ge1:SetValue(c21862633.valcheck)
		-- 注册一个用于检测召唤或特殊召唤是否包含通常怪兽的全局效果
		Duel.RegisterEffect(ge1,0)
	end
end
-- 当有怪兽被召唤或特殊召唤时，检查其是否包含通常怪兽，若有则标记该怪兽
function c21862633.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsType,1,nil,TYPE_NORMAL) then
		c:RegisterFlagEffect(21862633,RESET_EVENT+0x4fe0000,0,1)
	end
end
-- 用于筛选满足条件的召唤或特殊召唤的怪兽：必须是表侧表示、通常怪兽、是自己召唤的、不是衍生物
function c21862633.cfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_NORMAL) and c:IsSummonPlayer(tp) and not c:IsType(TYPE_TOKEN)
end
-- 判断是否有满足条件的怪兽被召唤或特殊召唤成功
function c21862633.drcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c21862633.cfilter,1,nil,tp)
end
-- 设置效果的目标玩家和参数，准备执行抽卡效果
function c21862633.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置效果的目标玩家为当前处理效果的玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果的目标参数为1（抽卡数量）
	Duel.SetTargetParam(1)
	-- 设置效果操作信息为抽卡效果
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 执行抽卡操作
function c21862633.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 执行抽卡动作，抽卡原因设为效果
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 判断是否满足攻击宣言时的条件：自己怪兽为通常怪兽且等级5以上，或使用通常怪兽作为素材进行仪式/融合/同调/超量召唤
function c21862633.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前正在战斗中的自己怪兽和对方怪兽
	local a,at=Duel.GetBattleMonster(tp)
	return a and at and at:GetAttack()>0 and (a:IsType(TYPE_NORMAL) and a:IsLevelAbove(5)
		or a:GetFlagEffect(21862633)>0 and (a:IsSummonType(SUMMON_TYPE_RITUAL)
			or a:IsSummonType(SUMMON_TYPE_FUSION)
			or a:IsSummonType(SUMMON_TYPE_SYNCHRO)
			or a:IsSummonType(SUMMON_TYPE_XYZ)))
end
-- 执行攻击力提升效果，将自己怪兽的攻击力提升为对方怪兽的攻击力
function c21862633.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前正在战斗中的自己怪兽和对方怪兽
	local a,at=Duel.GetBattleMonster(tp)
	if not a or not at or not a:IsRelateToBattle() or a:IsFacedown() or not at:IsRelateToBattle() or at:IsFacedown() then return end
	-- 创建一个攻击力提升效果，提升值为对方怪兽的攻击力，效果在回合结束时重置
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetValue(at:GetAttack())
	a:RegisterEffect(e1)
end

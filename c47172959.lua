--ユベル－Das Ewig Liebe Wächter
-- 效果：
-- 「于贝尔」怪兽＋场上的效果怪兽1只以上
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡融合召唤的场合才能发动。给与对方作为这张卡的融合素材的怪兽数量×500伤害。
-- ②：这张卡不会被战斗·效果破坏，这张卡的战斗发生的对自己的战斗伤害变成0。
-- ③：这张卡和对方怪兽进行战斗的伤害步骤结束时发动。给与对方那只对方怪兽的攻击力数值的伤害，那只怪兽除外。
local s,id,o=GetID()
-- 初始化效果函数，启用复活限制并设置融合召唤条件
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用于贝尔卡组怪兽作为融合素材，且场上有效果怪兽
	aux.AddFusionProcFunFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x1a5),s.matfilter,1,63,true)
	-- 效果①：这张卡融合召唤成功时发动，给与对方伤害
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DELAY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.dmgcon)
	e1:SetTarget(s.damtg)
	e1:SetOperation(s.dmgop)
	c:RegisterEffect(e1)
	-- 效果③：伤害步骤结束时发动，对对方怪兽造成其攻击力数值的伤害并除外
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"给与伤害并除外"
	e2:SetCategory(CATEGORY_DAMAGE+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_DAMAGE_STEP_END)
	-- 判断是否为战斗相关效果触发条件
	e2:SetCondition(aux.dsercon)
	e2:SetTarget(s.damrtg)
	e2:SetOperation(s.damrop)
	c:RegisterEffect(e2)
	-- 效果②：这张卡不会被战斗·效果破坏，战斗发生的对自己的战斗伤害变成0
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
	local e5=e3:Clone()
	e5:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	c:RegisterEffect(e5)
end
-- 融合素材过滤函数，筛选场上的效果怪兽
function s.matfilter(c)
	return c:IsLocation(LOCATION_MZONE) and c:IsType(TYPE_EFFECT)
end
-- 效果①发动条件：确认此卡为融合召唤 summoned
function s.dmgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 效果①的发动时点处理，计算伤害值并设置目标玩家和参数
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	local damage=c:GetMaterialCount()*500
	-- 设置连锁操作的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁操作的目标参数为伤害值
	Duel.SetTargetParam(damage)
	-- 设置连锁操作信息为造成伤害效果
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,damage)
	e:SetLabel(damage)
end
-- 效果①的处理函数，对对方造成指定伤害
function s.dmgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成指定伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 效果③的发动时点处理，判断是否满足发动条件并设置操作信息
function s.damrtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if chk==0 then return c:IsStatus(STATUS_OPPO_BATTLE) and bc~=nil end
	if bc:GetAttack()>0 then
		-- 设置连锁操作信息为造成伤害效果
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,bc:GetAttack())
	end
end
-- 效果③的处理函数，对对方怪兽造成其攻击力数值的伤害并除外
function s.damrop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	local atk=bc:GetAttack()
	local def=bc:GetDefense()
	if atk<0 then atk=0 end
	if bc:IsControler(tp) or bc:IsFacedown() then return end
	-- 若造成伤害不为0，则将对方怪兽除外
	if Duel.Damage(1-tp,atk,REASON_EFFECT,true)~=0 then
		-- 将目标怪兽除外
		Duel.Remove(bc,POS_FACEUP,REASON_EFFECT)
	end
	-- 完成伤害/恢复LP过程的分解时点
	Duel.RDComplete()
end

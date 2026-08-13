--ユベル－Das Ewig Liebe Wächter
-- 效果：
-- 「于贝尔」怪兽＋场上的效果怪兽1只以上
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡融合召唤的场合才能发动。给与对方作为这张卡的融合素材的怪兽数量×500伤害。
-- ②：这张卡不会被战斗·效果破坏，这张卡的战斗发生的对自己的战斗伤害变成0。
-- ③：这张卡和对方怪兽进行战斗的伤害步骤结束时发动。给与对方那只对方怪兽的攻击力数值的伤害，那只怪兽除外。
local s,id,o=GetID()
-- 初始化于贝尔-永远之爱的守护者的效果：设置融合召唤限制和融合素材条件，并注册①的融合召唤伤害效果、③的战斗步骤结束伤害除外效果以及②的战斗/效果破坏抗性与战斗伤害归零效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 为该卡添加融合召唤手续：以1只「于贝尔」怪兽（字段0x1a5）和场上1只以上效果怪兽作为融合素材，效果怪兽数量为1~63，允许使用融合素材代用品。
	aux.AddFusionProcFunFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x1a5),s.matfilter,1,63,true)
	-- ①：这张卡融合召唤的场合才能发动。给与对方作为这张卡的融合素材的怪兽数量×500伤害。
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
	-- ③：这张卡和对方怪兽进行战斗的伤害步骤结束时发动。给与对方那只对方怪兽的攻击力数值的伤害，那只怪兽除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"给与伤害并除外"
	e2:SetCategory(CATEGORY_DAMAGE+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_DAMAGE_STEP_END)
	-- 设置③效果的发动条件：在伤害步骤结束时，该卡仍与战斗相关（未离场或具有战斗破坏状态），即满足该场战斗涉及此卡。
	e2:SetCondition(aux.dsercon)
	e2:SetTarget(s.damrtg)
	e2:SetOperation(s.damrop)
	c:RegisterEffect(e2)
	-- 这张卡不会被战斗破坏。
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
-- 融合素材过滤函数：素材必须是位于怪兽区域的效果怪兽。
function s.matfilter(c)
	return c:IsLocation(LOCATION_MZONE) and c:IsType(TYPE_EFFECT)
end
-- ①效果的发动条件：本卡是以融合召唤方式特殊召唤成功的场合。
function s.dmgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- ①效果的发动时处理：无条件成立；计算本卡融合素材数量×500作为伤害值，将对象玩家设为对方、对象参数设为伤害值，设置操作信息并保存伤害值到效果标签。
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	local damage=c:GetMaterialCount()*500
	-- 将当前连锁的对象玩家设置为对方玩家。
	Duel.SetTargetPlayer(1-tp)
	-- 将当前连锁的对象参数设置为伤害值，供效果处理时读取。
	Duel.SetTargetParam(damage)
	-- 设置操作信息：分类为伤害效果，目标玩家为对方，预期伤害值为damage，用于连锁和时点检测。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,damage)
	e:SetLabel(damage)
end
-- ①效果处理：从连锁信息中取得对象玩家和伤害参数，并实际给对方造成伤害。
function s.dmgop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取得预先设置的对象玩家与伤害参数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成d点效果伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
-- ③效果的发动时处理：确认本卡与对方怪兽进行过战斗且战斗对象存在；若该怪兽攻击力大于0，则设置给对方造成其攻击力数值伤害的操作信息。
function s.damrtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if chk==0 then return c:IsStatus(STATUS_OPPO_BATTLE) and bc~=nil end
	if bc:GetAttack()>0 then
		-- 设置操作信息：给对方玩家造成战斗对象怪兽攻击力数值的伤害。
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,bc:GetAttack())
	end
end
-- ③效果处理：取得战斗对象怪兽的攻击力（负值按0处理）；若该怪兽已变成我方控制或处于里侧表示则效果不处理；否则给对方造成攻击力数值伤害，若伤害实际造成则将该怪兽表侧除外；最后完成伤害步骤处理。
function s.damrop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	local atk=bc:GetAttack()
	local def=bc:GetDefense()
	if atk<0 then atk=0 end
	if bc:IsControler(tp) or bc:IsFacedown() then return end
	-- 以伤害步骤分解方式给对方造成atk点伤害，并判断是否实际造成伤害，作为是否执行后续除外的条件。
	if Duel.Damage(1-tp,atk,REASON_EFFECT,true)~=0 then
		-- 将战斗对象怪兽以表侧表示除外。
		Duel.Remove(bc,POS_FACEUP,REASON_EFFECT)
	end
	-- 完成伤害步骤的伤害处理，触发相关时点。
	Duel.RDComplete()
end

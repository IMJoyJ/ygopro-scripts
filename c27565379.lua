--B・F－霊弓のアズサ
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡以外的「蜂军」怪兽的效果让对方受到伤害时才能发动（伤害步骤也能发动）。给与对方那只怪兽的原本攻击力数值的伤害。
-- ②：这张卡在墓地存在的状态，自己的「蜂军」怪兽的战斗让怪兽被破坏时才能发动。这张卡守备表示特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c27565379.initial_effect(c)
	-- 为这张卡添加同调召唤手续：调整（无限制）＋调整以外的怪兽1只以上。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡以外的「蜂军」怪兽的效果让对方受到伤害时才能发动（伤害步骤也能发动）。给与对方那只怪兽的原本攻击力数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27565379,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCode(EVENT_DAMAGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,27565379)
	e1:SetCondition(c27565379.damcon)
	e1:SetTarget(c27565379.damtg)
	e1:SetOperation(c27565379.damop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，自己的「蜂军」怪兽的战斗让怪兽被破坏时才能发动。这张卡守备表示特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(27565379,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c27565379.spcon)
	e2:SetTarget(c27565379.sptg)
	e2:SetOperation(c27565379.spop)
	c:RegisterEffect(e2)
end
-- ①的发动条件判定：对方受到伤害，且该伤害来自这张卡以外的「蜂军」怪兽的效果，并且不是战斗伤害。
function c27565379.damcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and bit.band(r,REASON_BATTLE)==0 and re and re:GetHandler()~=e:GetHandler() and re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsSetCard(0x12f)
end
-- 发动时处理：无对象选择，将对方设为对象玩家，并以伤害源怪兽的原本攻击力作为伤害数值写入操作信息。
function c27565379.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local tc=re:GetHandler()
	local atk=tc:GetBaseAttack()
	-- 将当前连锁的对象玩家设置为对方（1-tp），表示伤害对象为对方。
	Duel.SetTargetPlayer(1-tp)
	-- 登记操作信息：本次效果类别为造成伤害，目标玩家为对方，预计伤害值为此怪兽的原本攻击力atk。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,atk)
end
-- 效果处理：取出对象玩家，重新获取伤害源怪兽的原本攻击力，给对方造成该数值的效果伤害。
function c27565379.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取得对象玩家（即之前设置的对方玩家）。
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local tc=re:GetHandler()
	local atk=tc:GetBaseAttack()
	-- 以效果伤害的形式，给予玩家p等于atk的伤害（atk为那只怪兽的原本攻击力）。
	Duel.Damage(p,atk,REASON_EFFECT)
end
-- 过滤被战斗破坏的怪兽：满足以下任一情况即通过——(1)该怪兽是「蜂军」怪兽且战斗前由我方控制；(2)该怪兽的战斗对象是「蜂军」怪兽，且该战斗对象当前或战斗前由我方控制（在场上时看当前控制者，不在场上时看之前控制者）。
function c27565379.cfilter(c,tp)
	if c:IsSetCard(0x12f) and c:IsPreviousControler(tp) then return true end
	local rc=c:GetBattleTarget()
	return rc:IsSetCard(0x12f)
		and (not rc:IsLocation(LOCATION_MZONE) and rc:IsPreviousControler(tp)
			or rc:IsLocation(LOCATION_MZONE) and rc:IsControler(tp))
end
-- ②的发动条件：被战斗破坏的怪兽组中不包含这张卡自身，且其中至少有一只满足上述与己方「蜂军」怪兽相关的战斗破坏条件。
function c27565379.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c27565379.cfilter,1,nil,tp)
end
-- 发动时检查：自己主要怪兽区有空位，且这张卡可以以表侧守备表示特殊召唤。
function c27565379.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若为发动时点检查（chk==0），先确认自己主要怪兽区存在至少1个可用位置。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置操作信息：本效果属于特殊召唤效果，将特殊召唤的是这张卡自身，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：若这张卡仍与效果有关联，则将其以表侧守备表示特殊召唤；成功后给它附加一个离场时不去墓地而改为除外且不能被无效的效果。
function c27565379.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断这张卡与发动效果仍有联系，并尝试将其以表侧守备表示特殊召唤；召唤成功（返回值不为0）才继续附加离场除外效果。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end

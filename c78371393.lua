--ユベル
-- 效果：
-- ①：这张卡不会被战斗破坏，这张卡的战斗发生的对自己的战斗伤害变成0。
-- ②：攻击表示的这张卡被选择作为攻击对象的场合，那次伤害计算前发动。给与对方攻击怪兽的攻击力数值的伤害。
-- ③：自己结束阶段发动。自己场上1只其他怪兽解放或这张卡破坏。
-- ④：这个③的效果以外让这张卡被破坏时才能发动。从自己的手卡·卡组·墓地把1只「于贝尔-被憎恶的骑士」特殊召唤。
function c78371393.initial_effect(c)
	-- ①：这张卡的战斗发生的对自己的战斗伤害变成0。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ①：这张卡不会被战斗破坏
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ②：攻击表示的这张卡被选择作为攻击对象的场合，那次伤害计算前发动。给与对方攻击怪兽的攻击力数值的伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(78371393,0))  --"伤害"
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_BATTLE_CONFIRM)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCondition(c78371393.damcon)
	e3:SetTarget(c78371393.damtg)
	e3:SetOperation(c78371393.damop)
	c:RegisterEffect(e3)
	-- ③：自己结束阶段发动。自己场上1只其他怪兽解放或这张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_RELEASE+CATEGORY_DESTROY)
	e4:SetDescription(aux.Stringid(78371393,1))  --"破坏"
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetCondition(c78371393.descon)
	e4:SetTarget(c78371393.destg)
	e4:SetOperation(c78371393.desop)
	c:RegisterEffect(e4)
	-- ④：这个③的效果以外让这张卡被破坏时才能发动。从自己的手卡·卡组·墓地把1只「于贝尔-被憎恶的骑士」特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(78371393,3))  --"特殊召唤"
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e5:SetCode(EVENT_DESTROYED)
	e5:SetCondition(c78371393.spcon)
	e5:SetTarget(c78371393.sptg)
	e5:SetOperation(c78371393.spop)
	e5:SetLabelObject(e4)
	c:RegisterEffect(e5)
end
-- 伤害计算前给与对方伤害效果的发动条件函数
function c78371393.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自身是否为被攻击对象
	return e:GetHandler()==Duel.GetAttackTarget()
end
-- 伤害计算前给与对方伤害效果的发动准备函数
function c78371393.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAttackPos() end
	-- 设置效果处理的靶向玩家为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 获取攻击怪兽的当前攻击力
	local atk=Duel.GetAttacker():GetAttack()
	-- 设置效果处理的靶向参数为攻击怪兽的攻击力数值
	Duel.SetTargetParam(atk)
	-- 向系统宣告此效果包含给与对方玩家等同于攻击怪兽攻击力数值伤害的操作
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,atk)
end
-- 伤害计算前给与对方伤害效果的执行函数
function c78371393.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的靶向玩家和伤害数值参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果伤害的形式给与目标玩家对应数值的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 结束阶段解放或破坏效果的发动条件函数
function c78371393.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 结束阶段解放或破坏效果的发动准备函数
function c78371393.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 检查自己场上和手卡是否存在至少1只可解放的怪兽
	if not Duel.CheckReleaseGroupEx(tp,nil,1,REASON_EFFECT,false,nil) then
		-- 向系统宣告此效果在无法解放怪兽时将破坏自身
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	end
end
-- 结束阶段解放或破坏效果的执行函数
function c78371393.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 若存在除自身以外的可解放怪兽，询问玩家是否选择解放1只怪兽
	if Duel.CheckReleaseGroupEx(tp,nil,1,REASON_EFFECT,false,c) and Duel.SelectYesNo(tp,aux.Stringid(78371393,2)) then  --"是否要选择1只怪兽作为祭品？"
		-- 让玩家从除自身以外的怪兽中选择1只解放
		local g=Duel.SelectReleaseGroupEx(tp,nil,1,1,REASON_EFFECT,false,c)
		-- 以效果解放所选的怪兽
		Duel.Release(g,REASON_EFFECT)
	else
		-- 以效果破坏自身
		Duel.Destroy(c,REASON_EFFECT)
	end
end
-- 被破坏时特殊召唤效果的发动条件函数，需判定是否为自身结束阶段效果以外的破坏
function c78371393.spcon(e,tp,eg,ep,ev,re,r,rp)
	return re~=e:GetLabelObject()
end
-- 过滤手卡、卡组、墓地中「于贝尔-被憎恶的骑士」且可特殊召唤的卡片
function c78371393.filter(c,e,tp)
	return c:IsCode(4779091) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
-- 被破坏时特殊召唤效果的发动准备函数
function c78371393.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并检查自己的手卡、卡组、墓地中是否存在至少1只满足条件的「于贝尔-被憎恶的骑士」
		and Duel.IsExistingMatchingCard(c78371393.filter,tp,0x13,0,1,nil,e,tp) end
	-- 向系统宣告此效果包含从手卡、卡组、墓地特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0x13)
end
-- 被破坏时特殊召唤效果的执行函数
function c78371393.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 在客户端向玩家显示“请选择要特殊召唤的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡、卡组、墓地（受墓地限制卡影响）中选择1只「于贝尔-被憎恶的骑士」
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c78371393.filter),tp,0x13,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽无视召唤条件和苏生限制以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,true,true,POS_FACEUP)
		g:GetFirst():CompleteProcedure()
	end
end

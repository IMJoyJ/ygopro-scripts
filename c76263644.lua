--Dragoon D-END
-- 效果：
-- 「命运英雄 血魔-D」＋「命运英雄 教义人」
-- 这张卡的融合召唤不用上记的卡不能进行。
-- ①：1回合1次，以对方场上1只怪兽为对象才能发动。那只对方怪兽破坏，把表侧表示怪兽破坏的场合，给与对方那个攻击力数值的伤害。这个效果发动的回合，自己不能进行战斗阶段。
-- ②：这张卡在墓地存在的场合，自己准备阶段把自己墓地1张「命运英雄」卡除外才能发动。这张卡从墓地特殊召唤。
function c76263644.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置融合素材为「命运英雄 血魔-D」和「命运英雄 教义人」，且不能使用融合替代素材
	aux.AddFusionProcCode2(c,83965310,17132130,false,false)
	-- ①：1回合1次，以对方场上1只怪兽为对象才能发动。那只对方怪兽破坏，把表侧表示怪兽破坏的场合，给与对方那个攻击力数值的伤害。这个效果发动的回合，自己不能进行战斗阶段。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_DAMAGE+CATEGORY_DESTROY)
	e2:SetDescription(aux.Stringid(76263644,0))  --"破坏"
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c76263644.descost)
	e2:SetTarget(c76263644.destg)
	e2:SetOperation(c76263644.desop)
	c:RegisterEffect(e2)
	-- ②：这张卡在墓地存在的场合，自己准备阶段把自己墓地1张「命运英雄」卡除外才能发动。这张卡从墓地特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(76263644,1))  --"特殊召唤"
	e3:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1)
	e3:SetCondition(c76263644.spcon)
	e3:SetCost(c76263644.spcost)
	e3:SetTarget(c76263644.sptg)
	e3:SetOperation(c76263644.spop)
	c:RegisterEffect(e3)
end
c76263644.material_setcode=0xc008
-- 定义破坏效果的Cost函数，检查并注册本回合不能进行战斗阶段的限制
function c76263644.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查当前回合自己是否还没有进入过战斗阶段
	if chk==0 then return Duel.GetActivityCount(tp,ACTIVITY_BATTLE_PHASE)==0 end
	-- 「命运英雄 血魔-D」＋「命运英雄 教义人」 这张卡的融合召唤不用上记的卡不能进行。 ①：1回合1次，以对方场上1只怪兽为对象才能发动。那只对方怪兽破坏，把表侧表示怪兽破坏的场合，给与对方那个攻击力数值的伤害。这个效果发动的回合，自己不能进行战斗阶段。 ②：这张卡在墓地存在的场合，自己准备阶段把自己墓地1张「命运英雄」卡除外才能发动。这张卡从墓地特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 给发动效果的玩家注册本回合不能进行战斗阶段的全局效果
	Duel.RegisterEffect(e1,tp)
end
-- 定义破坏效果的Target函数，用于选择对方场上的一只怪兽作为对象，并设置破坏与伤害的操作信息
function c76263644.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在可以作为对象的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的一只怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	local d=g:GetFirst()
	local atk=0
	if d:IsFaceup() then atk=d:GetAttack() end
	-- 设置效果处理信息为破坏选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置效果处理信息为给与对方相当于该怪兽攻击力数值的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,atk)
end
-- 定义破坏效果的Operation函数，执行破坏对象怪兽并给与对方伤害的处理
function c76263644.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取选中的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local atk=0
		if tc:IsFaceup() then atk=tc:GetAttack() end
		-- 尝试破坏该怪兽，若破坏失败则终止效果处理
		if Duel.Destroy(tc,REASON_EFFECT)==0 then return end
		-- 给与对方相当于被破坏怪兽攻击力数值的伤害
		Duel.Damage(1-tp,atk,REASON_EFFECT)
	end
end
-- 定义特殊召唤效果的Condition函数，检查当前是否为自己的回合
function c76263644.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 定义特殊召唤效果的Cost函数，用于从自己墓地将一张「命运英雄」卡除外
function c76263644.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在可以作为Cost除外的「命运英雄」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c76263644.spfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 过滤并选择自己墓地的一张「命运英雄」卡
	local g=Duel.SelectMatchingCard(tp,c76263644.spfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的卡表侧表示除外作为发动的代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 定义过滤函数，用于筛选自己墓地中可以作为Cost除外的「命运英雄」卡
function c76263644.spfilter(c)
	return c:IsSetCard(0xc008) and c:IsAbleToRemoveAsCost()
end
-- 定义特殊召唤效果的Target函数，检查怪兽区域空位以及自身是否能特殊召唤，并设置特殊召唤的操作信息
function c76263644.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理信息为将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 定义特殊召唤效果的Operation函数，执行将自身从墓地特殊召唤的处理
function c76263644.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将自身以表侧表示特殊召唤到自己的怪兽区域
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end

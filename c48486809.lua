--ハネクリボー LV6
-- 效果：
-- 这个卡名在规则上也当作「元素英雄」卡、「至爱」卡使用。这张卡不能通常召唤。「羽翼栗子球 LV6」1回合1次在把自己的手卡·场上（表侧表示）·墓地1只「元素英雄」融合怪兽或「羽翼栗子球」除外的场合才能从手卡·墓地特殊召唤。
-- ①：对方怪兽的攻击宣言时或者对方把场上的怪兽的效果发动时，把这张卡解放才能发动。那1只怪兽破坏，给与对方那个原本攻击力数值的伤害。
local s,id,o=GetID()
-- 初始化效果函数，设置该卡不能通常召唤，并注册特殊召唤条件和两个诱发效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 该卡不能通常召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 1回合1次在把自己的手卡·场上（表侧表示）·墓地1只「元素英雄」融合怪兽或「羽翼栗子球」除外的场合才能从手卡·墓地特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e2:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e2:SetCondition(s.spcon)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- 对方怪兽的攻击宣言时或者对方把场上的怪兽的效果发动时，把这张卡解放才能发动。那1只怪兽破坏，给与对方那个原本攻击力数值的伤害
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.descon)
	e3:SetCost(s.descost)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_CHAINING)
	e4:SetCondition(s.descon2)
	e4:SetTarget(s.destg2)
	e4:SetOperation(s.desop2)
	c:RegisterEffect(e4)
end
s.lvup={id}
-- 过滤满足条件的卡片组，包括「元素英雄」融合怪兽或「羽翼栗子球」且表侧表示、可除外、场上怪兽区有空位
function s.spfilter(c,tp)
	return (c:IsCode(57116033) or c:IsSetCard(0x3008) and c:IsType(TYPE_FUSION))
		-- 卡片必须表侧表示、可作为除外费用、场上怪兽区有空位
		and c:IsFaceupEx() and c:IsAbleToRemoveAsCost() and Duel.GetMZoneCount(tp,c)>0
end
-- 判断是否有满足特殊召唤条件的卡片
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查是否存在满足spfilter条件的卡片
	return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_ONFIELD+LOCATION_HAND,0,1,c,tp)
end
-- 选择并除外满足条件的卡片作为特殊召唤的代价
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的卡片组
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE+LOCATION_ONFIELD+LOCATION_HAND,0,1,1,c)
	-- 将选中的卡片除外作为特殊召唤的代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 攻击宣言时触发的效果条件，仅在对方回合生效
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 仅在对方回合触发
	return tp~=Duel.GetTurnPlayer()
end
-- 支付效果代价，解放自身
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为效果代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 设置破坏和伤害效果的目标信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取当前攻击怪兽
	local tc=Duel.GetAttacker()
	if chk==0 then return tc:IsDestructable() end
	-- 设置破坏目标
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
	if tc:GetTextAttack()>0 then
		-- 设置给予对方伤害的数值
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,tc:GetTextAttack())
	end
end
-- 执行破坏和伤害效果
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前攻击怪兽
	local tc=Duel.GetAttacker()
	-- 判断攻击怪兽是否参与战斗、被破坏成功且攻击力大于0
	if tc:IsRelateToBattle() and Duel.Destroy(tc,REASON_EFFECT)>0 and tc:GetTextAttack()>0 then
		-- 给与对方相当于攻击怪兽攻击力的伤害
		Duel.Damage(1-tp,tc:GetTextAttack(),REASON_EFFECT)
	end
end
-- 对方发动场上怪兽效果时触发的效果条件，仅在对方回合且效果有效时生效
function s.descon2(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp and re:GetHandler():IsOnField() and re:GetHandler():IsRelateToEffect(re) and re:IsActiveType(TYPE_MONSTER)
end
-- 设置破坏和伤害效果的目标信息（针对对方发动的效果）
function s.destg2(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=re:GetHandler()
	if chk==0 then return tc:IsDestructable() end
	-- 设置破坏目标（针对对方发动的效果）
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
	-- 设置给予对方伤害的数值（针对对方发动的效果）
	if math.max(0,tc:GetTextAttack())>0 then Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0) end
end
-- 执行破坏和伤害效果（针对对方发动的效果）
function s.desop2(e,tp,eg,ep,ev,re,r,rp)
	local tc=re:GetHandler()
	if tc:IsRelateToEffect(re) and tc:IsLocation(LOCATION_MZONE)
		-- 判断被破坏成功且攻击力大于0
		and Duel.Destroy(tc,REASON_EFFECT)>0 and tc:GetTextAttack()>0 then
		-- 给与对方相当于攻击怪兽攻击力的伤害
		Duel.Damage(1-tp,tc:GetTextAttack(),REASON_EFFECT)
	end
end

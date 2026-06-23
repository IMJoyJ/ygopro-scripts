--EMピンチヘルパー
-- 效果：
-- ①：1回合1次，对方怪兽的直接攻击宣言时才能把这个效果发动。那次攻击无效，从卡组把1只「娱乐伙伴」怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
-- ②：自己怪兽和对方怪兽进行战斗的攻击宣言时，把魔法与陷阱区域的表侧表示的这张卡送去墓地才能发动。那次战斗发生的对自己的战斗伤害变成0。
function c36415522.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，对方怪兽的直接攻击宣言时才能把这个效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c36415522.spcon)
	e2:SetTarget(c36415522.sptg)
	e2:SetOperation(c36415522.spop)
	c:RegisterEffect(e2)
	-- ②：自己怪兽和对方怪兽进行战斗的攻击宣言时，把魔法与陷阱区域的表侧表示的这张卡送去墓地才能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCost(c36415522.atkcost)
	e3:SetTarget(c36415522.atktg)
	e3:SetOperation(c36415522.atkop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断卡组中是否存在满足条件的「娱乐伙伴」怪兽
function c36415522.filter(c,e,tp)
	return c:IsSetCard(0x9f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果条件函数，判断是否为对方怪兽的直接攻击
function c36415522.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 对方怪兽的直接攻击宣言时
	return Duel.GetAttacker():IsControler(1-tp) and Duel.GetAttackTarget()==nil
end
-- 设置特殊召唤的卡的筛选条件
function c36415522.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断卡组中是否存在满足条件的「娱乐伙伴」怪兽
		and Duel.IsExistingMatchingCard(c36415522.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将要特殊召唤一张怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，执行特殊召唤和无效化效果
function c36415522.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 无效此次攻击
	if not Duel.NegateAttack() then return end
	-- 判断场上是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择一张满足条件的「娱乐伙伴」怪兽
	local g=Duel.SelectMatchingCard(tp,c36415522.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 特殊召唤选中的怪兽
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 使特殊召唤的怪兽效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 使特殊召唤的怪兽效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
-- 攻击时的费用支付函数，将自身送去墓地
function c36415522.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsStatus(STATUS_EFFECT_ENABLED) and c:IsAbleToGraveAsCost() end
	-- 将自身送去墓地作为费用
	Duel.SendtoGrave(c,REASON_COST)
end
-- 攻击时的目标选择函数
function c36415522.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取此次攻击的攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取此次攻击的防守怪兽
	local d=Duel.GetAttackTarget()
	if chk==0 then return d and a:GetControler()~=d:GetControler() end
	if a:IsControler(1-tp) then a=d end
	e:SetLabelObject(a)
end
-- 效果处理函数，使战斗伤害变为0
function c36415522.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:IsRelateToBattle() then
		-- 注册战斗伤害无效效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetValue(1)
		e1:SetCondition(c36415522.damcon)
		e1:SetReset(RESET_PHASE+PHASE_DAMAGE_CAL)
		e1:SetLabelObject(tc)
		-- 将效果注册到玩家
		Duel.RegisterEffect(e1,tp)
	end
end
-- 伤害无效效果的条件函数
function c36415522.damcon(e)
	local tc=e:GetLabelObject()
	-- 判断目标怪兽是否参与了此次战斗
	return tc==Duel.GetAttacker() or tc==Duel.GetAttackTarget()
end

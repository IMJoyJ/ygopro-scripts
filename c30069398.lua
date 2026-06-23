--アイヴィ・ウォール
-- 效果：
-- 反转：在对方场上把1只「常春藤衍生物」（地·1星·植物族·攻/守0）守备表示特殊召唤。「常春藤衍生物」被破坏时，这衍生物的控制者受到300分伤害。
function c30069398.initial_effect(c)
	-- 反转效果，特殊召唤衍生物并设置操作信息
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(30069398,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_FLIP+EFFECT_TYPE_SINGLE)
	e1:SetTarget(c30069398.target)
	e1:SetOperation(c30069398.operation)
	c:RegisterEffect(e1)
end
-- 设置连锁操作信息，表示将特殊召唤1只衍生物
function c30069398.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息，表示将特殊召唤1只衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置连锁操作信息，表示将特殊召唤1只衍生物
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 反转效果的处理函数，用于特殊召唤衍生物并注册破坏时伤害效果
function c30069398.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方场上是否有足够的怪兽区域
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE)<=0 then return end
	-- 检查玩家是否可以特殊召唤指定的衍生物
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,30069399,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_PLANT,ATTRIBUTE_EARTH,POS_FACEUP_DEFENSE,1-tp) then return end
	-- 创建指定编号的衍生物卡片
	local token=Duel.CreateToken(tp,30069399)
	-- 尝试特殊召唤该衍生物到对方场上
	if Duel.SpecialSummonStep(token,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE) then
		-- 为衍生物注册一个离开场上的效果，用于触发伤害
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_LEAVE_FIELD)
		e1:SetOperation(c30069398.damop)
		token:RegisterEffect(e1,true)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
-- 衍生物被破坏时触发的伤害处理函数
function c30069398.damop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsReason(REASON_DESTROY) then
		-- 对衍生物的控制者造成300点伤害
		Duel.Damage(c:GetPreviousControler(),300,REASON_EFFECT)
	end
	e:Reset()
end

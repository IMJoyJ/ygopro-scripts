--スネークポット
-- 效果：
-- 反转：在自己场上把1只「毒蛇衍生物」（爬虫类族·地·3星·攻/守1200）特殊召唤。「毒蛇衍生物」被战斗破坏的场合，给与对方基本分500分伤害。
function c86801871.initial_effect(c)
	-- 反转：在自己场上把1只「毒蛇衍生物」（爬虫类族·地·3星·攻/守1200）特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(86801871,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c86801871.sptg)
	e1:SetOperation(c86801871.spop)
	c:RegisterEffect(e1)
end
-- 效果发动的目标检查与操作信息设置：确认是否可以特殊召唤衍生物，并向系统宣告特殊召唤和衍生物产生的操作信息。
function c86801871.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，向系统宣告此效果包含产生1只衍生物的操作。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置操作信息，向系统宣告此效果包含特殊召唤1只怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 效果处理：在自己场上特殊召唤1只「毒蛇衍生物」，并为该衍生物注册被战斗破坏时给予对方伤害的效果。
function c86801871.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上的怪兽区域是否有空位，若没有则不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 检查玩家是否具有特殊召唤该特定属性、种族、攻守和等级的衍生物怪兽的权限，若不能则不处理。
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,86801872,0,TYPES_TOKEN_MONSTER,1200,1200,3,RACE_REPTILE,ATTRIBUTE_EARTH) then return end
	-- 创建卡号为86801872的「毒蛇衍生物」卡片对象。
	local token=Duel.CreateToken(tp,86801872)
	-- 尝试以表侧表示将衍生物特殊召唤到自己场上，若特殊召唤步骤成功则执行后续逻辑。
	if Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP) then
		-- 「毒蛇衍生物」被战斗破坏的场合，给与对方基本分500分伤害。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_BATTLE_DESTROYED)
		e1:SetLabelObject(token)
		e1:SetCondition(c86801871.damcon)
		e1:SetOperation(c86801871.damop)
		-- 将该战斗破坏伤害效果作为全局效果注册给玩家。
		Duel.RegisterEffect(e1,tp)
	end
	-- 完成特殊召唤的流程（触发特殊召唤成功的时点）。
	Duel.SpecialSummonComplete()
end
-- 伤害效果的发动条件：检查被战斗破坏送去墓地的怪兽中是否包含该衍生物，若该衍生物已不在怪兽区则重置此效果。
function c86801871.damcon(e,tp,eg,ep,ev,re,r,rp)
	local tok=e:GetLabelObject()
	if eg:IsContains(tok) then
		return true
	else
		if not tok:IsLocation(LOCATION_MZONE) then e:Reset() end
		return false
	end
end
-- 伤害效果的处理：给与对方基本分500分的伤害。
function c86801871.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 因效果给与对方玩家500点伤害。
	Duel.Damage(1-tp,500,REASON_EFFECT)
end

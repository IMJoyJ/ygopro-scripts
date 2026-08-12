--FNo.0 未来皇ホープ
-- 效果：
-- 「No.」怪兽以外的相同阶级的超量怪兽×2
-- 规则上，这张卡的阶级当作1阶使用。
-- ①：这张卡不会被战斗破坏，这张卡的战斗发生的双方的战斗伤害变成0。
-- ②：这张卡和对方怪兽进行战斗的伤害步骤结束时才能发动。那只对方怪兽的控制权直到战斗阶段结束时得到。
-- ③：场上的这张卡被效果破坏的场合，可以作为代替把这张卡1个超量素材取除。
function c65305468.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置不受等级限制的超量召唤手续，需要2只满足特定过滤条件和检查条件的怪兽作为素材。
	aux.AddXyzProcedureLevelFree(c,c65305468.mfilter,c65305468.xyzcheck,2,2)
	-- ①：这张卡不会被战斗破坏
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- 这张卡的战斗发生的双方的战斗伤害变成0。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_NO_BATTLE_DAMAGE)
	c:RegisterEffect(e4)
	-- 这张卡的战斗发生的双方的战斗伤害变成0。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e5:SetValue(1)
	c:RegisterEffect(e5)
	-- ②：这张卡和对方怪兽进行战斗的伤害步骤结束时才能发动。那只对方怪兽的控制权直到战斗阶段结束时得到。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(65305468,0))  --"获得控制权"
	e6:SetCategory(CATEGORY_CONTROL)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_DAMAGE_STEP_END)
	-- 设置效果发动条件为伤害步骤结束时，且自身仍与战斗关联或被战斗破坏。
	e6:SetCondition(aux.dsercon)
	e6:SetTarget(c65305468.cttg)
	e6:SetOperation(c65305468.ctop)
	c:RegisterEffect(e6)
	-- ③：场上的这张卡被效果破坏的场合，可以作为代替把这张卡1个超量素材取除。
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e7:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e7:SetCode(EFFECT_DESTROY_REPLACE)
	e7:SetRange(LOCATION_MZONE)
	e7:SetTarget(c65305468.reptg)
	c:RegisterEffect(e7)
end
-- 设置这张卡的「No.」数值为0。
aux.xyz_number[65305468]=0
-- 超量素材过滤条件：非「No.」怪兽的超量怪兽。
function c65305468.mfilter(c,xyzc)
	return c:IsXyzType(TYPE_XYZ) and not c:IsSetCard(0x48)
end
-- 超量素材检查条件：参与叠放的怪兽阶级必须相同。
function c65305468.xyzcheck(g)
	return g:GetClassCount(Card.GetRank)==1
end
-- 获得控制权效果的目标过滤与确定：检查与这张卡进行战斗的对方怪兽是否仍存在于场上且可以改变控制权，并设置控制权分类的操作信息。
function c65305468.cttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetHandler():GetBattleTarget()
	if chk==0 then return tc and tc:IsRelateToBattle() and tc:IsControlerCanBeChanged() end
	-- 设置当前连锁的操作信息为：使1只目标怪兽的控制权转移。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,tc,1,0,0)
end
-- 获得控制权效果的执行：若目标怪兽仍与战斗关联，则直到战斗阶段结束时得到其控制权。
function c65305468.ctop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetBattleTarget()
	if tc:IsRelateToBattle() then
		-- 让当前玩家直到战斗阶段结束时得到目标怪兽的控制权。
		Duel.GetControl(tc,tp,PHASE_BATTLE,1)
	end
end
-- 代替破坏效果的目标与条件判断：当场上的这张卡因效果被破坏时，检查是否可以通过去除1个超量素材来代替破坏。
function c65305468.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE) and c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT) end
	-- 询问玩家是否发动代替破坏的效果。
	if Duel.SelectEffectYesNo(tp,c,96) then
		c:RemoveOverlayCard(tp,1,1,REASON_EFFECT)
		return true
	else return false end
end

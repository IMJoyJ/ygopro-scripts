--パワー・ジャイアント
-- 效果：
-- 这张卡可以把手卡1只4星以下的怪兽送去墓地，从手卡特殊召唤。这个方法特殊召唤的场合，这张卡的等级下降从手卡送去墓地的怪兽的等级数值。此外，这张卡进行战斗的场合，直到那次伤害步骤结束时自己受到的效果伤害变成0。
function c7025445.initial_effect(c)
	-- 这张卡可以把手卡1只4星以下的怪兽送去墓地，从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c7025445.spcon)
	e1:SetTarget(c7025445.sptg)
	e1:SetOperation(c7025445.spop)
	e1:SetValue(SUMMON_VALUE_SELF)
	c:RegisterEffect(e1)
	-- 这个方法特殊召唤的场合，这张卡的等级下降从手卡送去墓地的怪兽的等级数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c7025445.lvcon)
	e2:SetOperation(c7025445.lvop)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	-- 此外，这张卡进行战斗的场合，直到那次伤害步骤结束时自己受到的效果伤害变成0。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetOperation(c7025445.damop)
	c:RegisterEffect(e3)
	-- 此外，这张卡进行战斗的场合，直到那次伤害步骤结束时自己受到的效果伤害变成0。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_BE_BATTLE_TARGET)
	e4:SetOperation(c7025445.damop)
	c:RegisterEffect(e4)
end
-- 过滤条件：手卡中等级4星以下且能送去墓地的怪兽
function c7025445.cfilter(c)
	return c:IsLevelBelow(4) and c:IsAbleToGraveAsCost()
end
-- 特殊召唤规则的特殊召唤条件：怪兽区域有空位，且手卡存在满足条件的怪兽
function c7025445.spcon(e,c)
	if c==nil then return true end
	-- 检查自己场上是否有可用的怪兽区域空格
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 检查手卡中是否存在除自身以外满足过滤条件的怪兽
		and Duel.IsExistingMatchingCard(c7025445.cfilter,c:GetControler(),LOCATION_HAND,0,1,c)
end
-- 特殊召唤规则的特殊召唤目标选择：从手卡选择1只满足条件的怪兽
function c7025445.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取手卡中除自身以外所有满足过滤条件的怪兽组
	local g=Duel.GetMatchingGroup(c7025445.cfilter,tp,LOCATION_HAND,0,c)
	-- 给玩家发送“请选择要送去墓地的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则的特殊召唤操作：将选择的怪兽送去墓地，并记录其等级
function c7025445.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选择的怪兽作为特殊召唤的消耗送去墓地
	Duel.SendtoGrave(g,REASON_SPSUMMON)
	e:SetLabel(g:GetLevel())
end
-- 等级下降效果的触发条件：这张卡是通过自身效果特殊召唤成功的
function c7025445.lvcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 等级下降效果的操作：使这张卡的等级下降送去墓地怪兽的等级数值
function c7025445.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这张卡的等级下降从手卡送去墓地的怪兽的等级数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetValue(-e:GetLabelObject():GetLabel())
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	c:RegisterEffect(e1)
end
-- 战斗时效果伤害变0的操作：注册使自己受到的效果伤害变成0的效果，持续到伤害步骤结束
function c7025445.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 直到那次伤害步骤结束时自己受到的效果伤害变成0。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(c7025445.damval)
	e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
	-- 为玩家注册“效果伤害变成0”的效果
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	e2:SetReset(RESET_PHASE+PHASE_DAMAGE)
	-- 为玩家注册“不受效果伤害”的辅助状态效果
	Duel.RegisterEffect(e2,tp)
end
-- 伤害计算过滤：如果是效果伤害则将伤害数值变为0，否则保持原数值
function c7025445.damval(e,re,val,r,rp,rc)
	if bit.band(r,REASON_EFFECT)~=0 then return 0
	else return val end
end

--リミット・リバース
-- 效果：
-- 从自己墓地选择1只攻击力1000以下的怪兽，攻击表示特殊召唤。那只怪兽变成守备表示时，那只怪兽和这张卡破坏。这张卡从场上离开时，那只怪兽破坏。那只怪兽破坏时这张卡破坏。
function c27551.initial_effect(c)
	-- 从自己墓地选择1只攻击力1000以下的怪兽，攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE+TIMING_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c27551.target)
	e1:SetOperation(c27551.operation)
	c:RegisterEffect(e1)
	-- 这张卡从场上离开时，那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetOperation(c27551.desop)
	c:RegisterEffect(e2)
	-- 那只怪兽破坏时这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(c27551.descon2)
	e3:SetOperation(c27551.desop2)
	c:RegisterEffect(e3)
	-- 那只怪兽变成守备表示时，那只怪兽和这张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_CHANGE_POS)
	e4:SetCondition(c27551.descon3)
	e4:SetOperation(c27551.desop3)
	c:RegisterEffect(e4)
end
-- 过滤出自己墓地中攻击力1000以下且能由当前效果以表侧攻击表示特殊召唤的怪兽。
function c27551.filter(c,e,tp)
	return c:IsAttackBelow(1000) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 发动时的目标检查：若chkc为指定对象，则校验其是否在自己墓地、由自己控制且满足特殊召唤条件；若chk为0，则判断是否有空位且存在符合条件的对象。
function c27551.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c27551.filter(chkc,e,tp) end
	-- 检查自己场上主要怪兽区是否有可用空位，用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只满足过滤条件且能成为当前效果对象的怪兽。
		and Duel.IsExistingTarget(c27551.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从自己墓地选择1只符合条件的怪兽作为效果对象，同时登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c27551.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 登记操作信息：本效果将特殊召唤1只怪兽，供连锁判定等使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：取得对象怪兽，确认此卡与对象仍与效果关联后，将对象以表侧攻击表示特殊召唤，并让此卡以该怪兽为永续对象。
function c27551.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得发动时选择的对象怪兽（即从自己墓地选择的怪兽）。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e)
		-- 通过分解步骤将对象怪兽以表侧攻击表示特殊召唤到己方场上。
		and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK) then
		c:SetCardTarget(tc)
	end
	-- 完成特殊召唤分解步骤，确认特殊召唤处理结束。
	Duel.SpecialSummonComplete()
end
-- 此卡离场时，若其永续对象怪兽仍在场上，则将该怪兽以效果破坏。
function c27551.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		-- 以效果破坏那只被特殊召唤的怪兽。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 判定条件：存在与此卡关联的永续对象怪兽，且该怪兽已因破坏原因离场。
function c27551.descon2(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and eg:IsContains(tc) and tc:IsReason(REASON_DESTROY)
end
-- 当被特殊召唤的怪兽被破坏时，将这张卡以效果破坏。
function c27551.desop2(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果破坏此卡（限制苏生）。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
-- 判定条件：存在与此卡关联的永续对象怪兽，且该怪兽变成守备表示。
function c27551.descon3(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and eg:IsContains(tc) and tc:IsDefensePos()
end
-- 当被特殊召唤的怪兽变成守备表示时，将该怪兽和这张卡一并破坏。
function c27551.desop3(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetFirstCardTarget()
	local g=Group.FromCards(tc,c)
	-- 以效果破坏由对象怪兽和此卡组成的卡组，即二者同时破坏。
	Duel.Destroy(g,REASON_EFFECT)
end

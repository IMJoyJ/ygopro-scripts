--リボーンリボン
-- 效果：
-- 装备怪兽被战斗破坏送去墓地的场合，那个回合的结束阶段时把那只怪兽在自己场上特殊召唤。
function c37534148.initial_effect(c)
	-- 装备怪兽被战斗破坏送去墓地的场合，那个回合的结束阶段时把那只怪兽在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c37534148.target)
	e1:SetOperation(c37534148.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽被战斗破坏送去墓地的场合，那个回合的结束阶段时把那只怪兽在自己场上特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c37534148.eqlimit)
	c:RegisterEffect(e2)
	-- 装备怪兽被战斗破坏送去墓地的场合，那个回合的结束阶段时把那只怪兽在自己场上特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c37534148.regcon)
	e3:SetOperation(c37534148.regop)
	c:RegisterEffect(e3)
end
-- 装备对象不能特殊召唤
function c37534148.eqlimit(e,c)
	return not c:IsHasEffect(EFFECT_CANNOT_SPECIAL_SUMMON)
end
-- 满足特殊召唤条件的怪兽
function c37534148.filter(c)
	return c:IsFaceup() and not c:IsHasEffect(EFFECT_CANNOT_SPECIAL_SUMMON)
end
-- 选择装备对象
function c37534148.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c37534148.filter(chkc) end
	-- 判断是否有满足条件的装备对象
	if chk==0 then return Duel.IsExistingTarget(c37534148.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择装备对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择装备对象
	Duel.SelectTarget(tp,c37534148.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息为装备
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备操作
function c37534148.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将装备卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
	end
end
-- 判断是否满足特殊召唤条件
function c37534148.regcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetPreviousEquipTarget()
	return c:IsReason(REASON_LOST_TARGET) and ec:IsReason(REASON_BATTLE) and ec:IsLocation(LOCATION_GRAVE)
end
-- 注册特殊召唤效果
function c37534148.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetPreviousEquipTarget()
	-- 特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37534148,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1)
	e1:SetTarget(c37534148.sptg)
	e1:SetOperation(c37534148.spop)
	e1:SetLabelObject(ec)
	e1:SetReset(RESET_EVENT+0x16c0000+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
	ec:RegisterFlagEffect(37534148,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 设置特殊召唤目标
function c37534148.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ec=e:GetHandler():GetPreviousEquipTarget()
	if chk==0 then return ec:GetFlagEffect(37534148)~=0 end
	-- 设置特殊召唤目标
	Duel.SetTargetCard(ec)
	-- 设置效果处理信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,ec,1,0,0)
end
-- 执行特殊召唤
function c37534148.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有特殊召唤空间
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

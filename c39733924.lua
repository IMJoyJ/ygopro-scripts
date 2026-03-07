--フル・アーマード・エクシーズ
-- 效果：
-- ①：场上有超量怪兽存在的场合才能发动。进行1只超量怪兽的超量召唤。
-- ②：把墓地的这张卡除外，以自己场上1只超量怪兽为对象才能发动。那只怪兽以外的自己的场上（表侧表示）·墓地1只超量怪兽当作持有以下效果的装备魔法卡使用给作为对象的怪兽装备。
-- ●装备怪兽的攻击力上升这张卡的攻击力数值。
-- ●装备怪兽被战斗·效果破坏的场合，作为代替把这张卡破坏。
local s,id,o=GetID()
-- 注册两个效果：①超量召唤效果和②装备效果
function s.initial_effect(c)
	-- ①：场上有超量怪兽存在的场合才能发动。进行1只超量怪兽的超量召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCondition(s.xyzcond)
	e1:SetTarget(s.xyztg)
	e1:SetOperation(s.xyzop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己场上1只超量怪兽为对象才能发动。那只怪兽以外的自己的场上（表侧表示）·墓地1只超量怪兽当作持有以下效果的装备魔法卡使用给作为对象的怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	-- 将此卡从墓地除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
end
-- 过滤场上表侧表示的超量怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- 检查场上是否存在满足条件的超量怪兽
function s.xyzcond(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的超量怪兽
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 过滤可以超量召唤的超量怪兽
function s.xyzfilter(c)
	return c:IsXyzSummonable(nil)
end
-- 设置超量召唤效果的目标和操作信息
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组是否存在满足条件的超量怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置连锁操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 执行超量召唤操作
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取额外卡组中满足条件的超量怪兽
	local g=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil)
	if g:GetCount()>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=g:Select(tp,1,1,nil)
		-- 执行超量召唤
		Duel.XyzSummon(tp,tg:GetFirst(),nil)
	end
end
-- 过滤可以作为装备对象的超量怪兽
function s.tgfilter(c,tp)
	-- 检查是否存在满足条件的超量怪兽
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,c)
end
-- 过滤可以装备的超量怪兽
function s.eqfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
-- 设置装备效果的目标和操作信息
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tgfilter(chkc,tp) end
	if chk==0 then
		-- 获取玩家魔法区域的可用空位数
		local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
		-- 检查是否存在满足条件的装备对象
		return ft>0 and Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 提示玩家选择装备对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择装备对象
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
end
-- 执行装备效果
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家魔法区域是否有空位
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if not (tc:IsRelateToEffect(e) and tc:IsFaceup()) then return end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择满足条件的装备卡
	local ec=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.eqfilter),tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,tc,tp):GetFirst()
	-- 执行装备操作
	if ec and Duel.Equip(tp,ec,tc)then
		-- 装备怪兽的攻击力上升这张卡的攻击力数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetLabelObject(tc)
		e1:SetValue(s.eqlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		ec:RegisterEffect(e1)
		-- 装备怪兽被战斗·效果破坏的场合，作为代替把这张卡破坏。
		local e2=Effect.CreateEffect(ec)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(ec:GetAttack())
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		ec:RegisterEffect(e2,true)
		-- 装备怪兽被战斗·效果破坏的场合，作为代替把这张卡破坏。
		local e3=Effect.CreateEffect(ec)
		e3:SetType(EFFECT_TYPE_EQUIP)
		e3:SetCode(EFFECT_DESTROY_SUBSTITUTE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		e3:SetValue(s.desrepval)
		ec:RegisterEffect(e3,true)
	end
end
-- 限制装备卡只能装备给指定怪兽
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 判断破坏原因是否为战斗或效果
function s.desrepval(e,re,r,rp)
	return r&(REASON_BATTLE|REASON_EFFECT)~=0
end

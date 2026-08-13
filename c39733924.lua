--フル・アーマード・エクシーズ
-- 效果：
-- ①：场上有超量怪兽存在的场合才能发动。进行1只超量怪兽的超量召唤。
-- ②：把墓地的这张卡除外，以自己场上1只超量怪兽为对象才能发动。那只怪兽以外的自己的场上（表侧表示）·墓地1只超量怪兽当作持有以下效果的装备魔法卡使用给作为对象的怪兽装备。
-- ●装备怪兽的攻击力上升这张卡的攻击力数值。
-- ●装备怪兽被战斗·效果破坏的场合，作为代替把这张卡破坏。
local s,id,o=GetID()
-- 注册此卡的两个效果：e1为①效果（魔法卡发动，满足条件时进行1只超量怪兽的超量召唤）；e2为②效果（墓地快速效果，除外自身并以己方场上1只超量怪兽为对象，将另一只超量怪兽装备给它）。
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
	-- 将墓地的此卡除外作为②效果的发动COST。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
end
-- 定义过滤条件：表侧表示且为超量怪兽，用于①效果检查场上是否存在超量怪兽。
function s.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- ①效果的发动条件：场上存在表侧表示的超量怪兽时才能发动。
function s.xyzcond(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检索双方场上（主要怪兽区）是否有至少1只表侧表示的超量怪兽。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 定义额外卡组中可进行超量召唤的怪兽的筛选条件（IsXyzSummonable判定）。
function s.xyzfilter(c)
	return c:IsXyzSummonable(nil)
end
-- ①效果的发动时点处理：确认额外卡组存在可超量召唤的怪兽，并设置特殊召唤的操作信息。
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在chk==0（发动合法性确认）时，检查额外卡组是否存在至少1只满足超量召唤条件的超量怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置操作信息：本次连锁将进行从额外卡组的1只超量怪兽的特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ①效果处理阶段：从额外卡组选择1只可超量召唤的超量怪兽，使用场上素材进行超量召唤。
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取额外卡组中所有满足超量召唤条件的超量怪兽集合。
	local g=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_EXTRA,0,nil)
	if g:GetCount()>0 then
		-- 显示“请选择要特殊召唤的卡”的提示，引导玩家选择额外卡组的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=g:Select(tp,1,1,nil)
		-- 对选中的怪兽进行超量召唤手续（从场上选择素材叠放）。
		Duel.XyzSummon(tp,tg:GetFirst(),nil)
	end
end
-- ②效果的对象过滤条件：对象须为己方场上表侧表示的超量怪兽，且己方场上（表侧表示）或墓地存在另一只可作为装备的超量怪兽。
function s.tgfilter(c,tp)
	-- 判定目标怪兽是否满足：表侧超量怪兽，并且己方场上/墓地存在另一只可供装备的超量怪兽。
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,c)
end
-- 定义可装备的超量怪兽的条件：表侧表示且为超量怪兽、场上没有同名卡、不被禁止作为装备卡。
function s.eqfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
-- ②效果的发动时点处理：确认魔陷区有空位，选择己方场上1只表侧超量怪兽作为对象；在连锁确认时也验证已选对象是否合法。
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.tgfilter(chkc,tp) end
	if chk==0 then
		-- 获取己方魔陷区的可用空格数，用于判断能否放置装备卡。
		local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
		-- 发动条件判定：魔陷区有空位，并且存在满足条件的对象（己方场上表侧超量怪兽且其外另有可装备超量怪兽）。
		return ft>0 and Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 显示“请选择效果的对象”的提示，供玩家选择作为装备对象的超量怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从己方场上选择1只表侧表示的超量怪兽作为效果对象，并登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
end
-- ②效果处理阶段：若魔陷区有空位，从己方场上表侧表示或墓地选择1只超量怪兽作为装备卡，装备给对象怪兽，并为其添加攻击力上升与代替破坏的效果。
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 若己方魔陷区空位不足，则效果不处理，直接返回。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local c=e:GetHandler()
	-- 取得②效果发动时选择的对象怪兽（作为装备对象的超量怪兽）。
	local tc=Duel.GetFirstTarget()
	if not (tc:IsRelateToEffect(e) and tc:IsFaceup()) then return end
	-- 显示“请选择要装备的卡”的提示，引导玩家选择装备卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从己方场上（表侧表示）·墓地的超量怪兽中选择1只对象以外、可装备的超量怪兽作为装备卡（过滤王家长眠之谷影响）。
	local ec=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.eqfilter),tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,tc,tp):GetFirst()
	-- 如果成功选出装备卡并装备给对象怪兽，则继续为装备卡注册相关效果。
	if ec and Duel.Equip(tp,ec,tc)then
		-- 给作为对象的怪兽装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetLabelObject(tc)
		e1:SetValue(s.eqlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		ec:RegisterEffect(e1)
		-- ●装备怪兽的攻击力上升这张卡的攻击力数值。
		local e2=Effect.CreateEffect(ec)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(ec:GetAttack())
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		ec:RegisterEffect(e2,true)
		-- ●装备怪兽被战斗·效果破坏的场合，作为代替把这张卡破坏。
		local e3=Effect.CreateEffect(ec)
		e3:SetType(EFFECT_TYPE_EQUIP)
		e3:SetCode(EFFECT_DESTROY_SUBSTITUTE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		e3:SetValue(s.desrepval)
		ec:RegisterEffect(e3,true)
	end
end
-- 装备限制判定：该装备魔法卡只能装备给作为对象的怪兽（即e:GetLabelObject()记录的怪兽）。
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 代替破坏的判定：当装备怪兽将要因战斗或卡牌效果被破坏时，返回真值以此卡代替破坏。
function s.desrepval(e,re,r,rp)
	return r&(REASON_BATTLE|REASON_EFFECT)~=0
end

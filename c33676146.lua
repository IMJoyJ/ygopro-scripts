--エスケープ・ゴート
-- 效果：
-- ①：衍生物以外的自己场上的怪兽为对象的效果由对方发动时，把自己场上1只怪兽解放才能发动。在自己场上把1只「逃羊衍生物」（兽族·地·1星·攻/守0）守备表示特殊召唤。
-- ②：衍生物以外的自己场上的怪兽被战斗·效果破坏的场合，可以作为代替把自己场上1只衍生物破坏。
local s,id,o=GetID()
-- 初始化效果注册：创建e1使魔陷可在自由时点发动；e2为①效果，在对方发动取对象效果时解放自己场上1只怪兽特招逃羊衍生物；e3为②效果，提供代替破坏。
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：衍生物以外的自己场上的怪兽为对象的效果由对方发动时，把自己场上1只怪兽解放才能发动。在自己场上把1只「逃羊衍生物」（兽族·地·1星·攻/守0）守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.tkcon)
	e2:SetCost(s.tkcost)
	e2:SetTarget(s.tktg)
	e2:SetOperation(s.tkop)
	c:RegisterEffect(e2)
	-- ②：衍生物以外的自己场上的怪兽被战斗·效果破坏的场合，可以作为代替把自己场上1只衍生物破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTarget(s.reptg)
	e3:SetOperation(s.repop)
	-- 给e3设置Value过滤函数：被破坏的卡若为衍生物以外且位于自己怪兽区、破坏原因为战斗或效果，则返回true，允许触发代替破坏。
	e3:SetValue(aux.TargetBoolFunction(s.filter,e3))
	c:RegisterEffect(e3)
end
-- 过滤函数：卡c不是衍生物、位于主要怪兽区、且控制者为tp，用于①效果判断对方效果对象是否包含符合条件的自己怪兽。
function s.tfilter(c,tp)
	return not c:IsType(TYPE_TOKEN) and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
end
-- ①效果发动条件：效果发动者为对方(rp==1-tp)、该效果为取对象效果，且连锁对象中存在满足s.tfilter的自己怪兽（衍生物以外的自己场上怪兽）。
function s.tkcon(e,tp,eg,ep,ev,re,r,rp)
	if rp~=1-tp or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 取得对方发动效果的连锁对象卡组，用于判断对象中是否有符合条件的怪兽。
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and g:IsExists(s.tfilter,1,nil,tp)
end
-- 过滤函数：把c解放后自己场上仍有空余怪兽区，用于确保解放后能特殊召唤衍生物。
function s.cfilter(c,tp)
	-- 判断将c解放后自己的可用怪兽区数量是否大于0，即是否仍能腾出空位。
	return Duel.GetMZoneCount(tp,c)>0
end
-- ①效果的发动代价：从自己场上选择1只满足s.cfilter的怪兽解放（该怪兽被解放后要留出空位），以REASON_COST执行解放。
function s.tkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认自己场上是否存在至少1只满足s.cfilter的可解放怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,s.cfilter,1,nil,tp) end
	-- 选择自己要解放的1只怪兽（以s.cfilter过滤，保证解放后有空位）。
	local g=Duel.SelectReleaseGroup(tp,s.cfilter,1,1,nil,tp)
	-- 将选择的怪兽解放作为发动代价，原因标记为REASON_COST。
	Duel.Release(g,REASON_COST)
end
-- ①效果的目标/发动合法性检查：若代价已付则直接通过；否则需要主怪兽区有空位且玩家能特殊召唤逃羊衍生物，并设置效果操作信息。
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在未支付代价的检查阶段，判断自己主怪兽区是否有空位，若无空位则不满足发动条件。
	if chk==0 then return e:IsCostChecked() or Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 继续检查玩家是否可以将参数指定的「逃羊衍生物」（兽族·地·1星·攻/守0）以表侧守备表示特殊召唤。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_BEAST,ATTRIBUTE_EARTH,POS_FACEUP_DEFENSE) end
	-- 设置本连锁的操作信息：包含衍生物生成（CATEGORY_TOKEN），预计生成1只，不指定对象。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置本连锁的操作信息：包含特殊召唤（CATEGORY_SPECIAL_SUMMON），预计特殊召唤1只，不指定对象。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- ①效果处理：再次确认主怪兽区有空位且可以特招衍生物，然后创建衍生物并守备表示特殊召唤。
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己主怪兽区已无空位（<=0），则无法特殊召唤，终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		-- 若玩家因任何原因不能将逃羊衍生物以表侧守备表示特殊召唤，则终止处理。
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,id+o,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_BEAST,ATTRIBUTE_EARTH,POS_FACEUP_DEFENSE) then return end
	-- 在自己的场上生成1只「逃羊衍生物」（token），其卡号使用id+o表示。
	local tk=Duel.CreateToken(tp,id+o)
	-- 将生成的衍生物以表侧守备表示特殊召唤到自己场上，不适用特殊召唤条件和苏生限制（nocheck/nolimit为false仍检查，但token无条件）。
	Duel.SpecialSummon(tk,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ②代破过滤：判断被破坏的怪兽是否为衍生物以外的自己场上怪兽，且破坏原因是战斗或效果；同时排除因代替破坏而被破坏的情况，防止循环。
function s.filter(c,e)
	local tp=e:GetHandlerPlayer()
	return not c:IsType(TYPE_TOKEN) and c:IsLocation(LOCATION_MZONE) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and not c:IsReason(REASON_REPLACE)
end
-- 选择代破衍生物的过滤条件：是衍生物、可被效果破坏、且尚未处于破坏确认状态。
function s.rfilter(c,e)
	return c:IsType(TYPE_TOKEN) and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
end
-- ②代替破坏的target函数：检查存在符合条件的被破坏怪兽和可代破的衍生物；询问玩家是否发动；若发动则选择1张衍生物并标记STATUS_DESTROY_CONFIRMED，返回true。
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在chk==0时判断：本次将要破坏的卡组eg中存在满足s.filter的怪兽，且自己场上存在至少1张满足s.rfilter的衍生物，二者同时满足才能发动代破。
	if chk==0 then return eg:IsExists(s.filter,1,nil,e) and Duel.IsExistingMatchingCard(s.rfilter,tp,LOCATION_ONFIELD,0,1,nil,e) end
	-- 弹出询问框，让玩家决定是否发动代替破坏效果（使用提示文本96）。
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		-- 提示玩家选择要代替破坏的卡片，显示选择消息为HINTMSG_DESREPLACE。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
		-- 从自己场上选择1张满足s.rfilter的衍生物，取其中第一张作为代破对象。
		local tc=Duel.SelectMatchingCard(tp,s.rfilter,tp,LOCATION_ONFIELD,0,1,1,nil,e):GetFirst()
		e:SetLabelObject(tc)
		tc:SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	else return false end
end
-- ②代替破坏处理：清除衍生物上的STATUS_DESTROY_CONFIRMED标记，并以REASON_EFFECT+REASON_REPLACE将其破坏。
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	tc:SetStatus(STATUS_DESTROY_CONFIRMED,false)
	-- 以效果·代替破坏的原因将所选择的衍生物破坏，完成代替破坏。
	Duel.Destroy(tc,REASON_EFFECT+REASON_REPLACE)
end

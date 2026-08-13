--機甲部隊の最前線
-- 效果：
-- ①：1回合1次，机械族怪兽被战斗破坏送去自己墓地时才能发动。比墓地的那只怪兽攻击力低的1只相同属性的机械族怪兽从卡组特殊召唤。
function c31828916.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，机械族怪兽被战斗破坏送去自己墓地时才能发动。比墓地的那只怪兽攻击力低的1只相同属性的机械族怪兽从卡组特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetDescription(aux.Stringid(31828916,0))  --"特殊召唤"
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetCountLimit(1)
	e3:SetTarget(c31828916.target)
	e3:SetOperation(c31828916.operation)
	c:RegisterEffect(e3)
end
-- 筛选被战斗破坏后送入自己墓地的自己的机械族怪兽：需为机械族、原控制者为自己、在墓地、因战斗破坏且离场前为机械族，并确认卡组中存在可特殊召唤的符合条件的机械族怪兽。
function c31828916.cfilter(c,e,tp)
	return c:IsRace(RACE_MACHINE) and c:IsControler(tp) and c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_BATTLE)
		and bit.band(c:GetPreviousRaceOnField(),RACE_MACHINE)~=0
		-- 确认卡组中存在攻击力低于该墓地机械族怪兽、属性相同且满足特殊召唤条件的机械族怪兽。
		and Duel.IsExistingMatchingCard(c31828916.filter,tp,LOCATION_DECK,0,1,nil,c:GetAttack(),c:GetAttribute(),e,tp)
end
-- 定义卡组中可特殊召唤的机械族怪兽的筛选条件：攻击力非负且小于参照攻击力、机械族、属性与参照属性一致，并能被当前效果特殊召唤（满足召唤条件且不受苏生限制）。
function c31828916.filter(c,atk,att,e,tp)
	local a=c:GetAttack()
	return a>=0 and a<atk and c:IsRace(RACE_MACHINE) and c:IsAttribute(att)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时点（chk=0）的合法性检查：自己场上有可用的怪兽区，且本次战斗破坏相关的怪兽中存在满足条件的机械族怪兽。
function c31828916.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动条件之一：自己的主要怪兽区存在空位，可用于后续特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and eg:IsExists(c31828916.cfilter,1,nil,e,tp) end
	-- 将本次被战斗破坏的怪兽组设为当前效果的关联对象，确保处理时能正确筛选这些怪兽。
	Duel.SetTargetCard(eg)
	-- 设置操作信息，向系统声明本次效果将进行1只机械族怪兽从卡组的特殊召唤，用于其他卡片的连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时筛选仍然与效果关联的墓地机械族怪兽：需为机械族、原控制者为自己、与效果保持关联，且卡组中仍有符合条件的可特殊召唤怪兽。
function c31828916.cfilter2(c,e,tp)
	return c:IsRace(RACE_MACHINE) and c:IsControler(tp) and c:IsRelateToEffect(e)
		-- 确认卡组中存在攻击力低于该怪兽、属性相同且满足特殊召唤条件的机械族怪兽。
		and Duel.IsExistingMatchingCard(c31828916.filter,tp,LOCATION_DECK,0,1,nil,c:GetAttack(),c:GetAttribute(),e,tp)
end
-- 效果处理：若场上空位足够，从本次关联的被战斗破坏的机械族怪兽中筛选符合条件的墓地怪兽；若只有1只，则以它为基准选择卡组中怪兽特殊召唤；若有多只，则以其中最高攻击力和合并属性为条件选择1只机械族怪兽表侧表示特殊召唤。
function c31828916.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次检查自己的主要怪兽区是否仍有空位，若无空位则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local sg=eg:Filter(c31828916.cfilter2,nil,e,tp)
	if sg:GetCount()==1 then
		local tc=sg:GetFirst()
		-- 向操作玩家显示选择特殊召唤卡的提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组中选择1只攻击力低于参照怪兽、属性相同且满足特殊召唤条件的机械族怪兽。
		local g=Duel.SelectMatchingCard(tp,c31828916.filter,tp,LOCATION_DECK,0,1,1,nil,tc:GetAttack(),tc:GetAttribute(),e,tp)
		if g:GetCount()>0 then
			-- 将选择的机械族怪兽以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	else
		local tc=sg:GetFirst()
		if not tc then return end
		local atk=tc:GetAttack()
		local att=tc:GetAttribute()
		tc=sg:GetNext()
		if tc then
			if tc:GetAttack()>atk then atk=tc:GetAttack() end
			att=bit.bor(att,tc:GetAttribute())
		end
		-- 向操作玩家显示选择特殊召唤卡的提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组中选择1只攻击力低于所选最高攻击力、属性符合合并属性条件且满足特殊召唤条件的机械族怪兽。
		local g=Duel.SelectMatchingCard(tp,c31828916.filter,tp,LOCATION_DECK,0,1,1,nil,atk,att,e,tp)
		if g:GetCount()>0 then
			-- 将选择的机械族怪兽以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end

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
-- 过滤满足条件的墓地被战斗破坏的机械族怪兽，且其属性与卡组中满足条件的机械族怪兽存在匹配
function c31828916.cfilter(c,e,tp)
	return c:IsRace(RACE_MACHINE) and c:IsControler(tp) and c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_BATTLE)
		and bit.band(c:GetPreviousRaceOnField(),RACE_MACHINE)~=0
		-- 检查卡组中是否存在满足条件的机械族怪兽（攻击力低于目标怪兽，相同属性）
		and Duel.IsExistingMatchingCard(c31828916.filter,tp,LOCATION_DECK,0,1,nil,c:GetAttack(),c:GetAttribute(),e,tp)
end
-- 过滤满足条件的卡组中的机械族怪兽（攻击力低于指定值，相同属性，可特殊召唤）
function c31828916.filter(c,atk,att,e,tp)
	local a=c:GetAttack()
	return a>=0 and a<atk and c:IsRace(RACE_MACHINE) and c:IsAttribute(att)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足发动条件：场地上有空位且存在符合条件的被战斗破坏的机械族怪兽
function c31828916.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有空位用于特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and eg:IsExists(c31828916.cfilter,1,nil,e,tp) end
	-- 设置连锁处理的目标卡为被战斗破坏的怪兽
	Duel.SetTargetCard(eg)
	-- 设置操作信息为特殊召唤1只怪兽，目标为卡组
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 过滤满足条件的墓地被战斗破坏的机械族怪兽，且其与卡组中满足条件的机械族怪兽存在匹配
function c31828916.cfilter2(c,e,tp)
	return c:IsRace(RACE_MACHINE) and c:IsControler(tp) and c:IsRelateToEffect(e)
		-- 检查卡组中是否存在满足条件的机械族怪兽（攻击力低于目标怪兽，相同属性）
		and Duel.IsExistingMatchingCard(c31828916.filter,tp,LOCATION_DECK,0,1,nil,c:GetAttack(),c:GetAttribute(),e,tp)
end
-- 处理效果发动时的特殊召唤逻辑，根据被破坏怪兽数量选择召唤目标
function c31828916.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有空位用于特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local sg=eg:Filter(c31828916.cfilter2,nil,e,tp)
	if sg:GetCount()==1 then
		local tc=sg:GetFirst()
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组中选择满足条件的机械族怪兽
		local g=Duel.SelectMatchingCard(tp,c31828916.filter,tp,LOCATION_DECK,0,1,1,nil,tc:GetAttack(),tc:GetAttribute(),e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽特殊召唤到场上
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
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组中选择满足条件的机械族怪兽
		local g=Duel.SelectMatchingCard(tp,c31828916.filter,tp,LOCATION_DECK,0,1,1,nil,atk,att,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽特殊召唤到场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end

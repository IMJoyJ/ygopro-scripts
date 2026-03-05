--海晶乙女渦輪
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己或者对方的怪兽的攻击宣言时才能发动。那次攻击无效，从自己的额外卡组·墓地选1只「海晶少女 水晶心」特殊召唤。
-- ②：把墓地的这张卡除外，以自己场上1只连接2以上的「海晶少女」连接怪兽为对象才能发动。这个回合，那只怪兽在同1次的战斗阶段中可以作出最多有自身的连接标记数量的攻击，那只怪兽的战斗发生的对对方的战斗伤害变成0。
function c19712214.initial_effect(c)
	-- ①：自己或者对方的怪兽的攻击宣言时才能发动。那次攻击无效，从自己的额外卡组·墓地选1只「海晶少女 水晶心」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCountLimit(1,19712214+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c19712214.target)
	e1:SetOperation(c19712214.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己场上1只连接2以上的「海晶少女」连接怪兽为对象才能发动。这个回合，那只怪兽在同1次的战斗阶段中可以作出最多有自身的连接标记数量的攻击，那只怪兽的战斗发生的对对方的战斗伤害变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	-- 效果发动时必须满足战斗阶段或第一主要阶段的条件，确保可以进行战斗相关操作。
	e2:SetCondition(aux.bpcon)
	-- 发动此效果需要将此卡从墓地除外作为费用。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c19712214.attg)
	e2:SetOperation(c19712214.atop)
	c:RegisterEffect(e2)
end
-- 过滤满足条件的「海晶少女 水晶心」卡片，确保其可特殊召唤且位置合法。
function c19712214.spfilter(c,e,tp)
	return c:IsCode(67712104) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 当卡片在墓地时，检查场上是否有足够的怪兽区域可特殊召唤。
		and (c:IsLocation(LOCATION_GRAVE) and Duel.GetMZoneCount(tp)>0
			-- 当卡片在额外卡组时，检查是否可特殊召唤至场上。
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0)
end
-- 判断是否满足发动条件，即场上是否存在满足条件的「海晶少女 水晶心」。
function c19712214.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 设置连锁操作信息，表示将要特殊召唤1只「海晶少女 水晶心」。
	if chk==0 then return Duel.IsExistingMatchingCard(c19712214.spfilter,tp,LOCATION_GRAVE+LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 无效此次攻击并检索满足条件的「海晶少女 水晶心」进行特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_EXTRA)
end
-- 获取满足条件的「海晶少女 水晶心」卡片组。
function c19712214.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 无效此次攻击并判断是否有满足条件的卡片可特殊召唤。
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c19712214.spfilter),tp,LOCATION_GRAVE+LOCATION_EXTRA,0,nil,e,tp)
	-- 提示玩家选择要特殊召唤的卡片。
	if Duel.NegateAttack() and #g>0 then
		-- 执行特殊召唤操作。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 过滤满足条件的「海晶少女」连接怪兽，确保其为正面表示且连接数不少于2。
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 设置效果目标，选择符合条件的「海晶少女」连接怪兽。
function c19712214.tgfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x12b) and c:IsType(TYPE_LINK) and c:IsLinkAbove(2)
end
-- 判断是否满足发动条件，即场上是否存在符合条件的「海晶少女」连接怪兽。
function c19712214.attg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c19712214.tgfilter(chkc) end
	-- 提示玩家选择效果的目标。
	if chk==0 then return Duel.IsExistingTarget(c19712214.tgfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 选择目标「海晶少女」连接怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 设置效果目标，注册效果的处理对象。
	Duel.SelectTarget(tp,c19712214.tgfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 为选中的目标怪兽添加额外攻击次数和战斗伤害归零效果。
function c19712214.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁效果的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 为该怪兽添加额外攻击次数，次数等于其连接数减1。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetValue(tc:GetLink()-1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 为该怪兽添加战斗时不受战斗伤害的效果。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_NO_BATTLE_DAMAGE)
		e2:SetCondition(c19712214.damcon)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetOwnerPlayer(tp)
		tc:RegisterEffect(e2)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
		e3:SetCondition(c19712214.damcon2)
		e3:SetValue(1)
		tc:RegisterEffect(e3)
	end
end
-- 判断是否为该怪兽的控制者触发效果，用于确定是否生效。
function c19712214.damcon(e)
	return e:GetHandlerPlayer()==e:GetOwnerPlayer()
end
-- 判断是否为该怪兽的控制者触发效果，用于确定是否生效。
function c19712214.damcon2(e)
	return 1-e:GetHandlerPlayer()==e:GetOwnerPlayer()
end

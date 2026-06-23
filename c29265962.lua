--同姓同名同盟罷業
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己场上1只表侧表示怪兽为对象才能发动。原本卡名和那只自己怪兽相同的2只怪兽从自己的手卡·卡组·墓地当作装备魔法卡使用给作为对象的怪兽装备。那只怪兽只要这个效果把怪兽2只都装备中，不能攻击，不会被战斗破坏。这张卡的发动后，直到回合结束时自己不是原本种族和作为对象的怪兽相同的怪兽不能特殊召唤。
local s,id,o=GetID()
-- 注册卡的效果，设置为发动时点、自由连锁、取对象效果，并限制每回合只能发动1次
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断场上是否存在满足条件的怪兽（表侧表示且有2张以上相同卡名的怪兽可装备）
function s.filter(c,tp)
	local code=c:GetOriginalCode()
	-- 判断怪兽是否表侧表示且在手牌/卡组/墓地存在2张以上相同卡名的怪兽
	return c:IsFaceup() and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_HAND,0,2,nil,code,tp)
end
-- 装备过滤函数，用于筛选可装备的怪兽（卡名相同、怪兽卡、未被禁止、未重复）
function s.eqfilter(c,code,tp)
	return c:IsOriginalCodeRule(code) and c:IsType(TYPE_MONSTER) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
-- 设置效果的目标选择函数，判断是否能选择满足条件的怪兽作为对象
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc,tp) end
	local b=e:IsHasType(EFFECT_TYPE_ACTIVATE) and not e:GetHandler():IsLocation(LOCATION_SZONE)
	-- 获取玩家当前场上可用的魔法陷阱区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if b then ft=ft-1 end
	if chk==0 then return ft>1
		-- 检查是否满足发动条件，即场上存在满足条件的怪兽
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择满足条件的怪兽作为对象
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,tp)
end
-- 效果发动处理函数，执行装备和效果注册
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	local code=tc:GetOriginalCode()
	-- 判断目标怪兽是否仍然在场且满足发动条件
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsType(TYPE_MONSTER) and Duel.GetLocationCount(tp,LOCATION_SZONE)>1
		-- 检查是否满足装备条件，即手牌/卡组/墓地存在2张以上相同卡名的怪兽
		and Duel.GetMatchingGroupCount(aux.NecroValleyFilter(s.eqfilter),tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,nil,code,tp)>1 then
		-- 提示玩家选择要装备的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		-- 选择2张满足条件的怪兽进行装备
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.eqfilter),tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,2,2,nil,code,tp)
		if #g<2 then return end
		g:KeepAlive()
		local ec=g:GetFirst()
		while ec do
			-- 尝试将卡装备给目标怪兽
			if Duel.Equip(tp,ec,tc) then
				ec:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,0,id)
				-- 设置装备限制效果，防止其他卡装备给该怪兽
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_EQUIP_LIMIT)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetLabelObject(tc)
				e1:SetValue(s.eqlimit)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				ec:RegisterEffect(e1)
			end
			ec=g:GetNext()
		end
		-- 设置该怪兽不能攻击
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetLabelObject(g)
		e1:SetCondition(s.chkcon)
		tc:RegisterEffect(e1)
		-- 设置该怪兽不会被战斗破坏
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e2:SetValue(1)
		e2:SetLabelObject(g)
		e2:SetCondition(s.chkcon)
		tc:RegisterEffect(e2)
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 发动后，直到回合结束时自己不是原本种族和作为对象的怪兽相同的怪兽不能特殊召唤
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetLabel(tc:GetOriginalRace())
		e1:SetTarget(s.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册效果，使对方不能特殊召唤特定种族的怪兽
		Duel.RegisterEffect(e1,tp)
	end
end
-- 特殊召唤限制函数，判断怪兽种族是否与目标怪兽相同
function s.splimit(e,c)
	return c:GetOriginalRace()&e:GetLabel()==0
end
-- 检查装备的卡是否在装备组中
function s.chkfilter(c,id,eg)
	return c:GetFlagEffect(id)>0 and eg:IsContains(c)
end
-- 判断是否装备了2张卡，用于触发不能攻击和不会被战斗破坏效果
function s.chkcon(e)
	local eg=e:GetHandler():GetEquipGroup()
	local g=e:GetLabelObject()
	return g:Filter(s.chkfilter,nil,id,eg):GetCount()==2
end
-- 装备限制函数，判断装备卡是否只能装备给特定怪兽
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end

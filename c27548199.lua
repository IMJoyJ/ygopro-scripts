--ヴァレルロード・S・ドラゴン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡同调召唤成功的场合才能发动。从自己墓地选1只连接怪兽当作装备卡使用给这张卡装备，那个连接标记数量的枪管指示物给这张卡放置。
-- ②：这张卡的攻击力上升这张卡的效果装备的怪兽的攻击力一半数值。
-- ③：对方的效果发动时，把这张卡1个枪管指示物取除才能发动。那个发动无效。
function c27548199.initial_effect(c)
	c:EnableCounterPermit(0x4b)
	-- 为卡片添加同调召唤手续，要求必须是1只调整以外的怪兽作为素材
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤成功的场合才能发动。从自己墓地选1只连接怪兽当作装备卡使用给这张卡装备，那个连接标记数量的枪管指示物给这张卡放置。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetDescription(aux.Stringid(27548199,0))
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(c27548199.eqcon)
	e1:SetTarget(c27548199.eqtg)
	e1:SetOperation(c27548199.eqop)
	c:RegisterEffect(e1)
	-- ③：对方的效果发动时，把这张卡1个枪管指示物取除才能发动。那个发动无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(27548199,1))
	e2:SetCategory(CATEGORY_NEGATE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,27548199)
	e2:SetCondition(c27548199.discon)
	e2:SetCost(c27548199.discost)
	e2:SetTarget(c27548199.distg)
	e2:SetOperation(c27548199.disop)
	c:RegisterEffect(e2)
end
-- 判断是否为同调召唤成功
function c27548199.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤满足条件的墓地连接怪兽，包括唯一性检查、是否禁止、是否能放置枪管指示物
function c27548199.eqfilter(c,tp,mc)
	return c:IsType(TYPE_LINK) and c:CheckUniqueOnField(tp) and not c:IsForbidden() and mc:IsCanAddCounter(0x4b,c:GetLink())
end
-- 判断是否满足效果发动条件，包括魔法陷阱区域是否有空位和墓地是否存在满足条件的连接怪兽
function c27548199.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断魔法陷阱区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断墓地是否存在满足条件的连接怪兽
		and Duel.IsExistingMatchingCard(c27548199.eqfilter,tp,LOCATION_GRAVE,0,1,nil,tp,e:GetHandler()) end
	-- 设置操作信息，表示将要从墓地取出一张卡
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,0)
end
-- 执行装备操作，包括选择装备卡、装备、放置枪管指示物、设置装备限制和攻击力提升效果
function c27548199.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断魔法陷阱区域是否还有空位
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从墓地选择满足条件的连接怪兽作为装备卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c27548199.eqfilter),tp,LOCATION_GRAVE,0,1,1,nil,tp,c)
	local tc=g:GetFirst()
	if tc then
		-- 执行装备操作，若失败则返回
		if not Duel.Equip(tp,tc,c) then return end
		local lk=tc:GetLink()
		if lk>0 then
			c:AddCounter(0x4b,lk)
		end
		-- 设置装备限制效果，确保只有装备的怪兽能装备给该卡
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c27548199.eqlimit)
		tc:RegisterEffect(e1)
		local atk=tc:GetAttack()
		if atk>0 then
			-- 设置装备怪兽的攻击力提升效果，提升值为装备怪兽攻击力的一半（向上取整）
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_EQUIP)
			e2:SetProperty(EFFECT_FLAG_OWNER_RELATE+EFFECT_FLAG_IGNORE_IMMUNE)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			e2:SetValue(math.ceil(atk/2))
			tc:RegisterEffect(e2)
		end
	end
end
-- 装备限制效果的判断函数，确保只有装备的怪兽能装备给该卡
function c27548199.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 判断是否满足对方效果发动时的无效条件
function c27548199.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为对方发动效果且该卡未在战斗中被破坏且该连锁可被无效
	return rp==1-tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
-- 设置消耗枪管指示物作为代价
function c27548199.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x4b,1,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x4b,1,REASON_COST)
end
-- 设置无效效果的目标和操作信息
function c27548199.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表示将要使发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 执行使对方发动无效的操作
function c27548199.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使连锁发动无效
	Duel.NegateActivation(ev)
end

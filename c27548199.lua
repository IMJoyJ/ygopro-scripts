--ヴァレルロード・S・ドラゴン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡同调召唤成功的场合才能发动。从自己墓地选1只连接怪兽当作装备卡使用给这张卡装备，那个连接标记数量的枪管指示物给这张卡放置。
-- ②：这张卡的攻击力上升这张卡的效果装备的怪兽的攻击力一半数值。
-- ③：对方的效果发动时，把这张卡1个枪管指示物取除才能发动。那个发动无效。
function c27548199.initial_effect(c)
	c:EnableCounterPermit(0x4b)
	-- 添加同调召唤手续，要求1只调整和1只调整以外的怪兽参与同调召唤
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
c27548199.mentioned_counter={
	[0x4b]=true,
}
-- 效果适用条件：此卡必须是同调召唤成功时才能发动
function c27548199.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 装备卡筛选条件：连接怪兽且满足场上唯一性、未被禁止、此卡能添加对应数量枪管指示物
function c27548199.eqfilter(c,tp,mc)
	return c:IsType(TYPE_LINK) and c:CheckUniqueOnField(tp) and not c:IsForbidden() and mc:IsCanAddCounter(0x4b,c:GetLink())
end
-- 效果发动时的判定条件：确认场上是否有足够空间以及墓地是否存在符合条件的连接怪兽
function c27548199.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上魔陷区是否还有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断墓地是否存在满足条件的连接怪兽
		and Duel.IsExistingMatchingCard(c27548199.eqfilter,tp,LOCATION_GRAVE,0,1,nil,tp,e:GetHandler()) end
	-- 设置连锁操作信息，表示将从墓地取出1张卡进行装备
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,0)
end
-- 装备效果处理函数：检查场地、确认装备对象并执行装备与指示物添加等操作
function c27548199.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断场上是否有空位用于装备
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从墓地中选择满足条件的连接怪兽作为装备卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c27548199.eqfilter),tp,LOCATION_GRAVE,0,1,1,nil,tp,c)
	local tc=g:GetFirst()
	if tc then
		-- 尝试将选中的卡装备给此卡，若失败则返回
		if not Duel.Equip(tp,tc,c) then return end
		local lk=tc:GetLink()
		if lk>0 then
			c:AddCounter(0x4b,lk)
		end
		-- 设置装备限制效果，确保只有装备卡能装备给此卡
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c27548199.eqlimit)
		tc:RegisterEffect(e1)
		local atk=tc:GetAttack()
		if atk>0 then
			-- 设置装备卡攻击力提升效果，提升值为其攻击力的一半（向上取整）
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
-- 装备限制效果的判定函数：仅允许自身装备
function c27548199.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 无效效果发动时的触发条件：对方发动效果且此卡未在战斗阶段被破坏、该连锁可被无效
function c27548199.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 对方发动效果且此卡未在战斗阶段被破坏、该连锁可被无效
	return rp==1-tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
-- 无效效果发动时的消耗：移除1个枪管指示物作为代价
function c27548199.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x4b,1,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x4b,1,REASON_COST)
end
-- 无效效果发动时的目标设定：设置将要无效的连锁对象
function c27548199.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息，表示将使发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 无效效果发动时的操作函数：使指定连锁发动无效
function c27548199.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 执行连锁无效操作
	Duel.NegateActivation(ev)
end

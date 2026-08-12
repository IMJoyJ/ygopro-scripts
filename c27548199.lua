--ヴァレルロード・S・ドラゴン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡同调召唤成功的场合才能发动。从自己墓地选1只连接怪兽当作装备卡使用给这张卡装备，那个连接标记数量的枪管指示物给这张卡放置。
-- ②：这张卡的攻击力上升这张卡的效果装备的怪兽的攻击力一半数值。
-- ③：对方的效果发动时，把这张卡1个枪管指示物取除才能发动。那个发动无效。
function c27548199.initial_effect(c)
	c:EnableCounterPermit(0x4b)
	-- 为这张卡添加同调召唤手续：素材为调整＋调整以外的怪兽1只以上
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
	-- 这个卡名的③的效果1回合只能使用1次。③：对方的效果发动时，把这张卡1个枪管指示物取除才能发动。那个发动无效。
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
-- 效果发动条件：这张卡是同调召唤成功时才能发动
function c27548199.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 装备对象过滤条件：连接怪兽、在场上不与其他同名卡冲突、未被禁止装备，且这张卡能放置该连接标记数量的枪管指示物
function c27548199.eqfilter(c,tp,mc)
	return c:IsType(TYPE_LINK) and c:CheckUniqueOnField(tp) and not c:IsForbidden() and mc:IsCanAddCounter(0x4b,c:GetLink())
end
-- 效果发动对象检测：确认自己魔陷区有空位，且墓地存在满足条件的连接怪兽
function c27548199.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检测自己魔陷区（含场地区）是否有可用空格以放置装备卡
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检测自己墓地是否存在至少1只满足条件的连接怪兽
		and Duel.IsExistingMatchingCard(c27548199.eqfilter,tp,LOCATION_GRAVE,0,1,nil,tp,e:GetHandler()) end
	-- 设置操作信息：该效果处理会将1张卡从墓地离开（用于王家长眠之谷等检测）
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,0)
end
-- 效果处理：从自己墓地选1只连接怪兽当作装备卡给这张卡装备，放置其连接标记数量的枪管指示物，并赋予这张卡上升装备怪兽攻击力一半数值的攻击力
function c27548199.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若自己魔陷区没有空格则中止处理
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 向玩家提示「请选择要装备的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让自己玩家从自己墓地选择1只满足条件且不受王家长眠之谷影响的连接怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c27548199.eqfilter),tp,LOCATION_GRAVE,0,1,1,nil,tp,c)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的怪兽当作装备卡给这张卡装备，装备失败则中止处理
		if not Duel.Equip(tp,tc,c) then return end
		local lk=tc:GetLink()
		if lk>0 then
			c:AddCounter(0x4b,lk)
		end
		-- ①：从自己墓地选1只连接怪兽当作装备卡使用给这张卡装备（限定只能装备给这张卡）
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c27548199.eqlimit)
		tc:RegisterEffect(e1)
		local atk=tc:GetAttack()
		if atk>0 then
			-- ②：这张卡的攻击力上升这张卡的效果装备的怪兽的攻击力一半数值。
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
-- 装备限制：该装备卡只能装备给这张卡（效果持有者）
function c27548199.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 效果发动条件：对方发动效果时，且这张卡未被战斗破坏、该连锁的发动可以被无效
function c27548199.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 发动者是对方玩家，这张卡不处于被战斗破坏状态，且该连锁的发动可以被无效
	return rp==1-tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
-- 发动代价：把这张卡1个枪管指示物取除
function c27548199.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,0x4b,1,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,0x4b,1,REASON_COST)
end
-- 效果目标设定：无需检测，设置操作信息为将对方发动的1个效果无效
function c27548199.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：将对方发动的那1个效果的发动无效（CATEGORY_NEGATE）
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 效果处理：使对方那个效果的发动无效
function c27548199.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使该连锁的发动无效
	Duel.NegateActivation(ev)
end

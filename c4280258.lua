--召命の神弓－アポロウーサ
-- 效果：
-- 衍生物以外的卡名不同的怪兽2只以上
-- ①：「召命之神弓-阿波罗萨」在自己场上只能有1张表侧表示存在。
-- ②：这张卡的原本攻击力变成作为这张卡的连接素材的怪兽数量×800。
-- ③：对方把怪兽的效果发动时才能发动（同一连锁上最多1次）。这张卡的攻击力下降800，那个发动无效。
function c4280258.initial_effect(c)
	c:SetUniqueOnField(1,0,4280258)
	-- 为这张卡设置连接召唤手续：必须以衍生物以外的卡名不同的怪兽2只以上作为连接素材（素材上限99只），lcheck函数额外确保素材之间卡名各不相同。
	aux.AddLinkProcedure(c,aux.NOT(aux.FilterBoolFunction(Card.IsLinkType,TYPE_TOKEN)),2,99,c4280258.lcheck)
	c:EnableReviveLimit()
	-- ②：这张卡的原本攻击力变成作为这张卡的连接素材的怪兽数量×800。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MATERIAL_CHECK)
	e1:SetValue(c4280258.matcheck)
	c:RegisterEffect(e1)
	-- ③：对方把怪兽的效果发动时才能发动（同一连锁上最多1次）。这张卡的攻击力下降800，那个发动无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(4280258,0))
	e2:SetCategory(CATEGORY_NEGATE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e2:SetCondition(c4280258.condition)
	e2:SetTarget(c4280258.target)
	e2:SetOperation(c4280258.operation)
	c:RegisterEffect(e2)
end
-- 校验连接素材组g：按Card.GetLinkCode分类计数，若种类数等于卡数则说明素材中卡名各不相同，满足‘卡名不同的怪兽’的素材条件。
function c4280258.lcheck(g,lc)
	return g:GetClassCount(Card.GetLinkCode)==g:GetCount()
end
-- 素材检查：根据这张卡实际使用的连接素材数量，为这张卡注册一个将原本攻击力变为‘素材数量×800’的效果，以实现②的效果。
function c4280258.matcheck(e,c)
	local ct=c:GetMaterialCount()
	-- 为这张卡赋予原本攻击力变为素材数量×800的效果，即②效果的永久适用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetValue(ct*800)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_DISABLE)
	c:RegisterEffect(e1)
end
-- ③效果的发动脉冲：仅当对方发动怪兽效果且该效果发动可以被无效、这张卡未被战斗破坏确定时，才可能发动。
function c4280258.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 返回真需同时满足：对方玩家发动效果（ep==1-tp）、发动的是怪兽效果（re:IsActiveType(TYPE_MONSTER)）、且该连锁发动的效果可以被无效（Duel.IsChainNegatable(ev)）。
	return ep==1-tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
		and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
-- ③效果发动时的目标判断：确认此卡当前攻击力不低于800；满足后登记要无效的对象为对方发动的怪兽效果。
function c4280258.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAttackAbove(800) end
	-- 将本次效果处理登记为无效发动的操作（CATEGORY_NEGATE），对象为eg中对方发动效果的那张怪兽卡，数量1。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- ③效果处理前的最终校验：这张卡必须表侧表示、与效果仍有关联、攻击力≥800、当前处理的连锁确实是对应目标发动的下一连锁、且未被战斗破坏确定，否则直接不处理。
function c4280258.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) or c:GetAttack()<800
		-- 额外校验条件：当前连锁序号不等于目标发动连锁的下一链（Duel.GetCurrentChain()!=ev+1），或这张卡处于战斗破坏确定状态（STATUS_BATTLE_DESTROYED），满足任一则中止处理。
		or Duel.GetCurrentChain()~=ev+1 or c:IsStatus(STATUS_BATTLE_DESTROYED) then
		return
	end
	-- ③：这张卡的攻击力下降800。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	e1:SetValue(-800)
	c:RegisterEffect(e1)
	if not c:IsHasEffect(EFFECT_REVERSE_UPDATE) then
		-- 将对方那次效果发动无效化（Duel.NegateActivation(ev)），使该发动无效；若此卡带有EFFECT_REVERSE_UPDATE效果则不会执行到此步。
		Duel.NegateActivation(ev)
	end
end

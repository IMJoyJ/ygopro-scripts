--召命の神弓－アポロウーサ
-- 效果：
-- 衍生物以外的卡名不同的怪兽2只以上
-- ①：「召命之神弓-阿波罗萨」在自己场上只能有1张表侧表示存在。
-- ②：这张卡的原本攻击力变成作为这张卡的连接素材的怪兽数量×800。
-- ③：对方把怪兽的效果发动时才能发动（同一连锁上最多1次）。这张卡的攻击力下降800，那个发动无效。
function c4280258.initial_effect(c)
	c:SetUniqueOnField(1,0,4280258)
	-- 添加连接召唤手续，要求连接素材必须是衍生物以外且卡名不同的怪兽，最少2只，最多99只
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
-- 连接素材的卡名必须各不相同
function c4280258.lcheck(g,lc)
	return g:GetClassCount(Card.GetLinkCode)==g:GetCount()
end
-- 根据连接素材数量设置自身原本攻击力为素材数量乘以800
function c4280258.matcheck(e,c)
	local ct=c:GetMaterialCount()
	-- 设置自身原本攻击力
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetValue(ct*800)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_DISABLE)
	c:RegisterEffect(e1)
end
-- 判断是否为对方怪兽效果发动且可无效
function c4280258.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 对方怪兽效果发动且可无效
	return ep==1-tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
		and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 检查自身攻击力是否大于等于800以满足发动条件
function c4280258.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAttackAbove(800) end
	-- 设置连锁操作信息为使发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 判断是否满足效果发动条件，包括自身表侧表示、有足够攻击力、连锁顺序正确等
function c4280258.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) or c:GetAttack()<800
		-- 连锁顺序不正确或自身已被战斗破坏
		or Duel.GetCurrentChain()~=ev+1 or c:IsStatus(STATUS_BATTLE_DESTROYED) then
		return
	end
	-- 使自身攻击力下降800
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	e1:SetValue(-800)
	c:RegisterEffect(e1)
	if not c:IsHasEffect(EFFECT_REVERSE_UPDATE) then
		-- 使当前连锁的发动无效
		Duel.NegateActivation(ev)
	end
end

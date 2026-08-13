--トゥーン・テラー
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有「卡通世界」以及卡通怪兽存在，怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
function c53094821.initial_effect(c)
	-- 为这张卡注册关联卡名列表，记录它关联的卡名「卡通世界」（密码15259703），用于后续规则判断。
	aux.AddCodeList(c,15259703)
	-- 对应效果原文：这个卡名的卡在1回合只能发动1张。①：自己场上有「卡通世界」以及卡通怪兽存在，怪兽的效果·魔法·陷阱卡发动时才能发动。那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,53094821+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c53094821.condition)
	e1:SetTarget(c53094821.target)
	e1:SetOperation(c53094821.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件1：用于筛选自己场上表侧表示且卡名为「卡通世界」的卡。
function c53094821.cfilter1(c)
	return c:IsFaceup() and c:IsCode(15259703)
end
-- 过滤条件2：用于筛选自己场上表侧表示的卡通怪兽。
function c53094821.cfilter2(c)
	return c:IsFaceup() and c:IsType(TYPE_TOON)
end
-- 发动条件：满足双方连锁中存在怪兽效果或魔法·陷阱卡的发动且该发动可以被无效，并且自己场上有表侧表示的「卡通世界」和卡通怪兽。
function c53094821.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断发动的是否是怪兽效果或魔法·陷阱卡（即魔陷卡片的发动），并确认该连锁的发动可以被无效。
	return (re:IsActiveType(TYPE_MONSTER) or re:IsHasType(EFFECT_TYPE_ACTIVATE)) and Duel.IsChainNegatable(ev)
		-- 确认自己场上存在表侧表示的「卡通世界」。
		and Duel.IsExistingMatchingCard(c53094821.cfilter1,tp,LOCATION_ONFIELD,0,1,nil)
		-- 确认自己场上存在表侧表示的卡通怪兽。
		and Duel.IsExistingMatchingCard(c53094821.cfilter2,tp,LOCATION_MZONE,0,1,nil)
end
-- 发动时的目标/效果设定：宣告将要无效并破坏的对象，同时为后续处理登记操作信息。
function c53094821.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记操作信息：将当前连锁的发动对象视为「无效发动」（CATEGORY_NEGATE）的处理对象。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsRelateToEffect(re) and re:GetHandler():IsDestructable() then
		-- 登记操作信息：若发动的那张卡仍与效果相关且可被破坏，则同时将其视为破坏（CATEGORY_DESTROY）的对象。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理的实际操作：让该连锁的发动无效，并将因此被无效的卡破坏。
function c53094821.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 处理判定：只有发动无效成功，且被无效的那张卡仍与连锁效果相关联时，才继续执行破坏。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 以效果原因将引发连锁的那张卡（eg）破坏。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end

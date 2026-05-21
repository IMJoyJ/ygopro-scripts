--連鎖空穴
-- 效果：
-- ①：对方连锁魔法·陷阱·怪兽的效果的发动把怪兽的效果发动时才能发动。那个效果无效。那之后，对方可以从手卡·卡组选原本卡名和用这个效果无效的卡相同的1张卡除外。没有除外的场合，自己可以把对方手卡随机选1张除外。
function c9581215.initial_effect(c)
	-- ①：对方连锁魔法·陷阱·怪兽的效果的发动把怪兽的效果发动时才能发动。那个效果无效。那之后，对方可以从手卡·卡组选原本卡名和用这个效果无效的卡相同的1张卡除外。没有除外的场合，自己可以把对方手卡随机选1张除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c9581215.condition)
	e1:SetTarget(c9581215.target)
	e1:SetOperation(c9581215.activate)
	c:RegisterEffect(e1)
end
-- 定义发动条件函数，判断是否满足发动时点
function c9581215.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前连锁数大于1、由对方发动、是怪兽效果且该效果可以被无效
	return ev>1 and rp==1-tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainDisablable(ev)
end
-- 定义效果的目标确认函数
function c9581215.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，表明此效果包含使效果无效的操作
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 定义过滤函数，筛选出对方手卡或卡组中与被无效卡原本卡名相同的可除外卡
function c9581215.rmfilter(c,p,tc)
	return c:IsAbleToRemove(p) and c:IsOriginalCodeRule(tc:GetOriginalCodeRule())
end
-- 定义效果处理函数，执行无效效果及后续的除外处理
function c9581215.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 使该连锁的效果无效，若无效失败则结束处理
	if not Duel.NegateEffect(ev) then return end
	-- 中断效果处理，使后续的除外处理与无效处理不同时进行
	Duel.BreakEffect()
	local sel=1
	-- 获取对方手卡和卡组中与被无效卡同名的卡片组
	local g=Duel.GetMatchingGroup(c9581215.rmfilter,tp,0,LOCATION_HAND+LOCATION_DECK,nil,1-tp,eg:GetFirst())
	-- 获取对方手卡中可以被除外的卡片组
	local tg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_HAND,nil)
	-- 向对方玩家提示选择是否除外同名卡
	Duel.Hint(HINT_SELECTMSG,1-tp,aux.Stringid(9581215,0))  --"是否除外同名卡？"
	if g:GetCount()>0 then
		-- 让对方玩家选择“除外”或“不除外”
		sel=Duel.SelectOption(1-tp,1213,1214)
	else
		-- 若对方没有同名卡，则强制对方选择“不除外”
		sel=Duel.SelectOption(1-tp,1214)+1
	end
	if sel==0 then
		-- 向对方玩家提示选择要除外的卡片
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local sg=g:Select(1-tp,1,1,nil)
		-- 将对方选择的同名卡表侧表示除外
		Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
	-- 若对方没有除外同名卡且手卡有卡，询问自己是否除外对方手卡
	elseif #tg>0 and Duel.SelectYesNo(tp,aux.Stringid(9581215,1)) then  --"是否除外对方手卡？"
		local sg=tg:RandomSelect(tp,1)
		-- 将随机选出的对方手卡表侧表示除外
		Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
	end
end

--リプロドクス
-- 效果：
-- 怪兽2只
-- 这个卡名的效果1回合只能使用1次。
-- ①：可以从以下效果选择1个发动。
-- ●宣言1个种族才能发动。这张卡所连接区的全部表侧表示怪兽的种族直到回合结束时变成宣言的种族。
-- ●宣言1个属性才能发动。这张卡所连接区的全部表侧表示怪兽的属性直到回合结束时变成宣言的属性。
function c34989413.initial_effect(c)
	-- 为复制梁龙添加连接召唤手续：需要2只任意怪兽作为连接素材（素材种类不限）。
	aux.AddLinkProcedure(c,nil,2,2)
	c:EnableReviveLimit()
	-- 对应效果原文：这个卡名的效果1回合只能使用1次。①：可以从以下效果选择1个发动。●宣言1个种族才能发动。这张卡所连接区的全部表侧表示怪兽的种族直到回合结束时变成宣言的种族。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(34989413,0))  --"改变种族"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,34989413)
	e1:SetTarget(c34989413.ractg)
	e1:SetOperation(c34989413.racop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetDescription(aux.Stringid(34989413,1))  --"改变属性"
	e2:SetTarget(c34989413.atttg)
	e2:SetOperation(c34989413.attop)
	c:RegisterEffect(e2)
end
-- 定义筛选函数：目标必须是表侧表示怪兽，且处于这张卡的连接区域内。
function c34989413.filter(c,g)
	return c:IsFaceup() and g:IsContains(c)
end
-- 种族改变效果的发动条件与目标处理：检查场上是否存在位于连接区的表侧表示怪兽；若满足，则让玩家宣言1个种族，并将宣言的种族存入效果的Label。
function c34989413.ractg(e,tp,eg,ep,ev,re,r,rp,chk)
	local lg=e:GetHandler():GetLinkedGroup()
	-- 判定效果能否发动：必须存在至少1只位于这张卡连接区的表侧表示怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c34989413.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,lg) end
	-- 向玩家发出“请选择要宣言的种族”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)  --"请选择要宣言的种族"
	-- 让当前玩家从全部种族中宣言1个种族，并将宣言结果存入变量rac。
	local rac=Duel.AnnounceRace(tp,1,RACE_ALL)
	e:SetLabel(rac)
end
-- 种族改变效果处理：若这张卡仍与效果相关，则获取其连接区的全部表侧表示怪兽，为每只怪兽注册一个持续到回合结束的改变种族的效果，数值为之前宣言的种族。
function c34989413.racop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local lg=c:GetLinkedGroup()
	-- 获取这张卡连接区中的全部表侧表示怪兽（作为要改变种族的对象集合）。
	local g=Duel.GetMatchingGroup(c34989413.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,lg)
	local tc=g:GetFirst()
	while tc do
		-- 对应效果原文：这张卡所连接区的全部表侧表示怪兽的种族直到回合结束时变成宣言的种族。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_RACE)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
-- 属性改变效果的发动条件与目标处理：检查场上是否存在位于连接区的表侧表示怪兽；若满足，则让玩家宣言1个属性，并将宣言的属性存入效果的Label。
function c34989413.atttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local lg=e:GetHandler():GetLinkedGroup()
	-- 判定效果能否发动：必须存在至少1只位于这张卡连接区的表侧表示怪兽，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c34989413.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,lg) end
	-- 向玩家发出“请选择要宣言的属性”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
	-- 让当前玩家从全部属性中宣言1个属性，并将宣言结果存入变量att。
	local att=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL)
	e:SetLabel(att)
end
-- 属性改变效果处理：若这张卡仍与效果相关，则获取其连接区的全部表侧表示怪兽，为每只怪兽注册一个持续到回合结束的改变属性的效果，数值为之前宣言的属性。
function c34989413.attop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local lg=c:GetLinkedGroup()
	-- 获取这张卡连接区中的全部表侧表示怪兽（作为要改变属性的对象集合）。
	local g=Duel.GetMatchingGroup(c34989413.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,lg)
	local tc=g:GetFirst()
	while tc do
		-- 对应效果原文：这张卡所连接区的全部表侧表示怪兽的属性直到回合结束时变成宣言的属性。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end

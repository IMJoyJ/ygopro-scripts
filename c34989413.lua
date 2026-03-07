--リプロドクス
-- 效果：
-- 怪兽2只
-- 这个卡名的效果1回合只能使用1次。
-- ①：可以从以下效果选择1个发动。
-- ●宣言1个种族才能发动。这张卡所连接区的全部表侧表示怪兽的种族直到回合结束时变成宣言的种族。
-- ●宣言1个属性才能发动。这张卡所连接区的全部表侧表示怪兽的属性直到回合结束时变成宣言的属性。
function c34989413.initial_effect(c)
	-- 添加连接召唤手续，需要2个连接素材
	aux.AddLinkProcedure(c,nil,2,2)
	c:EnableReviveLimit()
	-- ①：可以从以下效果选择1个发动。
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
-- 过滤函数，检查怪兽是否为表侧表示且在连接组中
function c34989413.filter(c,g)
	return c:IsFaceup() and g:IsContains(c)
end
-- 种族选择阶段，检查是否有连接区的表侧表示怪兽
function c34989413.ractg(e,tp,eg,ep,ev,re,r,rp,chk)
	local lg=e:GetHandler():GetLinkedGroup()
	-- 检查是否存在满足条件的连接区怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c34989413.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,lg) end
	-- 提示玩家选择种族
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RACE)  --"请选择要宣言的种族"
	-- 让玩家宣言一个种族
	local rac=Duel.AnnounceRace(tp,1,RACE_ALL)
	e:SetLabel(rac)
end
-- 种族变更效果的处理函数，为连接区怪兽变更种族
function c34989413.racop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local lg=c:GetLinkedGroup()
	-- 获取连接区中满足条件的怪兽组
	local g=Duel.GetMatchingGroup(c34989413.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,lg)
	local tc=g:GetFirst()
	while tc do
		-- 为怪兽设置种族变更效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_RACE)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
-- 属性选择阶段，检查是否有连接区的表侧表示怪兽
function c34989413.atttg(e,tp,eg,ep,ev,re,r,rp,chk)
	local lg=e:GetHandler():GetLinkedGroup()
	-- 检查是否存在满足条件的连接区怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c34989413.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,lg) end
	-- 提示玩家选择属性
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
	-- 让玩家宣言一个属性
	local att=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL)
	e:SetLabel(att)
end
-- 属性变更效果的处理函数，为连接区怪兽变更属性
function c34989413.attop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local lg=c:GetLinkedGroup()
	-- 获取连接区中满足条件的怪兽组
	local g=Duel.GetMatchingGroup(c34989413.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,lg)
	local tc=g:GetFirst()
	while tc do
		-- 为怪兽设置属性变更效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end

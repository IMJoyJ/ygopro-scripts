--A－GMX最終検証
-- 效果：
-- 自己场上有「GMX」怪兽存在的场合才能把这张卡发动。
-- 1回合1次，对方把怪兽的效果在场上发动时（伤害步骤除外）：可以从自己卡组上面把5张卡翻开，那之后，翻到「GMX」卡的场合，那个发动的效果无效，翻开的卡用喜欢的顺序回到卡组上面或下面。
local s,id,o=GetID()
-- 注册卡的发动效果和诱发效果
function s.initial_effect(c)
	-- 自己场上有「GMX」怪兽存在的场合才能把这张卡发动。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCondition(s.actcon)
	c:RegisterEffect(e0)
	-- 1回合1次，对方把怪兽的效果在场上发动时（伤害步骤除外）：可以从自己卡组上面把5张卡翻开，那之后，翻到「GMX」卡的场合，那个发动的效果无效，翻开的卡用喜欢的顺序回到卡组上面或下面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"翻卡"
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.negcon)
	e1:SetTarget(s.negtg)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
end
-- 判断是否为「GMX」怪兽
function s.gmxm(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x1dd)
end
-- 检查自己场上是否存在「GMX」怪兽
function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在「GMX」怪兽
	return Duel.IsExistingMatchingCard(s.gmxm,tp,LOCATION_MZONE,0,1,nil,tp)
end
-- 判断连锁是否满足无效条件
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁发动位置
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	-- 对方在怪兽区域发动怪兽效果且该效果可被无效
	return ep~=tp and loc==LOCATION_MZONE and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainDisablable(ev)
end
-- 设置发动时的判定条件
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己卡组数量不少于5张
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=5 end
end
-- 判断是否为「GMX」卡
function s.gmxfilter(c)
	return c:IsSetCard(0x1dd)
end
-- 处理效果发动后的操作
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组最上方5张卡
	local g=Duel.GetDecktopGroup(tp,5)
	if g:GetCount()==0 then return end
	-- 确认自己卡组最上方5张卡
	Duel.ConfirmDecktop(tp,5)
	if e:GetHandler():IsSetCard(0x1dd) then
		-- 触发自定义事件
		Duel.RaiseEvent(e:GetHandler(),EVENT_CUSTOM+1595137,e,0,tp,tp,0)
	end
	-- 中断当前效果处理
	Duel.BreakEffect()
	local flag=g:IsExists(s.gmxfilter,1,nil)
	-- 若翻开的卡中有「GMX」卡则无效对方发动的效果
	if flag then Duel.NegateEffect(ev) end
	local ct=g:GetCount()
	-- 选择将翻开的卡放回卡组上方或下方
	local op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))  --"回到卡组上面/回到卡组下面"
	-- 根据选择对翻开的卡进行排序
	Duel.SortDecktop(tp,tp,ct)
	if op==0 then return end
	for i=1,ct do
		-- 获取卡组最上方一张卡
		local mg=Duel.GetDecktopGroup(tp,1)
		-- 将卡移至卡组底部
		Duel.MoveSequence(mg:GetFirst(),SEQ_DECKBOTTOM)
	end
end

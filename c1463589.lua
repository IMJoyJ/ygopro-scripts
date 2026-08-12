--A－GMX最終検証
-- 效果：
-- 自己场上有「基因组混合」怪兽存在的场合才能把这张卡发动。
-- ①：1回合1次，对方把场上的怪兽的效果发动时才能发动。从自己卡组上面把5张卡翻开，那之中有「基因组混合」卡的场合，那个发动的效果无效。翻开的卡在卡组上面或下面用喜欢的顺序回去。
local s,id,o=GetID()
-- 注册两个效果：e0为卡的发动（自由时点，需满足自己场上有「基因组混合」怪兽的发动条件），e1为场上诱发即时的无效效果（1回合1次，对方场上怪兽效果发动时才能发动）
function s.initial_effect(c)
	-- 自己场上有「基因组混合」怪兽存在的场合才能把这张卡发动。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCondition(s.actcon)
	c:RegisterEffect(e0)
	-- ①：1回合1次，对方把场上的怪兽的效果发动时才能发动。从自己卡组上面把5张卡翻开，那之中有「基因组混合」卡的场合，那个发动的效果无效。翻开的卡在卡组上面或下面用喜欢的顺序回去。
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
-- 过滤函数：检查卡是否为表侧表示的「基因组混合」怪兽
function s.gmxm(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x1dd)
end
-- 发动条件：自己场上存在至少1只表侧表示的「基因组混合」怪兽
function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己怪兽区域是否存在至少1只满足条件的「基因组混合」怪兽
	return Duel.IsExistingMatchingCard(s.gmxm,tp,LOCATION_MZONE,0,1,nil,tp)
end
-- 无效效果的发动条件：对方把场上怪兽的效果发动，且该连锁可以被无效
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取该连锁效果发动时所在的位置
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	-- 判断是否为对方发动的、发生在怪兽区域的怪兽效果，且该连锁可以被无效
	return ep~=tp and loc==LOCATION_MZONE and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainDisablable(ev)
end
-- 对象选取检查：自己卡组的卡数量在5张以上才能发动
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组的卡数量是否在5张以上
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=5 end
end
-- 过滤函数：检查卡是否为「基因组混合」卡
function s.gmxfilter(c)
	return c:IsSetCard(0x1dd)
end
-- 效果处理：翻开自己卡组上面5张卡，其中有「基因组混合」卡的场合使那个效果无效，之后让玩家选择把翻开的卡按喜欢的顺序回到卡组上面或下面
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得自己卡组最上方的5张卡
	local g=Duel.GetDecktopGroup(tp,5)
	if g:GetCount()==0 then return end
	-- 翻开（确认）自己卡组最上方的5张卡
	Duel.ConfirmDecktop(tp,5)
	if e:GetHandler():IsSetCard(0x1dd) then
		-- 若自身是「基因组混合」卡，则触发自定义事件（用于联动其他卡的效果）
		Duel.RaiseEvent(e:GetHandler(),EVENT_CUSTOM+1595137,e,0,tp,tp,0)
	end
	-- 中断当前效果处理，使之后的无效处理与翻卡视为不同时处理
	Duel.BreakEffect()
	local flag=g:IsExists(s.gmxfilter,1,nil)
	-- 若翻开的卡中有「基因组混合」卡，则使那个发动的效果无效
	if flag then Duel.NegateEffect(ev) end
	local ct=g:GetCount()
	-- 让玩家选择把翻开的卡回到卡组上面还是回到卡组下面
	local op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))  --"回到卡组上面/回到卡组下面"
	-- 让玩家用喜欢的顺序对卡组最上方的这些卡排序放回
	Duel.SortDecktop(tp,tp,ct)
	if op==0 then return end
	for i=1,ct do
		-- 取得当前卡组最上方的1张卡
		local mg=Duel.GetDecktopGroup(tp,1)
		-- 将该卡移动到卡组最下方
		Duel.MoveSequence(mg:GetFirst(),SEQ_DECKBOTTOM)
	end
end

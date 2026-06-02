--Anti-GMX Final Experiment
-- 效果：
-- 自己场上有「GMX」怪兽存在的场合才能把这张卡发动。
-- 1回合1次，对方把怪兽的效果在场上发动时（伤害步骤除外）：可以从自己卡组上面把5张卡翻开，那之后，翻到「GMX」卡的场合，那个发动的效果无效，翻开的卡用喜欢的顺序回到卡组上面或下面。
local s,id,o=GetID()
-- 初始化卡片效果：注册卡片的发动效果，以及注册卡片在魔陷区发动的诱发即时效果。
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
-- 过滤条件：表侧表示且是「GMX」怪兽。
function s.gmxm(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x1dd)
end
-- 判断卡片发动条件是否满足：自己场上是否存在「GMX」怪兽。
function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「GMX」怪兽。
	return Duel.IsExistingMatchingCard(s.gmxm,tp,LOCATION_MZONE,0,1,nil,tp)
end
-- 判断翻卡效果的条件是否满足：对方在场上（怪兽区）发动怪兽效果，且该效果可以被无效。
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前正在处理的连锁的发生位置。
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	-- 判断是否为对方玩家在怪兽区域发动的怪兽效果，且该连锁的效果可以被无效。
	return ep~=tp and loc==LOCATION_MZONE and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainDisablable(ev)
end
-- 效果的发动准备与检查：在效果发动时，判断自己卡组中是否存有至少5张卡。
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时，判断自己卡组的卡片数量是否在5张以上。
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=5 end
end
-- 过滤条件：是「GMX」卡片。
function s.gmxfilter(c)
	return c:IsSetCard(0x1dd)
end
-- 效果的处理：翻开自己卡组最上方的5张卡，如果翻到了「GMX」卡，则使那个发动的效果无效，然后由玩家选择以喜欢的顺序回到卡组最上方或最下方。
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组最上方的5张卡片组成的卡组。
	local g=Duel.GetDecktopGroup(tp,5)
	if g:GetCount()==0 then return end
	-- 向双方玩家确认（翻开）自己卡组最上方的5张卡。
	Duel.ConfirmDecktop(tp,5)
	if e:GetHandler():IsSetCard(0x1dd) then
		-- 触发以这张卡为源头的自定义事件，用于卡片效果的联动判定。
		Duel.RaiseEvent(e:GetHandler(),EVENT_CUSTOM+1595137,e,0,tp,tp,0)
	end
	-- 中断效果处理，使后续的效果处理与之前的操作不视为同时进行。
	Duel.BreakEffect()
	local flag=g:IsExists(s.gmxfilter,1,nil)
	-- 若翻开的卡片中存在「GMX」卡，则使发动的效果无效。
	if flag then Duel.NegateEffect(ev) end
	local ct=g:GetCount()
	-- 让玩家选择“回到卡组上面”或“回到卡组下面”。
	local op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))  --"回到卡组上面/回到卡组下面"
	-- 让玩家对卡组最上方的指定数量的卡片按照喜欢的顺序进行排序。
	Duel.SortDecktop(tp,tp,ct)
	if op==0 then return end
	for i=1,ct do
		-- 获取自己卡组最上方的那1张卡。
		local mg=Duel.GetDecktopGroup(tp,1)
		-- 将选取的卡片放回卡组最下方。
		Duel.MoveSequence(mg:GetFirst(),SEQ_DECKBOTTOM)
	end
end

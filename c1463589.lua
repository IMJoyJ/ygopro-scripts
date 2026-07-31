--A－GMX最終検証
-- 效果：
-- 自己场上有「GMX」怪兽存在的场合才能把这张卡发动。
-- 1回合1次，对方把怪兽的效果在场上发动时（伤害步骤除外）：可以从自己卡组上面把5张卡翻开，那之后，翻到「GMX」卡的场合，那个发动的效果无效，翻开的卡用喜欢的顺序回到卡组上面或下面。
local s,id,o=GetID()
-- 初始化效果 e0，设置类型为发动类型，触发时点为自由连锁，并绑定条件 s.actcon；随后初始化效果 e1，配置描述、类别、类型、触发码、位置限制、次数上限、条件、目标及操作函数。
function s.initial_effect(c)
	-- 对应原文：自己场上有「GMX」怪兽存在的场合才能把这张卡发动。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCondition(s.actcon)
	c:RegisterEffect(e0)
	-- 对应原文：1 回合 1 次，对方把怪兽的效果在场上发动时（伤害步骤除外）：可以从自己卡组上面把 5 张卡翻开，那之后，翻到「GMX」卡的场合，那个发动的效果无效，翻开的卡用喜欢的顺序回到卡组上面或下面。
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
-- 定义辅助函数 s.gmxm，用于判断怪兽是否为正面表示且属于 GMX 系列（SetCard ID=0x1dd）。
function s.gmxm(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x1dd)
end
-- s.actcon 条件函数的主体逻辑：检查玩家 tp 的主要怪兽区是否存在至少 1 张满足 s.gmxm 条件的卡片。
function s.actcon(e,tp,eg,ep,ev,re,r,rp)
	-- IsExistingMatchingCard 函数调用，用于检索指定位置存在的符合条件的卡组数量是否大于等于目标数（此处为 0-4 区域）。
	return Duel.IsExistingMatchingCard(s.gmxm,tp,LOCATION_MZONE,0,1,nil,tp)
end
-- s.negcon 条件函数的主体逻辑：获取触发连锁的位置信息，并综合判断对方玩家、怪兽区发动、怪兽效果类型及可被无效性。
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- GetChainInfo 函数调用，从当前连锁中提取触发位置信息。
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	-- IsChainDisablable 函数结合其他条件的最终返回值表达式，用于确认连锁是否具备被无效的资格。
	return ep~=tp and loc==LOCATION_MZONE and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainDisablable(ev)
end
-- s.negtg 目标函数的主体逻辑：检查卡组顶部的卡组数量是否大于等于 5 张（翻牌前提条件）。
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- GetFieldGroupCount 函数调用，统计玩家 tp 的卡组区域卡片总数。
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>=5 end
end
-- 定义辅助过滤函数 s.gmxfilter，用于后续判断卡组中是否存在 GMX 系列卡片。
function s.gmxfilter(c)
	return c:IsSetCard(0x1dd)
end
-- s.negop 操作函数的主体逻辑：获取并确认卡组顶部的 5 张卡；若翻到 GMX 则触发自定义事件；中断效果处理以错时点；检查是否包含 GMX 决定是否无效连锁；让玩家选择回卡组顶部或底部，并对选中的卡片进行排序和移动。
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	-- GetDecktopGroup 函数调用，获取玩家 tp 的卡组最上方 5 张卡组成的组对象。
	local g=Duel.GetDecktopGroup(tp,5)
	if g:GetCount()==0 then return end
	-- ConfirmDecktop 函数调用，正式确认玩家 tp 卡组顶部的 5 张卡进入翻开状态。
	Duel.ConfirmDecktop(tp,5)
	if e:GetHandler():IsSetCard(0x1dd) then
		-- RaiseEvent 函数调用，为翻到的 GMX 卡片触发自定义事件（EVENT_CUSTOM+1595137），用于后续效果处理或动画表现。
		Duel.RaiseEvent(e:GetHandler(),EVENT_CUSTOM+1595137,e,0,tp,tp,0)
	end
	-- BreakEffect 函数调用，中断当前效果的同步处理流程，使后续的无效判定和排序操作进入错时点状态。
	Duel.BreakEffect()
	local flag=g:IsExists(s.gmxfilter,1,nil)
	-- NegateEffect 函数调用，当卡组中存在 GMX 卡片时将触发连锁的效果标记为无效（对应原文“那个发动的效果无效”）。
	if flag then Duel.NegateEffect(ev) end
	local ct=g:GetCount()
	-- SelectOption 函数调用，让玩家选择翻开的卡是回到卡组顶部还是底部；aux.Stringid(id,1)和 aux.Stringid(id,2)分别对应选项文本。
	local op=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))  --"回到卡组上面/回到卡组下面"
	-- SortDecktop 函数调用，根据玩家的选择对已确认的卡组顶卡片组进行排序（最先选择的在最上方）。
	Duel.SortDecktop(tp,tp,ct)
	if op==0 then return end
	for i=1,ct do
		-- GetDecktopGroup 循环内调用，每次获取当前卡组最上方的单张卡对象。
		local mg=Duel.GetDecktopGroup(tp,1)
		-- MoveSequence 函数结合 SEQ_DECKBOTTOM 常量，将选中的卡移动到卡组底部
		Duel.MoveSequence(mg:GetFirst(),SEQ_DECKBOTTOM)
	end
end

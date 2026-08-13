--灰流うらら
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：包含以下其中任意种效果的魔法·陷阱·怪兽的效果发动时，把这张卡从手卡丢弃才能发动。那个效果无效。
-- ●从卡组把卡加入手卡的效果
-- ●从卡组把怪兽特殊召唤的效果
-- ●从卡组把卡送去墓地的效果
function c14558127.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：包含以下其中任意种效果的魔法·陷阱·怪兽的效果发动时，把这张卡从手卡丢弃才能发动。那个效果无效。●从卡组把卡加入手卡的效果 ●从卡组把怪兽特殊召唤的效果 ●从卡组把卡送去墓地的效果
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,14558127)
	e1:SetCondition(c14558127.discon)
	e1:SetCost(c14558127.discost)
	e1:SetTarget(c14558127.distg)
	e1:SetOperation(c14558127.disop)
	c:RegisterEffect(e1)
end
-- 效果发动条件：检查正在发动的魔法·陷阱·怪兽效果是否含有从卡组把卡加入手卡、从卡组把怪兽特殊召唤、从卡组把卡送去墓地中的任一效果，并且该连锁效果能够被无效，满足时才允许丢弃此卡发动。
function c14558127.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果中关于特殊召唤的操作信息，判断其是否包含特殊召唤分类，并取得其目标位置等参数，供后续判断是否为从卡组特殊召唤。
	local ex2,g2,gc2,dp2,dv2=Duel.GetOperationInfo(ev,CATEGORY_SPECIAL_SUMMON)
	-- 获取当前连锁效果中关于送去墓地的操作信息，判断其是否包含送墓分类，并取得其目标位置等参数，供后续判断是否为从卡组把卡送去墓地。
	local ex3,g3,gc3,dp3,dv3=Duel.GetOperationInfo(ev,CATEGORY_TOGRAVE)
	local ex4=re:IsHasCategory(CATEGORY_DRAW)
	local ex5=re:IsHasCategory(CATEGORY_SEARCH)
	local ex6=re:IsHasCategory(CATEGORY_DECKDES)
	return ((ex2 and bit.band(dv2,LOCATION_DECK)==LOCATION_DECK)
		or (ex3 and bit.band(dv3,LOCATION_DECK)==LOCATION_DECK)
		-- 与前半段条件合并：若效果本身具有抽卡、检索或卡组相关的特殊召唤/送墓分类（ex4/ex5/ex6），且该连锁效果可被无效，则发动条件成立。
		or ex4 or ex5 or ex6) and Duel.IsChainDisablable(ev)
end
-- 发动代价处理：从手卡丢弃这张卡作为发动代价；在代价确认阶段检查此卡可否丢弃，随后将其送入墓地。
function c14558127.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 以“代价+丢弃”的理由将这张卡从手卡送入墓地，实际执行丢弃代价。
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 发动时的目标设定：由于该效果不取对象，目标阶段仅确认可以发动，并设置操作信息，声明将无效当前连锁的效果。
function c14558127.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本次连锁处理将包含无效效果分类，对象为当前发动连锁的触发卡组eg，数量为1，供后续处理或相关卡片判定使用。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
end
-- 效果处理：对当前连锁的那个效果执行无效操作，即实现“那个效果无效”的规则处理。
function c14558127.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使连锁编号ev的效果无效，完成效果无效处理。
	Duel.NegateEffect(ev)
end

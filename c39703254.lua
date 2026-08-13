--トマボー
-- 效果：
-- 场上表侧表示存在的这张卡以外的1只植物族怪兽成为对方的魔法·陷阱卡的效果的对象时才能发动。把自己场上存在的这张卡解放，从自己卡组抽2张卡。
function c39703254.initial_effect(c)
	-- 对应效果原文：场上表侧表示存在的这张卡以外的1只植物族怪兽成为对方的魔法·陷阱卡的效果的对象时才能发动。把自己场上存在的这张卡解放，从自己卡组抽2张卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39703254,0))  --"抽卡"
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c39703254.condition)
	e1:SetCost(c39703254.cost)
	e1:SetTarget(c39703254.target)
	e1:SetOperation(c39703254.operation)
	c:RegisterEffect(e1)
end
-- 发动条件判定：对方玩家发动的魔法·陷阱卡效果必须为取对象效果，且对象是场上表侧表示、种族为植物族的1只怪兽，该对象不能是这张卡本身。
function c39703254.condition(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	if not re:IsActiveType(TYPE_SPELL+TYPE_TRAP) then return false end
	-- 获取当前连锁中对方那张魔法·陷阱卡效果所取的对象卡片组。
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	if not g or g:GetCount()~=1 then return false end
	local tg=g:GetFirst()
	local c=e:GetHandler()
	return tg~=c and tg:IsFaceup() and tg:IsRace(RACE_PLANT)
end
-- 代价函数：先检查此卡是否可解放（chk==0时检查），若可则实际解放此卡作为发动代价。
function c39703254.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 将这张卡解放作为发动代价（REASON_COST）。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 目标设定函数：确认己方可以抽2张卡后，设定效果的对象玩家为己方、抽卡数量为2，并登记操作信息。
function c39703254.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查：若当前玩家不能抽2张卡，则效果无法发动。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 将本次效果的对象玩家设定为当前玩家tp（用于抽卡）。
	Duel.SetTargetPlayer(tp)
	-- 将本次效果的对象参数设定为2，表示抽卡数量。
	Duel.SetTargetParam(2)
	-- 登记操作信息：效果分类为抽卡（CATEGORY_DRAW），目标玩家为tp，抽卡数量为2，无特定对象卡（nil,0）。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理函数：根据先前设定的对象玩家和抽卡数量执行抽卡。
function c39703254.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁中读取对象玩家p和对象参数d（即抽卡数量）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 令玩家p抽取d张卡，抽卡原因为效果（REASON_EFFECT）。
	Duel.Draw(p,d,REASON_EFFECT)
end

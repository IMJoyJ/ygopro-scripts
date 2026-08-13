--プレートクラッシャー
-- 效果：
-- 把自己场上存在的1张表侧表示的永续魔法或者永续陷阱卡送去墓地。给与对方基本分500分伤害。这个效果1回合可以使用最多2次。
function c114932.initial_effect(c)
	-- 把自己场上存在的1张表侧表示的永续魔法或者永续陷阱卡送去墓地。给与对方基本分500分伤害。这个效果1回合可以使用最多2次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(114932,0))  --"伤害"
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(2)
	e1:SetCost(c114932.descost)
	e1:SetTarget(c114932.destg)
	e1:SetOperation(c114932.desop)
	c:RegisterEffect(e1)
end
-- 定义代价筛选条件：卡必须为表侧表示、属于永续魔法或永续陷阱（TYPE_CONTINUOUS），并且可以作为代价送去墓地。
function c114932.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_CONTINUOUS) and c:IsAbleToGraveAsCost()
end
-- 代价函数：先检查是否存在可送去墓地的符合条件的永续魔法/陷阱，若存在则让玩家选择1张，并将该卡送去墓地作为发动代价。
function c114932.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在代价检测阶段，确认自己场上存在至少1张满足条件（表侧表示的永续魔法/永续陷阱且可作为代价）的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c114932.cfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 发出“请选择要送去墓地的卡”的选择提示，并缓存用于选择卡的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从自己场上选择1张满足cfilter条件的表侧表示永续魔法或永续陷阱卡（用于作为代价）。
	local g=Duel.SelectMatchingCard(tp,c114932.cfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 将选择的那张卡送去墓地，作为发动效果所需支付的代价（REASON_COST）。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 目标函数：效果对象为玩家（而非卡），设定目标玩家为对方、伤害数值为500，并登记伤害效果的操作信息，供后续处理与连锁检测使用。
function c114932.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设置为对方（1-tp），表示伤害将作用于对方。
	Duel.SetTargetPlayer(1-tp)
	-- 将当前连锁的对象参数设置为500，表示造成的伤害数值为500。
	Duel.SetTargetParam(500)
	-- 登记操作信息：声明本连锁包含伤害效果（CATEGORY_DAMAGE），目标为对方玩家，伤害值为500。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 效果处理函数：从连锁信息中取得目标玩家和伤害数值，并给予对方对应数值的效果伤害。
function c114932.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中记录的目标玩家和伤害参数，分别赋值给p和d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 给予玩家p（对方）d点（500）效果伤害（REASON_EFFECT）。
	Duel.Damage(p,d,REASON_EFFECT)
end

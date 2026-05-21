--災誕の呪眼
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从卡组把1只「咒眼」怪兽和1张「咒眼」魔法·陷阱卡送去墓地才能发动。从卡组把1张「咒眼」装备魔法卡加入手卡。这个回合，每次自己把「咒眼」卡以外的卡的效果发动让自己失去500基本分。
-- ②：自己对「咒眼」连接怪兽的连接召唤成功的场合，把墓地的这张卡除外才能发动。从自己墓地选1张「咒眼」装备魔法卡给自己场上1只「咒眼」连接怪兽装备。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果（卡组送墓检索装备魔法并附加扣血效果）和②效果（墓地除外给连接怪兽装备墓地装备魔法）
function s.initial_effect(c)
	-- ①：从卡组把1只「咒眼」怪兽和1张「咒眼」魔法·陷阱卡送去墓地才能发动。从卡组把1张「咒眼」装备魔法卡加入手卡。这个回合，每次自己把「咒眼」卡以外的卡的效果发动让自己失去500基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己对「咒眼」连接怪兽的连接召唤成功的场合，把墓地的这张卡除外才能发动。从自己墓地选1张「咒眼」装备魔法卡给自己场上1只「咒眼」连接怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.eqcon)
	-- 设置发动成本为将墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
end
-- 过滤卡组中可以作为发动成本送去墓地的「咒眼」卡片
function s.tgfilter(c)
	return c:IsSetCard(0x129) and c:IsAbleToGraveAsCost()
end
-- 过滤卡组中可以加入手牌的「咒眼」装备魔法卡
function s.thfilter(c)
	return c:IsSetCard(0x129) and c:IsType(TYPE_EQUIP) and c:IsAbleToHand()
end
-- 检查选取的两张卡是否为1只怪兽和1张魔陷，且卡组中仍有可检索的「咒眼」装备魔法卡
function s.gcheck(g,tp)
	-- 检查选取的两张卡是否分别满足“怪兽”和“魔法·陷阱”的条件
	return aux.gfcheck(g,Card.IsType,TYPE_MONSTER,TYPE_SPELL+TYPE_TRAP)
		-- 检查卡组中（排除选作Cost的卡后）是否存在可检索的「咒眼」装备魔法卡
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,g)
end
-- ①效果的发动成本处理：从卡组选1只「咒眼」怪兽和1张「咒眼」魔陷送去墓地
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取卡组中所有符合送墓条件的「咒眼」卡片
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return g:CheckSubGroup(s.gcheck,2,2,tp) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local sg=g:SelectSubGroup(tp,s.gcheck,false,2,2,tp)
	-- 将选定的卡作为发动成本送去墓地
	Duel.SendtoGrave(sg,REASON_COST)
end
-- ①效果的发动目标确认：若未确认Cost，则检查卡组中是否存在可检索的「咒眼」装备魔法卡
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 或者检查卡组中是否存在可检索的「咒眼」装备魔法卡
		or Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理的操作信息为“从卡组将1张卡加入手牌”
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果的效果处理：检索「咒眼」装备魔法卡，并注册“本回合每次发动「咒眼」以外卡片效果自己失去500基本分”的阶段性效果
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张「咒眼」装备魔法卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
	-- 这个回合，每次自己把「咒眼」卡以外的卡的效果发动让自己失去500基本分。②：自己对「咒眼」连接怪兽的连接召唤成功的场合，把墓地的这张卡除外才能发动。从自己墓地选1张「咒眼」装备魔法卡给自己场上1只「咒眼」连接怪兽装备。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAIN_SOLVED)
	e1:SetOperation(s.lpop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册该回合内生效的扣血效果
	Duel.RegisterEffect(e1,tp)
end
-- 扣血效果的具体处理：若发动效果的玩家是自己且该卡不属于「咒眼」字段，则扣除500基本分
function s.lpop(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp and not re:GetHandler():IsSetCard(0x129) then
		-- 让自己失去500基本分
		Duel.SetLP(tp,Duel.GetLP(tp)-500)
	end
end
-- 过滤自己成功连接召唤的「咒眼」连接怪兽
function s.cfilter(c,tp)
	return c:IsType(TYPE_LINK) and c:IsSetCard(0x129) and c:IsSummonType(SUMMON_TYPE_LINK) and c:IsSummonPlayer(tp)
end
-- ②效果的发动条件：自己对「咒眼」连接怪兽的连接召唤成功
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 过滤墓地中可以装备给场上「咒眼」连接怪兽的「咒眼」装备魔法卡
function s.eqfilter(c,tp)
	return c:IsSetCard(0x129) and c:IsType(TYPE_EQUIP) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
		-- 且场上存在可以装备该装备魔法卡的合法怪兽
		and Duel.IsExistingMatchingCard(s.eqtgfilter,tp,LOCATION_MZONE,0,1,nil,c)
end
-- 过滤场上表侧表示、属于「咒眼」字段且是连接怪兽的合法装备对象
function s.eqtgfilter(c,eqc)
	return c:IsFaceup() and c:IsSetCard(0x129) and c:IsType(TYPE_LINK) and eqc:CheckEquipTarget(c)
end
-- ②效果的发动目标确认：检查魔法与陷阱区域是否有空位，且墓地是否存在可装备的「咒眼」装备魔法
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的魔法与陷阱区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 且墓地中存在可装备的「咒眼」装备魔法卡
		and Duel.IsExistingMatchingCard(s.eqfilter,tp,LOCATION_GRAVE,0,1,nil,tp) end
	-- 设置连锁处理的操作信息为“有卡片离开墓地”
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,0)
end
-- ②效果的效果处理：从墓地选择1张「咒眼」装备魔法卡，装备给场上1只「咒眼」连接怪兽
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 再次确认魔法与陷阱区域是否有空位
	if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		-- 提示玩家选择要装备的装备卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
		-- 让玩家从墓地选择1张符合条件的「咒眼」装备魔法卡
		local ec=Duel.SelectMatchingCard(tp,s.eqfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp):GetFirst()
		if ec then
			-- 提示玩家选择要装备的怪兽
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
			-- 让玩家从场上选择1只符合条件的「咒眼」连接怪兽
			local tc=Duel.SelectMatchingCard(tp,s.eqtgfilter,tp,LOCATION_MZONE,0,1,1,nil,ec):GetFirst()
			-- 将选中的装备魔法卡装备给选中的连接怪兽
			Duel.Equip(tp,ec,tc)
		end
	end
end

--コーンフィールド コアトル
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：把这张卡从手卡丢弃才能发动。把「玉米田蛇神」以外的有「合成兽融合」的卡名记述的1只怪兽从卡组加入手卡。
-- ②：这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
-- ③：自己场上有「有翼幻兽 奇美拉」存在，自己场上的卡为对象的效果由对方发动时，把场上·墓地的这张卡除外才能发动。那个效果无效并破坏。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数。
function s.initial_effect(c)
	-- 注册该卡记述了「合成兽融合」（卡号63136489）的卡名。
	aux.AddCodeList(c,63136489)
	-- ②：这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(s.indtg)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ①：把这张卡从手卡丢弃才能发动。把「玉米田蛇神」以外的有「合成兽融合」的卡名记述的1只怪兽从卡组加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.cost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ③：自己场上有「有翼幻兽 奇美拉」存在，自己场上的卡为对象的效果由对方发动时，把场上·墓地的这张卡除外才能发动。那个效果无效并破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_GRAVE+LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.discon)
	-- 设置发动代价为将场上或墓地的这张卡除外。
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.distg)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
end
-- 战斗不破效果的目标过滤函数，确定不被破坏的卡为自身以及与自身战斗的怪兽。
function s.indtg(e,c)
	local tc=e:GetHandler()
	return c==tc or c==tc:GetBattleTarget()
end
-- 效果①的发动代价：从手卡丢弃这张卡。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 作为发动代价将这张卡丢弃送去墓地。
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 检索怪兽的过滤条件：怪兽卡、记述了「合成兽融合」卡名、能加入手卡、且不是同名卡。
function s.filter(c)
	-- 检查卡片是否为「玉米田蛇神」以外的有「合成兽融合」卡名记述的怪兽且能加入手卡。
	return c:IsType(TYPE_MONSTER) and aux.IsCodeListed(c,63136489) and c:IsAbleToHand() and not c:IsCode(id)
end
-- 效果①的发动准备与合法性检测（Target阶段）。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足检索条件的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息：从卡组将1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理（Operation阶段）：从卡组检索怪兽加入手卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家从卡组选择1张满足过滤条件的卡。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡加入手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 场上存在「有翼幻兽 奇美拉」（卡号4796100）的过滤条件。
function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(4796100)
end
-- 检查被对象卡片是否在自己场上。
function s.dfilter(c,tp)
	return c:IsOnField() and c:IsControler(tp)
end
-- 效果③的发动条件检测：对方发动效果、自身未被战斗破坏、场上有「有翼幻兽 奇美拉」存在、且该效果取了对象。
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		-- 检查自己场上是否存在「有翼幻兽 奇美拉」。
		or not Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
		or not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁中被选为对象的卡片组。
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 确认被对象卡片中包含自己场上的卡，且该连锁效果可以被无效。
	return g and g:IsExists(s.dfilter,1,nil,tp) and Duel.IsChainDisablable(ev)
end
-- 效果③的发动准备与合法性检测（Target阶段）。
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理信息：使该效果无效。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	local rc=re:GetHandler()
	if rc:IsDestructable() and rc:IsRelateToEffect(re) then
		-- 设置效果处理信息：如果发动效果的卡可以被破坏，则将其破坏。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果③的效果处理（Operation阶段）：无效并破坏对方发动的效果。
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 成功无效该效果，且发动效果的卡在场上（或与效果相关联）时。
	if Duel.NegateEffect(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏该发动效果的卡。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end

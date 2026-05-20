--ZW－獣王獅子武装
-- 效果：
-- 5星怪兽×2
-- 这张卡不能直接攻击。1回合1次，可以通过把这张卡1个超量素材取除，从卡组把1只名字带有「异热同心武器」的怪兽加入手卡。此外，场上的这只怪兽可以当作攻击力上升3000的装备卡使用给自己场上的名字带有「希望皇 霍普」的怪兽装备。装备怪兽攻击过的战斗阶段中，可以通过把装备的这张卡送去墓地，那次战斗阶段中，装备怪兽向对方怪兽只再1次可以攻击。
function c60992364.initial_effect(c)
	-- 添加XYZ召唤手续：需要2只5星怪兽
	aux.AddXyzProcedure(c,nil,5,2)
	c:EnableReviveLimit()
	-- 这张卡不能直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	c:RegisterEffect(e1)
	-- 1回合1次，可以通过把这张卡1个超量素材取除，从卡组把1只名字带有「异热同心武器」的怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetDescription(aux.Stringid(60992364,0))  --"卡组检索"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c60992364.cost)
	e2:SetTarget(c60992364.target)
	e2:SetOperation(c60992364.operation)
	c:RegisterEffect(e2)
	-- 此外，场上的这只怪兽可以当作攻击力上升3000的装备卡使用给自己场上的名字带有「希望皇 霍普」的怪兽装备。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(60992364,1))  --"变成装备"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCategory(CATEGORY_EQUIP)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(c60992364.eqtg)
	e3:SetOperation(c60992364.eqop)
	c:RegisterEffect(e3)
	-- 装备怪兽攻击过的战斗阶段中，可以通过把装备的这张卡送去墓地，那次战斗阶段中，装备怪兽向对方怪兽只再1次可以攻击。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(60992364,2))  --"多次攻击"
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(c60992364.atcon)
	e4:SetCost(c60992364.atcost)
	e4:SetTarget(c60992364.attg)
	e4:SetOperation(c60992364.atop)
	c:RegisterEffect(e4)
end
-- 检索效果的Cost：检查并取除这张卡的1个超量素材
function c60992364.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤卡组中名字带有「异热同心武器」的怪兽
function c60992364.thfilter(c)
	return c:IsSetCard(0x107e) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 检索效果的Target：检查卡组中是否存在可检索的怪兽，并设置操作信息为将卡加入手卡
function c60992364.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足条件的「异热同心武器」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c60992364.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的Operation：从卡组选择1只「异热同心武器」怪兽加入手卡并给对方确认
function c60992364.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足条件的「异热同心武器」怪兽
	local g=Duel.SelectMatchingCard(tp,c60992364.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤场上表侧表示的名字带有「希望皇 霍普」的怪兽
function c60992364.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x107f)
end
-- 装备效果的Target：检查魔法与陷阱区域是否有空位，并选择场上1只「希望皇 霍普」怪兽作为效果对象
function c60992364.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c60992364.filter(chkc) end
	-- 检查自己的魔法与陷阱区域是否有可用的空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己场上是否存在可以作为装备对象的名字带有「希望皇 霍普」的怪兽
		and Duel.IsExistingTarget(c60992364.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只名字带有「希望皇 霍普」的怪兽作为效果对象
	Duel.SelectTarget(tp,c60992364.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 装备效果的Operation：将自身作为装备卡装备给目标怪兽，若不满足装备条件则送去墓地
function c60992364.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 获取效果发动的目标怪兽（即被装备的「希望皇 霍普」怪兽）
	local tc=Duel.GetFirstTarget()
	-- 检查魔法与陷阱区是否有空位，以及目标怪兽是否仍满足装备条件（在自己场上、表侧表示、与效果相关联）
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsControler(1-tp) or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		-- 将这张卡送去墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	c60992364.zw_equip_monster(c,tp,tc)
end
-- 执行装备操作，并为装备卡添加装备限制和攻击力上升3000的效果
function c60992364.zw_equip_monster(c,tp,tc)
	-- 将这张卡作为装备卡装备给目标怪兽，若装备失败则结束处理
	if not Duel.Equip(tp,c,tc) then return end
	-- 当作...装备卡使用给自己场上的名字带有「希望皇 霍普」的怪兽装备
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c60992364.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
	-- 攻击力上升3000
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(3000)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
end
-- 装备限制：该装备卡只能装备给作为其效果对象的怪兽
function c60992364.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 追加攻击效果的Condition：必须在自己的回合的战斗步骤，且当前没有其他连锁正在处理
function c60992364.atcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为自己的回合、是否处于战斗步骤，且当前连锁数为0
	return Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_BATTLE_STEP and Duel.GetCurrentChain()==0
end
-- 追加攻击效果的Cost：将作为装备卡的这张卡送去墓地，并记录被装备的怪兽
function c60992364.atcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	e:SetLabelObject(e:GetHandler():GetEquipTarget())
	-- 将作为装备卡的这张卡送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 追加攻击效果的Target：检查装备怪兽是否只进行过1次攻击且未获得其他追加攻击效果，并锁定目标怪兽
function c60992364.attg(e,tp,eg,ep,ev,re,r,rp,chk)
	local eqc=e:GetHandler():GetEquipTarget()
	if chk==0 then return eqc and eqc:GetAttackedCount()==1 and eqc:GetEffectCount(EFFECT_EXTRA_ATTACK)==0 end
	-- 将之前记录的装备怪兽设为效果处理的目标
	Duel.SetTargetCard(e:GetLabelObject())
end
-- 追加攻击效果的Operation：赋予目标怪兽再1次向对方怪兽攻击的能力，并限制其不能直接攻击
function c60992364.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取要追加攻击的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 那次战斗阶段中，装备怪兽...只再1次可以攻击
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 向对方怪兽...可以攻击
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end

--パワー・ツール・ドラゴン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- ①：1回合1次，自己主要阶段才能发动。从卡组把3张装备魔法卡给对方观看，对方从那之中随机选1张。那1张卡加入自己手卡，剩余回到卡组。
-- ②：这张卡被破坏的场合，可以作为代替把这张卡装备的1张装备魔法卡送去墓地。
function c2403771.initial_effect(c)
	-- 设置这张卡的同调召唤条件：调整+调整以外的怪兽1只以上。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：1回合1次，自己主要阶段才能发动。从卡组把3张装备魔法卡给对方观看，对方从那之中随机选1张。那1张卡加入自己手卡，剩余回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2403771,0))  --"选择装备卡加入手卡"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c2403771.thtg)
	e1:SetOperation(c2403771.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡被破坏的场合，可以作为代替把这张卡装备的1张装备魔法卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetTarget(c2403771.desreptg)
	e2:SetOperation(c2403771.desrepop)
	c:RegisterEffect(e2)
end
-- 判断卡是否为装备魔法卡且可以被加入手卡（即成为检索对象）。
function c2403771.thfilter(c)
	return c:IsType(TYPE_EQUIP) and c:IsAbleToHand()
end
-- 效果的发动条件/目标判定：在发动时检查卡组中是否存在至少3张符合条件的装备魔法卡，并设置操作信息为将卡组中的卡加入手卡。
function c2403771.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时（chk==0）检查我方卡组是否存在至少3张满足thfilter（装备魔法卡且能加入手卡）的卡，存在则可发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c2403771.thfilter,tp,LOCATION_DECK,0,3,nil) end
	-- 设置操作信息：此效果处理时会把卡组中的1张卡加入手卡，供相关卡牌（如星尘龙等）进行效果检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
-- 效果处理：从我方卡组选取3张装备魔法卡，给对方确认后洗切卡组，对方随机选择其中1张加入持有者手卡，剩余的留在卡组（相当于回到卡组）。
function c2403771.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取我方卡组中所有满足thfilter条件的装备魔法卡集合。
	local g=Duel.GetMatchingGroup(c2403771.thfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>=3 then
		-- 显示选择提示消息，提示玩家选择要展示/加入手卡的卡（此处实际是选择要展示的3张装备魔法卡）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,3,3,nil)
		-- 将选中的3张装备魔法卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,sg)
		-- 洗切我方卡组。
		Duel.ShuffleDeck(tp)
		local tg=sg:RandomSelect(1-tp,1)
		tg:GetFirst():SetStatus(STATUS_TO_HAND_WITHOUT_CONFIRM,true)
		-- 将对方随机选中的那张卡加入其持有者的手卡，移动原因是效果。
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
end
-- 过滤函数：用于选出可以作为代替破坏送去墓地的装备魔法卡，要求是魔法卡、位于魔陷区、未被预定破坏状态。
function c2403771.repfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsLocation(LOCATION_SZONE) and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
end
-- 代替破坏效果的发动条件判定：这张卡因战斗或效果要被破坏且不是代替破坏时，若其装备区存在符合条件的装备魔法卡，则询问玩家是否发动；选择1张装备魔法卡作为代替破坏的对象。
function c2403771.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local g=c:GetEquipGroup()
		return c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE) and g:IsExists(c2403771.repfilter,1,nil)
	end
	-- 弹出询问框：是否使用这张装备魔法卡来代替这张卡的破坏（选择是则继续处理代替破坏）。
	if Duel.SelectEffectYesNo(tp,c,96) then
		local g=c:GetEquipGroup()
		-- 提示玩家选择要送去墓地的装备魔法卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg=g:FilterSelect(tp,c2403771.repfilter,1,1,nil)
		-- 将选择的装备魔法卡设置为当前效果的对象，供后续处理取得该卡。
		Duel.SetTargetCard(sg)
		return true
	else return false end
end
-- 代替破坏的执行处理：取得作为对象的装备魔法卡并将其送去墓地。
function c2403771.desrepop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取得之前设置的对象装备魔法卡。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	-- 将该装备魔法卡送去墓地，同时带有效果和代替破坏的原因。
	Duel.SendtoGrave(tg,REASON_EFFECT+REASON_REPLACE)
end

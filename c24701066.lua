--無限起動リヴァーストーム
-- 效果：
-- 5星怪兽×2
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：把这张卡1个超量素材取除才能发动。从卡组选1只机械族·地属性怪兽加入手卡或送去墓地。
-- ②：这张卡战斗破坏对方怪兽时才能发动。那只怪兽作为这张卡的超量素材。
-- ③：这张卡在墓地存在的场合，把自己场上1只机械族连接怪兽解放才能发动。这张卡守备表示特殊召唤。
function c24701066.initial_effect(c)
	-- 为卡片添加等级为5、需要2只怪兽进行叠放的XYZ召唤手续
	aux.AddXyzProcedure(c,nil,5,2)
	c:EnableReviveLimit()
	-- ①：把这张卡1个超量素材取除才能发动。从卡组选1只机械族·地属性怪兽加入手卡或送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(24701066,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_TOGRAVE+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,24701066)
	e1:SetCost(c24701066.cost)
	e1:SetTarget(c24701066.target)
	e1:SetOperation(c24701066.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡战斗破坏对方怪兽时才能发动。那只怪兽作为这张卡的超量素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(24701066,1))  --"超量素材"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetCondition(c24701066.xyzcon)
	e2:SetTarget(c24701066.xyztg)
	e2:SetOperation(c24701066.xyzop)
	c:RegisterEffect(e2)
	-- ③：这张卡在墓地存在的场合，把自己场上1只机械族连接怪兽解放才能发动。这张卡守备表示特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(24701066,2))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,24701067)
	e3:SetCost(c24701066.spcost)
	e3:SetTarget(c24701066.sptg)
	e3:SetOperation(c24701066.spop)
	c:RegisterEffect(e3)
end
-- 效果发动时，检查是否能从场上取除1个超量素材作为费用
function c24701066.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤函数，用于筛选满足条件的机械族·地属性怪兽（可加入手卡或送去墓地）
function c24701066.filter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_MACHINE) and (c:IsAbleToHand() or c:IsAbleToGrave())
end
-- 设置效果处理时要操作的卡组中的目标卡片，包括送去手卡和送去墓地的分类
function c24701066.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少1张满足过滤条件的机械族·地属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c24701066.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理时要操作的卡组中的目标卡片为送去手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置效果处理时要操作的卡组中的目标卡片为送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时，提示玩家选择要操作的卡，并根据选择将卡加入手卡或送去墓地
function c24701066.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家从卡组中选择要操作的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从卡组中选择满足条件的1张机械族·地属性怪兽
	local g=Duel.SelectMatchingCard(tp,c24701066.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()<=0 then return end
	local tc=g:GetFirst()
	-- 判断是否可以将选中的卡加入手卡，若不能则选择送去墓地
	if tc:IsAbleToHand() and (not tc:IsAbleToGrave() or Duel.SelectOption(tp,1190,1191)==0) then
		-- 将选中的卡加入手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方确认加入手卡的卡
		Duel.ConfirmCards(1-tp,tc)
	else
		-- 将选中的卡送去墓地
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
-- 判断战斗破坏的怪兽是否满足作为超量素材的条件
function c24701066.xyzcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	if not c:IsRelateToBattle() then return false end
	e:SetLabelObject(tc)
	return tc and tc:IsType(TYPE_MONSTER) and tc:IsReason(REASON_BATTLE) and tc:IsCanOverlay()
		and (tc:IsLocation(LOCATION_GRAVE) or tc:IsFaceup() and tc:IsLocation(LOCATION_EXTRA+LOCATION_REMOVED))
end
-- 设置效果处理时要操作的卡为战斗破坏的怪兽，并设置其离开墓地的分类
function c24701066.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ) end
	local tc=e:GetLabelObject()
	-- 设置当前处理的连锁对象为战斗破坏的怪兽
	Duel.SetTargetCard(tc)
	-- 设置效果处理时要操作的卡为战斗破坏的怪兽，并设置其离开墓地的分类
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,tc,1,0,0)
end
-- 效果处理时，将战斗破坏的怪兽作为超量素材叠放至自身
function c24701066.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前处理的连锁对象卡
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsCanOverlay() then
		-- 将目标怪兽作为超量素材叠放至自身
		Duel.Overlay(c,tc)
	end
end
-- 过滤函数，用于筛选满足条件的机械族连接怪兽（可解放）
function c24701066.cfilter(c,tp)
	-- 筛选条件：连接怪兽、机械族、且场上存在可用怪兽区
	return c:IsType(TYPE_LINK) and c:IsRace(RACE_MACHINE) and Duel.GetMZoneCount(tp,c)>0
end
-- 效果发动时，检查是否能从场上选择1只满足条件的连接怪兽作为费用
function c24701066.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少1只满足条件的连接怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c24701066.cfilter,1,nil,tp) end
	-- 从场上选择1只满足条件的连接怪兽
	local g=Duel.SelectReleaseGroup(tp,c24701066.cfilter,1,1,nil,tp)
	-- 将选中的连接怪兽解放作为费用
	Duel.Release(g,REASON_COST)
end
-- 设置效果处理时要操作的卡为自身，并设置特殊召唤的分类
function c24701066.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置效果处理时要操作的卡为自身，并设置特殊召唤的分类
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理时，将自身以守备表示特殊召唤至场上
function c24701066.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将自身以守备表示特殊召唤至场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end

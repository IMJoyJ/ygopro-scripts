--無限起動リヴァーストーム
-- 效果：
-- 5星怪兽×2
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：把这张卡1个超量素材取除才能发动。从卡组选1只机械族·地属性怪兽加入手卡或送去墓地。
-- ②：这张卡战斗破坏对方怪兽时才能发动。那只怪兽作为这张卡的超量素材。
-- ③：这张卡在墓地存在的场合，把自己场上1只机械族连接怪兽解放才能发动。这张卡守备表示特殊召唤。
function c24701066.initial_effect(c)
	-- 为这张卡添加超量召唤手续：以2只5星怪兽作为超量素材（对应“5星怪兽×2”）。
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
-- ①效果的发动代价：判定并取除此卡的1个超量素材。
function c24701066.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 检索或送去墓地的候选怪兽过滤条件：机械族·地属性，且能够加入手卡或送去墓地。
function c24701066.filter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_MACHINE) and (c:IsAbleToHand() or c:IsAbleToGrave())
end
-- ①效果的目标条件与操作信息：仅在卡组存在符合条件的机械族·地属性怪兽时可发动，并设定可能将卡加入手卡/送去墓地的操作信息。
function c24701066.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：己方卡组中存在至少1只满足过滤条件的机械族·地属性怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c24701066.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：预计将把1张卡从卡组加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息：预计将把1张卡从卡组送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：从卡组选择1只符合条件的机械族·地属性怪兽，根据其可处理方式及玩家选择，将其加入手卡或送去墓地，并向对方确认入手卡。
function c24701066.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择卡片的提示信息，提示玩家选择要操作的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 让玩家从卡组选择1只满足条件的机械族·地属性怪兽。
	local g=Duel.SelectMatchingCard(tp,c24701066.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()<=0 then return end
	local tc=g:GetFirst()
	-- 判断入手或入墓：若该卡能加入手卡，且（不能送去墓地或玩家选择选项0），则加入手卡；否则送去墓地。
	if tc:IsAbleToHand() and (not tc:IsAbleToGrave() or Duel.SelectOption(tp,1190,1191)==0) then
		-- 将选中的怪兽加入其持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的怪兽。
		Duel.ConfirmCards(1-tp,tc)
	else
		-- 将选中的怪兽送去墓地。
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
-- ②效果发动条件：这张卡进行战斗并破坏了对方怪兽，被破坏的怪兽因战斗送去墓地（或处于可叠放状态），且可以叠放在这张卡下。
function c24701066.xyzcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	if not c:IsRelateToBattle() then return false end
	e:SetLabelObject(tc)
	return tc and tc:IsType(TYPE_MONSTER) and tc:IsReason(REASON_BATTLE) and tc:IsCanOverlay()
		and (tc:IsLocation(LOCATION_GRAVE) or tc:IsFaceup() and tc:IsLocation(LOCATION_EXTRA+LOCATION_REMOVED))
end
-- ②效果发动时：将被战斗破坏的对方怪兽指定为对象，并设置“离开墓地”的操作信息。
function c24701066.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ) end
	local tc=e:GetLabelObject()
	-- 将已确定的被战斗破坏的对方怪兽设为当前连锁的对象。
	Duel.SetTargetCard(tc)
	-- 设置操作信息：该怪兽将在效果处理时离开墓地（作为超量素材叠放）。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,tc,1,0,0)
end
-- ②效果处理：若这张卡和对象怪兽仍与效果关联，且对象怪兽可以叠放，则将其作为这张卡的超量素材。
function c24701066.xyzop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取②效果处理时锁定的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsCanOverlay() then
		-- 将对象怪兽叠放在这张卡下方作为超量素材。
		Duel.Overlay(c,tc)
	end
end
-- ③效果的解放素材过滤：机械族连接怪兽，且解放后己方有可用的主要怪兽区。
function c24701066.cfilter(c,tp)
	-- 判定条件：该怪兽为机械族连接怪兽，且解放它后己方场上仍有空格可特殊召唤。
	return c:IsType(TYPE_LINK) and c:IsRace(RACE_MACHINE) and Duel.GetMZoneCount(tp,c)>0
end
-- ③效果发动代价：检查并选择解放自己场上1只机械族连接怪兽。
function c24701066.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：己方场上是否存在至少1只可解放的机械族连接怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c24701066.cfilter,1,nil,tp) end
	-- 让玩家选择解放自己场上1只机械族连接怪兽。
	local g=Duel.SelectReleaseGroup(tp,c24701066.cfilter,1,1,nil,tp)
	-- 解放所选择的怪兽作为发动代价。
	Duel.Release(g,REASON_COST)
end
-- ③效果目标：确认墓地的这张卡可以守备表示特殊召唤，并设置特殊召唤的操作信息。
function c24701066.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置操作信息：将特殊召唤墓地的这张卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ③效果处理：若墓地的这张卡仍与效果关联，则将其表侧守备表示特殊召唤。
function c24701066.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧守备表示特殊召唤到己方场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end

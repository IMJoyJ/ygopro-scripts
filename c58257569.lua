--真紅眼の幼竜
-- 效果：
-- ①：这张卡被战斗破坏送去墓地时才能发动。从卡组把1只7星以下的「真红眼」怪兽特殊召唤，墓地的这张卡当作攻击力上升300的装备卡使用给那只怪兽装备。
-- ②：给怪兽装备的这张卡被送去墓地的场合才能发动。从自己的卡组·墓地选1只龙族·1星怪兽加入手卡。
function c58257569.initial_effect(c)
	-- ①：这张卡被战斗破坏送去墓地时才能发动。从卡组把1只7星以下的「真红眼」怪兽特殊召唤，墓地的这张卡当作攻击力上升300的装备卡使用给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(58257569,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c58257569.condition)
	e1:SetTarget(c58257569.target)
	e1:SetOperation(c58257569.operation)
	c:RegisterEffect(e1)
	-- ②：给怪兽装备的这张卡被送去墓地的场合才能发动。从自己的卡组·墓地选1只龙族·1星怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(58257569,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c58257569.thcon)
	e3:SetTarget(c58257569.thtg)
	e3:SetOperation(c58257569.thop)
	c:RegisterEffect(e3)
end
-- 检查这张卡是否被战斗破坏并送去墓地
function c58257569.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 过滤卡组中7星以下的「真红眼」怪兽
function c58257569.filter(c,e,tp)
	return c:IsSetCard(0x3b) and c:IsLevelBelow(7) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动准备，检查怪兽区域和魔陷区域是否有空位，以及卡组中是否存在可特殊召唤的怪兽
function c58257569.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可以特殊召唤怪兽的空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上是否有可以放置装备卡的魔陷区空位
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查卡组中是否存在满足条件的「真红眼」怪兽
		and Duel.IsExistingMatchingCard(c58257569.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁信息，表示该效果包含从卡组特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	-- 设置连锁信息，表示该效果包含将自身作为装备卡装备的操作
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
	-- 设置连锁信息，表示该效果包含让墓地的卡离开墓地的操作
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- ①效果的处理：特殊召唤卡组中的「真红眼」怪兽，并将墓地的这张卡作为装备卡装备给该怪兽，使其攻击力上升300
function c58257569.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 若此时自己场上没有可用的怪兽区域空位，则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从卡组选择1只满足条件的「真红眼」怪兽
	local g=Duel.SelectMatchingCard(tp,c58257569.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		local c=e:GetHandler()
		local tc=g:GetFirst()
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 将墓地的这张卡作为装备卡装备给特殊召唤的怪兽
		Duel.Equip(tp,c,tc)
		-- 当作……装备卡使用给那只怪兽装备
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c58257569.eqlimit)
		e1:SetLabelObject(tc)
		c:RegisterEffect(e1)
		-- 攻击力上升300
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(300)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
	end
end
-- 限定这张卡只能装备给通过该效果特殊召唤的那只怪兽
function c58257569.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 检查这张卡之前是否在魔陷区作为装备卡装备给怪兽，且不是因为装备对象消失而送去墓地
function c58257569.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_SZONE) and c:GetPreviousEquipTarget() and not c:IsReason(REASON_LOST_TARGET)
end
-- 过滤龙族·1星且可以加入手卡的怪兽
function c58257569.thfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsLevel(1) and c:IsAbleToHand()
end
-- ②效果的发动准备，检查卡组或墓地是否存在满足条件的龙族·1星怪兽，并设置连锁信息
function c58257569.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的卡组或墓地是否存在满足条件的龙族·1星怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c58257569.thfilter,tp,LOCATION_GRAVE+LOCATION_DECK,0,1,nil) end
	-- 设置连锁信息，表示该效果包含从卡组或墓地将卡加入手卡的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- ②效果的处理：从卡组或墓地选择1只龙族·1星怪兽加入手卡
function c58257569.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组或不受王家长眠之谷影响的墓地中选择1只满足条件的龙族·1星怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c58257569.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
		-- 洗切自己的卡组
		Duel.ShuffleDeck(tp)
	end
end

--D・リモコン
-- 效果：
-- ①：这张卡得到表示形式的以下效果。
-- ●攻击表示：1回合1次，以自己墓地1只「变形斗士」怪兽为对象才能发动。那只怪兽除外，等级和那只怪兽相同的1只「变形斗士」怪兽从卡组加入手卡。
-- ●守备表示：1回合1次，自己主要阶段才能发动。从自己手卡选1只「变形斗士」怪兽送去墓地，从自己墓地选等级和那只怪兽相同的1只其他的「变形斗士」怪兽加入手卡。
function c57108202.initial_effect(c)
	-- ●攻击表示：1回合1次，以自己墓地1只「变形斗士」怪兽为对象才能发动。那只怪兽除外，等级和那只怪兽相同的1只「变形斗士」怪兽从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(57108202,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c57108202.cona)
	e1:SetTarget(c57108202.tga)
	e1:SetOperation(c57108202.opa)
	c:RegisterEffect(e1)
	-- ●守备表示：1回合1次，自己主要阶段才能发动。从自己手卡选1只「变形斗士」怪兽送去墓地，从自己墓地选等级和那只怪兽相同的1只其他的「变形斗士」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(57108202,1))  --"墓地回收"
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c57108202.cond)
	e2:SetTarget(c57108202.tgd)
	e2:SetOperation(c57108202.opd)
	c:RegisterEffect(e2)
end
-- 过滤函数：检索或回收等级为lv的「变形斗士」怪兽
function c57108202.filter(c,lv)
	return c:IsSetCard(0x26) and c:IsLevel(lv) and c:IsAbleToHand()
end
-- 攻击表示效果的发动条件：此卡未无效且处于攻击表示
function c57108202.cona(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsDisabled() and e:GetHandler():IsAttackPos()
end
-- 过滤函数：自己墓地中可以除外，且卡组中存在与其等级相同的「变形斗士」怪兽
function c57108202.filtera(c,tp)
	local lv=c:GetLevel()
	return c:IsSetCard(0x26) and lv>0 and c:IsAbleToRemove()
		-- 检查卡组中是否存在等级相同的「变形斗士」怪兽
		and Duel.IsExistingMatchingCard(c57108202.filter,tp,LOCATION_DECK,0,1,nil,lv)
end
-- 攻击表示效果的发动准备（选择墓地的「变形斗士」怪兽作为对象，并设置操作信息）
function c57108202.tga(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c57108202.filtera(chkc,tp) end
	-- 检查自己墓地是否存在满足条件的可作为对象除外的「变形斗士」怪兽
	if chk==0 then return Duel.IsExistingTarget(c57108202.filtera,tp,LOCATION_GRAVE,0,1,nil,tp) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择自己墓地1只满足条件的「变形斗士」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c57108202.filtera,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	-- 设置操作信息：将选中的墓地怪兽除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,tp,LOCATION_GRAVE)
	-- 设置操作信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 攻击表示效果的处理（除外对象怪兽，并从卡组检索同等级的「变形斗士」怪兽）
function c57108202.opa(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍适用效果，则将其表侧表示除外
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组选择1只与除外怪兽等级相同的「变形斗士」怪兽
		local g=Duel.SelectMatchingCard(tp,c57108202.filter,tp,LOCATION_DECK,0,1,1,nil,tc:GetLevel())
		if g:GetCount()>0 then
			-- 将选中的怪兽加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方玩家展示加入手牌的卡
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
-- 守备表示效果的发动条件：此卡未无效且处于守备表示
function c57108202.cond(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsDisabled() and e:GetHandler():IsDefensePos()
end
-- 过滤函数：手牌中可以送去墓地，且墓地中存在与其等级相同的其他「变形斗士」怪兽
function c57108202.filterd(c,tp)
	local lv=c:GetLevel()
	return c:IsSetCard(0x26) and lv>0 and c:IsAbleToGrave()
		-- 检查墓地中是否存在等级相同的「变形斗士」怪兽
		and Duel.IsExistingMatchingCard(c57108202.filter,tp,LOCATION_GRAVE,0,1,nil,lv)
end
-- 守备表示效果的发动准备（检查手牌中是否有可送去墓地的怪兽，并设置操作信息）
function c57108202.tgd(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在满足条件的「变形斗士」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c57108202.filterd,tp,LOCATION_HAND,0,1,nil,tp) end
	-- 设置操作信息：将手牌的1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
	-- 设置操作信息：从墓地将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- 守备表示效果的处理（将手牌1只「变形斗士」送去墓地，并回收墓地同等级的其他「变形斗士」）
function c57108202.opd(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从手牌选择1只满足条件的「变形斗士」怪兽
	local g=Duel.SelectMatchingCard(tp,c57108202.filterd,tp,LOCATION_HAND,0,1,1,nil,tp)
	local tc=g:GetFirst()
	if not tc then return end
	-- 将选中的手牌怪兽送去墓地
	Duel.SendtoGrave(tc,REASON_EFFECT)
	if not tc:IsLocation(LOCATION_GRAVE) then return end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从墓地选择1只与送去墓地的怪兽等级相同且非其自身的「变形斗士」怪兽
	local sg=Duel.SelectMatchingCard(tp,c57108202.filter,tp,LOCATION_GRAVE,0,1,1,tc,tc:GetLevel())
	if sg:GetCount()>0 then
		-- 将选中的墓地怪兽加入手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡
		Duel.ConfirmCards(1-tp,sg)
	end
end

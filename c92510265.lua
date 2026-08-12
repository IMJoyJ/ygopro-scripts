--聖戦士カオス・ソルジャー
-- 效果：
-- 「圣战士 混沌战士」的①的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤成功时，以除外的1只自己的光属性或者暗属性的怪兽和对方场上1张卡为对象才能发动。那张自己的卡回到墓地，那张对方的卡除外。
-- ②：这张卡战斗破坏对方怪兽时，以自己墓地1只7星以下的战士族怪兽为对象才能发动。那只怪兽加入手卡。
function c92510265.initial_effect(c)
	-- 「圣战士 混沌战士」的①的效果1回合只能使用1次。①：这张卡召唤·特殊召唤成功时，以除外的1只自己的光属性或者暗属性的怪兽和对方场上1张卡为对象才能发动。那张自己的卡回到墓地，那张对方的卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(92510265,0))  --"除外"
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCountLimit(1,92510265)
	e1:SetTarget(c92510265.rmtg)
	e1:SetOperation(c92510265.rmop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡战斗破坏对方怪兽时，以自己墓地1只7星以下的战士族怪兽为对象才能发动。那只怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(92510265,1))  --"加入手卡"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	-- 设置效果发动的条件为自身战斗破坏对方怪兽并送去墓地时
	e3:SetCondition(aux.bdocon)
	e3:SetTarget(c92510265.thtg)
	e3:SetOperation(c92510265.thop)
	c:RegisterEffect(e3)
end
-- 过滤条件：除外状态下表侧表示的光属性或暗属性怪兽
function c92510265.rgfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
end
-- 效果①的靶向/发动准备函数，进行合法对象检测并选择两个目标
function c92510265.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己除外区是否存在至少1只表侧表示的光属性或暗属性怪兽
	if chk==0 then return Duel.IsExistingTarget(c92510265.rgfilter,tp,LOCATION_REMOVED,0,1,nil)
		-- 并且对方场上是否存在至少1张可以被除外的卡
		and Duel.IsExistingTarget(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要回到墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(92510265,2))  --"请选择要回到墓地的卡"
	-- 选择自己除外区1只表侧表示的光属性或暗属性怪兽作为效果对象
	local g1=Duel.SelectTarget(tp,c92510265.rgfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	e:SetLabelObject(g1:GetFirst())
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方场上1张卡作为效果对象
	local g2=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁信息，表示该效果包含将选中的除外怪兽送去墓地的操作
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g1,1,0,0)
	-- 设置连锁信息，表示该效果包含将选中的对方场上的卡除外的操作
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g2,1,0,0)
end
-- 效果①的处理函数，将选中的自己除外怪兽送回墓地，并除外选中的对方卡片
function c92510265.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 获取当前连锁中被选为对象的所有卡片
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local lc=tg:GetFirst()
	if lc==tc then lc=tg:GetNext() end
	-- 检查自己的对象卡是否仍与效果相关，若成功将其送回墓地，则继续检查对方的对象卡是否仍与效果相关且仍由对方控制
	if tc:IsRelateToEffect(e) and Duel.SendtoGrave(tc,REASON_EFFECT+REASON_RETURN)~=0 and lc:IsRelateToEffect(e) and lc:IsControler(1-tp) then
		-- 将对方的对象卡表侧表示除外
		Duel.Remove(lc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 过滤条件：自己墓地等级7以下的战士族怪兽，且能加入手牌
function c92510265.thfilter(c)
	return c:IsLevelBelow(7) and c:IsRace(RACE_WARRIOR) and c:IsAbleToHand()
end
-- 效果②的靶向/发动准备函数，进行合法对象检测并选择目标
function c92510265.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c92510265.thfilter(chkc) end
	-- 检查自己墓地是否存在至少1只满足条件的7星以下战士族怪兽
	if chk==0 then return Duel.IsExistingTarget(c92510265.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只满足条件的7星以下战士族怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c92510265.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁信息，表示该效果包含将选中的怪兽加入手牌的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果②的处理函数，将选中的墓地怪兽加入手牌
function c92510265.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的第一张卡（即要加入手牌的怪兽）
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将选中的怪兽加入持有者的手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end

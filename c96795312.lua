--武の賢者－アーカス
-- 效果：
-- 这个卡名在规则上也当作「闪刀」卡使用。这个卡名的①②③的效果1回合各能使用1次。
-- ①：从手卡丢弃1张魔法卡才能发动。这张卡从手卡特殊召唤。
-- ②：自己场上的连接怪兽被战斗·效果破坏的场合，可以作为代替把自己墓地1张魔法卡除外。
-- ③：这张卡被战斗·效果破坏送去墓地的场合，以除外的1张自己的「闪刀」魔法卡为对象才能发动。那张卡加入手卡。
function c96795312.initial_effect(c)
	-- ①：从手卡丢弃1张魔法卡才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(96795312,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,96795312)
	e1:SetCost(c96795312.spcost)
	e1:SetTarget(c96795312.sptg)
	e1:SetOperation(c96795312.spop)
	c:RegisterEffect(e1)
	-- ②：自己场上的连接怪兽被战斗·效果破坏的场合，可以作为代替把自己墓地1张魔法卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,96795313)
	e2:SetTarget(c96795312.reptg)
	e2:SetValue(c96795312.repval)
	c:RegisterEffect(e2)
	-- ③：这张卡被战斗·效果破坏送去墓地的场合，以除外的1张自己的「闪刀」魔法卡为对象才能发动。那张卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(96795312,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,96795314)
	e3:SetCondition(c96795312.thcon)
	e3:SetTarget(c96795312.thtg)
	e3:SetOperation(c96795312.thop)
	c:RegisterEffect(e3)
end
-- 过滤函数：手牌中可丢弃的魔法卡
function c96795312.costfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsDiscardable()
end
-- 效果①的代价：从手牌丢弃1张魔法卡
function c96795312.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在除自身以外的可丢弃魔法卡
	if chk==0 then return Duel.IsExistingMatchingCard(c96795312.costfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 玩家选择并丢弃1张手牌中的魔法卡
	Duel.DiscardHand(tp,c96795312.costfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 效果①的发动准备：检查怪兽区域空格并确认自身能否特殊召唤
function c96795312.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁中的操作信息：特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理：将这张卡从手牌特殊召唤
function c96795312.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到自己场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤函数：自己场上因战斗或效果而被破坏的连接怪兽
function c96795312.repfilter(c,tp)
	return not c:IsReason(REASON_REPLACE) and c:IsType(TYPE_LINK)
		and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- 过滤函数：自己墓地中可以除外的魔法卡
function c96795312.rmfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToRemove()
end
-- 效果②的代替破坏处理：检查是否有符合条件的连接怪兽被破坏以及墓地是否有可除外的魔法卡
function c96795312.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c96795312.repfilter,1,nil,tp)
		-- 检查自己墓地是否存在至少1张可除外的魔法卡
		and Duel.IsExistingMatchingCard(c96795312.rmfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 询问玩家是否发动代替破坏的效果
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		-- 提示玩家选择要除外的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 玩家选择自己墓地中的1张魔法卡
		local g=Duel.SelectMatchingCard(tp,c96795312.rmfilter,tp,LOCATION_GRAVE,0,1,1,nil)
		-- 将选择的魔法卡表侧表示除外以代替破坏
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
		return true
	else return false end
end
-- 确定代替破坏效果所适用的卡片范围
function c96795312.repval(e,c)
	return c96795312.repfilter(c,e:GetHandlerPlayer())
end
-- 效果③的发动条件：这张卡被战斗或效果破坏并送去墓地
function c96795312.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- 过滤函数：除外的表侧表示的「闪刀」魔法卡
function c96795312.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x115) and c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 效果③的发动准备：选择除外的1张「闪刀」魔法卡作为对象
function c96795312.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c96795312.thfilter(chkc) end
	-- 检查除外区是否存在符合条件的「闪刀」魔法卡
	if chk==0 then return Duel.IsExistingTarget(c96795312.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择除外的1张「闪刀」魔法卡作为效果对象
	local g=Duel.SelectTarget(tp,c96795312.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置连锁中的操作信息：将对象卡片加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果③的效果处理：将作为对象的「闪刀」魔法卡加入手牌
function c96795312.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的第一个效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将该对象卡片加入持有者的手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end

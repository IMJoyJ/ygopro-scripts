--巳剣之尊 草那藝
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合或者这张卡被解放的场合，以「巳剑之尊 草那艺」以外的自己的墓地·除外状态的1张「巳剑」卡为对象才能发动。那张卡加入手卡。
-- ②：自己场上的其他的爬虫类族怪兽被战斗·效果破坏的场合，可以作为代替把场上的这张卡解放。
local s,id,o=GetID()
-- 注册卡片效果：①召唤·特殊召唤·解放时回收墓地/除外的「巳剑」卡；②自己场上其他爬虫类族怪兽被破坏时解放自身代替破坏。
function s.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合或者这张卡被解放的场合，以「巳剑之尊 草那艺」以外的自己的墓地·除外状态的1张「巳剑」卡为对象才能发动。那张卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"回收"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_RELEASE)
	c:RegisterEffect(e3)
	-- ②：自己场上的其他的爬虫类族怪兽被战斗·效果破坏的场合，可以作为代替把场上的这张卡解放。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+o)
	e4:SetTarget(s.reptg)
	e4:SetValue(s.repval)
	e4:SetOperation(s.repop)
	c:RegisterEffect(e4)
end
-- 过滤条件：除「巳剑之尊 草那艺」以外的自己墓地·除外状态的「巳剑」卡，且能加入手卡
function s.thfilter(c)
	return c:IsFaceupEx() and not c:IsCode(id) and c:IsSetCard(0x1c3) and c:IsAbleToHand()
end
-- ①效果的发动准备（检查合法对象、提示玩家选择、设置连锁操作信息）
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and s.thfilter(chkc) end
	-- 检查自己墓地或除外状态是否存在至少1张满足条件的「巳剑」卡
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择1张满足条件的卡作为效果的对象
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	-- 设置连锁操作信息，表示该效果的处理为将选中的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ①效果的处理（将选中的对象卡加入手牌）
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为效果对象的卡片
	local tc=Duel.GetFirstTarget()
	-- 检查对象卡是否仍与效果相关，且不受「王家之谷」的影响
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc) then
		-- 将对象卡加入持有者的手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 过滤条件：自己场上因战斗或效果被破坏的、除自身以外的表侧表示爬虫类族怪兽
function s.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsRace(RACE_REPTILE)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- ②代替破坏效果的发动准备（检查是否有符合条件的怪兽被破坏，且自身可以被解放）
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(s.repfilter,1,c,tp)
		and c:IsReleasableByEffect() and not c:IsStatus(STATUS_DESTROY_CONFIRMED) end
	-- 询问玩家是否发动代替破坏的效果
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- 确定被破坏的怪兽是否属于可以被代替破坏的范围
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
-- ②代替破坏效果的处理（解放自身代替破坏）
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示发动了该卡的效果（显示卡片动画）
	Duel.Hint(HINT_CARD,0,id)
	-- 将场上的这张卡解放
	Duel.Release(e:GetHandler(),REASON_EFFECT)
end

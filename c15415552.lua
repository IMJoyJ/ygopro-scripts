--Mortilux Heruvur
local s,id,o=GetID()
-- 为卡片添加XYZ召唤手续并注册触发效果
function s.initial_effect(c)
	-- 为卡片添加XYZ召唤手续，需要8星且叠放2只怪兽
	aux.AddXyzProcedure(c,nil,8,2,nil,nil,99)
	c:EnableReviveLimit()
	-- 注册合并的延迟事件监听，用于限制自身诱发效果在连锁中只响应一次
	local custom_code=aux.RegisterMergedDelayedEvent_ToSingleCard(c,id,EVENT_TO_GRAVE)
	-- 设置一个字段诱发效果，当有对方控制的卡进入墓地时发动，可以将对方墓地的怪兽叠放
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(custom_code)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.rmcon)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	-- 设置一个永续效果，使该卡不会被战斗破坏
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(1)
	e2:SetCondition(s.effcon(2))
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e3)
	-- 设置一个字段效果，使该卡不能成为对方效果的对象
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_GRAVE,LOCATION_GRAVE)
	-- 设置效果值为过滤函数，用于判断目标是否能成为效果对象
	e4:SetValue(aux.tgoval)
	e4:SetCondition(s.effcon(3))
	c:RegisterEffect(e4)
	-- 设置一个起动效果，可以消耗3个叠放卡将场上怪兽送去墓地
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_TOGRAVE)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(s.effcon(4))
	e5:SetCost(s.tgcost)
	e5:SetTarget(s.tgtg)
	e5:SetOperation(s.tgop)
	c:RegisterEffect(e5)
end
-- 条件函数，判断是否有对方控制的卡进入墓地
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsControler,1,nil,1-tp)
end
-- 过滤函数，用于筛选满足条件的墓地怪兽
function s.xyzfilter(c,tp,e)
	return c:IsLocation(LOCATION_GRAVE) and c:IsControler(1-tp) and c:IsType(TYPE_MONSTER) and c:IsCanOverlay()
		and c:IsCanBeEffectTarget(e)
end
-- 设置效果目标，选择符合条件的墓地怪兽作为对象
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local sg=eg:Filter(s.xyzfilter,nil,tp,e)
	if chkc then return sg:IsContains(chkc) end
	if chk==0 then return sg:GetCount()>0 end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	local g=sg:Select(tp,1,1,nil)
	-- 将选中的卡设为当前连锁的效果对象
	Duel.SetTargetCard(g)
	-- 设置操作信息，记录将要离开墓地的卡
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 设置效果处理函数，将目标怪兽叠放到该卡上
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	-- 判断该卡和对象卡是否仍在连锁中且未被王家长眠之谷影响
	if c:IsRelateToChain() and tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 将对象怪兽叠放到该卡上
		Duel.Overlay(c,Group.FromCards(tc))
	end
end
-- 条件函数生成器，返回一个判断叠放数量是否满足条件的函数
function s.effcon(ct)
	return function(e,tp,eg,ep,ev,re,r,rp)
		return e:GetHandler():GetOverlayCount()>=ct
	end
end
-- 设置效果费用，消耗3个叠放卡作为费用
function s.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,3,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,3,3,REASON_COST)
end
-- 设置效果目标，检查场上是否有怪兽可以送去墓地
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在可送去墓地的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 设置操作信息，记录将要送去墓地的卡
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,PLAYER_ALL,LOCATION_MZONE)
end
-- 设置效果处理函数，选择场上怪兽送去墓地
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择场上符合条件的怪兽作为目标
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	if g:GetCount()>0 then
		-- 显示选中的卡被选为对象的动画效果
		Duel.HintSelection(g)
		-- 将选中的卡以效果原因送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end

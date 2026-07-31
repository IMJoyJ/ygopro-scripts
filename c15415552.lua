--Mortilux Heruvur
local s,id,o=GetID()
-- 初始化卡片效果，包括XYZ召唤手续、墓地触发事件注册及四个主要效果组件(e1-e5)。
function s.initial_effect(c)
	-- 设置XYZ召唤手续，要求等级8以上的怪兽叠放。
	aux.AddXyzProcedure(c,nil,8,2,nil,nil,99)
	c:EnableReviveLimit()
	-- 为单张卡片注册合并的延迟事件监听，以限制其自身诱发效果在一连锁中只响应一次（对应墓地触发）。
	local custom_code=aux.RegisterMergedDelayedEvent_ToSingleCard(c,id,EVENT_TO_GRAVE)
	-- 当这张卡从场上送去墓地时（每回合一次）：选择对方墓地的一只XYZ素材怪兽重叠到这张卡上。
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
	-- 当这张卡的叠放数量达到2以上时，不会被战斗破坏的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(1)
	e2:SetCondition(s.effcon(2))
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e3)
	-- 当这张卡的叠放数量达到3以上时，对方效果的对象不能是墓地里的卡。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_GRAVE,LOCATION_GRAVE)
	-- 设置效果值为一个过滤函数，用于判断目标卡是否由当前处理效果的持有者控制。
	e4:SetValue(aux.tgoval)
	e4:SetCondition(s.effcon(3))
	c:RegisterEffect(e4)
	-- 发动时（每回合一次）：支付代价（移除最多3张叠放素材），选择场上的一张怪兽送去墓地。
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
-- 检查触发时送入墓地的怪兽组中是否包含对方控制的卡片（通常指这张卡本身或相关素材）。
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsControler,1,nil,1-tp)
end
-- 定义了一个过滤器函数，筛选墓地中属于对方、类型为怪兽且可叠放并能成为当前效果对象的卡片。
function s.xyzfilter(c,tp,e)
	return c:IsLocation(LOCATION_GRAVE) and c:IsControler(1-tp) and c:IsType(TYPE_MONSTER) and c:IsCanOverlay()
		and c:IsCanBeEffectTarget(e)
end
-- 处理目标选择逻辑：过滤符合条件的墓地怪兽并检查是否包含已选对象（如有），若有效则提示玩家选择一张卡作为重叠素材。
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local sg=eg:Filter(s.xyzfilter,nil,tp,e)
	if chkc then return sg:IsContains(chkc) end
	if chk==0 then return sg:GetCount()>0 end
	-- 向指定玩家显示\"请选择效果的对象\"的提示信息，用于引导玩家进行卡片选择操作。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	local g=sg:Select(tp,1,1,nil)
	-- 将当前连锁的处理对象设置为玩家选择的怪兽组g，以便后续效果处理使用。
	Duel.SetTargetCard(g)
	-- 设置当前连锁的操作信息为从墓地离开（CATEGORY_LEAVE_GRAVE），目标数量为1张卡。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 执行重叠操作：如果满足相关条件且未被王家长眠之谷影响，则将选中的墓地怪兽叠放到当前卡片上。
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的第一个处理对象卡tc，用于后续的重叠或效果判断逻辑。
	local tc=Duel.GetFirstTarget()
	-- 检查目标卡和源卡是否都关联到当前连锁且未被王家长眠之谷影响（确保重叠操作有效）。
	if c:IsRelateToChain() and tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 将选中的墓地怪兽作为叠放素材叠加到当前卡片c上，实现复活或补充XYZ素材的效果。
		Duel.Overlay(c,Group.FromCards(tc))
	end
end
-- 定义一个条件函数effcon(ct)，用于检查当前卡片的叠放数量是否达到指定阈值ct（如2或3）。
function s.effcon(ct)
	return function(e,tp,eg,ep,ev,re,r,rp)
		return e:GetHandler():GetOverlayCount()>=ct
	end
end
-- 处理起动效果的代价逻辑：检查并移除最多3张叠放素材作为发动效果的费用。
function s.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,3,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,3,3,REASON_COST)
end
-- 处理目标选择逻辑：检查场上是否存在至少一张可送去墓地的怪兽，用于确定操作信息中的数量。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否满足存在至少一张可送去墓地怪兽的条件（PLAYER_ALL表示任意玩家）。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 设置当前连锁的操作信息为从墓地离开（CATEGORY_TOGRAVE），目标数量为1张卡，范围为全场或指定区域。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,PLAYER_ALL,LOCATION_MZONE)
end
-- 处理起动效果的发动操作：提示玩家选择要送去墓地的怪兽并执行发送动作。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 向指定玩家显示\"请选择要送去墓地的卡\"的提示信息，用于引导玩家进行卡片选择操作。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家sel_player从场上（LOCATION_MZONE）中选择一张可送去墓地且数量为1张的怪兽作为目标。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	if g:GetCount()>0 then
		-- 手动为选中的怪兽组g显示被选为对象的动画效果，并记录这些卡被选为对象的状态。
		Duel.HintSelection(g)
		-- 以REASON_EFFECT原因将选中的怪兽组g送入墓地，完成效果的最终结算操作。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end

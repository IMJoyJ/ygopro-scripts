--Mortilux Heruvur
-- 效果：
-- 8星怪兽×2只以上
-- 怪兽被送去对方墓地的场合（伤害步骤除外）：可以以那之内的1只为对象；那只怪兽作为这张卡的超量素材。「悼光之希路伯」的这个效果1回合只能使用1次。
-- 这张卡根据素材数量得到以下效果。
-- ●2个以上：不会被战斗·效果破坏。
-- ●3个以上：对方不能把墓地的卡作为效果的对象。
-- ●4个以上：可以把这张卡3个素材取除；场上1只怪兽送去墓地。
local s,id,o=GetID()
-- 初始化卡片效果：注册8星怪兽×2只以上的超量召唤手续及苏生限制，并注册5个效果——e1怪兽被送去对方墓地时取对象为超量素材的诱发效果（1回合1次）、e2素材2个以上时不会被战斗破坏、e3素材2个以上时不会被效果破坏、e4素材3个以上时对方不能把墓地的卡作为效果对象、e5素材4个以上时取除3个素材把场上1只怪兽送去墓地的起动效果
function s.initial_effect(c)
	-- 为这张卡添加超量召唤手续：用2只以上（最多99只）8星怪兽叠放进行超量召唤
	aux.AddXyzProcedure(c,nil,8,2,nil,nil,99)
	c:EnableReviveLimit()
	-- 为这张卡注册合并的延迟事件监听，监听怪兽被送去墓地的事件，使该诱发效果在同一连锁中只响应一次
	local custom_code=aux.RegisterMergedDelayedEvent_ToSingleCard(c,id,EVENT_TO_GRAVE)
	-- 怪兽被送去对方墓地的场合（伤害步骤除外）：可以以那之内的1只为对象；那只怪兽作为这张卡的超量素材。「悼光之希路伯」的这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"获取超量素材"
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(custom_code)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.rmcon)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
	-- 这张卡根据素材数量得到以下效果。●2个以上：不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(1)
	e2:SetCondition(s.effcon(2))
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e3)
	-- ●3个以上：对方不能把墓地的卡作为效果的对象。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_GRAVE,LOCATION_GRAVE)
	-- 设定该效果的适用判定：只有对墓地的卡使用效果的玩家是对方（非这张卡的控制者）时，才适用不能取对象的效果
	e4:SetValue(aux.tgoval)
	e4:SetCondition(s.effcon(3))
	c:RegisterEffect(e4)
	-- ●4个以上：可以把这张卡3个素材取除；场上1只怪兽送去墓地。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))  --"送去墓地"
	e5:SetCategory(CATEGORY_TOGRAVE)
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCondition(s.effcon(4))
	e5:SetCost(s.tgcost)
	e5:SetTarget(s.tgtg)
	e5:SetOperation(s.tgop)
	c:RegisterEffect(e5)
end
-- 效果发动条件：触发事件送去墓地的怪兽中存在对方（对手玩家）控制的怪兽
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsControler,1,nil,1-tp)
end
-- 对象过滤函数：位于对方墓地、为怪兽卡、可以作为超量素材叠放且能成为这个效果对象的卡
function s.xyzfilter(c,tp,e)
	return c:IsLocation(LOCATION_GRAVE) and c:IsControler(1-tp) and c:IsType(TYPE_MONSTER) and c:IsCanOverlay()
		and c:IsCanBeEffectTarget(e)
end
-- 效果对象处理：从触发事件的卡中筛选出可作为对象的怪兽，存在则让玩家选择其中1只作为对象，并设置离开墓地的操作信息
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local sg=eg:Filter(s.xyzfilter,nil,tp,e)
	if chkc then return sg:IsContains(chkc) end
	if chk==0 then return sg:GetCount()>0 end
	-- 向玩家发送“请选择效果的对象”的选卡提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	local g=sg:Select(tp,1,1,nil)
	-- 把选中的卡设置为当前连锁处理的对象
	Duel.SetTargetCard(g)
	-- 设置连锁的操作信息：这1张对象卡将离开墓地（用于王家长眠之谷等卡的发动检测）
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 效果处理：确认这张卡与对象卡都仍与连锁关联且不受王家长眠之谷影响后，把对象怪兽叠放为这张卡的超量素材
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得当前连锁处理的对象卡
	local tc=Duel.GetFirstTarget()
	-- 检查这张卡与对象卡是否都仍与当前连锁关联，且对象卡不受王家长眠之谷的影响
	if c:IsRelateToChain() and tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 把对象怪兽作为超量素材叠放到这张卡下面
		Duel.Overlay(c,Group.FromCards(tc))
	end
end
-- 效果适用条件生成函数：返回一个条件函数，要求这张卡的超量素材数量达到指定个数ct
function s.effcon(ct)
	return function(e,tp,eg,ep,ev,re,r,rp)
		return e:GetHandler():GetOverlayCount()>=ct
	end
end
-- 发动代价：取除这张卡的3个超量素材（发动前检查是否能取除3个）
function s.tgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,3,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,3,3,REASON_COST)
end
-- 效果目标处理：确认双方场上存在至少1只可以送去墓地的怪兽，并设置送去墓地的操作信息
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动前检查：双方的主要怪兽区是否存在至少1只可以送去墓地的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 设置连锁的操作信息：将把场上1只怪兽送去墓地（对象在处理时确定）
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,PLAYER_ALL,LOCATION_MZONE)
end
-- 效果处理：让玩家选择双方场上1只可以送去墓地的怪兽，显示选择动画后将其送去墓地
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送“请选择要送去墓地的卡”的选卡提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择双方主要怪兽区1只可以送去墓地的怪兽
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGrave,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	if g:GetCount()>0 then
		-- 为选中的卡显示被选中的动画效果
		Duel.HintSelection(g)
		-- 以效果处理的原因把选中的怪兽送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end

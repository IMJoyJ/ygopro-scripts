--クシャトリラ・アライズハート
-- 效果：
-- 7星怪兽×3
-- 「俱舍怒威族·阿莱斯哈特」在「俱舍怒威族的香格里拉茧」把效果发动的回合有1次也能在自己的「俱舍怒威族」怪兽上面重叠来超量召唤。
-- ①：被送去墓地的卡不去墓地而除外。
-- ②：每次卡被除外发动（同一连锁上最多1次）。选除外中的1张卡作为这张卡的超量素材。
-- ③：双方回合1次，把这张卡3个超量素材取除，以场上1张卡为对象才能发动。那张卡里侧表示除外。
local s,id,o=GetID()
-- 初始化效果函数，设置XYZ召唤程序并注册相关效果
function s.initial_effect(c)
	aux.AddXyzProcedure(c,nil,7,3,s.ovfilter,aux.Stringid(id,0),3,s.xyzop)  --"是否在「俱舍怒威族」怪兽上面重叠来超量召唤？"
	c:EnableReviveLimit()
	-- 效果作用：被送去墓地的卡不去墓地而除外
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e1:SetTargetRange(LOCATION_DECK,LOCATION_DECK)
	e1:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e1)
	-- 效果作用：注册一个合并的除外事件监听器
	local custom_code=aux.RegisterMergedDelayedEvent_ToSingleCard(c,id,EVENT_REMOVE)
	-- 效果作用：每次卡被除外发动（同一连锁上最多1次）。选除外中的1张卡作为这张卡的超量素材
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"选除外中的1张卡作为这张卡的超量素材"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(custom_code)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e2:SetOperation(s.mtop)
	c:RegisterEffect(e2)
	-- 效果作用：双方回合1次，把这张卡3个超量素材取除，以场上1张卡为对象才能发动。那张卡里侧表示除外
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"选择1张卡里侧表示除外"
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCost(s.rmcost)
	e3:SetTarget(s.rmtg)
	e3:SetOperation(s.rmop)
	c:RegisterEffect(e3)
	-- 效果作用：添加一个用于记录连锁次数的自定义计数器
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,s.chainfilter)
end
-- 过滤函数：排除特定卡牌（73542331）的连锁计入
function s.chainfilter(re,tp,cid)
	return not re:GetHandler():IsCode(73542331)
end
-- 过滤函数：判断是否为表侧表示的「俱舍怒威族」怪兽
function s.ovfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x189)
end
-- XYZ召唤条件函数：检查是否满足召唤条件
function s.xyzop(e,tp,chk)
	-- 检查是否已使用过该效果
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0
		-- 检查自己或对方是否有连锁发生
		and (Duel.GetCustomActivityCount(id,tp,ACTIVITY_CHAIN)>0
			-- 检查对方是否有连锁发生
			or Duel.GetCustomActivityCount(id,1-tp,ACTIVITY_CHAIN)>0) end
	-- 注册标识效果，防止该效果在同回合再次发动
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- 效果处理函数：选择除外区的卡作为超量素材
function s.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (c:IsRelateToChain() and c:IsType(TYPE_XYZ)) then return end
	-- 提示玩家选择要作为超量素材的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 从除外区选择一张卡作为超量素材
	local mg=Duel.SelectMatchingCard(tp,Card.IsCanOverlay,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil)
	if #mg>0 then
		-- 将选中的卡叠放至主怪兽区的怪兽上
		Duel.Overlay(c,mg)
	end
end
-- 效果处理函数：支付3个超量素材作为费用
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,3,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,3,3,REASON_COST)
end
-- 过滤函数：判断目标卡是否可以被除外
function s.rmfilter(c,tp)
	return c:IsAbleToRemove(tp,POS_FACEDOWN)
end
-- 效果处理函数：选择场上一张卡进行除外
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.rmfilter(chkc,tp) end
	-- 检查是否有满足条件的目标卡
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,tp) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择场上一张卡作为除外对象
	local g=Duel.SelectTarget(tp,s.rmfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,tp)
	-- 设置操作信息，记录将要除外的卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果处理函数：将目标卡里侧表示除外
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡里侧表示除外
		Duel.Remove(tc,POS_FACEDOWN,REASON_EFFECT)
	end
end

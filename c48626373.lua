--クシャトリラ・アライズハート
-- 效果：
-- 7星怪兽×3
-- 「俱舍怒威族·阿莱斯哈特」在「俱舍怒威族的香格里拉茧」把效果发动的回合有1次也能在自己的「俱舍怒威族」怪兽上面重叠来超量召唤。
-- ①：被送去墓地的卡不去墓地而除外。
-- ②：每次卡被除外发动（同一连锁上最多1次）。选除外中的1张卡作为这张卡的超量素材。
-- ③：双方回合1次，把这张卡3个超量素材取除，以场上1张卡为对象才能发动。那张卡里侧表示除外。
local s,id,o=GetID()
-- 初始化阿莱斯哈特的所有效果：注册可叠放在「俱舍怒威族」怪兽上的超量召唤手续、苏生限制、①送墓改为除外的永续效果、②除外时选1张除外卡作超量素材的必发诱发效果、③拔3素材取对象里侧除外的二速效果，并登记香格里拉茧效果发动计数器。
function s.initial_effect(c)
	aux.AddXyzProcedure(c,nil,7,3,s.ovfilter,aux.Stringid(id,0),3,s.xyzop)  --"是否在「俱舍怒威族」怪兽上面重叠来超量召唤？"
	c:EnableReviveLimit()
	-- ①：被送去墓地的卡不去墓地而除外。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e1:SetTargetRange(LOCATION_DECK,LOCATION_DECK)
	e1:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e1)
	-- 为阿莱斯哈特注册一个合并的延迟事件监听器，将除外事件合并后触发，返回自定义事件码；用于使②效果在同一连锁中最多发动一次。
	local custom_code=aux.RegisterMergedDelayedEvent_ToSingleCard(c,id,EVENT_REMOVE)
	-- ②：每次卡被除外发动（同一连锁上最多1次）。选除外中的1张卡作为这张卡的超量素材。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"选除外中的1张卡作为这张卡的超量素材"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(custom_code)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e2:SetOperation(s.mtop)
	c:RegisterEffect(e2)
	-- ③：双方回合1次，把这张卡3个超量素材取除，以场上1张卡为对象才能发动。那张卡里侧表示除外。
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
	-- 注册自定义活动计数器，统计本回合双方发动「俱舍怒威族的香格里拉茧」效果的次数，用于额外超量召唤的条件判定。
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,s.chainfilter)
end
-- 计数器过滤函数：返回值为false时计数器增加；这里用not判定，因此仅当发动效果的卡是香格里拉茧（73542331）时才会计数。
function s.chainfilter(re,tp,cid)
	return not re:GetHandler():IsCode(73542331)
end
-- 额外超量召唤的叠放条件：选择场上的表侧表示且具有「俱舍怒威族」字段的怪兽作为叠放对象，使此卡可以叠放在这类怪兽上面超量召唤。
function s.ovfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x189)
end
-- 超量召唤手续的合法性判定：检查本回合是否未使用过该特殊召唤方式，且任一方发动过香格里拉茧效果；满足才允许在「俱舍怒威族」怪兽上叠放。
function s.xyzop(e,tp,chk)
	-- 检查己方是否已经使用过该叠放召唤方式：通过flag标记id为0表示尚未使用。
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0
		-- 同时检查己方本回合是否发动过香格里拉茧的效果（活动计数大于0）。
		and (Duel.GetCustomActivityCount(id,tp,ACTIVITY_CHAIN)>0
			-- 或者对方本回合也发动过香格里拉茧的效果；只要任意一方发动过，条件即满足。
			or Duel.GetCustomActivityCount(id,1-tp,ACTIVITY_CHAIN)>0) end
	-- 实际使用该方式召唤时，注册一个到结束阶段重置的誓约标记，记录本回合已使用过该叠放召唤方式，防止同一回合重复使用。
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- ②效果处理：先确认此卡仍与连锁相关且是XYZ怪兽；然后从双方除外区选择1张卡，将其叠放到此卡下方作为超量素材。
function s.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (c:IsRelateToChain() and c:IsType(TYPE_XYZ)) then return end
	-- 弹出选择提示，让玩家选择要作为超量素材的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 从双方除外区中选择1张可以作为超量素材的卡（过滤条件为Card.IsCanOverlay）。
	local mg=Duel.SelectMatchingCard(tp,Card.IsCanOverlay,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil)
	if #mg>0 then
		-- 将选择的卡叠放到阿莱斯哈特下面作为超量素材。
		Duel.Overlay(c,mg)
	end
end
-- ③效果的发动代价：chk==0时检查此卡是否有3个超量素材可取除；chk==1时实际取除3个超量素材作为cost。
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,3,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,3,3,REASON_COST)
end
-- 对象过滤条件：该卡可以被里侧表示除外（IsAbleToRemove检查是否满足除外条件）。
function s.rmfilter(c,tp)
	return c:IsAbleToRemove(tp,POS_FACEDOWN)
end
-- ③效果的发动时机与取对象处理：若指定对象则确认其在场上且可里侧除外；若无对象则检查场上是否存在合法对象；然后选择场上1张卡为对象，并登记除外操作信息。
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and s.rmfilter(chkc,tp) end
	-- 发动时合法性检查：场上是否有至少1张满足里侧除外条件的卡可以作为效果对象，存在才能发动。
	if chk==0 then return Duel.IsExistingTarget(s.rmfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,tp) end
	-- 弹出选择提示，让玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择场上1张满足条件的卡作为效果对象，并自动登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,s.rmfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,tp)
	-- 设置操作信息：本次效果将把对象g里侧除外，用于连锁处理后其他卡的能力判断（如星尘龙、王家长眠之谷等）。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- ③效果处理：取得发动时选择的对象卡，若该卡仍与此效果关联，则将其里侧表示除外。
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的唯一对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以里侧表示除外，执行效果处理。
		Duel.Remove(tc,POS_FACEDOWN,REASON_EFFECT)
	end
end

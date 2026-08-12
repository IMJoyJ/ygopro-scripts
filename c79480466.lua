--魂喰魔獣 バズー
-- 效果：
-- 4星怪兽×3
-- ①：只要这张卡在怪兽区域存在，从怪兽取除的超量素材不去墓地而除外。
-- ②：怪兽卡被送去墓地的场合才能发动（同一连锁上最多1次）。这张卡1个超量素材取除。
-- ③：这张卡的超量素材全部被取除的场合，以自己·对方的墓地的卡合计3张为对象才能发动。那些卡作为这张卡的超量素材。
local s,id,o=GetID()
-- 初始化函数：注册卡片效果，包括XYZ召唤手续、①效果（超量素材除外）、②效果（怪兽送墓时取除素材）、③效果（素材全部取除时补充素材）
function s.initial_effect(c)
	-- 开启全局标记，允许监听超量素材被取除的事件
	Duel.EnableGlobalFlag(GLOBALFLAG_DETACH_EVENT)
	-- 添加XYZ召唤手续：4星怪兽×3
	aux.AddXyzProcedure(c,nil,4,3)
	c:EnableReviveLimit()
	-- ①：只要这张卡在怪兽区域存在，从怪兽取除的超量素材不去墓地而除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_TO_GRAVE_REDIRECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(s.rmtg)
	e1:SetTargetRange(0xff,0xff)
	e1:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e1)
	-- ②：怪兽卡被送去墓地的场合才能发动（同一连锁上最多1次）。这张卡1个超量素材取除。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"取除超量素材"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e2:SetCondition(s.ovcon)
	e2:SetTarget(s.ovtg)
	e2:SetOperation(s.ovop)
	c:RegisterEffect(e2)
	-- ③：这张卡的超量素材全部被取除的场合，以自己·对方的墓地的卡合计3张为对象才能发动。那些卡作为这张卡的超量素材。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"获取超量素材"
	e3:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e3:SetCode(EVENT_DETACH_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCondition(s.matcon)
	e3:SetTarget(s.mattg)
	e3:SetOperation(s.matop)
	c:RegisterEffect(e3)
end
-- 过滤需要除外的卡片：作为超量素材被取除（因代价、特殊召唤或效果）而要送去墓地的卡
function s.rmtg(e,c)
	return (c:IsLocation(LOCATION_OVERLAY) or c:IsPreviousLocation(LOCATION_OVERLAY))
		and c:IsReason(REASON_COST+REASON_SPSUMMON+REASON_EFFECT)
end
-- 检查送去墓地的卡片组中是否存在怪兽卡，用于触发②效果
function s.ovcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsType,1,nil,TYPE_MONSTER)
end
-- 检查自身是否能因效果取除1个超量素材，用于②效果的发动准备
function s.ovtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_EFFECT) end
end
-- ②效果的处理：取除这张卡的1个超量素材
function s.ovop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		c:RemoveOverlayCard(tp,1,1,REASON_EFFECT)
	end
end
-- 检查这张卡的超量素材是否全部被取除，用于触发③效果
function s.matcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayGroup():GetCount()==0
end
-- 过滤可以作为超量素材重叠的卡片
function s.mattgfilter(c,sc)
	return c:IsCanOverlay()
end
-- ③效果的靶向处理：选择双方墓地合计3张卡作为对象，并设置操作信息
function s.mattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return false end
	-- 检查双方墓地是否存在合计3张可以作为超量素材的卡
	if chk==0 then return Duel.IsExistingTarget(s.mattgfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,3,nil,c) end
	-- 提示玩家选择要作为超量素材的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 选择双方墓地合计3张卡作为效果的对象
	local g=Duel.SelectTarget(tp,s.mattgfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,3,3,nil,c)
	-- 设置操作信息：选中的卡片将离开墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,#g,0,0)
end
-- 过滤不受效果影响且可以作为超量素材的卡片
function s.mafilter(c,e)
	return not c:IsImmuneToEffect(e) and c:IsCanOverlay()
end
-- ③效果的处理：将选择的3张墓地的卡作为这张卡的超量素材
function s.matop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取仍与连锁相关、不受王家之谷影响且可以作为超量素材的卡片
	local g=Duel.GetTargetsRelateToChain():Filter(aux.NecroValleyFilter(s.mafilter),nil,e)
	if c:IsRelateToChain() and #g>0 then
		-- 将目标卡片重叠作为这张卡的超量素材
		Duel.Overlay(c,g)
	end
end

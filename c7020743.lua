--怒小児様
-- 效果：
-- 1星怪兽×2
-- ①：卡的效果的发动无效的场合才能发动（同一连锁上最多1次）。把自己以及对方的墓地的卡各最多1张作为这张卡的超量素材。
-- ②：这张卡持有的超量素材数量让这张卡得到以下效果。
-- ●1个以上：这张卡的攻击力·守备力上升这张卡的超量素材数量×700。
-- ●4个以上：这张卡不会被战斗·效果破坏。
-- ●8个以上：自己·对方回合，把这张卡4个超量素材取除才能发动。场上的卡全部破坏。
local s,id,o=GetID()
-- 初始化此卡的效果，包括超量召唤手续、①效果（发动无效时叠素材）、②效果（根据素材数量获得攻击力/守备力上升、破坏抗性、场上卡全部破坏的即时诱发效果），以及用于检测发动无效的全局效果。
function s.initial_effect(c)
	-- 添加超量召唤手续：1星怪兽×2。
	aux.AddXyzProcedure(c,nil,1,2)
	c:EnableReviveLimit()
	-- ①：卡的效果的发动无效的场合才能发动（同一连锁上最多1次）。把自己以及对方的墓地的卡各最多1张作为这张卡的超量素材。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"获得超量素材"
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_CHAIN_NEGATED)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e1:SetTarget(s.ovtg)
	e1:SetOperation(s.ovop)
	c:RegisterEffect(e1)
	-- ●1个以上：这张卡的攻击力·守备力上升这张卡的超量素材数量×700。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(s.atkval)
	e2:SetCondition(s.effcon)
	e2:SetLabel(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- ●4个以上：这张卡不会被战斗·效果破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e4:SetValue(1)
	e4:SetCondition(s.effcon)
	e4:SetLabel(4)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e5)
	-- ●8个以上：自己·对方回合，把这张卡4个超量素材取除才能发动。场上的卡全部破坏。
	local e6=Effect.CreateEffect(c)
	e6:SetDescription(aux.Stringid(id,1))  --"破坏"
	e6:SetCategory(CATEGORY_DESTROY)
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetCode(EVENT_FREE_CHAIN)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCondition(s.effcon)
	e6:SetCost(s.descost)
	e6:SetTarget(s.destg)
	e6:SetOperation(s.desop)
	e6:SetLabel(8)
	c:RegisterEffect(e6)
	if not s.global_check then
		s.global_check=true
		-- ①：卡的效果的发动无效的场合才能发动（同一连锁上最多1次）。把自己以及对方的墓地的卡各最多1张作为这张卡的超量素材。②：这张卡持有的超量素材数量让这张卡得到以下效果。●1个以上：这张卡的攻击力·守备力上升这张卡的超量素材数量×700。●4个以上：这张卡不会被战斗·效果破坏。●8个以上：自己·对方回合，把这张卡4个超量素材取除才能发动。场上的卡全部破坏。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAIN_NEGATED)
		ge1:SetOperation(s.negcheck)
		ge1:SetReset(RESET_CHAIN)
		-- 注册全局效果，用于在连锁发动被无效时触发自定义事件。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 全局效果的触发操作：获取当前连锁被无效的信息，并抛出自定义事件。
function s.negcheck(e,tp,eg,ep,ev,re,r,rp)
	-- 获取导致当前连锁发动无效的效果。
	local de=Duel.GetChainInfo(ev,CHAININFO_DISABLE_REASON)
	if de then
		-- 触发自定义事件，通知此卡有效果发动被无效。
		Duel.RaiseEvent(e:GetHandler(),EVENT_CUSTOM+id,de,0,tp,tp,0)
	end
end
-- 过滤函数：检查卡片是否可以作为超量素材，且不受当前效果影响。
function s.ofilter(c,e)
	return c:IsCanOverlay() and (not e or not c:IsImmuneToEffect(e))
end
-- ①效果的发动条件与目标检查：此卡是超量怪兽，且双方墓地存在至少1张可以作为超量素材的卡。
function s.ovtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查可行性：自身为超量怪兽，且双方墓地合计存在至少1张可叠放的卡。
	if chk==0 then return e:GetHandler():IsType(TYPE_XYZ) and Duel.IsExistingMatchingCard(s.ofilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil) end
end
-- 过滤函数：检查卡片的持有者是否为指定玩家。
function s.gchecktp(c,tp)
	return c:GetOwner()==tp
end
-- 组过滤函数：限制选择的卡片组中，自己和对方墓地的卡各最多1张。
function s.gcheck(g,tp)
	return g:FilterCount(s.gchecktp,nil,tp)<=1 and g:FilterCount(s.gchecktp,nil,1-tp)<=1
end
-- ①效果的处理：从双方墓地选择各最多1张卡（合计最多2张，且不能受王家之谷影响），作为此卡的超量素材。
function s.ovop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 获取双方墓地中不受王家之谷影响且可以作为超量素材的卡片组。
		local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.ofilter),tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,e)
		if #g>0 then
			-- 提示玩家选择要作为超量素材的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
			local sg=g:SelectSubGroup(tp,s.gcheck,false,1,2,tp)
			if sg:GetCount()>0 then
				-- 选中卡片的视觉提示效果。
				Duel.HintSelection(sg)
				-- 将选中的卡片重叠作为此卡的超量素材。
				Duel.Overlay(c,sg)
			end
		end
	end
end
-- ②效果的获得条件：检查此卡的超量素材数量是否大于或等于设定的数值（Label值）。
function s.effcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayCount()>=e:GetLabel()
end
-- 攻击力/守备力上升值的计算函数：超量素材数量×700。
function s.atkval(e,c)
	return c:GetOverlayCount()*700
end
-- 破坏效果的Cost：取除此卡的4个超量素材。
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,4,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,4,4,REASON_COST)
end
-- 破坏效果的目标检查与操作信息设置：检查场上是否存在卡，并设置破坏的操作信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查可行性：场上是否存在至少1张卡。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 获取场上的所有卡。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置破坏操作信息，包含场上所有的卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏效果的处理：破坏场上的全部卡。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上的所有卡。
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 因效果破坏选中的卡片组。
	Duel.Destroy(g,REASON_EFFECT)
end

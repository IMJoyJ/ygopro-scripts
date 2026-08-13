--幻影騎士団ラスティ・バルディッシュ
-- 效果：
-- 暗属性怪兽2只以上
-- 这张卡不能作为连接素材。这个卡名的①②的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。从卡组把1只「幻影骑士团」怪兽送去墓地。那之后，从卡组把1张「幻影」魔法·陷阱卡在自己的魔法与陷阱区域盖放。
-- ②：这张卡在怪兽区域存在的状态，这张卡所连接区有暗属性超量怪兽特殊召唤的场合，以场上1张卡为对象才能发动。那张卡破坏。
function c26692769.initial_effect(c)
	-- 为这张卡添加连接召唤手续：以2只以上暗属性连接怪兽为素材才能连接召唤。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkAttribute,ATTRIBUTE_DARK),2)
	c:EnableReviveLimit()
	-- ①：自己主要阶段才能发动。从卡组把1只「幻影骑士团」怪兽送去墓地。那之后，从卡组把1张「幻影」魔法·陷阱卡在自己的魔法与陷阱区域盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,26692769)
	e1:SetTarget(c26692769.target)
	e1:SetOperation(c26692769.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡在怪兽区域存在的状态，这张卡所连接区有暗属性超量怪兽特殊召唤的场合，以场上1张卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetDescription(aux.Stringid(26692769,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,26692770)
	e2:SetCondition(c26692769.descon)
	e2:SetTarget(c26692769.destg)
	e2:SetOperation(c26692769.desop)
	c:RegisterEffect(e2)
	-- 这张卡不能作为连接素材。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
-- 过滤函数：判断卡是否为「幻影骑士团」怪兽且可送去墓地。
function c26692769.tgfilter(c)
	return c:IsSetCard(0x10db) and c:IsAbleToGrave() and c:IsType(TYPE_MONSTER)
end
-- 过滤函数：判断卡是否为「幻影」魔法·陷阱卡且可以盖放。
function c26692769.setfilter(c)
	return c:IsSetCard(0xdb) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- ①效果的发动条件检查：自己主要阶段，且卡组中存在满足条件的「幻影骑士团」怪兽和「幻影」魔法·陷阱卡。
function c26692769.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只「幻影骑士团」怪兽且能送去墓地。
	if chk==0 then return Duel.IsExistingMatchingCard(c26692769.tgfilter,tp,LOCATION_DECK,0,1,nil)
		-- 检查卡组中是否存在至少1张「幻影」魔法·陷阱卡且能盖放。
		and Duel.IsExistingMatchingCard(c26692769.setfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果处理后会有1张卡从卡组送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ①效果的处理：从卡组选1只「幻影骑士团」怪兽送去墓地，那之后从卡组选1张「幻影」魔法·陷阱卡盖放到自己的魔法与陷阱区域。
function c26692769.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组选择1只满足条件的「幻影骑士团」怪兽。
	local g=Duel.SelectMatchingCard(tp,c26692769.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 若成功选择且送去墓地成功，且该卡确实在墓地，则继续后续盖放处理。
	if #g>0 and Duel.SendtoGrave(g,REASON_EFFECT)>0 and g:GetFirst():IsLocation(LOCATION_GRAVE) then
		-- 提示玩家选择要盖放的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		-- 从卡组选择1张满足条件的「幻影」魔法·陷阱卡。
		local tc=Duel.SelectMatchingCard(tp,c26692769.setfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
		if tc then
			-- 中断当前效果，使后续的盖放处理视为不同时处理，避免错失时点。
			Duel.BreakEffect()
			-- 将选择的「幻影」魔法·陷阱卡盖放到自己的魔法与陷阱区域。
			Duel.SSet(tp,tc)
		end
	end
end
-- 过滤函数：判断特殊召唤的怪兽是否为表侧表示、暗属性、超量怪兽，且位于这张卡的连接区。
function c26692769.descfilter(c,lg)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsAttribute(ATTRIBUTE_DARK) and lg:IsContains(c)
end
-- ②效果的触发条件：这张卡仍在怪兽区域，且其连接区有暗属性超量怪兽特殊召唤成功。
function c26692769.descon(e,tp,eg,ep,ev,re,r,rp)
	local lg=e:GetHandler():GetLinkedGroup()
	return eg:IsExists(c26692769.descfilter,1,nil,lg)
end
-- ②效果的发动条件与对象选择：以场上1张卡为对象才能发动，效果处理时破坏那张卡。
function c26692769.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 检查场上是否存在至少1张可以成为对象的卡。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张卡作为效果对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：本次效果会破坏这1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,PLAYER_ALL,LOCATION_ONFIELD)
end
-- ②效果的处理：将对象卡破坏。
function c26692769.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时对象的那张卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以效果原因破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

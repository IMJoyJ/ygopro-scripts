--FNo.0 未来龍皇ホープ
-- 效果：
-- 「No.」怪兽以外的相同阶级的超量怪兽×3
-- 规则上，这张卡的阶级当作1阶使用，这个卡名也当作「未来皇 霍普」卡使用。这张卡也能在自己场上的「未来No.0 未来皇 霍普」上面重叠来超量召唤。
-- ①：这张卡不会被战斗·效果破坏。
-- ②：1回合1次，对方把怪兽的效果发动时，把这张卡1个超量素材取除才能发动。那个发动无效。这个效果把场上的怪兽的效果的发动无效的场合，再得到那个控制权。
function c26973555.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddXyzProcedureLevelFree(c,c26973555.mfilter,c26973555.xyzcheck,3,3,c26973555.ovfilter,aux.Stringid(26973555,0))  --"是否在「未来No.0 未来皇 霍普」上面重叠来超量召唤？"
	-- 对应效果原文：①：这张卡不会被战斗·效果破坏。（本段实现其中不会被战斗破坏的部分）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e2)
	-- 对应效果原文：②：1回合1次，对方把怪兽的效果发动时，把这张卡1个超量素材取除才能发动。那个发动无效。这个效果把场上的怪兽的效果的发动无效的场合，再得到那个控制权。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(26973555,1))
	e3:SetCategory(CATEGORY_NEGATE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c26973555.discon)
	e3:SetCost(c26973555.discost)
	e3:SetTarget(c26973555.distg)
	e3:SetOperation(c26973555.disop)
	c:RegisterEffect(e3)
end
-- 设定此卡在规则上的阶级为1，对应‘规则上，这张卡的阶级当作1阶使用’。
aux.xyz_number[26973555]=0
-- 超量素材过滤条件：选择的素材必须是超量怪兽，且不属于‘No.’怪兽，对应‘「No.」怪兽以外的超量怪兽’。
function c26973555.mfilter(c,xyzc)
	return c:IsXyzType(TYPE_XYZ) and not c:IsSetCard(0x48)
end
-- 检查素材组的阶级种类数是否为1，确保素材阶级相同，对应‘相同阶级的超量怪兽×3’。
function c26973555.xyzcheck(g)
	return g:GetClassCount(Card.GetRank)==1
end
-- 重叠超量召唤的追加素材条件：选择自己场上表侧表示且卡名为「未来No.0 未来皇 霍普」（卡号65305468）的卡，在其上面重叠来超量召唤。
function c26973555.ovfilter(c)
	return c:IsFaceup() and c:IsCode(65305468)
end
-- 效果②的发动条件：对方发动怪兽效果、此卡不在战斗破坏确定状态，且该连锁可被无效。
function c26973555.discon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER) and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED)
		-- 追加条件：对方发动的连锁必须能被无效，此卡的效果才能发动。
		and Duel.IsChainNegatable(ev)
end
-- 效果②的发动代价：检查并取除这张卡的1个超量素材。
function c26973555.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果②的发动时目标设定：默认将使对方发动无效；若对方发动的是场上怪兽的效果且该怪兽仍与连锁关联，则追加夺取其控制权。
function c26973555.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	e:SetCategory(CATEGORY_NEGATE)
	-- 向系统登记本次操作包含‘使对方发动无效’，对象为正在发动的效果，供相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	-- 判定被无效的效果是否发生在主要怪兽区且其效果怪兽仍与所发动的效果保持关联，以决定是否追加控制权。
	if Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)==LOCATION_MZONE and re:GetHandler():IsRelateToEffect(re)
		and not re:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then
		e:SetCategory(CATEGORY_NEGATE+CATEGORY_CONTROL)
		-- 向系统追加登记本次操作包含‘获得那只怪兽的控制权’。
		Duel.SetOperationInfo(0,CATEGORY_CONTROL,eg,1,0,0)
	end
end
-- 效果②的实际处理：无效对方怪兽效果的发动；若满足场上怪兽条件，则继续获得那只怪兽的控制权。
function c26973555.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 实际无效对方连锁；若无效成功且被无效效果发生在场上，则进行后续夺取控制权的处理。
	if Duel.NegateActivation(ev) and Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)==LOCATION_MZONE
		and re:GetHandler():IsRelateToEffect(re) and not re:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then
		-- 使用Duel.BreakEffect将无效发动与获得控制权分为两个效果处理阶段，避免时点被抢占。
		Duel.BreakEffect()
		-- 获得被无效效果的那只场上怪兽的控制权（交给这张卡的控制者）。
		Duel.GetControl(re:GetHandler(),tp)
	end
end

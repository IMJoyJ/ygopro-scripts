--クロノダイバー・レトログラード
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有「时间潜行者」超量怪兽存在，魔法·陷阱卡发动时才能发动。那个发动无效，那张卡在自己场上的「时间潜行者」超量怪兽下面重叠作为超量素材。
function c76587747.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上有「时间潜行者」超量怪兽存在，魔法·陷阱卡发动时才能发动。那个发动无效，那张卡在自己场上的「时间潜行者」超量怪兽下面重叠作为超量素材。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,76587747+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c76587747.condition)
	e1:SetTarget(c76587747.target)
	e1:SetOperation(c76587747.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的「时间潜行者」超量怪兽
function c76587747.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x126) and c:IsType(TYPE_XYZ)
end
-- 过滤条件：自己场上表侧表示且未被战斗破坏的「时间潜行者」超量怪兽
function c76587747.cfilter2(c)
	return c:IsFaceup() and c:IsSetCard(0x126) and c:IsType(TYPE_XYZ) and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 发动条件：自己场上有「时间潜行者」超量怪兽存在，且魔法·陷阱卡发动时才能发动
function c76587747.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的「时间潜行者」超量怪兽
	return Duel.IsExistingMatchingCard(c76587747.cfilter,tp,LOCATION_MZONE,0,1,nil)
		and re:IsHasType(EFFECT_TYPE_ACTIVATE)
		-- 检查该连锁的发动是否可以被无效
		and Duel.IsChainNegatable(ev)
end
-- 效果的目标处理：设置无效发动的操作信息
function c76587747.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：使该魔法·陷阱卡的发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 效果的处理：使发动无效，并将其作为自己场上「时间潜行者」超量怪兽的超量素材
function c76587747.activate(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	-- 如果成功无效了该卡的发动，且该卡与发动的效果存在关联
	if Duel.NegateActivation(ev) and rc:IsRelateToEffect(re) then
		-- 提示玩家选择表侧表示的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		-- 选择自己场上1只表侧表示的「时间潜行者」超量怪兽
		local g=Duel.SelectMatchingCard(tp,c76587747.cfilter2,tp,LOCATION_MZONE,0,1,1,nil)
		if g:GetCount()>0 and not g:GetFirst():IsImmuneToEffect(e) and rc:IsCanOverlay() then
			rc:CancelToGrave()
			-- 将该无效发动的卡重叠作为所选「时间潜行者」超量怪兽的超量素材
			Duel.Overlay(g:GetFirst(),Group.FromCards(rc))
		end
	end
end

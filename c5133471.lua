--ギャラクシー・サイクロン
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：以场上1张里侧表示的魔法·陷阱卡为对象才能发动。那张卡破坏。
-- ②：把这个回合没有送去墓地的这张卡从墓地除外，以场上1张表侧表示的魔法·陷阱卡为对象才能发动。那张卡破坏。
function c5133471.initial_effect(c)
	-- ①：以场上1张里侧表示的魔法·陷阱卡为对象才能发动。那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(5133471,0))  --"破坏盖放的魔法·陷阱卡"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c5133471.target)
	e1:SetOperation(c5133471.activate)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：把这个回合没有送去墓地的这张卡从墓地除外，以场上1张表侧表示的魔法·陷阱卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(5133471,1))  --"破坏表侧表示的魔法·陷阱卡"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,5133471)
	-- 设置②效果的发动条件：这张卡在送去墓地的回合不能发动，即只能在该卡被送去墓地之后的回合发动。
	e2:SetCondition(aux.exccon)
	-- 设置②效果的发动代价：将这张卡自身从墓地除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c5133471.destg)
	e2:SetOperation(c5133471.activate)
	c:RegisterEffect(e2)
end
-- 定义①效果可选择的对象：场上里侧表示的魔法·陷阱卡。
function c5133471.filter(c)
	return c:IsFacedown() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- ①效果的发动时处理：选择场上1张里侧表示的魔法·陷阱卡作为对象，并登记破坏信息。
function c5133471.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c5133471.filter(chkc) and chkc~=e:GetHandler() end
	-- 效果发动合法性检查：场上是否存在符合条件的里侧魔法·陷阱卡可作为对象（且不是发动效果的这张卡本身）。
	if chk==0 then return Duel.IsExistingTarget(c5133471.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 提示玩家从候选对象中选择要破坏的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择1张符合条件的里侧表示魔法·陷阱卡作为效果对象，并登记为本次连锁的对象。
	local g=Duel.SelectTarget(tp,c5133471.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 设置连锁操作信息：本次效果将破坏所选择的对象卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理时的操作：将仍然与该效果关联的对象卡破坏。
function c5133471.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将对象卡破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 定义②效果可选择的对象：场上表侧表示的魔法·陷阱卡。
function c5133471.filter2(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- ②效果的发动时处理：选择场上1张表侧表示的魔法·陷阱卡作为对象，并登记破坏信息。
function c5133471.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c5133471.filter2(chkc) and chkc~=e:GetHandler() end
	-- 效果发动合法性检查：场上是否存在符合条件的表侧魔法·陷阱卡可作为对象（且不是发动效果的这张卡本身）。
	if chk==0 then return Duel.IsExistingTarget(c5133471.filter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 提示玩家从候选对象中选择要破坏的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择1张符合条件的表侧表示魔法·陷阱卡作为效果对象，并登记为本次连锁的对象。
	local g=Duel.SelectTarget(tp,c5133471.filter2,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 设置连锁操作信息：本次效果将破坏所选择的对象卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end

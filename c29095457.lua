--原石の穿光
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把「原石的穿光」以外的手卡1张「原石」卡或1只通常怪兽给对方观看，以场上1张表侧表示卡为对象才能发动（除衍生物外的，通常怪兽或者5星以上的「原石」怪兽在自己场上存在的场合，也能不给人观看来发动）。作为对象的卡的效果无效并除外。
-- ②：自己场上有「原石」怪兽存在的场合，自己主要阶段才能发动。墓地的这张卡在自己场上盖放。
local s,id,o=GetID()
-- 创建主效果和盖放效果
function s.initial_effect(c)
	-- ①：把「原石的穿光」以外的手卡1张「原石」卡或1只通常怪兽给对方观看，以场上1张表侧表示卡为对象才能发动（除衍生物外的，通常怪兽或者5星以上的「原石」怪兽在自己场上存在的场合，也能不给人观看来发动）。作为对象的卡的效果无效并除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上有「原石」怪兽存在的场合，自己主要阶段才能发动。墓地的这张卡在自己场上盖放。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"这张卡盖放 "
	e3:SetCategory(CATEGORY_SSET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.setcon)
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)
end
-- 过滤手卡中非本卡的「原石」卡或通常怪兽且未公开的卡
function s.cfilter(c)
	return not c:IsCode(id) and (c:IsSetCard(0x1b9) or c:IsType(TYPE_NORMAL)) and not c:IsPublic()
end
-- 过滤自己场上表侧表示的非衍生物的通常怪兽或5星以上的「原石」怪兽
function s.confilter(c)
	return c:IsFaceup() and not c:IsType(TYPE_TOKEN)
		and (c:IsType(TYPE_NORMAL) or c:IsSetCard(0x1b9) and c:IsLevelAbove(5))
end
-- 判断是否满足发动条件，若满足则提示是否展示手卡
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断手卡中是否存在符合条件的卡
	local b1=Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil)
	-- 判断自己场上是否存在符合条件的怪兽
	local b2=Duel.IsExistingMatchingCard(s.confilter,tp,LOCATION_MZONE,0,1,nil)
	if chk==0 then return b1 or b2 end
	if b1 then
		-- 若同时满足条件1和条件2，则询问是否展示手卡
		if b2 and not Duel.SelectYesNo(tp,aux.Stringid(id,0)) then return end  --"是否展示卡来发动？"
		-- 提示选择要给对方确认的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		-- 选择一张符合条件的手卡
		local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil)
		-- 向对方展示所选的卡
		Duel.ConfirmCards(1-tp,g)
		-- 洗切自己的手牌
		Duel.ShuffleHand(tp)
	end
end
-- 过滤场上表侧表示且可被无效化的卡
function s.nbfilter(c)
	-- 场上表侧表示且可被无效化且可除外的卡
	return c:IsFaceup() and aux.NegateAnyFilter(c) and c:IsAbleToRemove()
end
-- 设置目标选择逻辑并设定操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and s.nbfilter(chkc) and c~=chkc end
	-- 判断是否存在满足条件的目标
	if chk==0 then return Duel.IsExistingTarget(s.nbfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
	-- 提示选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择一张满足条件的场上卡
	local g=Duel.SelectTarget(tp,s.nbfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c)
	-- 设置操作信息为除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	-- 设置操作信息为无效化
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 处理效果发动后的操作
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsCanBeDisabledByEffect(e) then
		local c=e:GetHandler()
		-- 使目标卡效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 使目标卡效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			-- 若目标为陷阱怪兽则使其陷阱怪兽效果无效
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e3)
		end
		-- 刷新场上卡的无效状态
		Duel.AdjustInstantly()
		-- 使目标卡相关的连锁无效
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 将目标卡除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 过滤自己场上表侧表示的「原石」怪兽
function s.setfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1b9)
end
-- 判断自己场上是否存在「原石」怪兽
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 自己场上存在「原石」怪兽
	return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 设置盖放效果的目标信息
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSSetable() end
	-- 设置操作信息为盖放
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
-- 处理盖放效果的发动
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断卡是否能盖放
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) then Duel.SSet(tp,c) end
end

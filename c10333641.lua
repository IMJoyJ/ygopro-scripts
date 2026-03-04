--超重武者オン－32
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：自己墓地没有魔法·陷阱卡存在的场合，这张卡可以从手卡特殊召唤。
-- ②：自己墓地没有魔法·陷阱卡存在的场合，把这张卡解放，以对方墓地1张魔法·陷阱卡为对象才能发动。那张卡在自己场上盖放。这个效果盖放的卡从场上离开的场合除外。这个效果在对方回合也能发动。
function c10333641.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤 1 回合只能有 1 次。①：自己墓地没有魔法·陷阱卡存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,10333641+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c10333641.spcon)
	c:RegisterEffect(e1)
	-- ②的效果 1 回合只能使用 1 次。②：自己墓地没有魔法·陷阱卡存在的场合，把这张卡解放，以对方墓地 1 张魔法·陷阱卡为对象才能发动。那张卡在自己场上盖放。这个效果盖放的卡从场上离开的场合除外。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,10333642)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCondition(c10333641.setcon)
	e2:SetCost(c10333641.setcost)
	e2:SetTarget(c10333641.settg)
	e2:SetOperation(c10333641.setop)
	c:RegisterEffect(e2)
end
-- 定义效果②的发动条件函数
function c10333641.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己墓地是否存在魔法·陷阱卡，不存在则满足条件
	return not Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_SPELL+TYPE_TRAP)
end
-- 定义特殊召唤程序的条件函数
function c10333641.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判断墓地无魔陷且自己主要怪兽区域有空位
	return c10333641.setcon(e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
end
-- 定义效果②的代价处理函数
function c10333641.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReleasable() end
	-- 将这张卡解放作为代价
	Duel.Release(c,REASON_COST)
end
-- 定义选择对象卡的过滤函数，筛选对方墓地可盖放的魔法·陷阱卡
function c10333641.setfilter(c,ft)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable(true) and (c:IsType(TYPE_FIELD) or ft>0)
end
-- 定义效果②的选择对象处理函数
function c10333641.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取自己魔法与陷阱区域的可用的空格数
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_GRAVE) and c10333641.setfilter(chkc,ft) end
	-- 判断对方墓地是否存在至少 1 张满足条件的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c10333641.setfilter,tp,0,LOCATION_GRAVE,1,nil,ft) end
	-- 向玩家发送选择盖放卡的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	-- 让玩家从对方墓地选择 1 张满足条件的魔法·陷阱卡作为对象
	local g=Duel.SelectTarget(tp,c10333641.setfilter,tp,0,LOCATION_GRAVE,1,1,nil,ft)
	-- 设置操作信息，表明将有卡片离开墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 定义效果②的效果处理函数
function c10333641.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的对象卡
	local tc=Duel.GetFirstTarget()
	-- 若对象卡仍关联效果则将其在自己场上盖放
	if tc:IsRelateToEffect(e) and Duel.SSet(tp,tc)~=0 then
		-- 这个效果盖放的卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		tc:RegisterEffect(e1,true)
	end
end

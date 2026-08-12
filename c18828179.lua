--マザー・ブレイン
-- 效果：
-- 这张卡可以把自己场上存在的1只「海洋怪鱼卫士」解放，从手卡特殊召唤。可以从手卡把1只水属性怪兽丢弃去墓地，场上盖放的1张卡破坏。
function c18828179.initial_effect(c)
	-- 从手卡特殊召唤所需效果，可以解放场上的「海洋怪鱼卫士」进行特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c18828179.spcon)
	e1:SetTarget(c18828179.sptg)
	e1:SetOperation(c18828179.spop)
	c:RegisterEffect(e1)
	-- 可以从手卡把1只水属性怪兽丢弃去墓地，场上盖放的1张卡破坏
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(18828179,0))  --"破坏"
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c18828179.descost)
	e2:SetTarget(c18828179.destg)
	e2:SetOperation(c18828179.desop)
	c:RegisterEffect(e2)
end
-- 判断是否可以解放的卡片过滤器，检查是否为「海洋怪鱼卫士」且有可用怪兽区
function c18828179.rfilter(c,tp)
	return c:IsCode(45045866)
		-- 检查目标卡片是否在场上且有可用怪兽区
		and Duel.GetMZoneCount(tp,c)>0 and (c:IsControler(tp) or c:IsFaceup())
end
-- 判断是否可以发动特殊召唤效果，检查是否有满足条件的「海洋怪鱼卫士」可解放
function c18828179.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查场上是否存在满足条件的「海洋怪鱼卫士」用于特殊召唤
	return Duel.CheckReleaseGroupEx(tp,c18828179.rfilter,1,REASON_SPSUMMON,false,nil,tp)
end
-- 选择并设置要解放的「海洋怪鱼卫士」
function c18828179.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取所有可解放的卡片并筛选出符合条件的「海洋怪鱼卫士」
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c18828179.rfilter,nil,tp)
	-- 提示玩家选择要解放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 执行特殊召唤的解放操作
function c18828179.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 实际将目标卡片解放
	Duel.Release(g,REASON_SPSUMMON)
end
-- 判断是否可以丢弃的水属性怪兽过滤器
function c18828179.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsDiscardable() and c:IsAbleToGraveAsCost()
end
-- 发动破坏效果的费用，丢弃1只水属性怪兽
function c18828179.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否手卡存在满足条件的水属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c18828179.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 执行丢弃手卡中满足条件的水属性怪兽
	Duel.DiscardHand(tp,c18828179.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 判断是否可以破坏的卡片过滤器，检查是否为盖放的卡片
function c18828179.filter(c)
	return c:IsFacedown()
end
-- 选择并设置要破坏的盖放卡片
function c18828179.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c18828179.filter(chkc) end
	-- 检查场上是否存在满足条件的盖放卡片
	if chk==0 then return Duel.IsExistingTarget(c18828179.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上满足条件的盖放卡片作为目标
	local g=Duel.SelectTarget(tp,c18828179.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置破坏效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行破坏效果，将目标卡片破坏
function c18828179.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡片
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFacedown() and tc:IsRelateToEffect(e) then
		-- 实际将目标卡片破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

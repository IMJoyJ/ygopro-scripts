--多元宇宙
-- 效果：
-- 自己的场地区域没有表侧表示卡存在的场合才能把这张卡发动。这个卡名的①的效果1回合只能使用1次。
-- ①：以自己或对方的墓地·除外状态的1张场地魔法卡为对象才能发动。这张卡破坏，作为对象的卡在自己的场地区域表侧表示放置。
-- ②：场地区域的卡被效果破坏的场合，可以作为代替把墓地的这张卡除外。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含发动条件、①效果（起动效果）和②效果（代破效果）。
function s.initial_effect(c)
	-- 自己的场地区域没有表侧表示卡存在的场合才能把这张卡发动。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCondition(s.accon)
	c:RegisterEffect(e0)
	-- ①：以自己或对方的墓地·除外状态的1张场地魔法卡为对象才能发动。这张卡破坏，作为对象的卡在自己的场地区域表侧表示放置。这个卡名的①的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetRange(LOCATION_FZONE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.mvtg)
	e1:SetOperation(s.mvop)
	c:RegisterEffect(e1)
	-- ②：场地区域的卡被效果破坏的场合，可以作为代替把墓地的这张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTarget(s.reptg)
	e2:SetValue(s.repval)
	e2:SetOperation(s.repop)
	c:RegisterEffect(e2)
end
-- 定义卡片发动的条件判定函数。
function s.accon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定自己的场地区域没有表侧表示的卡存在。
	return not Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_FZONE,0,1,nil)
end
-- 定义过滤函数：筛选自己或对方墓地·除外状态的、非禁止且可表侧表示存在的场地魔法卡。
function s.filter(c)
	return c:IsType(TYPE_FIELD) and not c:IsForbidden() and c:IsFaceup()
end
-- 定义①效果的发动准备与目标选择函数。
function s.mvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and s.filter(chkc) end
	-- 检查双方墓地或除外状态是否存在至少1张满足条件的场地魔法卡。
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_REMOVED,1,nil) end
	-- 提示玩家选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 玩家选择1张双方墓地或除外状态的场地魔法卡作为对象。
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_GRAVE+LOCATION_REMOVED,1,1,nil)
	if g:GetFirst():IsLocation(LOCATION_GRAVE) then
		-- 若目标卡在墓地，设置涉及卡片离开墓地的操作信息。
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	end
	-- 设置破坏自身的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 定义①效果的实际处理函数。
function s.mvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的那张场地魔法卡。
	local tc=Duel.GetFirstTarget()
	-- 检查自身是否仍与效果相关，并尝试通过效果破坏自身。
	if c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)~=0
		and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
		-- 将作为对象的场地魔法卡在自己的场地区域表侧表示放置。
		Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
	end
end
-- 定义过滤函数：筛选场地区域因效果被破坏且未处于代破状态的卡。
function s.repfilter(c)
	return c:IsLocation(LOCATION_FZONE) and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
-- 定义②效果的代破目标判定与玩家意愿确认函数。
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(s.repfilter,1,nil,tp) end
	-- 询问玩家是否发动代替破坏的效果。
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 定义代破价值判定函数，确定被破坏的卡是否属于可以被代替破坏的场地区域卡片。
function s.repval(e,c)
	return s.repfilter(c)
end
-- 定义②效果的实际处理函数。
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将墓地的这张卡表侧表示除外。
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end

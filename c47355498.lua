--王家の眠る谷－ネクロバレー
-- 效果：
-- ①：场上的「守墓」怪兽的攻击力·守备力上升500。
-- ②：只要这张卡在场地区域存在，双方不能把墓地的卡除外，对墓地的卡有涉及的效果无效化并且不适用。
function c47355498.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：场上的「守墓」怪兽的攻击力·守备力上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 选择场上所有「守墓」怪兽作为效果的对象
	e2:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x2e))
	e2:SetValue(500)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- ②：只要这张卡在场地区域存在，双方不能把墓地的卡除外。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_REMOVE)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(LOCATION_GRAVE,0)
	e4:SetCondition(c47355498.contp)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetTargetRange(0,LOCATION_GRAVE)
	e5:SetCondition(c47355498.conntp)
	c:RegisterEffect(e5)
	-- ②：只要这张卡在场地区域存在，对墓地的卡有涉及的效果无效化并且不适用。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e6:SetCode(EFFECT_NECRO_VALLEY)
	e6:SetRange(LOCATION_FZONE)
	e6:SetTargetRange(LOCATION_GRAVE,0)
	e6:SetCondition(c47355498.contp)
	c:RegisterEffect(e6)
	local e7=e6:Clone()
	e7:SetTargetRange(0,LOCATION_GRAVE)
	e7:SetCondition(c47355498.conntp)
	c:RegisterEffect(e7)
	-- ②：只要这张卡在场地区域存在，对墓地的卡有涉及的效果无效化并且不适用。
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD)
	e8:SetCode(EFFECT_NECRO_VALLEY)
	e8:SetRange(LOCATION_FZONE)
	e8:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e8:SetTargetRange(1,0)
	e8:SetCondition(c47355498.contp)
	c:RegisterEffect(e8)
	local e9=e8:Clone()
	e9:SetTargetRange(0,1)
	e9:SetCondition(c47355498.conntp)
	c:RegisterEffect(e9)
	-- ②：只要这张卡在场地区域存在，对墓地的卡有涉及的效果无效化并且不适用。
	local e10=Effect.CreateEffect(c)
	e10:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e10:SetCode(EVENT_CHAIN_SOLVING)
	e10:SetRange(LOCATION_FZONE)
	e10:SetOperation(c47355498.disop)
	c:RegisterEffect(e10)
end
-- 判断是否受到「王家长眠之谷」效果影响的条件函数
function c47355498.contp(e)
	-- 若该玩家未被「王家长眠之谷」免疫，则返回true
	return not Duel.IsPlayerAffectedByEffect(e:GetHandler():GetControler(),EFFECT_NECRO_VALLEY_IM)
end
-- 判断是否受到「王家长眠之谷」效果影响的条件函数
function c47355498.conntp(e)
	-- 若对方玩家未被「王家长眠之谷」免疫，则返回true
	return not Duel.IsPlayerAffectedByEffect(1-e:GetHandler():GetControler(),EFFECT_NECRO_VALLEY_IM)
end
-- 用于检测连锁效果中涉及墓地操作的卡牌是否受「王家长眠之谷」影响
function c47355498.disfilter(c,re)
	return c:IsHasEffect(EFFECT_NECRO_VALLEY) and c:IsRelateToEffect(re)
end
-- 检查连锁效果是否涉及对墓地的操作并判断是否应被无效
function c47355498.discheck(ev,category,re,im0,im1)
	-- 获取连锁效果的操作信息，包括目标、数量、玩家等参数
	local ex,tg,ct,p,v=Duel.GetOperationInfo(ev,category)
	if not ex then return false end
	if v==LOCATION_GRAVE and ct>0 then
		if p==0 then return im0
		elseif p==1 then return im1
		elseif p==PLAYER_ALL then return im0 and im1
		end
	end
	if tg and tg:GetCount()>0 then
		return tg:IsExists(c47355498.disfilter,1,nil,re)
	end
	return false
end
-- 处理连锁效果时的无效化操作函数
function c47355498.disop(e,tp,eg,ep,ev,re,r,rp)
	local tc=re:GetHandler()
	-- 若当前连锁效果无法被无效或其发动卡已免疫，则不进行无效化
	if not Duel.IsChainDisablable(ev) or tc:IsHasEffect(EFFECT_NECRO_VALLEY_IM) then return end
	local res=false
	-- 判断玩家0是否未被「王家长眠之谷」免疫
	local im0=not Duel.IsPlayerAffectedByEffect(0,EFFECT_NECRO_VALLEY_IM)
	-- 判断玩家1是否未被「王家长眠之谷」免疫
	local im1=not Duel.IsPlayerAffectedByEffect(1,EFFECT_NECRO_VALLEY_IM)
	if not res and c47355498.discheck(ev,CATEGORY_SPECIAL_SUMMON,re,im0,im1) then res=true end
	if not res and c47355498.discheck(ev,CATEGORY_TOHAND,re,im0,im1) then res=true end
	if not res and c47355498.discheck(ev,CATEGORY_TODECK,re,im0,im1) then res=true end
	if not res and c47355498.discheck(ev,CATEGORY_TOEXTRA,re,im0,im1) then res=true end
	if not res and c47355498.discheck(ev,CATEGORY_LEAVE_GRAVE,re,im0,im1) then res=true end
	if not res and c47355498.discheck(ev,CATEGORY_REMOVE,re,im0,im1) then res=true end
	-- 如果满足条件则使当前连锁效果无效
	if res then Duel.NegateEffect(ev,true) end
end

--マスターモンク
-- 效果：
-- 这张卡不能通常召唤。把自己场上存在的1只「武僧战士」做祭品的场合才能特殊召唤。这张卡1回合可以攻击2次。
function c49814180.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 把自己场上存在的1只「武僧战士」做祭品的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c49814180.spcon)
	e2:SetTarget(c49814180.sptg)
	e2:SetOperation(c49814180.spop)
	c:RegisterEffect(e2)
	-- 这张卡1回合可以攻击2次。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EXTRA_ATTACK)
	e3:SetValue(1)
	c:RegisterEffect(e3)
end
-- 判断是否满足特殊召唤条件所需的过滤器函数，用于筛选场上的「武僧战士」卡片。
function c49814180.spfilter(c,tp)
	return c:IsCode(3810071)
		-- 确保该「武僧战士」存在于场上且有可用怪兽区域。
		and Duel.GetMZoneCount(tp,c)>0 and (c:IsControler(tp) or c:IsFaceup())
end
-- 检查玩家场上是否存在至少1张满足条件的「武僧战士」可解放。
function c49814180.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查玩家场上是否存在至少1张满足条件的「武僧战士」可解放。
	return Duel.CheckReleaseGroupEx(tp,c49814180.spfilter,1,REASON_SPSUMMON,false,nil,tp)
end
-- 设置特殊召唤时的选择处理函数，用于选择要解放的「武僧战士」。
function c49814180.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家可解放的卡片组，并从中筛选出符合条件的「武僧战士」。
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c49814180.spfilter,nil,tp)
	-- 向玩家发送提示信息“请选择要解放的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 设置特殊召唤时的执行处理函数，用于实际进行解放操作。
function c49814180.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将指定卡片以特殊召唤为理由进行解放。
	Duel.Release(g,REASON_SPSUMMON)
end

--ターレット・ウォリアー
-- 效果：
-- 这张卡可以把自己场上存在的1只战士族怪兽解放，从手卡特殊召唤。这个方法特殊召唤的这张卡的攻击力上升解放怪兽的原本攻击力的数值。
function c88559132.initial_effect(c)
	-- 这张卡可以把自己场上存在的1只战士族怪兽解放，从手卡特殊召唤。这个方法特殊召唤的这张卡的攻击力上升解放怪兽的原本攻击力的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c88559132.spcon)
	e1:SetTarget(c88559132.sptg)
	e1:SetOperation(c88559132.spop)
	c:RegisterEffect(e1)
end
-- 过滤满足解放条件的战士族怪兽：属于战士族，且解放后能腾出可用的怪兽区域，且为自己控制或在场上表侧表示
function c88559132.spfilter(c,tp)
	return c:IsRace(RACE_WARRIOR)
		-- 检查该卡解放后是否有可用怪兽区域供自身特殊召唤，且该卡由自己控制或者是场上的表侧表示怪兽
		and Duel.GetMZoneCount(tp,c)>0 and (c:IsControler(tp) or c:IsFaceup())
end
-- 特殊召唤规则的条件函数：检查场上是否存在可用于特殊召唤解放的战士族怪兽
function c88559132.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查玩家场上是否存在至少1张满足过滤条件的可解放卡片
	return Duel.CheckReleaseGroupEx(tp,c88559132.spfilter,1,REASON_SPSUMMON,false,nil,tp)
end
-- 特殊召唤规则的选择函数：让玩家选择1只用于解放的怪兽，并将其保存在效果对象中
function c88559132.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家场上可解放的卡片组，并筛选出满足条件的战士族怪兽
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c88559132.spfilter,nil,tp)
	-- 在客户端提示玩家选择要解放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则的操作函数：解放选定的怪兽，并使自身攻击力上升该怪兽原本攻击力的数值
function c88559132.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local tc=e:GetLabelObject()
	-- 解放选定的怪兽
	Duel.Release(tc,REASON_SPSUMMON)
	local atk=tc:GetBaseAttack()
	if atk<0 then return end
	-- 这个方法特殊召唤的这张卡的攻击力上升解放怪兽的原本攻击力的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(atk)
	e1:SetReset(RESET_EVENT+0xff0000)
	c:RegisterEffect(e1)
end

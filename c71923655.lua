--シャークラーケン
-- 效果：
-- 这张卡可以把自己场上1只水属性怪兽解放，从手卡特殊召唤。
function c71923655.initial_effect(c)
	-- 这张卡可以把自己场上1只水属性怪兽解放，从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c71923655.spcon)
	e1:SetTarget(c71923655.sptg)
	e1:SetOperation(c71923655.spop)
	c:RegisterEffect(e1)
end
-- 过滤满足解放条件的水属性怪兽的函数
function c71923655.spfilter(c,tp)
	return c:IsAttribute(ATTRIBUTE_WATER)
		-- 检查该怪兽解放后是否能让玩家在怪兽区域特殊召唤怪兽，且该怪兽必须由自己控制或者是场上表侧表示的怪兽
		and Duel.GetMZoneCount(tp,c)>0 and (c:IsControler(tp) or c:IsFaceup())
end
-- 特殊召唤规则的条件判定函数，检查场上是否存在可用于特殊召唤解放的怪兽
function c71923655.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查玩家场上是否存在至少1只满足过滤条件、可用于特殊召唤解放的怪兽
	return Duel.CheckReleaseGroupEx(tp,c71923655.spfilter,1,REASON_SPSUMMON,false,nil,tp)
end
-- 特殊召唤规则的目标选择函数，让玩家选择1只用于解放的怪兽，并将其记录在效果对象中
function c71923655.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家场上所有可用于特殊召唤解放的怪兽，并过滤出满足水属性等条件的怪兽组
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c71923655.spfilter,nil,tp)
	-- 给玩家发送“请选择要解放的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则的执行操作函数，解放选定的怪兽
function c71923655.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 以特殊召唤为原因解放选定的怪兽
	Duel.Release(g,REASON_SPSUMMON)
end

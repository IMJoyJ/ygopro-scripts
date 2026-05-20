--サウザンド・アイズ・フィッシュ
-- 效果：
-- 这张卡不能通常召唤，把自己场上存在的1只「海洋怪鱼卫士」解放的场合才能特殊召唤。只要这张卡在自己场上表侧表示存在，对方必须把手卡持续公开。
function c81434470.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 把自己场上存在的1只「海洋怪鱼卫士」解放的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c81434470.spcon)
	e2:SetTarget(c81434470.sptg)
	e2:SetOperation(c81434470.spop)
	c:RegisterEffect(e2)
	-- 只要这张卡在自己场上表侧表示存在，对方必须把手卡持续公开。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_PUBLIC)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_HAND)
	c:RegisterEffect(e3)
end
-- 过滤满足特殊召唤解放条件的「海洋怪鱼卫士」
function c81434470.spfilter(c,tp)
	return c:IsCode(45045866)
		-- 检查解放该卡后是否有可用的怪兽区域，并确认该卡由自己控制或为表侧表示
		and Duel.GetMZoneCount(tp,c)>0 and (c:IsControler(tp) or c:IsFaceup())
end
-- 特殊召唤规则的条件函数，检查场上是否存在可解放的「海洋怪鱼卫士」
function c81434470.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查场上是否存在至少1张可因特殊召唤而解放的「海洋怪鱼卫士」
	return Duel.CheckReleaseGroupEx(tp,c81434470.spfilter,1,REASON_SPSUMMON,false,nil,tp)
end
-- 特殊召唤规则的目标选择函数，让玩家选择1只用于解放的「海洋怪鱼卫士」并记录
function c81434470.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取场上可因特殊召唤解放且满足过滤条件的卡片组
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c81434470.spfilter,nil,tp)
	-- 向玩家发送选择要解放的卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则的操作函数，解放选中的怪兽
function c81434470.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 以特殊召唤为原因解放选中的怪兽
	Duel.Release(g,REASON_SPSUMMON)
end

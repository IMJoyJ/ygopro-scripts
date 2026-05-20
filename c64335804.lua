--レッドアイズ・ブラックメタルドラゴン
-- 效果：
-- 这张卡不能通常召唤。把有「金属化·魔法反射装甲」装备的自己场上1只「真红眼黑龙」解放的场合可以从卡组特殊召唤。
function c64335804.initial_effect(c)
	c:EnableReviveLimit()
	-- 把有「金属化·魔法反射装甲」装备的自己场上1只「真红眼黑龙」解放的场合可以从卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_DECK)
	e1:SetCondition(c64335804.spcon)
	e1:SetTarget(c64335804.sptg)
	e1:SetOperation(c64335804.spop)
	c:RegisterEffect(e1)
end
-- 过滤满足“装备有「金属化·魔法反射装甲」的「真红眼黑龙」”且“解放后有可用怪兽区域”条件的卡片
function c64335804.spfilter(c,tp)
	return c:IsCode(74677422) and c:GetEquipGroup():IsExists(Card.IsCode,1,nil,68540058)
		-- 检查将该怪兽解放后，自己场上是否有可用于特殊召唤的空余怪兽区域
		and Duel.GetMZoneCount(tp,c)>0
end
-- 特殊召唤规则的条件判定函数，检查自己场上是否存在可解放的、满足条件的怪兽
function c64335804.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否存在至少1只满足特殊召唤过滤条件的可解放怪兽
	return Duel.CheckReleaseGroupEx(tp,c64335804.spfilter,1,REASON_SPSUMMON,false,nil,tp)
end
-- 特殊召唤规则的目标选择函数，让玩家选择1只满足条件的怪兽作为解放对象，并将其记录在效果中
function c64335804.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家场上所有可解放的卡片，并筛选出满足特殊召唤过滤条件的怪兽组
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c64335804.spfilter,nil,tp)
	-- 向玩家发送提示信息，要求选择要解放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则的操作执行函数，解放选定的怪兽并洗切卡组
function c64335804.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选定的怪兽以特殊召唤为原因解放
	Duel.Release(g,REASON_SPSUMMON)
	-- 因为是从卡组特殊召唤，在特殊召唤后手动洗切玩家的卡组
	Duel.ShuffleDeck(tp)
end

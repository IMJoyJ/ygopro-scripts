--アームド・ドラゴン LV10
-- 效果：
-- 这张卡不能通常召唤。把自己场上1只「武装龙 LV7」解放的场合才能特殊召唤。
-- ①：把1张手卡送去墓地才能发动。对方场上的表侧表示怪兽全部破坏。
function c59464593.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件为不可特殊召唤（必须通过自身特定的特殊召唤程序进行特殊召唤）
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 把自己场上1只「武装龙 LV7」解放的场合才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c59464593.spcon)
	e2:SetTarget(c59464593.sptg)
	e2:SetOperation(c59464593.spop)
	c:RegisterEffect(e2)
	-- ①：把1张手卡送去墓地才能发动。对方场上的表侧表示怪兽全部破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(59464593,0))  --"破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c59464593.descost)
	e3:SetTarget(c59464593.destg)
	e3:SetOperation(c59464593.desop)
	c:RegisterEffect(e3)
end
c59464593.lvup={73879377}
c59464593.lvdn={73879377,46384672,980973}
-- 过滤特殊召唤所需的解放怪兽（卡名为「武装龙 LV7」，且解放后能空出足够的怪兽区域，且由自己控制或是表侧表示）
function c59464593.spfilter(c,tp)
	return c:IsCode(73879377)
		-- 检查该卡解放后是否能让自身特殊召唤到怪兽区域（怪兽区数量大于0），且该卡必须由自己控制或者是表侧表示
		and Duel.GetMZoneCount(tp,c)>0 and (c:IsControler(tp) or c:IsFaceup())
end
-- 特殊召唤规则的条件判定函数（检查场上是否存在可解放的「武装龙 LV7」）
function c59464593.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查场上是否存在至少1只满足特殊召唤过滤条件的可解放怪兽
	return Duel.CheckReleaseGroupEx(tp,c59464593.spfilter,1,REASON_SPSUMMON,false,nil,tp)
end
-- 特殊召唤规则的目标选择函数（让玩家选择要解放的怪兽，并将其保存在效果标签对象中）
function c59464593.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家场上可解放的卡片组，并过滤出符合特殊召唤条件的「武装龙 LV7」
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c59464593.spfilter,nil,tp)
	-- 给玩家发送提示信息，要求选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则的具体操作函数（解放选定的怪兽）
function c59464593.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 解放选定的怪兽组
	Duel.Release(g,REASON_SPSUMMON)
end
-- 过滤表侧表示怪兽
function c59464593.dfilter(c)
	return c:IsFaceup()
end
-- 破坏效果的发动代价处理函数（将1张手卡送去墓地）
function c59464593.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查发动代价，判断手卡中是否存在至少1张可以作为代价送去墓地的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
	-- 给玩家发送提示信息，要求选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家选择1张手卡作为代价送去墓地
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选定的手卡作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 破坏效果的发动准备与目标确认函数
function c59464593.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1只表侧表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c59464593.dfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有的表侧表示怪兽
	local g=Duel.GetMatchingGroup(c59464593.dfilter,tp,0,LOCATION_MZONE,nil)
	-- 设置效果处理的操作信息，声明此效果将破坏对方场上的所有表侧表示怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 破坏效果的具体执行函数
function c59464593.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前对方场上所有的表侧表示怪兽
	local g=Duel.GetMatchingGroup(c59464593.dfilter,tp,0,LOCATION_MZONE,nil)
	-- 因效果破坏选定的怪兽组
	Duel.Destroy(g,REASON_EFFECT)
end

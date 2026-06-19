--デビルマゼラ
-- 效果：
-- 这张卡不能进行通常召唤。这张卡仅当场上存在「万魔殿-恶魔的巢窟-」时，祭掉自己场上1只以表侧表示存在的「杰拉的战士」才能特殊召唤。这张卡特殊召唤成功时，对方随机丢弃3张手卡。此效果仅当自己场上存在「万魔殿-恶魔的巢窟-」时才适用。
function c6133894.initial_effect(c)
	-- 注册卡片关联密码（杰拉的战士、万魔殿-恶魔的巢窟-）
	aux.AddCodeList(c,66073051,94585852)
	c:EnableReviveLimit()
	-- 这张卡不能进行通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 这张卡仅当场上存在「万魔殿-恶魔的巢窟-」时，祭掉自己场上1只以表侧表示存在的「杰拉的战士」才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c6133894.spcon)
	e2:SetTarget(c6133894.sptg)
	e2:SetOperation(c6133894.spop)
	c:RegisterEffect(e2)
	-- 这张卡特殊召唤成功时，对方随机丢弃3张手卡。此效果仅当自己场上存在「万魔殿-恶魔的巢窟-」时才适用。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(6133894,0))
	e3:SetCategory(CATEGORY_HANDES_OPPO)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetTarget(c6133894.hdtg)
	e3:SetOperation(c6133894.hdop)
	c:RegisterEffect(e3)
end
-- 定义解放怪兽的过滤条件函数
function c6133894.rfilter(c,tp)
	-- 检查怪兽是否为表侧表示的「杰拉的战士」，且解放后能让出可用的怪兽区域
	return c:IsFaceup() and c:IsCode(66073051) and Duel.GetMZoneCount(tp,c)>0
end
-- 定义特殊召唤规则的条件检查函数
function c6133894.spcon(e,c)
	-- 在手牌特召规则预检时，检查场上是否存在「万魔殿-恶魔的巢窟-」
	if c==nil then return Duel.IsEnvironment(94585852) end
	-- 检查自己场上是否存在至少1只可解放的怪兽
	return Duel.CheckReleaseGroupEx(c:GetControler(),c6133894.rfilter,1,REASON_SPSUMMON,false,nil,c:GetControler())
end
-- 定义特殊召唤规则的目标选择函数
function c6133894.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取并筛选自己场上可解放的「杰拉的战士」
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c6133894.rfilter,nil,tp)
	-- 提示玩家选择要解放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 定义特殊召唤规则的执行操作函数
function c6133894.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 解放选中的怪兽
	Duel.Release(g,REASON_SPSUMMON)
end
-- 定义丢弃手牌效果的发动准备与目标确认函数
function c6133894.hdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_HANDES_OPPO,nil,0,1-tp,3)
end
-- 定义丢弃手牌效果的执行操作函数
function c6133894.hdop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在「万魔殿-恶魔的巢窟-」
	if Duel.IsEnvironment(94585852,tp) then
		-- 随机选择对方的3张手牌
		local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND):RandomSelect(tp,3)
		-- 将选中的手牌以效果丢弃送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)
	end
end

--鎧皇竜－サイバー・ダーク・エンド・ドラゴン
-- 效果：
-- 「铠黑龙-电子暗黑龙」＋「电子终结龙」
-- 这张卡用融合召唤以及以下方法才能特殊召唤。
-- ●把有「电子终结龙」装备的1只自己的10星以下的「电子暗黑」融合怪兽解放的场合可以从额外卡组特殊召唤。
-- ①：这张卡不受对方发动的效果影响。
-- ②：1回合1次，可以发动。选自己·对方的墓地1只怪兽给这张卡装备。
-- ③：这张卡在同1次的战斗阶段中可以作出最多有这张卡的装备卡数量的攻击。
function c37542782.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用卡号为40418351和1546123的2只怪兽为融合素材
	aux.AddFusionProcCode2(c,40418351,1546123,true,true)
	-- 这张卡用融合召唤以及以下方法才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该卡只能通过融合召唤特殊召唤
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	-- ●把有「电子终结龙」装备的1只自己的10星以下的「电子暗黑」融合怪兽解放的场合可以从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetCondition(c37542782.hspcon)
	e2:SetTarget(c37542782.hsptg)
	e2:SetOperation(c37542782.hspop)
	c:RegisterEffect(e2)
	-- ①：这张卡不受对方发动的效果影响。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(c37542782.efilter)
	c:RegisterEffect(e3)
	-- ②：1回合1次，可以发动。选自己·对方的墓地1只怪兽给这张卡装备。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(37542782,0))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(c37542782.eqtg)
	e4:SetOperation(c37542782.eqop)
	c:RegisterEffect(e4)
	-- ③：这张卡在同1次的战斗阶段中可以作出最多有这张卡的装备卡数量的攻击。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_EXTRA_ATTACK)
	e5:SetValue(c37542782.atkval)
	c:RegisterEffect(e5)
end
-- 过滤函数，检查是否为装备有1546123的1546123的卡
function c37542782.eqspfilter(c)
	return c:IsFaceup() and c:IsCode(1546123)
end
-- 过滤函数，检查是否为10星以下的电子暗黑融合怪兽且有装备1546123且可作为融合素材
function c37542782.hspfilter(c,tp,sc)
	return c:IsLevelBelow(10) and c:IsSetCard(0x4093) and c:IsFusionType(TYPE_FUSION)
		-- 检查该怪兽是否为10星以下且为电子暗黑融合怪兽且有装备1546123且可作为融合素材
		and c:IsControler(tp) and c:GetEquipGroup():IsExists(c37542782.eqspfilter,1,nil) and Duel.GetLocationCountFromEx(tp,tp,c,sc)>0
		and c:IsCanBeFusionMaterial(sc,SUMMON_TYPE_SPECIAL)
end
-- 检查是否有满足条件的怪兽可作为解放对象
function c37542782.hspcon(e,c)
	if c==nil then return true end
	-- 检查是否有满足条件的怪兽可作为解放对象
	return Duel.CheckReleaseGroupEx(c:GetControler(),c37542782.hspfilter,1,REASON_SPSUMMON,false,nil,c:GetControler(),c)
end
-- 选择满足条件的怪兽作为解放对象
function c37542782.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取满足条件的怪兽组
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c37542782.hspfilter,nil,tp,c)
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 执行解放操作
function c37542782.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local tc=e:GetLabelObject()
	c:SetMaterial(Group.FromCards(tc))
	-- 实际进行解放操作
	Duel.Release(tc,REASON_SPSUMMON)
end
-- 效果过滤函数，判断是否为对方发动且已发动的效果
function c37542782.efilter(e,re)
	return e:GetHandlerPlayer()~=re:GetOwnerPlayer() and re:IsActivated()
end
-- 过滤函数，检查是否为可装备的怪兽
function c37542782.eqfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and (c:IsControler(tp) or c:IsAbleToChangeControler())
		and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- 判断是否满足装备效果发动条件
function c37542782.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的装备区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断墓地是否有可装备的怪兽
		and Duel.IsExistingMatchingCard(c37542782.eqfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,tp) end
	-- 获取墓地中的所有怪兽
	local g=Duel.GetFieldGroup(tp, LOCATION_GRAVE, LOCATION_GRAVE)
	-- 设置操作信息，表示将有怪兽从墓地离开
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 执行装备操作
function c37542782.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (c:IsFaceup() and c:IsRelateToEffect(e)) then return end
	-- 判断场上是否有足够的装备区域
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择满足条件的怪兽进行装备
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c37542782.eqfilter),tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,tp)
	local tc=g:GetFirst()
	if tc then
		-- 执行装备操作
		if not Duel.Equip(tp,tc,c) then return end
		-- 设置装备限制效果，确保只能装备给该卡
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetLabelObject(c)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c37542782.eqlimit)
		tc:RegisterEffect(e1)
	end
end
-- 装备限制效果的过滤函数，确保只能装备给指定的卡
function c37542782.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 计算攻击次数，等于装备卡数量减一
function c37542782.atkval(e,c)
	return e:GetHandler():GetEquipCount()-1
end

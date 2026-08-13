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
	-- 为这张卡添加融合召唤手续，融合素材为「铠黑龙-电子暗黑龙」和「电子终结龙」。
	aux.AddFusionProcCode2(c,40418351,1546123,true,true)
	-- 这张卡用融合召唤以及以下方法才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件判定为仅允许通过融合召唤（SUMMON_TYPE_FUSION）进行特殊召唤。
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
-- 用于判定一张卡是否为表侧表示的「电子终结龙」（卡号1546123），以检查装备区是否存在该装备卡。
function c37542782.eqspfilter(c)
	return c:IsFaceup() and c:IsCode(1546123)
end
-- 过滤出可作为特殊召唤替代素材的怪兽：自己场上、10星以下、属「电子暗黑」系列的融合怪兽，且装备区有「电子终结龙」，并满足额外区空位及可作融合素材的条件。
function c37542782.hspfilter(c,tp,sc)
	return c:IsLevelBelow(10) and c:IsSetCard(0x4093) and c:IsFusionType(TYPE_FUSION)
		-- 追加条件：该怪兽必须由我方控制，其装备区存在「电子终结龙」，且解放后额外怪兽区有空位供这张卡特殊召唤。
		and c:IsControler(tp) and c:GetEquipGroup():IsExists(c37542782.eqspfilter,1,nil) and Duel.GetLocationCountFromEx(tp,tp,c,sc)>0
		and c:IsCanBeFusionMaterial(sc,SUMMON_TYPE_SPECIAL)
end
-- 特殊召唤手续的条件函数：判断是否满足通过解放装备「电子终结龙」的电子暗黑融合怪兽来特殊召唤的条件。
function c37542782.hspcon(e,c)
	if c==nil then return true end
	-- 检查我方是否存在至少1只满足hspfilter条件的可解放怪兽（解放原因为特殊召唤）。
	return Duel.CheckReleaseGroupEx(c:GetControler(),c37542782.hspfilter,1,REASON_SPSUMMON,false,nil,c:GetControler(),c)
end
-- 特殊召唤手续的目标选择函数：从满足条件的解放候补中选择1只怪兽，并保存到效果中供后续处理使用。
function c37542782.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取当前可作为特殊召唤解放的怪兽组，并筛选出满足hspfilter条件的候选。
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c37542782.hspfilter,nil,tp,c)
	-- 提示玩家选择要解放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤手续的处理函数：将选定的怪兽作为素材解放，并将这张卡的素材信息设为该怪兽。
function c37542782.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local tc=e:GetLabelObject()
	c:SetMaterial(Group.FromCards(tc))
	-- 以特殊召唤为解放原因解放选定的怪兽。
	Duel.Release(tc,REASON_SPSUMMON)
end
-- 效果免疫的判定函数：仅当效果发动者不是这张卡的控制者且该效果已经发动时，才视为对方发动的效果而免疫。
function c37542782.efilter(e,re)
	return e:GetHandlerPlayer()~=re:GetOwnerPlayer() and re:IsActivated()
end
-- 从墓地选择装备卡的过滤条件：必须是怪兽，且属于自己或允许变更控制权（以支持选择双方墓地），不是禁止卡，并满足同名卡限制。
function c37542782.eqfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and (c:IsControler(tp) or c:IsAbleToChangeControler())
		and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- ②的发动条件与目标设置：要求魔陷区有空位且双方墓地存在可装备的怪兽，并登记操作信息。
function c37542782.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件：自己魔陷区必须存在空位（用于放置装备卡）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 发动条件：双方墓地存在至少1只满足eqfilter条件的怪兽。
		and Duel.IsExistingMatchingCard(c37542782.eqfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,tp) end
	-- 获取双方墓地的全部卡作为集合，用于设置操作信息。
	local g=Duel.GetFieldGroup(tp, LOCATION_GRAVE, LOCATION_GRAVE)
	-- 设置操作信息为CATEGORY_LEAVE_GRAVE，标记该效果可能使墓地的卡离开墓地（供王家长眠之谷等效果对应）。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- ②的效果处理：选择双方墓地1只符合条件的怪兽装备给这张卡，若成功则给装备卡加上只能装备给这张卡的限制效果。
function c37542782.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not (c:IsFaceup() and c:IsRelateToEffect(e)) then return end
	-- 处理时再次确认魔陷区有空位，若无则中止处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 提示玩家选择要装备的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从双方墓地中选择1只满足eqfilter且不受王家长眠之谷影响的怪兽作为装备卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c37542782.eqfilter),tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽卡装备给这张卡，若装备失败则中止处理。
		if not Duel.Equip(tp,tc,c) then return end
		-- 选自己·对方的墓地1只怪兽给这张卡装备。
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
-- 装备限制的判定函数：装备对象只能是这张铠皇龙本体，其他卡不能装备。
function c37542782.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 计算额外攻击次数：装备卡数量-1，使总攻击次数等于装备卡数量。
function c37542782.atkval(e,c)
	return e:GetHandler():GetEquipCount()-1
end

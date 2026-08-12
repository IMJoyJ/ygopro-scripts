--焔聖騎士－テュルパン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有把装备卡装备的怪兽存在的场合才能发动。这张卡从手卡·墓地特殊召唤。这个效果从墓地特殊召唤的这张卡从场上离开的场合除外。
-- ②：这张卡在墓地存在的场合，以自己场上1只战士族怪兽为对象才能发动。这张卡当作装备魔法卡使用给那只自己怪兽装备。
-- ③：把装备怪兽作为同调素材的场合，可以当作调整使用。
local s,id,o=GetID()
-- 注册卡片效果：①手卡·墓地特殊召唤，②墓地当作装备卡装备，③装备怪兽作为同调素材时当作调整。
function s.initial_effect(c)
	-- ①：自己场上有把装备卡装备的怪兽存在的场合才能发动。这张卡从手卡·墓地特殊召唤。这个效果从墓地特殊召唤的这张卡从场上离开的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"这张卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，以自己场上1只战士族怪兽为对象才能发动。这张卡当作装备魔法卡使用给那只自己怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"这张卡当作装备"
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
	-- ③：把装备怪兽作为同调素材的场合，可以当作调整使用。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_TUNER)
	e3:SetValue(s.tunerval)
	c:RegisterEffect(e3)
end
-- 过滤条件：场上装备有装备卡的怪兽。
function s.eqpfilter(c)
	return c:GetEquipCount()>0
end
-- 效果①的发动条件：自己场上存在装备有装备卡的怪兽。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只装备有装备卡的怪兽。
	return Duel.IsExistingMatchingCard(s.eqpfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果①的发动准备与合法性检测（检查怪兽区域空位及自身是否能特殊召唤）。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有可用的怪兽区域空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 向对方玩家提示发动了“这张卡特殊召唤”的效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置连锁信息：包含特殊召唤自身的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果①的处理：特殊召唤自身，若从墓地特殊召唤则添加离场除外的限制。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查怪兽区域是否有空位且此卡是否仍与效果相关联。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsRelateToEffect(e)
		-- 成功将此卡以表侧表示特殊召唤，并检查其特殊召唤时的出处是否为墓地。
		and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 and c:IsSummonLocation(LOCATION_GRAVE) then
		-- 这个效果从墓地特殊召唤的这张卡从场上离开的场合除外。②：这张卡在墓地存在的场合，以自己场上1只战士族怪兽为对象才能发动。这张卡当作装备魔法卡使用给那只自己怪兽装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		c:RegisterEffect(e1,true)
	end
end
-- 过滤条件：自己场上表侧表示的战士族怪兽。
function s.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR)
end
-- 效果②的发动准备与对象选择（检查魔法与陷阱区域空位、自身是否能装备、选择战士族怪兽作为对象）。
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	-- 检查自己场上是否有可用的魔法与陷阱区域空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and c:CheckUniqueOnField(tp) and not c:IsForbidden()
		-- 检查自己场上是否存在可以作为装备对象的表侧表示战士族怪兽。
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向对方玩家提示发动了“这张卡当作装备”的效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 提示玩家选择要装备的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只表侧表示的战士族怪兽作为效果对象。
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置连锁信息：包含此卡离开墓地的操作。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
-- 效果②的处理：检查自身及对象状态，若不满足装备条件则送去墓地，否则将自身装备给目标怪兽。
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 获取效果②选择的装备对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 检查自己场上的魔法与陷阱区域是否已无空位。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0
		or tc:IsControler(1-tp) or tc:IsFacedown() or not tc:IsRelateToEffect(e)
		or not c:CheckUniqueOnField(tp) or c:IsForbidden() then
		-- 因规则原因将此卡送去墓地（无法合法装备时）。
		Duel.SendtoGrave(c,REASON_RULE)
		return
	end
	-- 尝试将此卡作为装备卡装备给目标怪兽，若失败则结束处理。
	if not Duel.Equip(tp,c,tc) then return end
	-- 这张卡当作装备魔法卡使用给那只自己怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(s.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
end
-- 装备限制：此卡只能装备给作为效果对象的怪兽。
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 调整判定：限制只有自己场上的怪兽作为同调素材时，装备怪兽才能当作调整使用。
function s.tunerval(e,sc)
	return sc:IsControler(e:GetHandlerPlayer())
end

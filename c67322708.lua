--DDランス・ソルジャー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1只「DD」怪兽为对象才能发动。那只怪兽的等级上升最多有自己的场上·墓地的「契约书」卡数量的数值。
-- ②：这张卡在墓地存在的场合，以自己场上1张「契约书」卡为对象才能发动。那张卡破坏，这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
local s,id,o=GetID()
-- 注册卡片效果：①效果（场上起动，上升等级）和②效果（墓地起动，破坏契约书特召并离场除外）。
function s.initial_effect(c)
	-- ①：以自己场上1只「DD」怪兽为对象才能发动。那只怪兽的等级上升最多有自己的场上·墓地的「契约书」卡数量的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"上升等级"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.lvtg)
	e1:SetOperation(s.lvop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，以自己场上1张「契约书」卡为对象才能发动。那张卡破坏，这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.spdtg)
	e2:SetOperation(s.spdop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示、等级1以上的「DD」怪兽。
function s.lvfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xaf) and c:IsLevelAbove(1)
end
-- 过滤条件：自己场上表侧表示或墓地的「契约书」卡。
function s.cfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0xae)
end
-- ①效果的发动准备与对象选择：如果进行对象确认，检查该对象是否是自己场上的表侧表示「DD」怪兽。
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.lvfilter(chkc)
		and chkc:IsControler(tp) end
	-- 检查自己场上是否存在可以作为对象的表侧表示「DD」怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.lvfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 并且自己场上或墓地存在至少1张「契约书」卡。
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的「DD」怪兽作为效果对象。
	Duel.SelectTarget(tp,s.lvfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ①效果的处理：获取对象怪兽和「契约书」卡数量，让玩家宣言要上升的等级并适用。
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的怪兽。
	local tc=Duel.GetFirstTarget()
	-- 计算自己场上及墓地的「契约书」卡的总数。
	local ct=Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,nil)
	if tc:IsFaceup() and tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) and ct>0 then
		-- 提示玩家选择要上升的等级。
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))  --"请选择上升的等级"
		-- 让玩家宣言一个介于1到「契约书」卡数量之间的等级数值。
		local lv=Duel.AnnounceLevel(tp,1,ct)
		-- 那只怪兽的等级上升最多有自己的场上·墓地的「契约书」卡数量的数值。
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(lv)
		tc:RegisterEffect(e1)
	end
end
-- 过滤条件：自己场上表侧表示的「契约书」卡，且该卡被破坏后能空出可用的怪兽区域。
function s.desfilter(c,tp)
	-- 检查卡片是否为表侧表示的「契约书」卡，且该卡离开场上后自己场上有可用于特殊召唤的怪兽区域。
	return c:IsFaceup() and c:IsSetCard(0xae) and Duel.GetMZoneCount(tp,c)>0
end
-- ②效果的发动准备与对象选择：如果进行对象确认，检查该对象是否是自己场上满足条件的「契约书」卡。
function s.spdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and s.desfilter(chkc,tp) end
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 并且自己场上存在可以作为破坏对象的「契约书」卡。
		and Duel.IsExistingTarget(s.desfilter,tp,LOCATION_ONFIELD,0,1,nil,tp) end
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1张表侧表示的「契约书」卡作为效果对象。
	local g=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp)
	-- 设置连锁信息：包含破坏该「契约书」卡的操作。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置连锁信息：包含将墓地的这张卡特殊召唤的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ②效果的处理：破坏作为对象的「契约书」卡，将这张卡特殊召唤，并添加离场除外的约束。
function s.spdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为破坏对象的「契约书」卡。
	local tc=Duel.GetFirstTarget()
	-- 如果对象卡仍存在于连锁中，则将其因效果破坏。若破坏成功，则继续处理。
	if tc:IsRelateToChain() and Duel.Destroy(tc,REASON_EFFECT)~=0
		-- 检查墓地的这张卡是否仍存在于连锁中，且不受王家长眠之谷的影响。
		and c:IsRelateToChain() and aux.NecroValleyFilter()(c)
		-- 将这张卡以表侧表示特殊召唤到自己场上。若特殊召唤成功，则继续处理。
		and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end

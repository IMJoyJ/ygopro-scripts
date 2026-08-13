--DDD死謳王バイス・レクイエム
-- 效果：
-- ←4 【灵摆】 4→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：以自己场上的「契约书」卡任意数量为对象才能发动。那些卡破坏，这张卡特殊召唤。那之后，可以让这张卡的等级上升或下降破坏数量的数值。
-- 【怪兽效果】
-- 这个卡名的②的怪兽效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，自己不是「DDD」怪兽不能特殊召唤。
-- ②：场上的这张卡为素材作融合·同调·超量·连接召唤的「DDD」怪兽得到以下效果。
-- ●1回合1次，以场上1张卡为对象才能发动。从自己的场上（表侧表示）·墓地让1张「契约书」卡回到卡组，作为对象的卡破坏。那之后，自己回复1000基本分。
function c25857977.initial_effect(c)
	-- 调用aux.EnablePendulumAttribute为这张卡启用灵摆怪兽属性，使其能够作为灵摆卡在灵摆区域发动并参与灵摆召唤。
	aux.EnablePendulumAttribute(c)
	-- 这个卡名的灵摆效果1回合只能使用1次。①：以自己场上的「契约书」卡任意数量为对象才能发动。那些卡破坏，这张卡特殊召唤。那之后，可以让这张卡的等级上升或下降破坏数量的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25857977,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,25857977)
	e1:SetTarget(c25857977.sptg)
	e1:SetOperation(c25857977.spop)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在怪兽区域存在，自己不是「DDD」怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c25857977.splimit)
	c:RegisterEffect(e2)
	-- 这个卡名的②的怪兽效果1回合只能使用1次。②：场上的这张卡为素材作融合·同调·超量·连接召唤的「DDD」怪兽得到以下效果。●1回合1次，以场上1张卡为对象才能发动。从自己的场上（表侧表示）·墓地让1张「契约书」卡回到卡组，作为对象的卡破坏。那之后，自己回复1000基本分。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e3:SetCountLimit(1,25857978)
	e3:SetCondition(c25857977.effcon)
	e3:SetOperation(c25857977.effop)
	c:RegisterEffect(e3)
end
-- 过滤条件：卡片为表侧表示且属于「契约书」卡（0xae）。
function c25857977.desfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xae)
end
-- 过滤条件：在前者基础上，该卡还必须能够成为当前效果的对象（IsCanBeEffectTarget）。
function c25857977.desfilter2(c,e)
	return c25857977.desfilter(c) and c:IsCanBeEffectTarget(e)
end
-- 灵摆效果的发动条件与对象选择：选择自己场上任意数量（至少1张）表侧表示「契约书」卡为对象，并确认这张卡能够特殊召唤且选择后仍有足够的怪兽区域空格。
function c25857977.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c25857977.desfilter(chkc) end
	-- 取得自己场上所有满足desfilter2条件的「契约书」卡（表侧表示且可成为效果对象）。
	local g=Duel.GetMatchingGroup(c25857977.desfilter2,tp,LOCATION_ONFIELD,0,nil,e)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查这些「契约书」卡中存在一个子组，将其作为素材处理（破坏）后玩家tp场上仍有可用怪兽区域空格，以保证特殊召唤可行。
		and g:CheckSubGroup(aux.mzctcheck,1,g:GetCount(),tp) end
	-- 向操作者发出选择提示：请选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从候选中选择1到全部张「契约书」卡，所选集合需满足破坏后仍有特召空位，返回选择的卡片组sg。
	local sg=g:SelectSubGroup(tp,aux.mzctcheck,false,1,g:GetCount(),tp)
	-- 将选择的卡片组sg登记为当前连锁的效果对象（取对象）。
	Duel.SetTargetCard(sg)
	-- 设置操作信息：本连锁将破坏sg中的卡，数量为sg的卡片数。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
	-- 设置操作信息：本连锁将特殊召唤这张卡（e:GetHandler()）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 处理灵摆效果：破坏对象卡，若破坏数不为0且这张卡仍与效果相关，则将其特殊召唤；若特殊召唤成功，再根据破坏数量选择是否改变等级。
function c25857977.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 从连锁对象中筛选出仍然与效果相关的卡（未离场或未被无效），作为实际要破坏的集合。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 破坏这些对象卡，返回实际被破坏的数量ct。
	local ct=Duel.Destroy(g,REASON_EFFECT)
	if ct~=0 then
		local c=e:GetHandler()
		-- 若这张卡仍然与效果相关且成功特殊召唤到场上（返回非0），则继续处理等级变更。
		if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
			local res=0
			if c:GetLevel()==1 then
				-- 当这张卡等级为1时，弹出选项：不改变等级或上升等级（等级不能降至0）。
				res=Duel.SelectOption(tp,aux.Stringid(25857977,2),aux.Stringid(25857977,3))  --"不改变等级/上升等级"
			else
				-- 当等级大于1时，弹出选项：不改变等级、上升等级或下降等级。
				res=Duel.SelectOption(tp,aux.Stringid(25857977,2),aux.Stringid(25857977,3),aux.Stringid(25857977,4))  --"不改变等级/上升等级/下降等级"
			end
			if res>0 then
				-- 那之后，可以让这张卡的等级上升或下降破坏数量的数值。
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_LEVEL)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				if res==1 then
					e1:SetValue(ct)
				else
					e1:SetValue(-ct)
				end
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				c:RegisterEffect(e1)
			end
		end
	end
end
-- 特殊召唤限制的过滤条件：若被特殊召唤的怪兽不是「DDD」族（0x10af），则禁止其特殊召唤。
function c25857977.splimit(e,c,tp,sumtp,sumpos)
	return not c:IsSetCard(0x10af)
end
-- 作为素材时的触发条件：被用于融合·同调·超量·连接召唤，且这张卡之前在场上，并且所召唤出的怪兽是「DDD」怪兽。
function c25857977.effcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_FUSION+REASON_SYNCHRO+REASON_XYZ+REASON_LINK)~=0 and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
		and e:GetHandler():GetReasonCard():IsSetCard(0x10af)
end
-- 处理作为素材时的效果：给召唤出的「DDD」怪兽注册‘1回合1次破坏场上卡’的效果；若该怪兽不是效果怪兽则补上效果怪兽类型，并附加效果提示标记。
function c25857977.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- ●1回合1次，以场上1张卡为对象才能发动。从自己的场上（表侧表示）·墓地让1张「契约书」卡回到卡组，作为对象的卡破坏。那之后，自己回复1000基本分。
	local e1=Effect.CreateEffect(rc)
	e1:SetDescription(aux.Stringid(25857977,1))  --"破坏卡片（DDD 死讴王 恶德镇魂神）"
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_DESTROY+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c25857977.destg)
	e1:SetOperation(c25857977.desop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	if not rc:IsType(TYPE_EFFECT) then
		-- ●1回合1次，以场上1张卡为对象才能发动。从自己的场上（表侧表示）·墓地让1张「契约书」卡回到卡组，作为对象的卡破坏。那之后，自己回复1000基本分。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e2,true)
	end
	rc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(25857977,5))  --"「DDD 死讴王 恶德镇魂神」效果适用中"
end
-- 破坏对象的额外条件：场上存在另一张能够返回卡组的「契约书」卡（自己场上表侧或墓地），否则不能选择该卡为破坏对象。
function c25857977.desfilter3(c,tp)
	-- 检查是否存在至少1张满足tdfilter的「契约书」卡（自己场上表侧或墓地），且该卡不是当前候选对象。
	return Duel.IsExistingMatchingCard(c25857977.tdfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,c)
end
-- 返回卡组筛选条件：若是场上卡则需表侧表示，或在墓地，并且属于「契约书」卡且允许返回卡组。
function c25857977.tdfilter(c)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsSetCard(0xae) and c:IsAbleToDeck()
end
-- 已赋予效果的发动条件与对象选择：选择场上1张卡为对象，且必须存在可返回卡组的「契约书」卡；同时设置破坏与回卡组的操作信息。
function c25857977.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c25857977.desfilter3(chkc,tp) end
	-- 发动合法性检查：场上是否存在1张满足desfilter3条件的卡可作为对象（即存在另一张可回卡组的契约书）。
	if chk==0 then return Duel.IsExistingTarget(c25857977.desfilter3,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,tp) end
	-- 向操作者发出选择提示：请选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张满足条件的卡为效果对象，并登记到当前连锁。
	local g=Duel.SelectTarget(tp,c25857977.desfilter3,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,tp)
	-- 设置操作信息：本连锁将破坏对象卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息：本连锁将从自己场上（表侧表示）或墓地中选择1张「契约书」卡返回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_ONFIELD+LOCATION_GRAVE)
end
-- 处理赋予的效果：选择1张「契约书」卡返回卡组（排除破坏对象）；若成功返回且破坏对象仍存在，则破坏对象，然后回复1000基本分。
function c25857977.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取第一个效果对象卡，即要被破坏的场上卡片。
	local tc=Duel.GetFirstTarget()
	local exc=nil
	if tc:IsRelateToEffect(e) then exc=tc end
	-- 向操作者发出选择提示：请选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择1张符合条件的「契约书」卡（自己场上表侧或墓地，且不受王家长眠之谷影响）返回卡组，排除已选定的破坏对象。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c25857977.tdfilter),tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,1,exc)
	-- 若选择了契约书且成功返回卡组，并且返回后的卡确实位于卡组/额外卡组，同时破坏对象仍与效果相关，则继续执行破坏。
	if g:GetCount()>0 and Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0
		and g:GetFirst():IsLocation(LOCATION_DECK+LOCATION_EXTRA) and tc:IsRelateToEffect(e) then
		-- 若对象卡被成功破坏，则继续执行后续的回复基本分处理。
		if Duel.Destroy(tc,REASON_EFFECT)~=0 then
			-- 中断当前效果链，使后续的回复LP处理与之前的破坏效果不同时处理（错开时点）。
			Duel.BreakEffect()
			-- 回复自己1000基本分。
			Duel.Recover(tp,1000,REASON_EFFECT)
		end
	end
end

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
	-- 为卡片添加灵摆怪兽属性，使其可以进行灵摆召唤
	aux.EnablePendulumAttribute(c)
	-- ①：以自己场上的「契约书」卡任意数量为对象才能发动。那些卡破坏，这张卡特殊召唤。那之后，可以让这张卡的等级上升或下降破坏数量的数值。
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
	-- ②：场上的这张卡为素材作融合·同调·超量·连接召唤的「DDD」怪兽得到以下效果。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e3:SetCountLimit(1,25857978)
	e3:SetCondition(c25857977.effcon)
	e3:SetOperation(c25857977.effop)
	c:RegisterEffect(e3)
end
-- 过滤函数：判断目标怪兽是否为表侧表示的「契约书」卡
function c25857977.desfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xae)
end
-- 过滤函数：判断目标怪兽是否为表侧表示的「契约书」卡且可以成为效果的对象
function c25857977.desfilter2(c,e)
	return c25857977.desfilter(c) and c:IsCanBeEffectTarget(e)
end
-- 灵摆效果的发动条件判断：检查是否有满足条件的「契约书」卡可破坏并特殊召唤自身
function c25857977.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and c25857977.desfilter(chkc) end
	-- 获取满足条件的「契约书」卡组
	local g=Duel.GetMatchingGroup(c25857977.desfilter2,tp,LOCATION_ONFIELD,0,nil,e)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查是否有足够的怪兽区空位来容纳所选的「契约书」卡
		and g:CheckSubGroup(aux.mzctcheck,1,g:GetCount(),tp) end
	-- 提示玩家选择要破坏的「契约书」卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从满足条件的卡组中选择一个子集作为要破坏的卡
	local sg=g:SelectSubGroup(tp,aux.mzctcheck,false,1,g:GetCount(),tp)
	-- 将选择的卡设置为连锁对象
	Duel.SetTargetCard(sg)
	-- 设置操作信息：破坏所选的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
	-- 设置操作信息：特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 灵摆效果的处理函数：破坏选中的卡并特殊召唤自身，之后根据破坏数量调整等级
function c25857977.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中被选中的卡组并过滤出与效果相关的卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 将选中的卡破坏
	local ct=Duel.Destroy(g,REASON_EFFECT)
	if ct~=0 then
		local c=e:GetHandler()
		-- 检查自身是否可以特殊召唤并执行特殊召唤
		if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
			local res=0
			if c:GetLevel()==1 then
				-- 当自身等级为1时，选择是否提升等级
				res=Duel.SelectOption(tp,aux.Stringid(25857977,2),aux.Stringid(25857977,3))  --"不改变等级/上升等级"
			else
				-- 当自身等级大于1时，选择是否提升或降低等级
				res=Duel.SelectOption(tp,aux.Stringid(25857977,2),aux.Stringid(25857977,3),aux.Stringid(25857977,4))  --"不改变等级/上升等级/下降等级"
			end
			if res>0 then
				-- 创建等级调整效果，根据选择结果提升或降低等级
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
-- 限制非「DDD」怪兽不能特殊召唤
function c25857977.splimit(e,c,tp,sumtp,sumpos)
	return not c:IsSetCard(0x10af)
end
-- 判断是否为通过融合/同调/超量/连接召唤成为素材的场合
function c25857977.effcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_FUSION+REASON_SYNCHRO+REASON_XYZ+REASON_LINK)~=0 and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
		and e:GetHandler():GetReasonCard():IsSetCard(0x10af)
end
-- 处理效果适用：为融合/同调/超量/连接召唤的「DDD」怪兽添加效果
function c25857977.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- 为融合/同调/超量/连接召唤的「DDD」怪兽添加效果：以场上1张卡为对象，破坏该卡并回复1000基本分
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
		-- 若融合/同调/超量/连接召唤的怪兽没有效果类型，则添加效果类型
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e2,true)
	end
	rc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(25857977,5))  --"「DDD 死讴王 恶德镇魂神」效果适用中"
end
-- 过滤函数：判断场上是否存在可返回卡组的「契约书」卡
function c25857977.desfilter3(c,tp)
	-- 检查是否存在满足条件的「契约书」卡
	return Duel.IsExistingMatchingCard(c25857977.tdfilter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,c)
end
-- 过滤函数：判断卡是否为「契约书」卡且可以返回卡组
function c25857977.tdfilter(c)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsSetCard(0xae) and c:IsAbleToDeck()
end
-- 效果处理函数：选择场上1张卡为对象，破坏该卡并从场上或墓地返回1张「契约书」卡到卡组
function c25857977.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c25857977.desfilter3(chkc,tp) end
	-- 检查是否有满足条件的卡可以作为对象
	if chk==0 then return Duel.IsExistingTarget(c25857977.desfilter3,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,tp) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张卡作为对象
	local g=Duel.SelectTarget(tp,c25857977.desfilter3,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,tp)
	-- 设置操作信息：破坏所选的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息：返回1张「契约书」卡到卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_ONFIELD+LOCATION_GRAVE)
end
-- 效果处理函数：破坏对象卡并回复LP
function c25857977.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的对象卡
	local tc=Duel.GetFirstTarget()
	local exc=nil
	if tc:IsRelateToEffect(e) then exc=tc end
	-- 提示玩家选择要返回卡组的「契约书」卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择满足条件的「契约书」卡返回卡组
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c25857977.tdfilter),tp,LOCATION_ONFIELD+LOCATION_GRAVE,0,1,1,exc)
	-- 检查是否成功将卡返回卡组
	if g:GetCount()>0 and Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0
		and g:GetFirst():IsLocation(LOCATION_DECK+LOCATION_EXTRA) and tc:IsRelateToEffect(e) then
		-- 破坏对象卡
		if Duel.Destroy(tc,REASON_EFFECT)~=0 then
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 使玩家回复1000基本分
			Duel.Recover(tp,1000,REASON_EFFECT)
		end
	end
end

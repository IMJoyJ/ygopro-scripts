--デスカイザー・ドラゴン／バスター
-- 效果：
-- 这张卡不能通常召唤。「爆裂模式」的效果才能特殊召唤。这张卡特殊召唤成功时，从自己·对方的墓地选择不死族怪兽任意数量在自己场上特殊召唤。这个效果特殊召唤的怪兽的效果无效化，这个回合的结束阶段时破坏。此外，场上的这张卡被破坏时，可以选择自己墓地1只「死亡帝王龙」特殊召唤。
function c1764972.initial_effect(c)
	-- 记录该卡具有「爆裂模式」效果的卡片编号
	aux.AddCodeList(c,80280737)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 限制该卡只能通过「爆裂模式」效果特殊召唤
	e1:SetValue(aux.AssaultModeLimit)
	c:RegisterEffect(e1)
	-- 这张卡特殊召唤成功时，从自己·对方的墓地选择不死族怪兽任意数量在自己场上特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1764972,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetTarget(c1764972.sptg1)
	e2:SetOperation(c1764972.spop1)
	c:RegisterEffect(e2)
	-- 场上的这张卡被破坏时，可以选择自己墓地1只「死亡帝王龙」特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(1764972,1))  --"特殊召唤「死亡帝王龙」"
	e3:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCondition(c1764972.spcon2)
	e3:SetTarget(c1764972.sptg2)
	e3:SetOperation(c1764972.spop2)
	c:RegisterEffect(e3)
end
c1764972.assault_name=6021033
-- 筛选墓地中的不死族怪兽作为特殊召唤目标
function c1764972.filter1(c,e,tp)
	return c:IsRace(RACE_ZOMBIE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足特殊召唤不死族怪兽的条件
function c1764972.sptg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c1764972.filter1(chkc,e,tp) end
	-- 判断场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断墓地中是否存在符合条件的不死族怪兽
		and Duel.IsExistingTarget(c1764972.filter1,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) end
	-- 获取玩家当前可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标墓地中的不死族怪兽
	local g=Duel.SelectTarget(tp,c1764972.filter1,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,ft,nil,e,tp)
	-- 设置效果操作信息，记录将要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,g:GetCount(),0,0)
end
-- 筛选已选择的卡是否满足特殊召唤条件
function c1764972.sfilter(c,e,tp)
	return c:IsRelateToEffect(e) and c:IsRace(RACE_ZOMBIE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 执行特殊召唤不死族怪兽的效果
function c1764972.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家当前可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 获取连锁中已选择的目标卡组并筛选符合条件的卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c1764972.sfilter,nil,e,tp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if g:GetCount()==0 or g:GetCount()>ft or (g:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133)) then return false end
	local c=e:GetHandler()
	local fid=c:GetFieldID()
	local tc=g:GetFirst()
	while tc do
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 使特殊召唤的怪兽效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		-- 使特殊召唤的怪兽效果无效并设置其在回合结束时被破坏
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
		tc:RegisterFlagEffect(1764972,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
		tc=g:GetNext()
	end
	-- 完成所有特殊召唤步骤
	Duel.SpecialSummonComplete()
	g:KeepAlive()
	-- 注册一个回合结束时自动破坏特殊召唤怪兽的效果
	local de=Effect.CreateEffect(c)
	de:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	de:SetCode(EVENT_PHASE+PHASE_END)
	de:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	de:SetCountLimit(1)
	de:SetReset(RESET_PHASE+PHASE_END)
	de:SetLabel(fid)
	de:SetLabelObject(g)
	de:SetCondition(c1764972.descon)
	de:SetOperation(c1764972.desop)
	-- 将自动破坏效果注册到游戏中
	Duel.RegisterEffect(de,tp)
end
-- 判断目标怪兽是否属于本次特殊召唤的怪兽
function c1764972.desfilter(c,fid)
	return c:GetFlagEffectLabel(1764972)==fid
end
-- 判断是否需要触发自动破坏效果
function c1764972.descon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(c1764972.desfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 执行自动破坏效果
function c1764972.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local dg=g:Filter(c1764972.desfilter,nil,e:GetLabel())
	g:DeleteGroup()
	-- 将符合条件的怪兽从场上破坏
	Duel.Destroy(dg,REASON_EFFECT)
end
-- 判断该卡是否在场上被破坏
function c1764972.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 筛选墓地中的「死亡帝王龙」作为特殊召唤目标
function c1764972.spfilter2(c,e,tp)
	return c:IsCode(6021033) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足特殊召唤「死亡帝王龙」的条件
function c1764972.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c1764972.spfilter2(chkc,e,tp) end
	-- 判断场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断墓地中是否存在符合条件的「死亡帝王龙」
		and Duel.IsExistingTarget(c1764972.spfilter2,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标墓地中的「死亡帝王龙」
	local g=Duel.SelectTarget(tp,c1764972.spfilter2,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果操作信息，记录将要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤「死亡帝王龙」的效果
function c1764972.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

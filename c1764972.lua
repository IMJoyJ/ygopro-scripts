--デスカイザー・ドラゴン／バスター
-- 效果：
-- 这张卡不能通常召唤。「爆裂模式」的效果才能特殊召唤。这张卡特殊召唤成功时，从自己·对方的墓地选择不死族怪兽任意数量在自己场上特殊召唤。这个效果特殊召唤的怪兽的效果无效化，这个回合的结束阶段时破坏。此外，场上的这张卡被破坏时，可以选择自己墓地1只「死亡帝王龙」特殊召唤。
function c1764972.initial_effect(c)
	-- 记录这张卡效果文本中记载的卡片：80280737（爆裂模式），用于关联检索相关卡名。
	aux.AddCodeList(c,80280737)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。「爆裂模式」的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设定特殊召唤条件判定函数为爆裂体共通限制：仅允许通过「爆裂模式」进行的特殊召唤。
	e1:SetValue(aux.AssaultModeLimit)
	c:RegisterEffect(e1)
	-- 这张卡特殊召唤成功时，从自己·对方的墓地选择不死族怪兽任意数量在自己场上特殊召唤。这个效果特殊召唤的怪兽的效果无效化，这个回合的结束阶段时破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1764972,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetTarget(c1764972.sptg1)
	e2:SetOperation(c1764972.spop1)
	c:RegisterEffect(e2)
	-- 此外，场上的这张卡被破坏时，可以选择自己墓地1只「死亡帝王龙」特殊召唤。
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
-- 筛选条件：不死族怪兽且能够被该效果特殊召唤（满足苏生限制与召唤规则）。
function c1764972.filter1(c,e,tp)
	return c:IsRace(RACE_ZOMBIE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的取对象处理：若返回已选对象则验证其为墓地且符合filter1；发动时检查空位并存在至少1只可选不死族怪兽。
function c1764972.sptg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c1764972.filter1(chkc,e,tp) end
	-- 检查自己场上是否存在可用主要怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查双方墓地是否存在至少1只满足filter1条件且可特殊召唤的不死族怪兽。
		and Duel.IsExistingTarget(c1764972.filter1,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) end
	-- 获取自己场上主要怪兽区域的可用空格数量，用于决定最多可选几只。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 显示选择提示：请选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从双方墓地选择1至可用空格数张满足filter1的不死族怪兽，并将其设为该连锁的对象。
	local g=Duel.SelectTarget(tp,c1764972.filter1,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,ft,nil,e,tp)
	-- 设置操作信息：本次效果将进行特殊召唤，对象组为g，数量为对象张数，供后续连锁判定与卡牌效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,g:GetCount(),0,0)
end
-- 处理时筛选：对象仍与效果相关且仍为不死族、可特殊召唤。
function c1764972.sfilter(c,e,tp)
	return c:IsRelateToEffect(e) and c:IsRace(RACE_ZOMBIE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理：重新获取空位；获取并过滤连锁对象；若对象数量为0或超出空位，或存在青眼精灵龙效果且对象>1则处理失败；否则逐只正面攻击表示特殊召唤，并为其附加效果无效化、效果无效、结束阶段破坏标记；最后完成特殊召唤并注册结束阶段破坏效果。
function c1764972.spop1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前自己场上主要怪兽区域可用空格数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 从连锁的对象卡中筛选出仍然有效且满足不死族、可特殊召唤条件的怪兽组。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c1764972.sfilter,nil,e,tp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if g:GetCount()==0 or g:GetCount()>ft or (g:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133)) then return false end
	local c=e:GetHandler()
	local fid=c:GetFieldID()
	local tc=g:GetFirst()
	while tc do
		-- 以特殊召唤步骤方式将当前目标怪兽正面攻击表示特殊召唤（暂不触发召唤成功，待统一完成）。
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		-- 这个效果特殊召唤的怪兽的效果无效化，这个回合的结束阶段时破坏。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
		tc:RegisterFlagEffect(1764972,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
		tc=g:GetNext()
	end
	-- 完成先前所有SpecialSummonStep的特殊召唤流程，统一触发特殊召唤成功时的时点。
	Duel.SpecialSummonComplete()
	g:KeepAlive()
	-- 这个回合的结束阶段时破坏。此外，场上的这张卡被破坏时，可以选择自己墓地1只「死亡帝王龙」特殊召唤。
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
	-- 将结束阶段破坏怪兽的持续效果注册给当前玩家，使其在结束阶段执行。
	Duel.RegisterEffect(de,tp)
end
-- 筛选带有所记录fid标记的怪兽，用于识别由本次效果特殊召唤的怪兽。
function c1764972.desfilter(c,fid)
	return c:GetFlagEffectLabel(1764972)==fid
end
-- 结束阶段破坏效果的条件：若标记组中仍有被本次效果特殊召唤的怪兽，则返回true；否则释放组引用并重置该效果。
function c1764972.descon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(c1764972.desfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 结束阶段破坏的处理：从标记组中筛选出本次特殊召唤的怪兽，并执行破坏。
function c1764972.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local dg=g:Filter(c1764972.desfilter,nil,e:GetLabel())
	g:DeleteGroup()
	-- 以效果原因破坏这些特殊召唤的怪兽。
	Duel.Destroy(dg,REASON_EFFECT)
end
-- “场上的这张卡被破坏时”的发动条件：该卡被破坏前位于场上。
function c1764972.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 筛选自己墓地中卡名为「死亡帝王龙」（6021033）且可被特殊召唤的怪兽。
function c1764972.spfilter2(c,e,tp)
	return c:IsCode(6021033) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 从自己墓地选择1只「死亡帝王龙」作为对象：若指定对象则验证位置与控制者；发动时检查自场有空位且墓地存在合法对象。
function c1764972.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c1764972.spfilter2(chkc,e,tp) end
	-- 检查自己场上是否存在可用主要怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只满足spfilter2的「死亡帝王龙」。
		and Duel.IsExistingTarget(c1764972.spfilter2,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 显示选择提示：请选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只「死亡帝王龙」作为效果对象。
	local g=Duel.SelectTarget(tp,c1764972.spfilter2,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：本次效果将把1只怪兽特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特召处理：若选择的对象仍与该效果关联，则将其特殊召唤。
function c1764972.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取该连锁上的第一张对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡正面攻击表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

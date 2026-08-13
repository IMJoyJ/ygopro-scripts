--重力均衡
-- 效果：
-- 这个卡名在规则上也当作「G石人」卡使用。这个卡名的①②的效果1回合各能使用1次。
-- ①：从自己墓地的怪兽以及除外的自己怪兽之中以2只地属性同名怪兽为对象才能发动。那2只攻击力·守备力变成0，效果无效守备表示特殊召唤。这个效果特殊召唤的怪兽在结束阶段破坏。
-- ②：自己场上的「G石人」怪兽被战斗或者对方的效果破坏的场合，可以作为代替把墓地的这张卡除外。
function c37930737.initial_effect(c)
	-- ①：从自己墓地的怪兽以及除外的自己怪兽之中以2只地属性同名怪兽为对象才能发动。那2只攻击力·守备力变成0，效果无效守备表示特殊召唤。这个效果特殊召唤的怪兽在结束阶段破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,37930737)
	e1:SetTarget(c37930737.target)
	e1:SetOperation(c37930737.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上的「G石人」怪兽被战斗或者对方的效果破坏的场合，可以作为代替把墓地的这张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,37930738)
	e2:SetTarget(c37930737.reptg)
	e2:SetValue(c37930737.repval)
	e2:SetOperation(c37930737.repop)
	c:RegisterEffect(e2)
end
-- 过滤可作为对象的自己墓地/表侧除外区域的地属性怪兽，且该怪兽能被效果以表侧守备表示特殊召唤。
function c37930737.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsCanBeEffectTarget(e)
end
-- 判断候选组中所有卡的卡名种类数是否为1，即是否为地属性同名怪兽（用于选出2只同名卡）。
function c37930737.fselect(g)
	return g:GetClassCount(Card.GetCode)==1
end
-- 效果发动时的目标选择处理：检查自己场上至少有2个可用怪兽区域、候选组中存在2只地属性同名怪兽，且没有禁止同时特殊召唤2只以上怪兽的效果（如青眼精灵龙）适用；满足后由玩家选择2只同名怪兽作为对象。
function c37930737.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取自己墓地及除外区中所有符合spfilter条件的怪兽，作为可选特殊召唤对象的候选组。
	local g=Duel.GetMatchingGroup(c37930737.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e,tp)
	if chkc then return false end
	-- 发动合法性检查：自己场上须有至少2个空闲怪兽区域，才能特殊召唤2只怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and g:CheckSubGroup(c37930737.fselect,2,2) and not Duel.IsPlayerAffectedByEffect(tp,59822133) end
	-- 向玩家显示选择提示：请选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=g:SelectSubGroup(tp,c37930737.fselect,false,2,2)
	-- 将玩家选择的2只怪兽设为当前连锁的效果对象（取对象）。
	Duel.SetTargetCard(sg)
	-- 设置连锁操作信息：本次效果将特殊召唤2只怪兽，供时点检测与后续处理参考。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,2,0,0)
end
-- ①效果处理：确认条件满足后，将作为对象的2只怪兽以表侧守备表示特殊召唤，使其攻击力·守备力变成0、效果无效，并注册结束阶段破坏的效果。
function c37930737.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次检查：若自己场上可用怪兽区域不足2个，则整个特殊召唤效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=1 then return end
	local c=e:GetHandler()
	-- 取得发动时选择的对象怪兽，并过滤掉已不与本效果相关的卡（如已离场或联系重置）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=1 or g:GetCount()~=2 or Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	local tc=g:GetFirst()
	local fid=c:GetFieldID()
	while tc do
		-- 将当前对象怪兽以表侧守备表示逐步特殊召唤（配合SpecialSummonComplete完成）。
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		tc:RegisterFlagEffect(37930737,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 效果无效：使特殊召唤的怪兽的效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- 效果无效：使特殊召唤的怪兽的效果无效（离场后仍保持无效状态，变里侧时重置）。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		e3:SetValue(RESET_TURN_SET)
		tc:RegisterEffect(e3)
		-- 攻击力变成0：将特殊召唤的怪兽攻击力设为0（即原文“攻击力·守备力变成0”的攻击力部分）。
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetCode(EFFECT_SET_ATTACK_FINAL)
		e4:SetValue(0)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e4)
		local e5=e4:Clone()
		e5:SetCode(EFFECT_SET_DEFENSE_FINAL)
		tc:RegisterEffect(e5)
		tc=g:GetNext()
	end
	-- 完成多只怪兽的特殊召唤处理，触发特殊召唤成功时点。
	Duel.SpecialSummonComplete()
	g:KeepAlive()
	-- 对应“这个效果特殊召唤的怪兽在结束阶段破坏。”以及②效果“自己场上的「G石人」怪兽被战斗或者对方的效果破坏的场合，可以作为代替把墓地的这张卡除外。”
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCountLimit(1)
	e1:SetLabel(fid)
	e1:SetLabelObject(g)
	e1:SetCondition(c37930737.descon)
	e1:SetOperation(c37930737.desop)
	-- 将结束阶段破坏的效果注册到场上，使其在后续结束阶段适用。
	Duel.RegisterEffect(e1,tp)
end
-- 判断怪兽是否带有本次特殊召唤对应的标记fid，用于筛选出本次效果特殊召唤的怪兽。
function c37930737.desfilter(c,fid)
	return c:GetFlagEffectLabel(37930737)==fid
end
-- 结束阶段破坏效果的发动条件：若仍存在带fid标记的怪兽则执行破坏；若已不存在则清理该效果。
function c37930737.descon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(c37930737.desfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else
		return true
	end
end
-- 破坏处理：将所有带fid标记的本次特殊召唤怪兽作为对象进行破坏。
function c37930737.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(c37930737.desfilter,nil,e:GetLabel())
	-- 以效果原因破坏这些特殊召唤的怪兽。
	Duel.Destroy(tg,REASON_EFFECT)
end
-- ②代破的过滤条件：我方场上表侧表示且卡名含G石人（0x186），并且是因战斗或对方的效果将要被破坏，且不是被代替破坏的场合。
function c37930737.repfilter(c,tp)
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:IsSetCard(0x186)
		and (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)) and not c:IsReason(REASON_REPLACE)
end
-- 代破发动判定：墓地中的这张卡可以除外，且场上有满足代破条件的G石人怪兽时，询问玩家是否发动。
function c37930737.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c37930737.repfilter,1,nil,tp) end
	-- 弹出是否发动代替破坏的确认选择，返回玩家的选择（是/否）。
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 代替破坏的判定函数：由引擎询问repfilter判断当前将被破坏的怪兽是否适用此代破效果。
function c37930737.repval(e,c)
	return c37930737.repfilter(c,e:GetHandlerPlayer())
end
-- 代破效果的处理：将墓地中的这张卡以表侧表示除外。
function c37930737.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将墓地中的重力均衡以表侧表示除外，作为代替破坏的代价。
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end

--重力均衡
-- 效果：
-- 这个卡名在规则上也当作「G石人」卡使用。这个卡名的①②的效果1回合各能使用1次。
-- ①：从自己墓地的怪兽以及除外的自己怪兽之中以2只地属性同名怪兽为对象才能发动。那2只攻击力·守备力变成0，效果无效守备表示特殊召唤。这个效果特殊召唤的怪兽在结束阶段破坏。
-- ②：自己场上的「G石人」怪兽被战斗或者对方的效果破坏的场合，可以作为代替把墓地的这张卡除外。
function c37930737.initial_effect(c)
	-- 效果原文内容：①：从自己墓地的怪兽以及除外的自己怪兽之中以2只地属性同名怪兽为对象才能发动。那2只攻击力·守备力变成0，效果无效守备表示特殊召唤。这个效果特殊召唤的怪兽在结束阶段破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,37930737)
	e1:SetTarget(c37930737.target)
	e1:SetOperation(c37930737.activate)
	c:RegisterEffect(e1)
	-- 效果原文内容：②：自己场上的「G石人」怪兽被战斗或者对方的效果破坏的场合，可以作为代替把墓地的这张卡除外。
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
-- 检索满足条件的卡片组：地属性、可以特殊召唤、表侧表示或在墓地、可以成为效果对象的怪兽
function c37930737.spfilter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsCanBeEffectTarget(e)
end
-- 判断组内是否所有卡片编号相同：获取组内不同编号的卡片数量是否等于1
function c37930737.fselect(g)
	return g:GetClassCount(Card.GetCode)==1
end
-- 判断是否满足发动条件：检测场上是否有足够的召唤位置、满足条件的卡片组是否存在、是否受到青眼精灵龙效果影响
function c37930737.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取满足条件的卡片组：从墓地和除外区检索地属性怪兽
	local g=Duel.GetMatchingGroup(c37930737.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e,tp)
	if chkc then return false end
	-- 检测场上是否有足够的召唤位置：判断玩家的主怪兽区域是否至少有2个空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		and g:CheckSubGroup(c37930737.fselect,2,2) and not Duel.IsPlayerAffectedByEffect(tp,59822133) end
	-- 提示玩家选择要特殊召唤的卡：向玩家发送提示信息，提示内容为“请选择要特殊召唤的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local sg=g:SelectSubGroup(tp,c37930737.fselect,false,2,2)
	-- 设置当前处理的连锁的对象为sg：将选择的卡片组设置为连锁对象
	Duel.SetTargetCard(sg)
	-- 设置当前处理的连锁的操作信息：设置操作分类为特殊召唤，目标为sg，数量为2
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,sg,2,0,0)
end
-- 效果作用：检测场上是否有足够的召唤位置、获取连锁对象卡片组、判断是否满足发动条件、特殊召唤目标怪兽、设置结束阶段破坏效果
function c37930737.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检测场上是否有足够的召唤位置：判断玩家的主怪兽区域是否至少有2个空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=1 then return end
	local c=e:GetHandler()
	-- 获取连锁对象卡片组：从当前连锁中获取目标卡片组并过滤出与效果相关的卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=1 or g:GetCount()~=2 or Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	local tc=g:GetFirst()
	local fid=c:GetFieldID()
	while tc do
		-- 特殊召唤目标怪兽：将目标怪兽以守备表示特殊召唤
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		tc:RegisterFlagEffect(37930737,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 效果作用：使目标怪兽效果无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- 效果作用：使目标怪兽效果无效
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_DISABLE_EFFECT)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		e3:SetValue(RESET_TURN_SET)
		tc:RegisterEffect(e3)
		-- 效果作用：将目标怪兽攻击力设置为0
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
	-- 完成特殊召唤流程：结束特殊召唤步骤
	Duel.SpecialSummonComplete()
	g:KeepAlive()
	-- 效果作用：注册一个结束阶段破坏效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCountLimit(1)
	e1:SetLabel(fid)
	e1:SetLabelObject(g)
	e1:SetCondition(c37930737.descon)
	e1:SetOperation(c37930737.desop)
	-- 注册结束阶段破坏效果：将效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 判断目标怪兽是否属于本次特殊召唤：通过标记判断目标怪兽是否属于本次特殊召唤
function c37930737.desfilter(c,fid)
	return c:GetFlagEffectLabel(37930737)==fid
end
-- 判断是否满足结束阶段破坏条件：检测目标怪兽是否存在于目标组中
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
-- 效果作用：破坏满足条件的怪兽
function c37930737.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(c37930737.desfilter,nil,e:GetLabel())
	-- 破坏目标怪兽：以效果原因破坏目标怪兽
	Duel.Destroy(tg,REASON_EFFECT)
end
-- 判断目标怪兽是否满足代替破坏条件：判断目标怪兽是否为表侧表示、在主怪兽区、控制者为玩家、为G石人卡组、被战斗或对方效果破坏且未被代替破坏
function c37930737.repfilter(c,tp)
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp) and c:IsSetCard(0x186)
		and (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)) and not c:IsReason(REASON_REPLACE)
end
-- 判断是否满足代替破坏发动条件：检测是否可以除外自身、是否有满足条件的怪兽被破坏
function c37930737.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c37930737.repfilter,1,nil,tp) end
	-- 提示玩家选择是否发动代替破坏效果：向玩家发送提示信息，提示内容为“是否发动代替破坏效果”
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 判断目标怪兽是否满足代替破坏条件：返回目标怪兽是否满足代替破坏条件
function c37930737.repval(e,c)
	return c37930737.repfilter(c,e:GetHandlerPlayer())
end
-- 效果作用：将自身除外
function c37930737.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将自身除外：以效果原因将自身除外
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end

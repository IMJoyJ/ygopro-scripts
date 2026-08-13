--極天気ランブラ
-- 效果：
-- ①：这张卡召唤成功时才能发动。从自己的手卡·卡组·墓地选1张「天气」魔法·陷阱卡在自己的魔法与陷阱区域表侧表示放置。
-- ②：只要这张卡在怪兽区域存在，自己场上的「天气」魔法·陷阱卡不会成为对方的效果的对象，不会被对方的效果破坏。
-- ③：场上的这张卡为让「天气」卡的效果发动而被除外的场合，下个回合的准备阶段才能发动。除外的这张卡特殊召唤。
function c27784944.initial_effect(c)
	-- ①：这张卡召唤成功时才能发动。从自己的手卡·卡组·墓地选1张「天气」魔法·陷阱卡在自己的魔法与陷阱区域表侧表示放置。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27784944,0))  --"放置「天气」魔法·陷阱卡"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c27784944.tftg)
	e1:SetOperation(c27784944.tfop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，自己场上的「天气」魔法·陷阱卡不会成为对方的效果的对象
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTargetRange(LOCATION_ONFIELD,0)
	e2:SetTarget(c27784944.immtg)
	-- 设置“不能成为对方效果的对象”的判定函数，使对方的效果不能选择自己场上的「天气」魔法·陷阱卡为对象。
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	-- 设置“不会被对方效果破坏”的判定函数，使对方的效果不能破坏自己场上的「天气」魔法·陷阱卡。
	e3:SetValue(aux.indoval)
	c:RegisterEffect(e3)
	-- ③：场上的这张卡为让「天气」卡的效果发动而被除外的场合
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EVENT_REMOVE)
	e4:SetOperation(c27784944.spreg)
	c:RegisterEffect(e4)
	-- 下个回合的准备阶段才能发动。除外的这张卡特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(27784944,1))  --"除外的这张卡特殊召唤"
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetRange(LOCATION_REMOVED)
	e5:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e5:SetCondition(c27784944.spcon)
	e5:SetTarget(c27784944.sptg)
	e5:SetOperation(c27784944.spop)
	e5:SetLabelObject(e4)
	c:RegisterEffect(e5)
end
-- 该过滤函数筛选符合条件的「天气」魔法·陷阱卡：须为「天气」字段的魔法·陷阱卡，不能是场地魔法，不能是禁止卡，且不会因同名卡限制而无法放置到场上的卡。
function c27784944.tffilter(c,tp)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsType(TYPE_FIELD) and c:IsSetCard(0x109)
		and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
-- ①效果的发动条件判定函数：检查自己魔陷区是否有空位，并且手卡·卡组·墓地中是否存在至少1张符合tffilter条件的「天气」魔法·陷阱卡可供放置。
function c27784944.tftg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 作为发动条件之一：确认自己魔法与陷阱区域存在可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 作为发动条件之一：确认手卡·卡组·墓地中存在至少1张满足tffilter条件的「天气」魔法·陷阱卡。
		and Duel.IsExistingMatchingCard(c27784944.tffilter,tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK,0,1,nil,tp) end
	-- 向对方玩家展示本效果发动的描述信息，提示对方本卡发动了放置「天气」魔法·陷阱卡的效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- ①效果的实际处理：若自己魔法与陷阱区域有空位，则从手卡·卡组·墓地选择1张符合条件的「天气」魔法·陷阱卡（受王家长眠之谷影响的卡除外），表侧放置到自己的魔法与陷阱区域。
function c27784944.tfop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理前再次确认自己魔法与陷阱区域有空位，否则不进行放置处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 向发动玩家显示选择提示，要求其从手卡·卡组·墓地选择1张要放置到魔法与陷阱区域的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 让发动玩家从手卡·卡组·墓地中选出1张满足条件的「天气」魔法·陷阱卡（应用王家长眠之谷过滤），并取得选中的那张卡。
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c27784944.tffilter),tp,LOCATION_HAND+LOCATION_GRAVE+LOCATION_DECK,0,1,1,nil,tp):GetFirst()
	if tc then
		-- 将选中的卡由发动玩家以表侧表示放置到自己的魔法与陷阱区域。
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end
-- ②效果的保护对象过滤函数：判定是否为「天气」字段的魔法·陷阱卡，是则获得“不能成为对方效果对象”和“不被对方效果破坏”的抗性。
function c27784944.immtg(e,c)
	return c:IsSetCard(0x109) and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 这是③效果的记录用连续效果：当这张卡在场上为发动「天气」卡的效果而作为代价被除外时，记录下个回合的准备阶段并给自身设置标记，以便后续触发特召效果。
function c27784944.spreg(e,tp,eg,ep,ev,re,r,rp)
	if not re then return end
	local c=e:GetHandler()
	local rc=re:GetHandler()
	if c:IsReason(REASON_COST) and rc:IsSetCard(0x109) and c:IsPreviousLocation(LOCATION_ONFIELD) and re:IsActivated() then
		-- 将e4的标签记录为当前回合数+1，即下个回合的准备阶段（用于判断发动时机）。
		e:SetLabel(Duel.GetTurnCount()+1)
		c:RegisterFlagEffect(27784944,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,2)
	end
end
-- ③效果的特殊召唤在准备阶段的发动条件：当前回合必须是被记录的下个回合的准备阶段，且这张卡存在因「天气」效果除外而设置的标记。
function c27784944.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合是否为记录的下个准备阶段，且这张卡持有标记（确实为发动「天气」效果而被除外过）。
	return e:GetLabelObject():GetLabel()==Duel.GetTurnCount() and e:GetHandler():GetFlagEffect(27784944)>0
end
-- ③效果特殊召唤的发动条件：自己主要怪兽区有空位，且除外的这张卡自身可以被特殊召唤。
function c27784944.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 作为发动条件之一：确认自己主要怪兽区域存在可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 将本次连锁的操作信息设置为特殊召唤这张卡，用于告知系统并供相关效果（如星尘龙等）进行响应判断。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	e:GetHandler():ResetFlagEffect(27784944)
end
-- ③效果的特殊召唤处理：若这张卡仍在除外区且与效果关联有效，则将其特殊召唤。
function c27784944.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己的主要怪兽区域。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

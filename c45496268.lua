--SDロボ・エレファン
-- 效果：
-- 这张卡召唤成功时，可以从手卡把1只名字带有「超级防卫机器人」的怪兽或者「轨道 7」特殊召唤。1回合1次，选择自己场上1只名字带有「超级防卫机器人」的怪兽或者「轨道 7」才能发动。选择的怪兽的等级直到结束阶段时变成8星。此外，把这张卡作为超量召唤的素材的场合，不是机械族怪兽的超量召唤不能使用。
function c45496268.initial_effect(c)
	-- 这张卡召唤成功时，可以从手卡把1只名字带有「超级防卫机器人」的怪兽或者「轨道 7」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45496268,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c45496268.sumtg)
	e1:SetOperation(c45496268.sumop)
	c:RegisterEffect(e1)
	-- 1回合1次，选择自己场上1只名字带有「超级防卫机器人」的怪兽或者「轨道 7」才能发动。选择的怪兽的等级直到结束阶段时变成8星。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(45496268,1))  --"等级变化"
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c45496268.lvtg)
	e2:SetOperation(c45496268.lvop)
	c:RegisterEffect(e2)
	-- 此外，把这张卡作为超量召唤的素材的场合，不是机械族怪兽的超量召唤不能使用。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetValue(c45496268.xyzlimit)
	c:RegisterEffect(e3)
end
-- 过滤手牌中满足条件的卡片：卡名属于「超级防卫机器人」字段或卡号为71071546（轨道 7），并且能够被特殊召唤成功的怪兽。
function c45496268.filter(c,e,tp)
	return (c:IsSetCard(0x85) or c:IsCode(71071546)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动条件判定：己方主要怪兽区域有空位，并且手牌中存在1只以上满足filter筛选条件的「超级防卫机器人」或「轨道 7」怪兽。
function c45496268.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方主要怪兽区域是否还有可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在至少1只满足filter筛选条件的「超级防卫机器人」或「轨道 7」怪兽。
		and Duel.IsExistingMatchingCard(c45496268.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 登记本次效果处理的信息：将从手牌特殊召唤1只怪兽，供其他卡的效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 特殊召唤效果的实际处理：若己方主要怪兽区域仍有空位，则从手牌选择1只符合条件的「超级防卫机器人」或「轨道 7」怪兽，以表侧表示特殊召唤到己方场上。
function c45496268.sumop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果处理时再次确认己方主要怪兽区域仍有空位；若无空位则直接结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示“请选择要特殊召唤的卡”的提示信息，引导玩家选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌中选择1张满足filter条件的「超级防卫机器人」或「轨道 7」怪兽。
	local g=Duel.SelectMatchingCard(tp,c45496268.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到己方场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 等级变化效果的筛选条件：对象必须是表侧表示的「超级防卫机器人」或「轨道 7」怪兽，且当前等级不是8星、等级在1以上。
function c45496268.lvfilter(c)
	return c:IsFaceup() and (c:IsSetCard(0x85) or c:IsCode(71071546)) and not c:IsLevel(8) and c:IsLevelAbove(1)
end
-- 等级变化效果的发动判定与取对象：选择己方场上1只表侧表示且满足lvfilter条件的「超级防卫机器人」或「轨道 7」怪兽作为对象。
function c45496268.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c45496268.lvfilter(chkc) end
	-- 效果发动时检查己方场上是否存在至少1只满足lvfilter条件的表侧表示怪兽可作为对象。
	if chk==0 then return Duel.IsExistingTarget(c45496268.lvfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 显示“请选择表侧表示的卡”的提示信息，引导玩家选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 从己方场上选择1只满足lvfilter条件的表侧表示怪兽，并将其设置为效果对象。
	Duel.SelectTarget(tp,c45496268.lvfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 等级变化效果的实际处理：将对象怪兽的等级直到结束阶段变成8星。
function c45496268.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本效果连锁中登记的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 选择的怪兽的等级直到结束阶段时变成8星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(8)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- 作为超量素材限制的判断函数：当这张卡被用作超量素材时，若素材怪兽不是机械族则返回true，使该超量召唤不能进行；即只有机械族超量召唤才可使用这张卡作为素材。
function c45496268.xyzlimit(e,c)
	if not c then return false end
	return not c:IsRace(RACE_MACHINE)
end

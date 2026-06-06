--夢幻崩界イヴリース
-- 效果：
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡召唤成功时，以自己墓地1只连接怪兽为对象才能发动。那只怪兽的攻击力变成0，效果无效，在要和这张卡成为连接状态的自己场上特殊召唤。
-- ②：只要这张卡在怪兽区域存在，这张卡的控制者不是连接怪兽不能特殊召唤。
-- ③：这张卡从自己场上送去墓地的场合才能发动。这张卡在对方场上守备表示特殊召唤。
function c10158145.initial_effect(c)
	-- ①：这张卡召唤成功时，以自己墓地1只连接怪兽为对象才能发动。那只怪兽的攻击力变成0，效果无效，在要和这张卡成为连接状态的自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10158145,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetTarget(c10158145.sptg)
	e1:SetOperation(c10158145.spop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，这张卡的控制者不是连接怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c10158145.splimit)
	c:RegisterEffect(e2)
	-- ③：这张卡从自己场上送去墓地的场合才能发动。这张卡在对方场上守备表示特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(10158145,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,10158145)
	e3:SetCondition(c10158145.condition)
	e3:SetTarget(c10158145.target)
	e3:SetOperation(c10158145.operation)
	c:RegisterEffect(e3)
	-- ②：只要这张卡在怪兽区域存在，这张卡的控制者不是连接怪兽不能特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(63060238)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(1,0)
	c:RegisterEffect(e4)
end
-- 计算与此卡相邻且有连接箭头指向的怪兽区域
function c10158145.get_zone(c,seq)
	local zone=0
	if seq<4 and c:IsLinkMarker(LINK_MARKER_LEFT) then zone=bit.replace(zone,0x1,seq+1) end
	if seq>0 and seq<5 and c:IsLinkMarker(LINK_MARKER_RIGHT) then zone=bit.replace(zone,0x1,seq-1) end
	return zone
end
-- 过滤条件：自己墓地中满足可在此卡相邻连接端特殊召唤的连接怪兽
function c10158145.spfilter(c,e,tp,seq)
	local zone=c10158145.get_zone(c,seq)
	return zone~=0 and c:IsType(TYPE_LINK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
-- 以自己墓地1只连接怪兽为对象发动的检测与效果靶向设置
function c10158145.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local seq=e:GetHandler():GetSequence()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c10158145.spfilter(chkc,e,tp,seq) end
	-- 判断自己场上是否有可用的主要怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检测自己墓地是否存在可特殊召唤的连接怪兽
		and Duel.IsExistingTarget(c10158145.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,seq) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家选择自己墓地1只可以特殊召唤的连接怪兽作为对象
	local g=Duel.SelectTarget(tp,c10158145.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,seq)
	-- 设置当前处理的连锁信息：包含特殊召唤目标怪兽的效果分类
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 召唤成功时将目标连接怪兽特殊召唤、使其效果无效并使攻击力变0的效果处理
function c10158145.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的对象卡
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsControler(tp) and tc:IsRelateToEffect(e) then
		local zone=c10158145.get_zone(tc,c:GetSequence())
		-- 判断召唤成功的此卡与目标卡是否关联，若是则在其相邻连接端特殊召唤目标怪兽
		if zone~=0 and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP,zone) then
			-- 效果无效
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 效果无效
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
			-- 那只怪兽的攻击力变成0
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_SET_ATTACK)
			e3:SetValue(0)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e3)
		end
		-- 完成特殊召唤的处理
		Duel.SpecialSummonComplete()
	end
end
-- 限制玩家不能特殊召唤连接怪兽以外的怪兽
function c10158145.splimit(e,c,sump,sumtype,sumpos,targetp)
	return c:GetOriginalType()&TYPE_LINK~=TYPE_LINK
end
-- 判断这张卡是否是从自己场上送去墓地
function c10158145.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) and e:GetHandler():IsPreviousControler(tp)
end
-- 特殊召唤此卡到对方场上的检测与效果靶向设置
function c10158145.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断对方场上是否有可用的主要怪兽区域
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,1-tp) end
	-- 设置当前处理的连锁信息：包含特殊召唤自身的效果分类
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 送去墓地时在对方场上守备表示特殊召唤自身的效果处理
function c10158145.operation(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将此卡在对方场上守备表示特殊召唤
		Duel.SpecialSummon(e:GetHandler(),0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)
	end
end

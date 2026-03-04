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
	-- ②的效果：禁止不是连接怪兽的特殊召唤（使用衍生物限制代码63060238）
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(63060238)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(1,0)
	c:RegisterEffect(e4)
end
-- 计算连接怪兽左侧或右侧可用的格子区域，返回可用区域的位掩码
function c10158145.get_zone(c,seq)
	local zone=0
	if seq<4 and c:IsLinkMarker(LINK_MARKER_LEFT) then zone=bit.replace(zone,0x1,seq+1) end
	if seq>0 and seq<5 and c:IsLinkMarker(LINK_MARKER_RIGHT) then zone=bit.replace(zone,0x1,seq-1) end
	return zone
end
-- 定义过滤器：筛选墓地中可被特殊召唤到指定连接位置的连接怪兽
function c10158145.spfilter(c,e,tp,seq)
	local zone=c10158145.get_zone(c,seq)
	return zone~=0 and c:IsType(TYPE_LINK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
-- ①效果的发动处理：选择要特殊召唤的连接怪兽对象
function c10158145.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local seq=e:GetHandler():GetSequence()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c10158145.spfilter(chkc,e,tp,seq) end
	-- 检查我方主要怪兽区是否有可用位置（至少1格）
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查我方墓地是否存在满足条件的连接怪兽可用作对象
		and Duel.IsExistingTarget(c10158145.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp,seq) end
	-- 向玩家发送选择特殊召唤对象的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 让玩家从墓地中选择1只满足条件的连接怪兽作为对象
	local g=Duel.SelectTarget(tp,c10158145.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,seq)
	-- 设置操作信息：宣告即将进行特殊召唤处理
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果的处理操作：执行特殊召唤并应用效果
function c10158145.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取玩家选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsControler(tp) and tc:IsRelateToEffect(e) then
		local zone=c10158145.get_zone(tc,c:GetSequence())
		-- 尝试将目标怪兽特殊召唤到当前卡左侧或右侧的可用格子
		if zone~=0 and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP,zone) then
			-- 那只怪兽的效果无效（EFFECT_DISABLE）
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 那只怪兽的怪兽效果无效（EFFECT_DISABLE_EFFECT）
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
			-- 那只怪兽的攻击力变成0（EFFECT_SET_ATTACK）
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_SET_ATTACK)
			e3:SetValue(0)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e3)
		end
		-- 完成特殊召唤处理（必须调用以结束多体特殊召唤流程）
		Duel.SpecialSummonComplete()
	end
end
-- ②效果的限制函数：检查要特殊召唤的怪兽是否为非连接怪兽
function c10158145.splimit(e,c,sump,sumtype,sumpos,targetp)
	return c:GetOriginalType()&TYPE_LINK~=TYPE_LINK
end
-- ③效果的发动条件：从场上送去墓地且原本由自己控制
function c10158145.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD) and e:GetHandler():IsPreviousControler(tp)
end
-- ③效果的发动处理：检查能否在对方场特殊召唤
function c10158145.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查对方主要怪兽区是否有可用位置
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,1-tp) end
	-- 设置操作信息：宣告即将特殊召唤到对方场
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ③效果的处理操作：特殊召唤到对方场
function c10158145.operation(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将这张卡在对方场上守备表示特殊召唤
		Duel.SpecialSummon(e:GetHandler(),0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)
	end
end

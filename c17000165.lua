--レプティレス・リコイル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1只攻击力0的怪兽和自己墓地1只爬虫类族·暗属性怪兽为对象才能发动。那只场上的怪兽破坏，那只墓地的怪兽特殊召唤。
-- ②：对方把怪兽的效果发动的场合，以对方场上1只攻击力0的怪兽为对象才能发动。得到那只怪兽的控制权。那之后，在对方场上把1只「爬虫妖衍生物」（爬虫类族·地·1星·攻/守0）特殊召唤。
function c17000165.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：以自己场上1只攻击力0的怪兽和自己墓地1只爬虫类族·暗属性怪兽为对象才能发动。那只场上的怪兽破坏，那只墓地的怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(17000165,0))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,17000165)
	e2:SetTarget(c17000165.destg)
	e2:SetOperation(c17000165.desop)
	c:RegisterEffect(e2)
	-- ②：对方把怪兽的效果发动的场合，以对方场上1只攻击力0的怪兽为对象才能发动。得到那只怪兽的控制权。那之后，在对方场上把1只「爬虫妖衍生物」（爬虫类族·地·1星·攻/守0）特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(17000165,1))
	e3:SetCategory(CATEGORY_CONTROL+CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,17000166)
	e3:SetCondition(c17000165.ctcon)
	e3:SetTarget(c17000165.cttg)
	e3:SetOperation(c17000165.ctop)
	c:RegisterEffect(e3)
end
-- 检索满足条件的场上怪兽组，该怪兽必须正面表示且攻击力为0且玩家场上存在可用怪兽区
function c17000165.desfilter(c,tp)
	-- 该怪兽必须正面表示且攻击力为0且玩家场上存在可用怪兽区
	return c:IsFaceup() and c:IsAttack(0) and Duel.GetMZoneCount(tp,c)>0
end
-- 检索满足条件的墓地怪兽组，该怪兽必须为爬虫类族且暗属性且可以特殊召唤
function c17000165.spfilter(c,e,tp)
	return c:IsRace(RACE_REPTILE) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足①效果的发动条件，即场上存在满足条件的怪兽且墓地存在满足条件的怪兽
function c17000165.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 判断是否满足①效果的发动条件，即场上存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c17000165.desfilter,tp,LOCATION_MZONE,0,1,nil,tp)
		-- 判断是否满足①效果的发动条件，即墓地存在满足条件的怪兽
		and Duel.IsExistingTarget(c17000165.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上满足条件的怪兽作为破坏对象
	local g1=Duel.SelectTarget(tp,c17000165.desfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择墓地满足条件的怪兽作为特殊召唤对象
	local g2=Duel.SelectTarget(tp,c17000165.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理时要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,1,0,0)
	-- 设置效果处理时要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g2,1,0,0)
end
-- 处理①效果的发动，先获取操作信息中的破坏和特殊召唤对象，然后执行破坏和特殊召唤操作
function c17000165.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取操作信息中要破坏的卡
	local ex,g1=Duel.GetOperationInfo(0,CATEGORY_DESTROY)
	-- 获取操作信息中要特殊召唤的卡
	local ex,g2=Duel.GetOperationInfo(0,CATEGORY_SPECIAL_SUMMON)
	local tc1=g1:GetFirst()
	local tc2=g2:GetFirst()
	-- 判断破坏和特殊召唤对象是否仍然有效，若有效则执行破坏和特殊召唤操作
	if tc1:IsRelateToEffect(e) and Duel.Destroy(tc1,REASON_EFFECT)~=0 and tc2:IsRelateToEffect(e) then
		-- 将满足条件的墓地怪兽特殊召唤到场上
		Duel.SpecialSummon(tc2,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断②效果是否可以发动，即对方发动了怪兽效果
function c17000165.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER)
end
-- 检索满足条件的对方场上怪兽组，该怪兽必须正面表示且攻击力为0且可以改变控制权且对方场上存在可用怪兽区
function c17000165.ctfilter(c,tp)
	-- 该怪兽必须正面表示且攻击力为0且可以改变控制权且对方场上存在可用怪兽区
	return c:IsFaceup() and c:IsAttack(0) and c:IsControlerCanBeChanged() and Duel.GetMZoneCount(1-tp,c,tp)>0
end
-- 判断是否满足②效果的发动条件，即对方场上存在满足条件的怪兽且自己可以特殊召唤衍生物
function c17000165.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c17000165.ctfilter(chkc,tp) end
	-- 判断是否满足②效果的发动条件，即对方场上存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c17000165.ctfilter,tp,0,LOCATION_MZONE,1,nil,tp)
		-- 判断是否满足②效果的发动条件，即自己可以特殊召唤衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,21179144,0x3c,TYPES_TOKEN_MONSTER,0,0,1,RACE_REPTILE,ATTRIBUTE_EARTH) end
	-- 提示玩家选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上满足条件的怪兽作为控制权变更对象
	local g=Duel.SelectTarget(tp,c17000165.ctfilter,tp,0,LOCATION_MZONE,1,1,nil,tp)
	-- 设置效果处理时要改变控制权的卡
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 处理②效果的发动，先获取操作信息中的控制权变更对象，然后执行控制权变更和特殊召唤衍生物操作
function c17000165.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中的目标卡
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡是否仍然有效且成功获得其控制权
	if tc:IsRelateToEffect(e) and Duel.GetControl(tc,tp)
		-- 判断对方场上是否存在可用怪兽区
		and Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0
		-- 判断自己是否可以特殊召唤衍生物
		and Duel.IsPlayerCanSpecialSummonMonster(tp,21179144,0x3c,TYPES_TOKEN_MONSTER,0,0,1,RACE_REPTILE,ATTRIBUTE_EARTH) then
		-- 中断当前效果，使之后的效果处理视为不同时处理
		Duel.BreakEffect()
		-- 创建一张爬虫妖衍生物
		local token=Duel.CreateToken(tp,17000166)
		-- 将爬虫妖衍生物特殊召唤到对方场上
		Duel.SpecialSummon(token,0,tp,1-tp,false,false,POS_FACEUP)
	end
end

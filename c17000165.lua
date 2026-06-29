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
-- 作为破坏对象表侧表示且攻击力为0的自己怪兽过滤条件
function c17000165.desfilter(c,tp)
	-- 确保该怪兽在被破坏后能腾出空位用于特殊召唤
	return c:IsFaceup() and c:IsAttack(0) and Duel.GetMZoneCount(tp,c)>0
end
-- 可从墓地特殊召唤的爬虫类族·暗属性怪兽过滤条件
function c17000165.spfilter(c,e,tp)
	return c:IsRace(RACE_REPTILE) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 破坏并特殊召唤效果的发动准备与对象选择
function c17000165.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己场上是否存在满足条件的攻击力为0的怪兽
	if chk==0 then return Duel.IsExistingTarget(c17000165.desfilter,tp,LOCATION_MZONE,0,1,nil,tp)
		-- 检查自己墓地是否存在满足条件的爬虫类族·暗属性怪兽
		and Duel.IsExistingTarget(c17000165.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家发送提示，请选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1只满足条件的怪兽为破坏对象
	local g1=Duel.SelectTarget(tp,c17000165.desfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 向玩家发送提示，请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地中1只满足条件的怪兽为特殊召唤对象
	local g2=Duel.SelectTarget(tp,c17000165.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息为破坏选中的场上怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,1,0,0)
	-- 设置操作信息为特殊召唤选中的墓地怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g2,1,0,0)
end
-- 破坏并特殊召唤效果的执行
function c17000165.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中登记的被破坏怪兽目标
	local ex,g1=Duel.GetOperationInfo(0,CATEGORY_DESTROY)
	-- 获取连锁中登记的特殊召唤怪兽目标
	local ex,g2=Duel.GetOperationInfo(0,CATEGORY_SPECIAL_SUMMON)
	local tc1=g1:GetFirst()
	local tc2=g2:GetFirst()
	-- 若破坏怪兽与特召怪兽均与效果关联，且被选场上怪兽被成功破坏
	if tc1:IsRelateToEffect(e) and Duel.Destroy(tc1,REASON_EFFECT)~=0 and tc2:IsRelateToEffect(e) then
		-- 将墓地中被选中的那只爬虫类族·暗属性怪兽特殊召唤
		Duel.SpecialSummon(tc2,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 对方发动怪兽效果的触发条件判断
function c17000165.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER)
end
-- 可夺取控制权的对方场上表侧表示攻击力为0的怪兽过滤条件
function c17000165.ctfilter(c,tp)
	-- 确保目标怪兽可以变更控制权且移动控制权后场上有其放置位置
	return c:IsFaceup() and c:IsAttack(0) and c:IsControlerCanBeChanged() and Duel.GetMZoneCount(1-tp,c,tp)>0
end
-- 夺取控制权并生成衍生物效果的发动准备与对象选择
function c17000165.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c17000165.ctfilter(chkc,tp) end
	-- 检查对方场上是否存在满足条件的攻击力为0的怪兽
	if chk==0 then return Duel.IsExistingTarget(c17000165.ctfilter,tp,0,LOCATION_MZONE,1,nil,tp)
		-- 检查自己是否能在对方场上特殊召唤「爬虫妖衍生物」
		and Duel.IsPlayerCanSpecialSummonMonster(tp,21179144,0x3c,TYPES_TOKEN_MONSTER,0,0,1,RACE_REPTILE,ATTRIBUTE_EARTH) end
	-- 向玩家发送提示，请选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 选择对方场上1只满足条件的怪兽为效果对象
	local g=Duel.SelectTarget(tp,c17000165.ctfilter,tp,0,LOCATION_MZONE,1,1,nil,tp)
	-- 设置操作信息为夺取选中怪兽的控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- 夺取控制权并生成衍生物效果的执行
function c17000165.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被选择夺取控制权的怪兽
	local tc=Duel.GetFirstTarget()
	-- 若该怪兽与效果关联且自己成功夺取其控制权
	if tc:IsRelateToEffect(e) and Duel.GetControl(tc,tp)>0
		-- 检查对方场上是否有空怪兽区域
		and Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0
		-- 确认系统是否允许在对方场上特殊召唤该「爬虫妖衍生物」
		and Duel.IsPlayerCanSpecialSummonMonster(tp,21179144,0x3c,TYPES_TOKEN_MONSTER,0,0,1,RACE_REPTILE,ATTRIBUTE_EARTH) then
		-- 切断效果处理的连锁时点
		Duel.BreakEffect()
		-- 创建「爬虫妖衍生物」
		local token=Duel.CreateToken(tp,17000166)
		-- 将创建的「爬虫妖衍生物」特殊召唤到对方场上
		Duel.SpecialSummon(token,0,tp,1-tp,false,false,POS_FACEUP)
	end
end

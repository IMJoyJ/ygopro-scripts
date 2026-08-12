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
-- 筛选自己场上表侧表示的攻击力0的怪兽，且该怪兽离场后自己场上仍有可用的主要怪兽区
function c17000165.desfilter(c,tp)
	-- 判定该卡为表侧表示且攻击力为0，并且该卡离场后自己场上至少有1个可用的主要怪兽区
	return c:IsFaceup() and c:IsAttack(0) and Duel.GetMZoneCount(tp,c)>0
end
-- 筛选墓地中可以被特殊召唤的爬虫类族·暗属性怪兽
function c17000165.spfilter(c,e,tp)
	return c:IsRace(RACE_REPTILE) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的对象选择：确认自己场上存在可选择的攻击力0的怪兽，且自己墓地存在可特殊召唤的爬虫类族·暗属性怪兽
function c17000165.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 效果发动条件检查：自己怪兽区存在1只以上可成为对象的攻击力0的怪兽（且其离场后有可用怪兽区）
	if chk==0 then return Duel.IsExistingTarget(c17000165.desfilter,tp,LOCATION_MZONE,0,1,nil,tp)
		-- 并且自己墓地存在1只以上可成为对象且可特殊召唤的爬虫类族·暗属性怪兽
		and Duel.IsExistingTarget(c17000165.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 以自己场上1只表侧表示的攻击力0的怪兽为对象（作为要破坏的怪兽）
	local g1=Duel.SelectTarget(tp,c17000165.desfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 以自己墓地1只可特殊召唤的爬虫类族·暗属性怪兽为对象
	local g2=Duel.SelectTarget(tp,c17000165.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：本次连锁将破坏作为对象的1只场上怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,1,0,0)
	-- 设置操作信息：本次连锁将特殊召唤作为对象的1只墓地怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g2,1,0,0)
end
-- ①效果的处理：破坏对象的场上怪兽，成功后特殊召唤对象的墓地怪兽
function c17000165.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得破坏操作信息中的卡片组（要破坏的怪兽）
	local ex,g1=Duel.GetOperationInfo(0,CATEGORY_DESTROY)
	-- 取得特殊召唤操作信息中的卡片组（要特殊召唤的墓地怪兽）
	local ex,g2=Duel.GetOperationInfo(0,CATEGORY_SPECIAL_SUMMON)
	local tc1=g1:GetFirst()
	local tc2=g2:GetFirst()
	-- 若场上对象怪兽仍与本效果关联，则以效果将其破坏，且墓地对象怪兽仍与本效果关联时继续处理
	if tc1:IsRelateToEffect(e) and Duel.Destroy(tc1,REASON_EFFECT)~=0 and tc2:IsRelateToEffect(e) then
		-- 将墓地的对象怪兽在自己场上以表侧表示特殊召唤
		Duel.SpecialSummon(tc2,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的发动条件：对方玩家把怪兽的效果发动
function c17000165.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and re:IsActiveType(TYPE_MONSTER)
end
-- 筛选对方场上表侧表示的攻击力0、控制权可以变更的怪兽，且其离场后我方场上仍有可用的主要怪兽区
function c17000165.ctfilter(c,tp)
	-- 判定该卡为表侧表示且攻击力为0、控制权可以变更，并且其离场后我方场上至少有1个可用的主要怪兽区
	return c:IsFaceup() and c:IsAttack(0) and c:IsControlerCanBeChanged() and Duel.GetMZoneCount(1-tp,c,tp)>0
end
-- ②效果的对象选择：确认对方场上存在符合条件的攻击力0的怪兽，且自己可以特殊召唤爬虫妖衍生物
function c17000165.cttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c17000165.ctfilter(chkc,tp) end
	-- 效果发动条件检查：对方怪兽区存在1只以上可成为对象的攻击力0且控制权可变更的怪兽
	if chk==0 then return Duel.IsExistingTarget(c17000165.ctfilter,tp,0,LOCATION_MZONE,1,nil,tp)
		-- 并且自己可以把「爬虫妖衍生物」（爬虫类族·地·1星·攻/守0）特殊召唤
		and Duel.IsPlayerCanSpecialSummonMonster(tp,21179144,0x3c,TYPES_TOKEN_MONSTER,0,0,1,RACE_REPTILE,ATTRIBUTE_EARTH) end
	-- 提示玩家选择要改变控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 以对方场上1只符合条件的攻击力0的怪兽为对象
	local g=Duel.SelectTarget(tp,c17000165.ctfilter,tp,0,LOCATION_MZONE,1,1,nil,tp)
	-- 设置操作信息：本次连锁将得到对象怪兽的控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
-- ②效果的处理：得到对象怪兽的控制权，那之后在对方场上特殊召唤1只爬虫妖衍生物
function c17000165.ctop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本连锁的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍与本效果关联，则得到那只怪兽的控制权
	if tc:IsRelateToEffect(e) and Duel.GetControl(tc,tp)>0
		-- 并且对方场上有可用于特殊召唤衍生物的主要怪兽区空格
		and Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0
		-- 并且自己可以把「爬虫妖衍生物」（爬虫类族·地·1星·攻/守0）特殊召唤
		and Duel.IsPlayerCanSpecialSummonMonster(tp,21179144,0x3c,TYPES_TOKEN_MONSTER,0,0,1,RACE_REPTILE,ATTRIBUTE_EARTH) then
		-- 中断效果处理，使之后的衍生物特殊召唤与控制权变更视为不同时处理
		Duel.BreakEffect()
		-- 生成「爬虫妖衍生物」
		local token=Duel.CreateToken(tp,17000166)
		-- 把1只「爬虫妖衍生物」在对方场上以表侧表示特殊召唤
		Duel.SpecialSummon(token,0,tp,1-tp,false,false,POS_FACEUP)
	end
end

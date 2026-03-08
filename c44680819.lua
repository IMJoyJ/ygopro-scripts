--ランリュウ
-- 效果：
-- ①：「岚龙」在自己场上只能有1张表侧表示存在。
-- ②：自己场上有魔法师族怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ③：这张卡被战斗·效果破坏送去墓地的场合，以除「岚龙」外的自己墓地1只攻击力1500/守备力200的怪兽为对象才能发动。那只怪兽特殊召唤。
function c44680819.initial_effect(c)
	c:SetUniqueOnField(1,0,44680819)
	-- 效果原文内容：②：自己场上有魔法师族怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c44680819.sprcon)
	c:RegisterEffect(e1)
	-- 效果原文内容：③：这张卡被战斗·效果破坏送去墓地的场合，以除「岚龙」外的自己墓地1只攻击力1500/守备力200的怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(44680819,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c44680819.spcon)
	e2:SetTarget(c44680819.sptg)
	e2:SetOperation(c44680819.spop)
	c:RegisterEffect(e2)
end
-- 规则层面作用：检查场上是否存在正面表示的魔法师族怪兽
function c44680819.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER)
end
-- 规则层面作用：判断是否满足从手卡特殊召唤的条件（有空场且己方场上存在魔法师族怪兽）
function c44680819.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 规则层面作用：判断己方场上是否有足够的怪兽区域
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 规则层面作用：判断己方场上是否存在至少1只魔法师族怪兽
		and Duel.IsExistingMatchingCard(c44680819.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 规则层面作用：判断此卡是否因战斗或效果破坏而送入墓地
function c44680819.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- 规则层面作用：过滤墓地中攻击力为1500、守备力为200且不是岚龙的怪兽
function c44680819.spfilter(c,e,tp)
	return c:IsAttack(1500) and c:IsDefense(200) and not c:IsCode(44680819) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 规则层面作用：判断是否可以选取符合条件的墓地怪兽作为特殊召唤对象
function c44680819.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c44680819.spfilter(chkc,e,tp) end
	-- 规则层面作用：检查是否存在满足条件的墓地怪兽
	if chk==0 then return Duel.IsExistingTarget(c44680819.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 规则层面作用：确认己方场上是否有足够的怪兽区域用于特殊召唤
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 规则层面作用：向玩家提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面作用：选择目标墓地怪兽作为特殊召唤对象
	local g=Duel.SelectTarget(tp,c44680819.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 规则层面作用：设置连锁操作信息，表明将要特殊召唤一只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 规则层面作用：执行特殊召唤操作
function c44680819.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取当前连锁中选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 规则层面作用：将目标怪兽以正面表示形式特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

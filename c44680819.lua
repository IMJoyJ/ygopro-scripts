--ランリュウ
-- 效果：
-- ①：「岚龙」在自己场上只能有1张表侧表示存在。
-- ②：自己场上有魔法师族怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ③：这张卡被战斗·效果破坏送去墓地的场合，以除「岚龙」外的自己墓地1只攻击力1500/守备力200的怪兽为对象才能发动。那只怪兽特殊召唤。
function c44680819.initial_effect(c)
	c:SetUniqueOnField(1,0,44680819)
	-- ②：自己场上有魔法师族怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c44680819.sprcon)
	c:RegisterEffect(e1)
	-- ③：这张卡被战斗·效果破坏送去墓地的场合，以除「岚龙」外的自己墓地1只攻击力1500/守备力200的怪兽为对象才能发动。那只怪兽特殊召唤。
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
-- 判定怪兽是否为表侧表示且种族为魔法师族，用于检查自己场上是否存在魔法师族怪兽。
function c44680819.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER)
end
-- ②无种类特殊召唤的处理：这张卡在手牌时，若自己主要怪兽区有空位且自己场上有表侧表示魔法师族怪兽，则可以作为特殊召唤规则从手卡特殊召唤；c为nil时表示该召唤手续存在。
function c44680819.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己主要怪兽区是否有可用空格，保证特殊召唤能进行。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上是否存在至少1只表侧表示且为魔法师族的怪兽，满足②的发动条件。
		and Duel.IsExistingMatchingCard(c44680819.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ③的发动条件：这张卡被战斗或效果破坏并送去墓地。
function c44680819.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- 筛选满足③对象的墓地怪兽：攻击力1500、守备力200、卡名不是「岚龙」，且能够被当前效果特殊召唤。
function c44680819.spfilter(c,e,tp)
	return c:IsAttack(1500) and c:IsDefense(200) and not c:IsCode(44680819) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③的取对象发动处理：选择自己墓地1只符合条件的怪兽为对象，同时确认自己主要怪兽区有空位；chkc用于连锁判定对象合法性，chk==0时检查是否存在合法对象和空位。
function c44680819.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c44680819.spfilter(chkc,e,tp) end
	-- 检查自己墓地是否存在至少1只符合条件且能特殊召唤的怪兽，作为取对象目标的候选。
	if chk==0 then return Duel.IsExistingTarget(c44680819.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 同时确认自己主要怪兽区有空位，确保特殊召唤能够进行。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 向玩家提示“请选择要特殊召唤的卡”（选择目标怪兽的提示消息）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只符合条件的怪兽作为效果对象，并自动建立对象关联。
	local g=Duel.SelectTarget(tp,c44680819.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：本次效果为特殊召唤，目标为已选择的怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ③的效果处理：取回对象怪兽，若其仍与效果关联，则将其表侧表示特殊召唤到自己场上。
function c44680819.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中第一个对象卡，即墓地的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到自己场上（不指定特殊召唤类型，不检查苏生限制）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end

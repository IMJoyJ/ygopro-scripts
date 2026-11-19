--サイバー・エタニティ・ドラゴン
-- 效果：
-- 「电子龙」怪兽＋机械族怪兽×2
-- ①：只要自己墓地有机械族融合怪兽存在，这张卡不会被对方的效果破坏，对方不能把这张卡作为效果的对象。
-- ②：融合召唤的这张卡被对方送去墓地的场合才能发动。从自己的手卡·卡组·墓地把1只「电子龙」特殊召唤。
-- ③：把墓地的这张卡除外才能发动。这个回合中，自己场上的融合怪兽不会被对方的效果破坏，对方不能把那些作为效果的对象。
function c82315403.initial_effect(c)
	-- 登记卡片文本中记述的关联卡名「电子龙」
	aux.AddCodeList(c,70095154)
	c:EnableReviveLimit()
	-- 注册融合召唤素材要求，需要1只「电子龙」融合字段怪兽和2只机械族怪兽作为融合素材（并允许正规融合召唤）
	aux.AddFusionProcFunFun(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x1093),aux.FilterBoolFunction(Card.IsRace,RACE_MACHINE),2,true)
	-- ①：只要自己墓地有机械族融合怪兽存在，这张卡不会被对方的效果破坏，对方不能把这张卡作为效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c82315403.indcon)
	-- 设置取对象抗性的过滤值，使这张卡不会成为对方效果的对象
	e1:SetValue(aux.tgoval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	-- 设置效果破坏抗性的过滤值，使这张卡不会被对方的效果破坏
	e2:SetValue(aux.indoval)
	c:RegisterEffect(e2)
	-- ②：融合召唤的这张卡被对方送去墓地的场合才能发动。从自己的手卡·卡组·墓地把1只「电子龙」特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(82315403,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c82315403.spcon)
	e3:SetTarget(c82315403.sptg)
	e3:SetOperation(c82315403.spop)
	c:RegisterEffect(e3)
	-- ③：把墓地的这张卡除外才能发动。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(82315403,1))
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_GRAVE)
	-- 设置③效果的发动代价，使用通用函数把墓地的这张卡除外
	e4:SetCost(aux.bfgcost)
	e4:SetOperation(c82315403.operation)
	c:RegisterEffect(e4)
end
c82315403.material_setcode=0x1093
-- 过滤墓地中的怪兽：须为融合怪兽且种族为机械族
function c82315403.cfilter(c)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_MACHINE)
end
-- 检查①效果的适用条件：自己墓地是否存在至少1只机械族融合怪兽
function c82315403.indcon(e)
	-- 判定控制者墓地中是否存在至少1只满足条件的机械族融合怪兽
	return Duel.IsExistingMatchingCard(c82315403.cfilter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,1,nil)
end
-- 检查②效果的发动条件：这张卡是通过融合召唤出场的、且由对方玩家的操作从自己怪兽区送去墓地
function c82315403.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_FUSION) and rp==1-tp and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
end
-- 过滤可被②效果特殊召唤的怪兽：卡名为「电子龙」且能够被特殊召唤
function c82315403.spfilter(c,e,tp)
	return c:IsCode(70095154) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动合法性检查：确认自己怪兽区仍有空位且手卡·卡组·墓地存在可特殊召唤的「电子龙」
function c82315403.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否还有至少1个可用空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己手卡·卡组·墓地中是否存在至少1只可特殊召唤的「电子龙」
		and Duel.IsExistingMatchingCard(c82315403.spfilter,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 登记本次连锁包含从自己手卡·卡组·墓地特殊召唤1只怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE)
end
-- 执行②效果处理：确认怪兽区仍有空位后，从自己手卡·卡组·墓地（受王家长眠之谷过滤）选择1只「电子龙」以表侧表示特殊召唤到自己场上
function c82315403.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己主要怪兽区是否已无空位，若无空位则中止特殊召唤处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向发动玩家发送选择要特殊召唤的卡片提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让发动玩家从自己手卡·卡组·墓地中（排除受王家长眠之谷影响的墓地卡）选择1只「电子龙」
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c82315403.spfilter),tp,LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选出的「电子龙」以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 执行③效果处理：为自己注册持续到回合结束为止、使自己场上全部融合怪兽获得不被对方选为效果对象与不被对方效果破坏抗性的场上效果
function c82315403.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合中，自己场上的融合怪兽不会被对方的效果破坏，对方不能把那些作为效果的对象。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c82315403.efftg)
	-- 设置取对象抗性的过滤值，使适用范围内的融合怪兽不会成为对方效果的对象
	e1:SetValue(aux.tgoval)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 为自己注册赋予场上融合怪兽不被对方选为对象抗性的效果
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	-- 设置效果破坏抗性的过滤值，使适用范围内的融合怪兽不会被对方的效果破坏
	e2:SetValue(aux.indoval)
	-- 为自己注册赋予场上融合怪兽不被对方效果破坏抗性的效果
	Duel.RegisterEffect(e2,tp)
end
-- 效果适用对象过滤函数：只对属于融合怪兽的怪兽卡生效
function c82315403.efftg(e,c)
	return c:IsType(TYPE_FUSION)
end

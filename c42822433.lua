--星騎士 アルテア
-- 效果：
-- 这个卡名在规则上也当作「星圣」卡使用。这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·反转召唤·特殊召唤的场合，以最多有自己场上的光·暗属性超量怪兽数量的场上的卡为对象才能发动。那些卡破坏。
-- ②：自己场上有「星骑士 牛郎星」以外的「星骑士」、「星圣」怪兽特殊召唤的场合才能发动。这张卡从墓地特殊召唤。这个回合，自己不用超量怪兽不能攻击宣言。
function c42822433.initial_effect(c)
	-- ①：这张卡召唤·反转召唤·特殊召唤的场合，以最多有自己场上的光·暗属性超量怪兽数量的场上的卡为对象才能发动。那些卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,42822433)
	e1:SetTarget(c42822433.destg)
	e1:SetOperation(c42822433.desop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	c42822433.star_knight_summon_effect=e1
	-- ②：自己场上有「星骑士 牛郎星」以外的「星骑士」、「星圣」怪兽特殊召唤的场合才能发动。这张卡从墓地特殊召唤。这个回合，自己不用超量怪兽不能攻击宣言。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1,42822434)
	e4:SetCondition(c42822433.spcon)
	e4:SetTarget(c42822433.sptg)
	e4:SetOperation(c42822433.spop)
	c:RegisterEffect(e4)
end
-- 过滤函数，用于判断场上是否存在光·暗属性的超量怪兽
function c42822433.ckfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsType(TYPE_XYZ)
end
-- 效果处理时的取对象阶段，计算自己场上光·暗属性超量怪兽数量，并选择场上数量的卡进行破坏
function c42822433.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 计算自己场上光·暗属性超量怪兽数量
	local ct=Duel.GetMatchingGroupCount(c42822433.ckfilter,tp,LOCATION_MZONE,0,nil)
	if chkc then return chkc:IsOnField() end
	-- 判断是否满足发动条件：场上存在光·暗属性超量怪兽且存在可破坏的场上卡
	if chk==0 then return ct>0 and Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择最多等于光·暗属性超量怪兽数量的场上卡作为破坏对象
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,nil)
	-- 设置效果操作信息，确定要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
-- 效果处理阶段，将选择的卡进行破坏
function c42822433.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取与当前连锁相关的破坏对象
	local g=Duel.GetTargetsRelateToChain()
	if #g==0 then return end
	-- 将对象卡进行破坏
	Duel.Destroy(g,REASON_EFFECT)
end
-- 过滤函数，用于判断是否为「星骑士」或「星圣」怪兽且非牛郎星
function c42822433.cfilter(c,tp)
	return not c:IsCode(42822433) and c:IsFaceup() and c:IsControler(tp)
		and c:IsSetCard(0x9c,0x53)
end
-- 判断是否有满足条件的「星骑士」或「星圣」怪兽被特殊召唤
function c42822433.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c42822433.cfilter,1,nil,tp)
end
-- 判断是否满足特殊召唤条件：场上存在空位且自身可特殊召唤
function c42822433.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果操作信息，确定要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理阶段，将自身从墓地特殊召唤并设置不能攻击宣言效果
function c42822433.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将自身从墓地特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 这个回合，自己不用超量怪兽不能攻击宣言。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c42822433.atktg)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册不能攻击宣言的效果
	Duel.RegisterEffect(e1,tp)
end
-- 设置不能攻击宣言效果的目标条件：非超量怪兽不能攻击宣言
function c42822433.atktg(e,c)
	return not c:IsType(TYPE_XYZ)
end

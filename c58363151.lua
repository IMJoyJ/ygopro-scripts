--S－Force プラ＝ティナ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合，以「治安战警队 铂金女」以外的除外的1只自己的「治安战警队」怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：只要这张卡在怪兽区域存在，自己的「治安战警队」怪兽的正对面的对方怪兽的攻击力下降600。
function c58363151.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡召唤·特殊召唤成功的场合，以「治安战警队 铂金女」以外的除外的1只自己的「治安战警队」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(58363151,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,58363151)
	e1:SetTarget(c58363151.sptg)
	e1:SetOperation(c58363151.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在怪兽区域存在，自己的「治安战警队」怪兽的正对面的对方怪兽的攻击力下降600。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetTarget(c58363151.atktg)
	e3:SetValue(-600)
	c:RegisterEffect(e3)
end
-- 过滤除外状态、表侧表示、卡名非「治安战警队 铂金女」且可以特殊召唤的「治安战警队」怪兽
function c58363151.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0x156) and not c:IsCode(58363151) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动准备与目标选择，确认除外区有符合条件的怪兽并将其选择为效果对象
function c58363151.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c58363151.spfilter(chkc,e,tp) end
	-- 在发动时，检查除外区是否存在符合条件的怪兽，且己方场上有可用的怪兽区域
	if chk==0 then return Duel.IsExistingTarget(c58363151.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) and Duel.GetMZoneCount(tp)>0 end
	-- 向玩家发送提示信息，要求选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择除外的1只符合条件的「治安战警队」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c58363151.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置连锁的操作信息，表明此效果包含特殊召唤该对象的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果的实际处理，将选择的对象怪兽特殊召唤
function c58363151.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤到己方场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤己方场上表侧表示的「治安战警队」怪兽
function c58363151.atkfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x156) and c:IsLocation(LOCATION_MZONE) and c:IsControler(tp)
end
-- 判断对方怪兽的同纵列是否存在己方的「治安战警队」怪兽
function c58363151.atktg(e,c)
	local cg=c:GetColumnGroup()
	return cg:IsExists(c58363151.atkfilter,1,nil,e:GetHandlerPlayer())
end

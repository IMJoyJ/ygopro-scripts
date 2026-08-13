--ヒロイック・コール
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从自己的手卡·墓地选1只战士族怪兽特殊召唤。这个效果把「英豪」怪兽以外的怪兽特殊召唤的场合，那只怪兽不能攻击，效果无效化。
-- ②：自己基本分是500以下的场合，把墓地的这张卡除外，以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力上升自己场上的「英豪」卡以及作为超量素材中的「英豪」卡数量×500。
local s,id,o=GetID()
-- 初始化该卡的全部效果：注册①的特殊召唤效果和②的墓地除外加攻效果，分别设置描述、类别、类型、发动条件、限制、目标与处理函数。
function s.initial_effect(c)
	-- ①：从自己的手卡·墓地选1只战士族怪兽特殊召唤。这个效果把「英豪」怪兽以外的怪兽特殊召唤的场合，那只怪兽不能攻击，效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：自己基本分是500以下的场合，把墓地的这张卡除外，以自己场上1只表侧表示怪兽为对象才能发动。那只怪兽的攻击力上升自己场上的「英豪」卡以及作为超量素材中的「英豪」卡数量×500。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"攻击力上升"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(s.atkcon)
	-- 将除外自身作为效果发动的代价。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
-- 定义检索/选择的怪兽条件：必须是战士族怪兽，且能够被当前效果特殊召唤。
function s.filter(c,e,tp)
	return c:IsRace(RACE_WARRIOR) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时判定：自己的主要怪兽区有空位，且手卡·墓地存在满足条件的战士族怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主要怪兽区空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡·墓地是否存在1只满足检索条件的战士族怪兽。
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp) end
	-- 预设置效果处理信息：本次特殊召唤的卡来自手卡·墓地，预计处理1只。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
-- 效果处理：从手卡·墓地选择1只战士族怪兽特殊召唤；若召唤的不是「英豪」怪兽，则对其附加不能攻击、效果无效化的状态。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理前再次确认主要怪兽区仍有空格，否则直接结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家弹出选择提示，要求选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·墓地选择1只满足过滤器（并排除王家长眠之谷影响的）战士族怪兽。
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp):GetFirst()
	-- 将选择的怪兽以表侧攻击表示特殊召唤；如果该怪兽不属于「英豪」怪兽，则追加无效化及不能攻击的处理。
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) and not tc:IsSetCard(0x6f) then
		local c=e:GetHandler()
		-- 这个效果把「英豪」怪兽以外的怪兽特殊召唤的场合，那只怪兽效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 这个效果把「英豪」怪兽以外的怪兽特殊召唤的场合，那只怪兽效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- 这个效果把「英豪」怪兽以外的怪兽特殊召唤的场合，那只怪兽不能攻击。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_CANNOT_ATTACK)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e3)
	end
	-- 结束分步特殊召唤的连续处理，完成整个特殊召唤过程。
	Duel.SpecialSummonComplete()
end
-- ②效果的发动条件：自己的基本分在500以下。
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前玩家LP是否≤500。
	return Duel.GetLP(tp)<=500
end
-- 定义「英豪」卡过滤器：字段为「英豪」且表侧表示。
function s.afilter(c)
	return c:IsSetCard(0x6f) and c:IsFaceup()
end
-- ②发动时的目标选择及数量计算：先确认可以取对象，且场上表侧「英豪」卡与作为超量素材的「英豪」卡合计数量大于0。
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 计算自己场上表侧表示的「英豪」卡数量。
	local ct1=Duel.GetMatchingGroupCount(s.afilter,tp,LOCATION_ONFIELD,0,nil)
	-- 计算自己场上所有作为超量素材中的「英豪」卡数量。
	local ct2=Duel.GetOverlayGroup(tp,1,0):FilterCount(Card.IsSetCard,nil,0x6f)
	-- 确认自己场上存在1只可以成为对象的表侧表示怪兽。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil)
		and ct1+ct2>0 end
	-- 向玩家弹出选择提示，要求选择1只表侧表示怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示怪兽作为效果对象（并登记为对象）。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：取得对象怪兽，计算场上及超量素材中的「英豪」卡数量，使对象怪兽攻击力上升该数量×500。
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动②时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 再次计算自己场上表侧表示的「英豪」卡数量。
		local ct1=Duel.GetMatchingGroupCount(s.afilter,tp,LOCATION_ONFIELD,0,nil)
		-- 再次计算自己场上所有作为超量素材中的「英豪」卡数量。
		local ct2=Duel.GetOverlayGroup(tp,1,0):FilterCount(Card.IsSetCard,nil,0x6f)
		-- 那只怪兽的攻击力上升自己场上的「英豪」卡以及作为超量素材中的「英豪」卡数量×500。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue((ct1+ct2)*500)
		tc:RegisterEffect(e1)
	end
end

--シャドウ・ヴァンパイア
-- 效果：
-- 把这张卡作为超量召唤的素材的场合，不是暗属性怪兽的超量召唤不能使用。
-- ①：这张卡召唤成功时才能发动。从手卡·卡组把「影之吸血鬼」以外的1只暗属性「吸血鬼」怪兽特殊召唤。这个效果特殊召唤成功的回合，那只怪兽以外的自己怪兽不能攻击。
function c14212201.initial_effect(c)
	-- ①：这张卡召唤成功时才能发动。从手卡·卡组把「影之吸血鬼」以外的1只暗属性「吸血鬼」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(14212201,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c14212201.sptg)
	e1:SetOperation(c14212201.spop)
	c:RegisterEffect(e1)
	-- 把这张卡作为超量召唤的素材的场合，不是暗属性怪兽的超量召唤不能使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e2:SetValue(c14212201.xyzlimit)
	c:RegisterEffect(e2)
end
-- 特殊召唤对象的筛选条件：不是「影之吸血鬼」自身、暗属性、属于「吸血鬼」系列，且能被当前效果特殊召唤（满足苏生限制）。
function c14212201.filter(c,e,tp)
	return not c:IsCode(14212201) and c:IsSetCard(0x8e) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动合法性判定：自己主要怪兽区有空位，且手卡·卡组中存在至少1只满足筛选条件的暗属性「吸血鬼」怪兽。
function c14212201.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否有可用空格（用于判定能否特殊召唤）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌或卡组是否存在至少1只满足c14212201.filter的怪兽。
		and Duel.IsExistingMatchingCard(c14212201.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 将连锁的操作信息设置为特殊召唤分类，预定从手卡·卡组特殊召唤1只怪兽（供后续时点和相关效果检测）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果处理：若主要怪兽区有空位，提示选择并让玩家从手卡·卡组选择1只符合条件的怪兽特殊召唤；若特殊召唤成功，则给那只怪兽以外的自己怪兽附加本回合不能攻击的效果。
function c14212201.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认自己主要怪兽区仍有空位，否则不进行处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示‘请选择要特殊召唤的卡’的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·卡组中选择1只满足c14212201.filter的怪兽作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c14212201.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 若选中的怪兽存在，且以表侧表示特殊召唤成功，则继续执行攻击限制的处理。
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 这个效果特殊召唤成功的回合，那只怪兽以外的自己怪兽不能攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetTarget(c14212201.ftarget)
		e1:SetLabel(tc:GetFieldID())
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将‘不能攻击’的永续效果注册到场上，使限制效果在本回合内持续生效。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 攻击限制的判定：除特殊召唤成功的那只怪兽（通过FieldID标记）以外，自己场上的其他怪兽都会受到不能攻击的限制。
function c14212201.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID()
end
-- 作为超量素材的限制判定：若所用于超量召唤的素材不是暗属性怪兽，则不能将这张卡作为超量素材。
function c14212201.xyzlimit(e,c)
	if not c then return false end
	return not c:IsAttribute(ATTRIBUTE_DARK)
end

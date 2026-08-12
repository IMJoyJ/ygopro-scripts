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
-- 过滤函数，用于筛选满足条件的暗属性吸血鬼怪兽
function c14212201.filter(c,e,tp)
	return not c:IsCode(14212201) and c:IsSetCard(0x8e) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理函数，用于设置特殊召唤的处理目标
function c14212201.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足发动条件，检查场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否满足发动条件，检查手卡或卡组中是否存在符合条件的怪兽
		and Duel.IsExistingMatchingCard(c14212201.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理信息，指定将要特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果处理函数，执行特殊召唤操作
function c14212201.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否还有空位，如果没有则不执行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c14212201.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 执行特殊召唤操作，如果成功则设置后续效果
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 设置不能攻击的效果，使除特殊召唤的怪兽外的其他自己怪兽不能攻击
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetTarget(c14212201.ftarget)
		e1:SetLabel(tc:GetFieldID())
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将设置好的不能攻击效果注册到场上
		Duel.RegisterEffect(e1,tp)
	end
end
-- 用于判断是否为被特殊召唤的怪兽，以决定是否可以攻击
function c14212201.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID()
end
-- 用于判断是否可以作为超量素材，若不是暗属性则不能作为超量素材
function c14212201.xyzlimit(e,c)
	if not c then return false end
	return not c:IsAttribute(ATTRIBUTE_DARK)
end

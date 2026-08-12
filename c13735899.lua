--ミュステリオンの竜冠
-- 效果：
-- 魔法师族怪兽＋龙族怪兽
-- 这张卡不能作为融合素材。这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡的攻击力下降自己的除外状态的卡数量×100。
-- ②：怪兽发动的效果让那只怪兽或者原本种族和那只怪兽相同的怪兽特殊召唤的场合，以那之内的1只为对象才能发动。作为对象的怪兽以及原本种族和那只怪兽相同的场上的怪兽全部除外。
function c13735899.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续，使用一张魔法师族怪兽和一张龙族怪兽作为融合素材
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsRace,RACE_SPELLCASTER),aux.FilterBoolFunction(Card.IsRace,RACE_DRAGON),true)
	-- 这张卡不能作为融合素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 这张卡的攻击力下降自己的除外状态的卡数量×100。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetValue(c13735899.atkval)
	c:RegisterEffect(e2)
	-- 怪兽发动的效果让那只怪兽或者原本种族和那只怪兽相同的怪兽特殊召唤的场合，以那之内的1只为对象才能发动。作为对象的怪兽以及原本种族和那只怪兽相同的场上的怪兽全部除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(13735899,0))  --"怪兽除外"
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,13735899)
	e3:SetCondition(c13735899.remcon)
	e3:SetTarget(c13735899.remtg)
	e3:SetOperation(c13735899.remop)
	c:RegisterEffect(e3)
end
-- 计算攻击力下降值，为除外区卡数量乘以-100
function c13735899.atkval(e)
	-- 返回除外区卡数量乘以-100作为攻击力下降值
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_REMOVED,0)*-100
end
-- 筛选符合条件的特殊召唤怪兽，用于判断是否满足除外条件
function c13735899.cfilter(c,e)
	local typ,se=c:GetSpecialSummonInfo(SUMMON_INFO_TYPE,SUMMON_INFO_REASON_EFFECT)
	if not se then return false end
	local sc=se:GetHandler()
	local tp=e:GetHandlerPlayer()
	return typ&TYPE_MONSTER~=0 and se:IsActivated()
		and c:IsFaceup() and (c:GetOriginalRace()==sc:GetOriginalRace() or c==sc)
		-- 确保目标怪兽可以成为效果对象，并且场上存在满足除外条件的怪兽
		and c:IsCanBeEffectTarget(e) and Duel.IsExistingMatchingCard(c13735899.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,c)
end
-- 判断是否满足除外效果的发动条件
function c13735899.remcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c13735899.cfilter,1,nil,e)
		and not eg:IsContains(e:GetHandler())
end
-- 筛选与目标怪兽种族相同的场上怪兽
function c13735899.rmfilter(c,tc)
	return c:IsFaceup() and c:GetOriginalRace()==tc:GetOriginalRace() and c:IsAbleToRemove()
end
-- 设置除外效果的目标选择处理
function c13735899.remtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=eg:Filter(c13735899.cfilter,nil,e):Filter(Card.IsLocation,nil,LOCATION_MZONE)
	-- 判断目标是否在筛选组中
	if chkc then return aux.IsInGroup(chkc,g) end
	-- 检查是否有满足条件的目标怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.IsInGroup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,g) end
	local tc=g:GetFirst()
	if #g>1 then
		-- 向玩家发送选择提示消息
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		tc=g:Select(tp,1,1,nil):GetFirst()
	end
	-- 设置当前效果的目标怪兽
	Duel.SetTargetCard(tc)
	-- 获取与目标怪兽种族相同的场上怪兽组
	local tg=Duel.GetMatchingGroup(c13735899.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tc)
	tg:AddCard(tc)
	-- 设置操作信息，指定将要除外的怪兽组
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,tg,#tg,0,0)
end
-- 执行除外效果的操作处理
function c13735899.remop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local g=Group.FromCards(tc)
		if tc:IsFaceup() then
			-- 将与目标怪兽种族相同的场上怪兽加入除外组
			g=g+Duel.GetMatchingGroup(c13735899.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tc)
		end
		-- 将指定怪兽组除外
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end

--ミュステリオンの竜冠
-- 效果：
-- 魔法师族怪兽＋龙族怪兽
-- 这张卡不能作为融合素材。这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡的攻击力下降自己的除外状态的卡数量×100。
-- ②：怪兽发动的效果让那只怪兽或者原本种族和那只怪兽相同的怪兽特殊召唤的场合，以那之内的1只为对象才能发动。作为对象的怪兽以及原本种族和那只怪兽相同的场上的怪兽全部除外。
function c13735899.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加融合召唤手续：以魔法师族怪兽1只和龙族怪兽1只作为融合素材（对应融合素材条件“魔法师族怪兽＋龙族怪兽”）。
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsRace,RACE_SPELLCASTER),aux.FilterBoolFunction(Card.IsRace,RACE_DRAGON),true)
	-- 这张卡不能作为融合素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ①：这张卡的攻击力下降自己的除外状态的卡数量×100。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetValue(c13735899.atkval)
	c:RegisterEffect(e2)
	-- 这个卡名的②的效果1回合只能使用1次。②：怪兽发动的效果让那只怪兽或者原本种族和那只怪兽相同的怪兽特殊召唤的场合，以那之内的1只为对象才能发动。作为对象的怪兽以及原本种族和那只怪兽相同的场上的怪兽全部除外。
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
-- 攻击力变化值函数：根据这张卡的控制者除外区的卡数量计算攻击力下降值，每有1张除外卡攻击力下降100，返回负值。
function c13735899.atkval(e)
	-- 返回（控制者除外区卡数 × -100）作为攻击力增减数值。
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_REMOVED,0)*-100
end
-- ②的触发过滤函数：判断特殊召唤成功的怪兽c是否由怪兽效果发动的特殊召唤，且c与发动效果的怪兽原本种族相同或是其自身，并且c能成为效果对象且场上存在至少1只可被除外的同原本种族表侧怪兽。
function c13735899.cfilter(c,e)
	local typ,se=c:GetSpecialSummonInfo(SUMMON_INFO_TYPE,SUMMON_INFO_REASON_EFFECT)
	if not se then return false end
	local sc=se:GetHandler()
	local tp=e:GetHandlerPlayer()
	return typ&TYPE_MONSTER~=0 and se:IsActivated()
		and c:IsFaceup() and (c:GetOriginalRace()==sc:GetOriginalRace() or c==sc)
		-- 并且该特殊召唤怪兽能成为效果对象，且场上存在至少1只与其原本种族相同、表侧表示且可除外的怪兽。
		and c:IsCanBeEffectTarget(e) and Duel.IsExistingMatchingCard(c13735899.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,c)
end
-- ②的发动条件：本次特殊召唤成功的怪兽组中存在满足cfilter的怪兽，且该怪兽组中不包含这张卡自身。
function c13735899.remcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c13735899.cfilter,1,nil,e)
		and not eg:IsContains(e:GetHandler())
end
-- 要除外的卡的筛选条件：表侧表示、原本种族与对象怪兽相同、且可以被除外。
function c13735899.rmfilter(c,tc)
	return c:IsFaceup() and c:GetOriginalRace()==tc:GetOriginalRace() and c:IsAbleToRemove()
end
-- ②的发动时处理：从满足条件的特殊召唤怪兽中选出1只作为对象（多只时选择），再检索场上所有与对象原本种族相同的表侧可除外怪兽（含对象自身），并设置除外相关的操作信息。
function c13735899.remtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=eg:Filter(c13735899.cfilter,nil,e):Filter(Card.IsLocation,nil,LOCATION_MZONE)
	-- 连锁处理中检查被指定为对象的卡是否仍属于可选组g，以确认对象合法。
	if chkc then return aux.IsInGroup(chkc,g) end
	-- 发动时检查场上是否存在至少1只可选组g中的合法对象，以此作为发动条件。
	if chk==0 then return Duel.IsExistingTarget(aux.IsInGroup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,g) end
	local tc=g:GetFirst()
	if #g>1 then
		-- 向玩家显示“请选择要除外的卡”的提示，用于选择要除外的那1只对象怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		tc=g:Select(tp,1,1,nil):GetFirst()
	end
	-- 将选择的怪兽设置为该效果的对象，使其与效果建立关联，便于后续处理时确认。
	Duel.SetTargetCard(tc)
	-- 获取场上所有与对象怪兽原本种族相同、表侧表示且可除外的怪兽（包含对象自身）。
	local tg=Duel.GetMatchingGroup(c13735899.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tc)
	tg:AddCard(tc)
	-- 设置操作信息：把组内卡片作为除外对象，登记效果处理时将除外这些卡。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,tg,#tg,0,0)
end
-- ②的效果处理：取出对象怪兽，若其仍与该效果关联，则将其除外；若对象仍为表侧表示，则把场上所有与对象原本种族相同的表侧可除外怪兽一并除外。
function c13735899.remop(e,tp,eg,ep,ev,re,r,rp)
	-- 取出本效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local g=Group.FromCards(tc)
		if tc:IsFaceup() then
			-- 当对象仍为表侧表示时，将场上所有与其原本种族相同、表侧表示且可除外的怪兽加入除外组。
			g=g+Duel.GetMatchingGroup(c13735899.rmfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tc)
		end
		-- 将组中的全部卡片以表侧表示除外，除外原因为效果。
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end

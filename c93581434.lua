--剛鬼ヘルトレーナー
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己场上没有怪兽存在的场合，把手卡的这张卡给对方观看，以自己墓地1只「刚鬼」连接怪兽为对象才能发动。这张卡从手卡特殊召唤。那之后，作为对象的怪兽特殊召唤。这个效果特殊召唤的连接怪兽攻击力下降500。
-- ②：只要自己场上有「刚鬼」连接怪兽存在，这张卡不会被战斗破坏。
function c93581434.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：自己场上没有怪兽存在的场合，把手卡的这张卡给对方观看，以自己墓地1只「刚鬼」连接怪兽为对象才能发动。这张卡从手卡特殊召唤。那之后，作为对象的怪兽特殊召唤。这个效果特殊召唤的连接怪兽攻击力下降500。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(93581434,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,93581434)
	e1:SetCondition(c93581434.spcon)
	e1:SetCost(c93581434.spcost)
	e1:SetTarget(c93581434.sptg)
	e1:SetOperation(c93581434.spop)
	c:RegisterEffect(e1)
	-- ②：只要自己场上有「刚鬼」连接怪兽存在，这张卡不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetCondition(c93581434.indcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件判定函数
function c93581434.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在怪兽
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 效果①的发动代价判定函数（展示手卡的这张卡）
function c93581434.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 用于筛选自己墓地「刚鬼」连接怪兽的过滤函数
function c93581434.spfilter(c,e,tp)
	return c:IsSetCard(0xfc) and c:IsType(TYPE_LINK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动判定与对象选择函数
function c93581434.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c93581434.spfilter(chkc,e,tp) end
	-- 在发动判定时，检查自己场上是否有2个以上的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 在发动判定时，检查自己墓地是否存在符合条件的「刚鬼」连接怪兽
		and Duel.IsExistingTarget(c93581434.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置选择卡片时的提示信息为特殊召唤
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只「刚鬼」连接怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c93581434.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	g:AddCard(c)
	-- 设置特殊召唤2只怪兽的效果处理信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,0,0)
end
-- 效果①的效果处理函数
function c93581434.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将手卡的这张卡特殊召唤，若成功则继续处理
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取作为效果对象的墓地怪兽
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			-- 中断当前效果处理，使后续的特殊召唤不与前者视为同时进行
			Duel.BreakEffect()
			-- 将作为对象的怪兽特殊召唤
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			-- 这个效果特殊召唤的连接怪兽攻击力下降500。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(-500)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 完成特殊召唤的最终处理
			Duel.SpecialSummonComplete()
		end
	end
end
-- 用于筛选自己场上表侧表示「刚鬼」连接怪兽的过滤函数
function c93581434.indfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_LINK) and c:IsSetCard(0xfc)
end
-- 效果②的适用条件判定函数
function c93581434.indcon(e)
	-- 检查自己场上是否存在表侧表示的「刚鬼」连接怪兽
	return Duel.IsExistingMatchingCard(c93581434.indfilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end

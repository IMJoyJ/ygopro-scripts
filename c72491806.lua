--U.A.ファンタジスタ
-- 效果：
-- 「超级运动员 九号半球员」的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：这张卡可以让「超级运动员 九号半球员」以外的自己场上1只「超级运动员」怪兽回到手卡，从手卡特殊召唤。
-- ②：以这张卡以外的自己场上1只「超级运动员」怪兽为对象才能发动。那只表侧表示怪兽回到手卡，那之后把和那只怪兽卡名不同的1只「超级运动员」怪兽从手卡特殊召唤。这个效果在对方回合也能发动。
function c72491806.initial_effect(c)
	-- ①：这张卡可以让「超级运动员 九号半球员」以外的自己场上1只「超级运动员」怪兽回到手卡，从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,72491806+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c72491806.spcon)
	e1:SetTarget(c72491806.sptg)
	e1:SetOperation(c72491806.spop)
	c:RegisterEffect(e1)
	-- ②：以这张卡以外的自己场上1只「超级运动员」怪兽为对象才能发动。那只表侧表示怪兽回到手卡，那之后把和那只怪兽卡名不同的1只「超级运动员」怪兽从手卡特殊召唤。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(72491806,0))  --"返回手卡"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,72491807)
	e2:SetTarget(c72491806.tstg)
	e2:SetOperation(c72491806.tsop)
	c:RegisterEffect(e2)
end
-- 特殊召唤规则的过滤条件：自己场上表侧表示的「超级运动员 九号半球员」以外的「超级运动员」怪兽，且能回到手卡，并且能空出怪兽区域
function c72491806.spfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xb2) and not c:IsCode(72491806) and c:IsAbleToHandAsCost()
		-- 检查该怪兽回到手卡后，自己场上是否有可用的怪兽区域
		and Duel.GetMZoneCount(tp,c)>0
end
-- 特殊召唤规则的出现条件
function c72491806.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否存在满足特殊召唤规则过滤条件的怪兽
	return Duel.IsExistingMatchingCard(c72491806.spfilter,tp,LOCATION_MZONE,0,1,nil,tp)
end
-- 特殊召唤规则的选择目标阶段
function c72491806.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己场上所有满足特殊召唤规则过滤条件的怪兽组
	local g=Duel.GetMatchingGroup(c72491806.spfilter,tp,LOCATION_MZONE,0,nil,tp)
	-- 给玩家发送“请选择要返回手牌的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则的执行操作阶段
function c72491806.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选择的怪兽因特殊召唤原因返回持有者手卡
	Duel.SendtoHand(g,nil,REASON_SPSUMMON)
end
-- 效果②中作为对象的怪兽的过滤条件：自己场上表侧表示的「超级运动员」怪兽，能回到手卡，且手卡有与其卡名不同的「超级运动员」怪兽可以特殊召唤
function c72491806.thfilter(c,e,tp,ft)
	return c:IsFaceup() and c:IsSetCard(0xb2) and c:IsAbleToHand() and (ft>0 or c:GetSequence()<5)
		-- 检查手卡中是否存在与该怪兽卡名不同的、可以特殊召唤的「超级运动员」怪兽
		and Duel.IsExistingMatchingCard(c72491806.spfilter2,tp,LOCATION_HAND,0,1,nil,e,tp,c:GetCode())
end
-- 效果②中从手卡特殊召唤的怪兽的过滤条件：与返回手卡的怪兽卡名不同的「超级运动员」怪兽，且可以特殊召唤
function c72491806.spfilter2(c,e,tp,code)
	return c:IsSetCard(0xb2) and not c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备（检查可行性、选择对象并设置操作信息）
function c72491806.tstg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取自己场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c72491806.thfilter(chkc,e,tp,ft) end
	-- 检查发动可行性：怪兽区域数量大于-1（考虑怪兽离场空出格子），且存在可以作为对象的怪兽
	if chk==0 then return ft>-1 and Duel.IsExistingTarget(c72491806.thfilter,tp,LOCATION_MZONE,0,1,e:GetHandler(),e,tp,ft) end
	-- 给玩家发送“请选择要返回手牌的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择自己场上1只「超级运动员」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c72491806.thfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler(),e,tp,ft)
	-- 设置效果处理信息：将选择的对象怪兽送回手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 设置效果处理信息：从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果②的效果处理
function c72491806.tsop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍适用效果且表侧表示，并将其因效果原因返回手卡
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 then
		-- 检查自己场上是否有可用的怪兽区域，若无则结束效果处理
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 给玩家发送“请选择要特殊召唤的卡”的提示信息
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手卡选择1只与返回手卡的怪兽卡名不同的「超级运动员」怪兽
		local sg=Duel.SelectMatchingCard(tp,c72491806.spfilter2,tp,LOCATION_HAND,0,1,1,nil,e,tp,tc:GetCode())
		if sg:GetCount()>0 then
			-- 中断当前效果，使后续的特殊召唤处理与返回手卡不视为同时进行
			Duel.BreakEffect()
			-- 将选择的怪兽以表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end

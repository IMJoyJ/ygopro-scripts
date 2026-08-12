--アルティメット・インセクト LV5
-- 效果：
-- 「究极昆虫 LV3」的效果特殊召唤的场合，只要这张卡在场上存在，对方场上的全部怪兽攻击力下降500。自己回合的准备阶段时，可以把表侧表示的这张卡送去墓地，从手卡·卡组特殊召唤1只「究极昆虫 LV7」上场。（召唤·特殊召唤·反转的回合不能使用此效果）
function c34830502.initial_effect(c)
	-- 「究极昆虫 LV3」的效果特殊召唤的场合，只要这张卡在场上存在，对方场上的全部怪兽攻击力下降500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetCondition(c34830502.con)
	e1:SetValue(-500)
	c:RegisterEffect(e1)
	-- 自己回合的准备阶段时，可以把表侧表示的这张卡送去墓地，从手卡·卡组特殊召唤1只「究极昆虫 LV7」上场。（召唤·特殊召唤·反转的回合不能使用此效果）
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(34830502,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetCondition(c34830502.spcon)
	e2:SetCost(c34830502.spcost)
	e2:SetTarget(c34830502.sptg)
	e2:SetOperation(c34830502.spop)
	c:RegisterEffect(e2)
	-- 「究极昆虫 LV3」的效果特殊召唤的场合，只要这张卡在场上存在，对方场上的全部怪兽攻击力下降500。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetOperation(c34830502.regop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
	local e5=e3:Clone()
	e5:SetCode(EVENT_FLIP)
	c:RegisterEffect(e5)
end
c34830502.lvup={34088136,19877898}
c34830502.lvdn={49441499,34088136}
-- 判断此卡是否为「究极昆虫 LV3」的效果特殊召唤
function c34830502.con(e)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_LV
end
-- 为该卡注册一个标记，用于记录其是否已使用过特殊召唤效果
function c34830502.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(34830503,RESET_EVENT+0x1ec0000+RESET_PHASE+PHASE_END,0,1)
end
-- 判断是否为当前玩家回合且该卡未使用过特殊召唤效果
function c34830502.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为当前玩家回合且该卡未使用过特殊召唤效果
	return tp==Duel.GetTurnPlayer() and e:GetHandler():GetFlagEffect(34830503)==0
end
-- 支付将此卡送入墓地作为代价
function c34830502.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将此卡送入墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 筛选可以特殊召唤的「究极昆虫 LV7」
function c34830502.spfilter(c,e,tp)
	return c:IsCode(19877898) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
-- 判断是否满足特殊召唤条件
function c34830502.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 判断手牌或卡组中是否存在可特殊召唤的「究极昆虫 LV7」
		and Duel.IsExistingMatchingCard(c34830502.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 执行特殊召唤操作
function c34830502.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有足够的召唤位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择一张可特殊召唤的「究极昆虫 LV7」
	local g=Duel.SelectMatchingCard(tp,c34830502.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的卡以LV召唤方式特殊召唤上场
		Duel.SpecialSummon(tc,SUMMON_VALUE_LV,tp,tp,true,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end

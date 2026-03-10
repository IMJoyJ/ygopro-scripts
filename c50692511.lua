--RR－コール
-- 效果：
-- 「急袭猛禽-呼唤」在1回合只能发动1张，这张卡发动的回合，自己不是「急袭猛禽」怪兽不能特殊召唤。
-- ①：以自己场上1只「急袭猛禽」怪兽为对象才能发动。那1只同名怪兽从手卡·卡组守备表示特殊召唤。
function c50692511.initial_effect(c)
	-- 「急袭猛禽-呼唤」在1回合只能发动1张，这张卡发动的回合，自己不是「急袭猛禽」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,50692511+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c50692511.cost)
	e1:SetTarget(c50692511.target)
	e1:SetOperation(c50692511.activate)
	c:RegisterEffect(e1)
	-- 设置一个计数器，用于记录玩家在该回合中特殊召唤的「急袭猛禽」怪兽数量
	Duel.AddCustomActivityCounter(50692511,ACTIVITY_SPSUMMON,c50692511.counterfilter)
end
-- 过滤函数，判断卡片是否为「急袭猛禽」卡组
function c50692511.counterfilter(c)
	return c:IsSetCard(0xba)
end
-- 发动时检查该回合是否已进行过特殊召唤，若未进行则设置不能特殊召唤非「急袭猛禽」怪兽的效果
function c50692511.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查该玩家在本回合是否已经进行过特殊召唤操作
	if chk==0 then return Duel.GetCustomActivityCount(50692511,tp,ACTIVITY_SPSUMMON)==0 end
	-- 以自己场上1只「急袭猛禽」怪兽为对象才能发动。那1只同名怪兽从手卡·卡组守备表示特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetLabelObject(e)
	e1:SetTarget(c50692511.splimit)
	-- 将效果注册给指定玩家，使该效果生效
	Duel.RegisterEffect(e1,tp)
end
-- 限制非「急袭猛禽」怪兽不能特殊召唤
function c50692511.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0xba)
end
-- 过滤函数，选择场上表侧表示的「急袭猛禽」怪兽，并确保其同名卡存在于手牌或卡组中
function c50692511.filter1(c,e,tp)
	return c:IsFaceup() and c:IsSetCard(0xba)
		-- 检查是否存在满足条件的同名怪兽（在手牌或卡组）
		and Duel.IsExistingMatchingCard(c50692511.filter2,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp,c:GetCode())
end
-- 过滤函数，判断某张卡是否为指定代码的怪兽且可特殊召唤
function c50692511.filter2(c,e,tp,code)
	return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 设置效果目标选择条件，确保只能选择自己场上的「急袭猛禽」怪兽
function c50692511.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsCode(e:GetLabel()) end
	-- 检查场上是否有足够的空间进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查是否存在满足条件的「急袭猛禽」怪兽作为效果对象
		and Duel.IsExistingTarget(c50692511.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择符合条件的「急袭猛禽」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c50692511.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	e:SetLabel(g:GetFirst():GetCode())
	-- 设置操作信息，表明本次连锁将处理特殊召唤的效果
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_DECK+LOCATION_HAND)
end
-- 处理效果发动后的操作，从手牌或卡组中选择同名怪兽进行特殊召唤
function c50692511.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否有足够的召唤空间
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取当前连锁中的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local code=tc:GetCode()
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手牌或卡组中选择符合条件的同名怪兽
		local g=Duel.SelectMatchingCard(tp,c50692511.filter2,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp,code)
		if g:GetCount()>0 then
			-- 将选中的怪兽以守备表示特殊召唤到场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	end
end

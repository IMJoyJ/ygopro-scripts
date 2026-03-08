--ギミック・パペット－キラーナイト
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次，这些效果发动的回合，自己不是「机关傀儡」怪兽不能从额外卡组特殊召唤。
-- ①：这张卡在手卡存在的场合，以自己墓地1只「机关傀儡」怪兽或者对方墓地1只怪兽为对象才能发动。那只怪兽在持有者场上效果无效守备表示特殊召唤。那之后，这张卡特殊召唤。
-- ②：这张卡从手卡以外送去墓地的场合才能发动。这张卡加入手卡。
local s,id,o=GetID()
-- 初始化效果函数，注册两个效果：①起动效果和②诱发效果
function s.initial_effect(c)
	-- ①：这张卡在手卡存在的场合，以自己墓地1只「机关傀儡」怪兽或者对方墓地1只怪兽为对象才能发动。那只怪兽在持有者场上效果无效守备表示特殊召唤。那之后，这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡从手卡以外送去墓地的场合才能发动。这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.thcon)
	e2:SetCost(s.cost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- 设置一个计数器，用于限制每回合特殊召唤次数
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
-- 计数器过滤函数，判断是否为额外卡组召唤且非机关傀儡怪兽
function s.counterfilter(c)
	return not c:IsSummonLocation(LOCATION_EXTRA) or c:IsSetCard(0x1083)
end
-- 费用函数，检查是否为本回合第一次特殊召唤
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否为本回合第一次特殊召唤
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	-- 注册一个影响玩家的永续效果，禁止召唤非机关傀儡怪兽
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制效果的目标为非机关傀儡怪兽且在额外卡组
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x1083) and c:IsLocation(LOCATION_EXTRA)
end
-- 特殊召唤目标过滤函数，判断是否满足特殊召唤条件
function s.spfilter(c,e,tp)
	local cp=c:GetOwner()
	return (c:IsSetCard(0x1083) and c:IsControler(tp) or c:IsControler(1-tp))
		-- 判断目标为己方怪兽且满足特殊召唤条件
		and (cp==tp and Duel.GetLocationCount(tp,LOCATION_MZONE)>1 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
		-- 判断目标为对方怪兽且满足特殊召唤条件
		or cp==1-tp and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,1-tp))
end
-- 设置特殊召唤目标选择函数
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.spfilter(chkc,e,tp) end
	-- 检查是否可以特殊召唤2只怪兽
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查是否存在满足条件的目标怪兽
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) end
	-- 提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
	g:AddCard(c)
	-- 设置操作信息，准备特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤处理函数，执行特殊召唤和后续处理
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local res=false
		local cp=tc:GetOwner()
		-- 判断目标为己方怪兽并满足特殊召唤条件
		if cp==tp and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) then
			-- 执行特殊召唤步骤
			res=Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
			if res then
				-- 使目标怪兽效果无效
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
				-- 使目标怪兽效果无效
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetValue(RESET_TURN_SET)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e2)
			end
			-- 完成特殊召唤步骤
			Duel.SpecialSummonComplete()
		-- 判断目标为对方怪兽并满足特殊召唤条件
		elseif cp==1-tp and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,1-tp) then
			-- 执行特殊召唤步骤
			res=Duel.SpecialSummonStep(tc,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)
			if res then
				-- 使目标怪兽效果无效
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_DISABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
				-- 使目标怪兽效果无效
				local e2=Effect.CreateEffect(c)
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetCode(EFFECT_DISABLE_EFFECT)
				e2:SetValue(RESET_TURN_SET)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e2)
			end
			-- 完成特殊召唤步骤
			Duel.SpecialSummonComplete()
		end
		-- 检查是否可以将自身特殊召唤
		if res and c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) then
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 将自身特殊召唤
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 判断效果发动条件，确保不是从手卡送去墓地
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsPreviousLocation(LOCATION_HAND)
end
-- 设置加入手卡的目标选择函数
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置操作信息，准备加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 加入手卡处理函数，执行加入手卡和确认操作
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将卡加入手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 向对方确认该卡
		Duel.ConfirmCards(1-tp,c)
	end
end

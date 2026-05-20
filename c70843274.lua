--サイコ・プロセッサー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把场上的这张卡除外才能发动。从手卡把最多2只机械族·念动力族·电子界族怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合可以直接攻击。
-- ②：这张卡被除外的下个回合的准备阶段才能发动。除外状态的这张卡加入手卡。
local s,id,o=GetID()
-- 初始化卡片效果，注册效果①（主动除外自身特召手卡怪兽并赋予直击能力）与效果②（被除外下回合准备阶段回手）
function s.initial_effect(c)
	-- ①：把场上的这张卡除外才能发动。从手卡把最多2只机械族·念动力族·电子界族怪兽特殊召唤。这个效果特殊召唤的怪兽在这个回合可以直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡被除外的下个回合的准备阶段才能发动。除外状态的这张卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"加入手卡"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetCountLimit(1,id+o)
	e3:SetRange(LOCATION_REMOVED)
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- 效果①的代价处理：检查自身是否能被除外，并在发动时将场上的这张卡除外
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	-- 将作为发动代价的场上的这张卡表侧表示除外
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
-- 过滤条件：手卡中可以特殊召唤的机械族、念动力族或电子界族怪兽
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_MACHINE+RACE_PSYCHO+RACE_CYBERSE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动检测：检查自身离开后是否有可用的怪兽区域，且手卡中是否存在至少1只满足特召条件的怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自身作为代价离开场后，己方场上是否有可用于特殊召唤的怪兽区域
	if chk==0 then return Duel.GetMZoneCount(tp,e:GetHandler())>0
		-- 检查手卡中是否存在至少1只满足特召过滤条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，预计从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果①的效果处理：计算可特召数量，从手卡选择最多2只符合条件的怪兽特殊召唤，并赋予它们本回合直接攻击的效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方场上空余的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	if ft>2 then ft=2 end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1到ft张满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,ft,nil,e,tp)
	local tc=g:GetFirst()
	while tc do
		-- 尝试将选中的怪兽以表侧表示特殊召唤到场上（分解步骤）
		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
			-- 这个效果特殊召唤的怪兽在这个回合可以直接攻击。②：这张卡被除外的下个回合的准备阶段才能发动。除外状态的这张卡加入手卡。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DIRECT_ATTACK)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1,true)
		end
		tc=g:GetNext()
	end
	-- 完成特殊召唤的流程，使之前通过SpecialSummonStep特召的怪兽同时视作特召成功
	Duel.SpecialSummonComplete()
end
-- 效果②的发动条件：当前回合数必须是这张卡被除外时的回合数加1（即被除外的下个回合）
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合是否为该卡被除外回合的下个回合
	return Duel.GetTurnCount()==e:GetHandler():GetTurnID()+1
end
-- 效果②的发动检测：检查自身是否能加入手卡，并设置回收手卡的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置加入手卡的操作信息，预计将除外状态的这张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果②的效果处理：如果这张卡仍存在于除外区，则将其加入手卡并给对方确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡加入持有者的手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		-- 向对方玩家展示并确认加入手卡的这张卡
		Duel.ConfirmCards(1-tp,c)
	end
end

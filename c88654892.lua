--突然回帰
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把自己场上1只融合·同调怪兽解放才能发动。把持有和解放的怪兽的原本等级相同等级的1只怪兽从卡组特殊召唤。这个效果特殊召唤的怪兽在结束阶段回到手卡。
function c88654892.initial_effect(c)
	-- ①：把自己场上1只融合·同调怪兽解放才能发动。把持有和解放的怪兽的原本等级相同等级的1只怪兽从卡组特殊召唤。这个效果特殊召唤的怪兽在结束阶段回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,88654892+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c88654892.cost)
	e1:SetTarget(c88654892.target)
	e1:SetOperation(c88654892.activate)
	c:RegisterEffect(e1)
end
-- 定义发动代价：检查并选择场上1只满足条件的融合或同调怪兽解放，并记录其等级
function c88654892.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检查阶段，检查玩家场上是否存在可作为代价解放的合法怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c88654892.filter1,1,nil,e,tp) end
	-- 让玩家选择场上1只满足条件的融合或同调怪兽作为解放对象
	local rg=Duel.SelectReleaseGroup(tp,c88654892.filter1,1,1,nil,e,tp)
	e:SetLabel(rg:GetFirst():GetLevel())
	-- 将选择的怪兽解放作为发动的代价
	Duel.Release(rg,REASON_COST)
end
-- 过滤函数1：筛选场上可解放的、且卡组中存在与其原本等级相同的可特殊召唤怪兽的融合或同调怪兽
function c88654892.filter1(c,e,tp)
	local lv=c:GetLevel()
	-- 检查怪兽是否有等级、是否为融合或同调怪兽、解放后是否能空出怪兽区域，以及是否由自己控制或在场上表侧表示
	return lv>0 and (c:IsType(TYPE_FUSION) or c:IsType(TYPE_SYNCHRO)) and Duel.GetMZoneCount(tp,c)>0 and (c:IsControler(tp) or c:IsFaceup())
		-- 检查卡组中是否存在与该怪兽原本等级相同且可以特殊召唤的怪兽
		and Duel.IsExistingMatchingCard(c88654892.filter2,tp,LOCATION_DECK,0,1,nil,lv,e,tp)
end
-- 过滤函数2：筛选卡组中等级与解放怪兽相同且可以特殊召唤的怪兽
function c88654892.filter2(c,lv,e,tp)
	return c:IsType(TYPE_MONSTER) and c:IsLevel(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 定义效果的目标：检查代价是否已支付，并设置特殊召唤的操作信息
function c88654892.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked() end
	-- 设置效果处理信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 定义效果的处理：从卡组特殊召唤1只与解放怪兽等级相同的怪兽，并注册结束阶段回到手卡的效果
function c88654892.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前玩家场上是否有可用的怪兽区域，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local lv=e:GetLabel()
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择1只与解放怪兽原本等级相同的怪兽
	local tc=Duel.SelectMatchingCard(tp,c88654892.filter2,tp,LOCATION_DECK,0,1,1,nil,lv,e,tp,nil):GetFirst()
	if tc then
		-- 将选择的怪兽在自己场上表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		local fid=e:GetHandler():GetFieldID()
		tc:RegisterFlagEffect(88654892,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 这个效果特殊召唤的怪兽在结束阶段回到手卡。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCondition(c88654892.thcon)
		e1:SetOperation(c88654892.thop)
		-- 注册全局延迟效果，用于在结束阶段将特殊召唤的怪兽送回手卡
		Duel.RegisterEffect(e1,tp)
	end
end
-- 检查特殊召唤的怪兽是否仍在场上且标记未丢失，若已离开或标记失效则重置该效果
function c88654892.thcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(88654892)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 执行结束阶段将怪兽送回手卡的操作
function c88654892.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 将特殊召唤的怪兽送回持有者的手卡
	Duel.SendtoHand(e:GetLabelObject(),nil,REASON_EFFECT)
end

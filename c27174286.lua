--異次元からの帰還
-- 效果：
-- 把基本分支付一半才能发动。从游戏中除外的自己怪兽尽可能在自己场上特殊召唤。这个效果特殊召唤的怪兽在结束阶段时从游戏中除外。
function c27174286.initial_effect(c)
	-- 把基本分支付一半才能发动。从游戏中除外的自己怪兽尽可能在自己场上特殊召唤。这个效果特殊召唤的怪兽在结束阶段时从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c27174286.cost)
	e1:SetTarget(c27174286.tg)
	e1:SetOperation(c27174286.op)
	c:RegisterEffect(e1)
end
-- 过滤函数：筛选除外区中表侧表示且能被当前效果特殊召唤的自己怪兽。
function c27174286.filter(c,e,tp)
	return c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 代价函数：chk==0时仅判定能否支付代价；实际支付时执行支付一半LP。
function c27174286.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 支付当前LP的一半作为发动代价。
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
-- 发动目标的合法性判定：需要我方主要怪兽区有空位，并且除外区存在至少1只符合条件的怪兽。
function c27174286.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查我方主要怪兽区是否存在可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查除外区是否存在至少1只可特殊召唤的表侧表示自己怪兽。
		and Duel.IsExistingMatchingCard(c27174286.filter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 设置操作信息，宣告本效果将进行特殊召唤，使相关卡能够对此进行响应。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end
-- 效果处理：获取可用格子数（受青眼精灵龙限制时为1），从除外区选择最多该数量的怪兽进行特殊召唤，并给这些怪兽标记，同时注册在结束阶段将它们除外的效果。
function c27174286.op(e,tp,eg,ep,ev,re,r,rp)
	-- 获取我方场上可用的主要怪兽区数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 显示选择提示，要求玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从除外区中选出最多等于可用格子数的、可特殊召唤的表侧表示自己怪兽。
	local g=Duel.SelectMatchingCard(tp,c27174286.filter,tp,LOCATION_REMOVED,0,ft,ft,nil,e,tp)
	if g:GetCount()>0 then
		local fid=e:GetHandler():GetFieldID()
		local tc=g:GetFirst()
		while tc do
			-- 将选出的怪兽逐只以表侧表示进行特殊召唤的步骤。
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			tc:RegisterFlagEffect(27174286,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
			tc=g:GetNext()
		end
		-- 完成特殊召唤步骤，正式处理全部特殊召唤。
		Duel.SpecialSummonComplete()
		g:KeepAlive()
		-- 这个效果特殊召唤的怪兽在结束阶段时从游戏中除外。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCountLimit(1)
		e1:SetLabel(fid)
		e1:SetLabelObject(g)
		e1:SetCondition(c27174286.rmcon)
		e1:SetOperation(c27174286.rmop)
		-- 将结束阶段除外怪兽的效果注册到场上，使其在结束阶段时执行。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 筛选函数：判断怪兽是否带有本次特殊召唤时的标识fid，用于识别需要被除外的怪兽。
function c27174286.rmfilter(c,fid)
	return c:GetFlagEffectLabel(27174286)==fid
end
-- 结束阶段除外效果的发动条件：如果带有该标识的怪兽已经不存，则清理该效果；否则允许执行。
function c27174286.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(c27174286.rmfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 结束阶段除外效果的处理：选取带有标识的怪兽组并从游戏中除外。
function c27174286.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(c27174286.rmfilter,nil,e:GetLabel())
	-- 将符合条件的怪兽以表侧表示从游戏中除外。
	Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
end

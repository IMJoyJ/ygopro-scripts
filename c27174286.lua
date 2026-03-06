--異次元からの帰還
-- 效果：
-- 把基本分支付一半才能发动。从游戏中除外的自己怪兽尽可能在自己场上特殊召唤。这个效果特殊召唤的怪兽在结束阶段时从游戏中除外。
function c27174286.initial_effect(c)
	-- 效果发动时的初始化设置，包括类型、分类、触发条件、费用、目标和效果处理函数
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c27174286.cost)
	e1:SetTarget(c27174286.tg)
	e1:SetOperation(c27174286.op)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于检测除外区的怪兽是否可以被特殊召唤
function c27174286.filter(c,e,tp)
	return c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 支付一半基本分的费用处理
function c27174286.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 支付一半基本分
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
-- 设置效果发动时的目标信息，检查是否有满足条件的除外怪兽
function c27174286.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查除外区是否存在满足条件的怪兽数量
		and Duel.IsExistingMatchingCard(c27174286.filter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 设置操作信息，表示将要特殊召唤除外区的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
end
-- 效果处理函数，执行特殊召唤并设置结束阶段除外效果
function c27174286.op(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的除外怪兽进行特殊召唤
	local g=Duel.SelectMatchingCard(tp,c27174286.filter,tp,LOCATION_REMOVED,0,ft,ft,nil,e,tp)
	if g:GetCount()>0 then
		local fid=e:GetHandler():GetFieldID()
		local tc=g:GetFirst()
		while tc do
			-- 特殊召唤一张怪兽到场上
			Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
			tc:RegisterFlagEffect(27174286,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
			tc=g:GetNext()
		end
		-- 完成所有特殊召唤步骤
		Duel.SpecialSummonComplete()
		g:KeepAlive()
		-- 注册结束阶段除外效果，用于在结束阶段将特殊召唤的怪兽除外
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCountLimit(1)
		e1:SetLabel(fid)
		e1:SetLabelObject(g)
		e1:SetCondition(c27174286.rmcon)
		e1:SetOperation(c27174286.rmop)
		-- 将结束阶段除外效果注册到场上
		Duel.RegisterEffect(e1,tp)
	end
end
-- 过滤函数，用于判断怪兽是否属于本次特殊召唤的怪兽
function c27174286.rmfilter(c,fid)
	return c:GetFlagEffectLabel(27174286)==fid
end
-- 判断是否还有本次特殊召唤的怪兽存在
function c27174286.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(c27174286.rmfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 执行怪兽除外操作
function c27174286.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(c27174286.rmfilter,nil,e:GetLabel())
	-- 将怪兽从游戏中除外
	Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
end

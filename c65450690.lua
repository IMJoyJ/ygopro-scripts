--限定解除
-- 效果：
-- 支付1000基本分。从手卡特殊召唤1只仪式怪兽。这个效果特殊召唤的仪式怪兽不能攻击，结束阶段时破坏。「限定解除」在1回合只能发动1张。
function c65450690.initial_effect(c)
	-- 支付1000基本分。从手卡特殊召唤1只仪式怪兽。这个效果特殊召唤的仪式怪兽不能攻击，结束阶段时破坏。「限定解除」在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,65450690+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c65450690.cost)
	e1:SetTarget(c65450690.target)
	e1:SetOperation(c65450690.activate)
	c:RegisterEffect(e1)
end
-- 定义发动代价：检查并支付1000点基本分
function c65450690.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查玩家是否能够支付1000点基本分
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 扣除玩家1000点基本分作为发动代价
	Duel.PayLPCost(tp,1000)
end
-- 过滤函数：筛选手卡中可以特殊召唤的仪式怪兽
function c65450690.filter(c,e,tp)
	return bit.band(c:GetType(),0x81)==0x81 and c:IsCanBeSpecialSummoned(e,0,tp,false,true)
end
-- 定义效果发动时的目标选择与合法性检查
function c65450690.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查手卡中是否存在至少1只满足特殊召唤条件的仪式怪兽
		and Duel.IsExistingMatchingCard(c65450690.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息：从手卡特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_HAND)
end
-- 定义效果处理：从手卡特殊召唤仪式怪兽并施加限制与后续破坏效果
function c65450690.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，若自己场上已无可用怪兽区域，则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只满足条件的仪式怪兽
	local g=Duel.SelectMatchingCard(tp,c65450690.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的仪式怪兽以表侧表示特殊召唤（无视苏生限制）
		Duel.SpecialSummon(tc,0,tp,tp,false,true,POS_FACEUP)
		-- 这个效果特殊召唤的仪式怪兽不能攻击
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		tc:RegisterFlagEffect(65450690,RESET_EVENT+RESETS_STANDARD,0,1)
		-- 结束阶段时破坏
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetCountLimit(1)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetLabelObject(tc)
		e2:SetCondition(c65450690.descon)
		-- 设置结束阶段时的操作为破坏该怪兽
		e2:SetOperation(aux.EPDestroyOperation)
		-- 将结束阶段破坏的效果注册给玩家
		Duel.RegisterEffect(e2,tp)
	end
end
-- 定义结束阶段破坏效果的触发条件：检查目标怪兽是否仍带有此效果的标记，若无则重置该效果
function c65450690.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(65450690)~=0 then
		return true
	else
		e:Reset()
		return false
	end
end

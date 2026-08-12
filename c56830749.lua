--痛み分け
-- 效果：
-- 把自己场上1只怪兽解放发动。对方必须把1只怪兽解放。
function c56830749.initial_effect(c)
	-- 把自己场上1只怪兽解放发动。对方必须把1只怪兽解放。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c56830749.cost)
	e1:SetTarget(c56830749.target)
	e1:SetOperation(c56830749.activate)
	c:RegisterEffect(e1)
end
-- 定义发动代价（Cost）函数，用于处理解放自己场上1只怪兽的操作
function c56830749.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查自己场上是否存在至少1只可解放的怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,nil,1,nil) end
	-- 让发动玩家选择自己场上1只可解放的怪兽
	local g=Duel.SelectReleaseGroup(tp,nil,1,1,nil)
	-- 解放选中的怪兽作为发动代价
	Duel.Release(g,REASON_COST)
end
-- 定义效果的目标（Target）函数，检查对方场上是否有可解放的怪兽
function c56830749.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查对方场上是否存在至少1只可因规则解放的怪兽
	if chk==0 then return Duel.CheckReleaseGroupEx(1-tp,nil,1,REASON_RULE,false,nil) end
end
-- 定义效果处理（Operation）函数，强制对方玩家解放1只怪兽
function c56830749.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 让对方玩家选择其场上1只可因规则解放的怪兽
	local g=Duel.SelectReleaseGroupEx(1-tp,nil,1,1,REASON_RULE,false,nil)
	if g:GetCount()>0 then
		-- 为对方选中的怪兽显示被选为对象的动画效果
		Duel.HintSelection(g)
		-- 对方玩家将选中的怪兽因规则解放
		Duel.Release(g,REASON_RULE,1-tp)
	end
end

--E.M.R.
-- 效果：
-- ①：把自己场上1只机械族怪兽解放，以解放的怪兽的原本攻击力每1000最多1张的场上的卡为对象才能发动。那些卡破坏。
function c17427333.initial_effect(c)
	-- 效果原文内容：①：把自己场上1只机械族怪兽解放，以解放的怪兽的原本攻击力每1000最多1张的场上的卡为对象才能发动。那些卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c17427333.cost)
	e1:SetTarget(c17427333.target)
	e1:SetOperation(c17427333.operation)
	c:RegisterEffect(e1)
end
-- 效果作用：设置cost标签为100，表示进入cost阶段
function c17427333.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		e:SetLabel(100)
		return true
	end
end
-- 效果作用：过滤满足条件的机械族怪兽，包括控制者或表侧表示，攻击力至少1000，并且场上存在可选择的目标
function c17427333.costfilter(c,tp)
	return c:IsRace(RACE_MACHINE) and (c:IsControler(tp) or c:IsFaceup()) and c:GetTextAttack()>=1000
		-- 效果作用：检查场上是否存在满足条件的目标卡片
		and Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
end
-- 效果作用：判断是否满足发动条件，选择并解放符合条件的机械族怪兽，根据攻击力计算可破坏卡片数量，并选择目标卡片
function c17427333.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 效果作用：检查玩家场上是否存在满足costfilter条件的可解放怪兽
		return Duel.CheckReleaseGroup(tp,c17427333.costfilter,1,nil,tp)
	end
	-- 效果作用：从玩家场上选择1只满足costfilter条件的怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,c17427333.costfilter,1,1,nil,tp)
	local atk=g:GetFirst():GetTextAttack()
	-- 效果作用：以代價原因解放选择的怪兽
	Duel.Release(g,REASON_COST)
	local ct=math.floor(atk/1000)
	local exc=nil
	if not e:GetHandler():IsStatus(STATUS_EFFECT_ENABLED) then exc=e:GetHandler() end
	-- 效果作用：提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 效果作用：选择满足条件的目标卡片，数量为根据攻击力计算出的最多数量
	local g1=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,ct,exc)
	-- 效果作用：设置操作信息，记录将要破坏的卡片组和数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,g1:GetCount(),0,0)
end
-- 效果作用：处理连锁效果，获取目标卡片并进行破坏
function c17427333.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取连锁中目标卡片，并筛选出与当前效果相关的卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 效果作用：以效果原因破坏符合条件的卡片
		Duel.Destroy(g,REASON_EFFECT)
	end
end

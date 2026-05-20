--十二獣ワイルドボウ
-- 效果：
-- 4星怪兽×5
-- 「十二兽 猪弓」1回合1次也能在同名卡以外的自己场上的「十二兽」怪兽上面重叠来超量召唤。
-- ①：这张卡的攻击力·守备力上升这张卡作为超量素材中的「十二兽」怪兽的各自数值。
-- ②：这张卡可以向对方直接攻击。
-- ③：持有的超量素材数量是12以上的这张卡给与对方战斗伤害时才能发动。对方的手卡·场上的卡全部送去墓地，那之后，这张卡变成守备表示。
function c74393852.initial_effect(c)
	aux.AddXyzProcedure(c,nil,4,5,c74393852.ovfilter,aux.Stringid(74393852,0),5,c74393852.xyzop)  --"是否在「十二兽」怪兽上面重叠来超量召唤？"
	c:EnableReviveLimit()
	-- ①：这张卡的攻击力·守备力上升这张卡作为超量素材中的「十二兽」怪兽的各自数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c74393852.atkval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	e2:SetValue(c74393852.defval)
	c:RegisterEffect(e2)
	-- ③：持有的超量素材数量是12以上的这张卡给与对方战斗伤害时才能发动。对方的手卡·场上的卡全部送去墓地，那之后，这张卡变成守备表示。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(74393852,1))  --"对方卡全部送去墓地"
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DAMAGE)
	e3:SetCondition(c74393852.condition)
	e3:SetTarget(c74393852.target)
	e3:SetOperation(c74393852.operation)
	c:RegisterEffect(e3)
	-- ②：这张卡可以向对方直接攻击。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e4)
end
-- 过滤用于重叠超量召唤的怪兽：自己场上表侧表示的「十二兽」怪兽且非同名卡
function c74393852.ovfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xf1) and not c:IsCode(74393852)
end
-- 重叠超量召唤时的操作：检查并注册每回合1次重叠召唤的玩家标识
function c74393852.xyzop(e,tp,chk)
	-- 检查当前回合玩家是否已使用过「十二兽」怪兽重叠超量召唤「十二兽 猪弓」的效果
	if chk==0 then return Duel.GetFlagEffect(tp,74393852)==0 end
	-- 给玩家注册全局标识，限制本回合不能再使用此方法进行超量召唤（誓约效果，持续到回合结束）
	Duel.RegisterFlagEffect(tp,74393852,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- 过滤作为超量素材的「十二兽」怪兽且攻击力大于等于0
function c74393852.atkfilter(c)
	return c:IsSetCard(0xf1) and c:GetAttack()>=0
end
-- 计算作为超量素材的「十二兽」怪兽的攻击力合计值
function c74393852.atkval(e,c)
	local g=e:GetHandler():GetOverlayGroup():Filter(c74393852.atkfilter,nil)
	return g:GetSum(Card.GetAttack)
end
-- 过滤作为超量素材的「十二兽」怪兽且守备力大于等于0
function c74393852.deffilter(c)
	return c:IsSetCard(0xf1) and c:GetDefense()>=0
end
-- 计算作为超量素材的「十二兽」怪兽的守备力合计值
function c74393852.defval(e,c)
	local g=e:GetHandler():GetOverlayGroup():Filter(c74393852.deffilter,nil)
	return g:GetSum(Card.GetDefense)
end
-- 触发条件：给与对方玩家战斗伤害，且这张卡的超量素材数量在12个以上
function c74393852.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and e:GetHandler():GetOverlayCount()>=12
end
-- 效果发动目标：检查对方手卡和场上是否有卡，并设置送去墓地的操作信息
function c74393852.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取对方的手卡和场上的所有卡片
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND+LOCATION_ONFIELD)
	if chk==0 then return g:GetCount()>0 end
	-- 向对方玩家提示发动的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置连锁的操作信息：将对方手卡和场上的所有卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
end
-- 效果处理：将对方手卡·场上的卡全部送去墓地，若成功送去墓地，则将这张卡变成守备表示
function c74393852.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前对方手卡和场上的所有卡片
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND+LOCATION_ONFIELD)
	-- 因效果将获取到的卡片全部送去墓地
	Duel.SendtoGrave(g,REASON_EFFECT)
	-- 获取实际被送去墓地的卡片组
	local og=Duel.GetOperatedGroup()
	if og:GetCount()>0 then
		-- 中断当前效果处理，使后续的表示形式变更不与送去墓地视为同时处理
		Duel.BreakEffect()
		local c=e:GetHandler()
		if c:IsRelateToEffect(e) and c:IsFaceup() then
			-- 将这张卡转为表侧守备表示
			Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
		end
	end
end

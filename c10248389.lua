--サイバー・ブレイダー
-- 效果：
-- 「电子化明星」＋「利刃滑冰者」
-- 这张卡的融合召唤不用上记的卡不能进行。
-- ①：对方场上的怪兽数量让这张卡得到以下效果。
-- ●1只：这张卡不会被战斗破坏。
-- ●2只：这张卡的攻击力变成2倍。
-- ●3只：对方发动的魔法·陷阱·怪兽的效果无效化。
function c10248389.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加融合召唤手续，必须使用'电子化明星'（卡号97023549）和'利刃滑冰者'（卡号11460577）作为融合素材。
	aux.AddFusionProcCode2(c,97023549,11460577,false,false)
	-- ●1只：这张卡不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetCondition(c10248389.indcon)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ●2只：这张卡的攻击力变成2倍。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_SET_ATTACK_FINAL)
	e2:SetCondition(c10248389.atkcon)
	e2:SetValue(c10248389.atkval)
	c:RegisterEffect(e2)
	-- ●3只：对方发动的魔法·陷阱·怪兽的效果无效化。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_CHAIN_SOLVING)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c10248389.discon)
	e4:SetOperation(c10248389.disop)
	c:RegisterEffect(e4)
end
-- 定义条件函数，检查对方场上怪兽数量是否为1。
function c10248389.indcon(e)
	-- 获取对方场上怪兽数量并判断是否等于1。
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),0,LOCATION_MZONE)==1
end
-- 定义条件函数，检查对方场上怪兽数量是否为2。
function c10248389.atkcon(e)
	-- 获取对方场上怪兽数量并判断是否等于2。
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),0,LOCATION_MZONE)==2
end
-- 定义条件函数，检查对方场上怪兽数量是否为3。
function c10248389.discon(e)
	-- 获取对方场上怪兽数量并判断是否等于3。
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),0,LOCATION_MZONE)==3
end
-- 定义值函数，计算并返回当前攻击力的两倍。
function c10248389.atkval(e,c)
	return c:GetAttack()*2
end
-- 定义操作函数，处理无效化效果。
function c10248389.disop(e,tp,eg,ep,ev,re,r,rp)
	if rp==1-tp then
		-- 使当前连锁的效果无效。
		Duel.NegateEffect(ev)
	end
end

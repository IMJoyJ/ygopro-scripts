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
	-- 注册融合素材为「电子化明星」与「利刃滑冰者」的融合召唤手续
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
-- 战斗不破效果的发动条件：对方场上的怪兽数量为1只
function c10248389.indcon(e)
	-- 返回对方怪兽区的怪兽数量是否为1只
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),0,LOCATION_MZONE)==1
end
-- 攻击力变成2倍效果的发动条件：对方场上的怪兽数量为2只
function c10248389.atkcon(e)
	-- 返回对方怪兽区的怪兽数量是否为2只
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),0,LOCATION_MZONE)==2
end
-- 效果无效化效果的发动条件：对方场上的怪兽数量为3只
function c10248389.discon(e)
	-- 返回对方怪兽区的怪兽数量是否为3只
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),0,LOCATION_MZONE)==3
end
-- 攻击力数值计算函数：返回此卡当前攻击力2倍的值
function c10248389.atkval(e,c)
	return c:GetAttack()*2
end
-- 效果无效化效果的执行操作：若是对方玩家发动的效果，将其无效化
function c10248389.disop(e,tp,eg,ep,ev,re,r,rp)
	if rp==1-tp then
		-- 将该连锁的效果无效化
		Duel.NegateEffect(ev)
	end
end

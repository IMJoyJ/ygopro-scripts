--E・HERO エアー・ネオス
-- 效果：
-- 「元素英雄 新宇侠」＋「新空间侠·天空蜂鸟」
-- 把自己场上存在的上记的卡回到卡组的场合才能从额外卡组特殊召唤（不需要「融合」）。自己基本分比对方基本分少的场合，这张卡的攻击力上升那个数值。结束阶段时这张卡回到额外卡组。
function c11502550.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加融合召唤手续，使用卡号89943723和54959865的两只怪兽作为融合素材
	aux.AddFusionProcCode2(c,89943723,54959865,false,false)
	-- 添加接触融合的特殊召唤程序，要求将场上符合条件的素材怪兽送回卡组作为召唤条件
	aux.AddContactFusionProcedure(c,Card.IsAbleToDeckOrExtraAsCost,LOCATION_ONFIELD,0,aux.ContactFusionSendToDeck(c))
	-- 特殊召唤条件：这张卡不能从额外卡组特殊召唤，必须满足接触融合的条件
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c11502550.splimit)
	c:RegisterEffect(e1)
	-- 为卡片注册结束阶段返回卡组的效果
	aux.EnableNeosReturn(c,c11502550.retop)
	-- 攻击力变化效果：当自己的基本分小于对方基本分时，攻击力上升差值数值
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetCode(EFFECT_UPDATE_ATTACK)
	e5:SetRange(LOCATION_MZONE)
	e5:SetValue(c11502550.atkval)
	c:RegisterEffect(e5)
end
c11502550.material_setcode=0x8
-- 判断特殊召唤是否满足条件，确保该卡不在额外卡组
function c11502550.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
end
-- 结束阶段返回卡组效果的处理函数
function c11502550.retop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) or e:GetHandler():IsFacedown() then return end
	-- 将该卡以洗牌方式送回卡组
	Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
-- 计算攻击力变化值的函数
function c11502550.atkval(e,c)
	-- 获取当前控制者的当前基本分
	local lps=Duel.GetLP(c:GetControler())
	-- 获取对方玩家的基本分
	local lpo=Duel.GetLP(1-c:GetControler())
	if lps>=lpo then return 0
	else return lpo-lps end
end

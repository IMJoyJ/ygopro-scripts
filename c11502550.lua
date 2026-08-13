--E・HERO エアー・ネオス
-- 效果：
-- 「元素英雄 新宇侠」＋「新空间侠·天空蜂鸟」
-- 把自己场上存在的上记的卡回到卡组的场合才能从额外卡组特殊召唤（不需要「融合」）。自己基本分比对方基本分少的场合，这张卡的攻击力上升那个数值。结束阶段时这张卡回到额外卡组。
function c11502550.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加普通融合召唤手续：以卡号89943723的「元素英雄 新宇侠」和卡号54959865的「新空间侠·天空蜂鸟」为融合素材进行融合召唤（不涉及接触融合）。
	aux.AddFusionProcCode2(c,89943723,54959865,false,false)
	-- 为这张卡注册接触融合（不需要「融合」）的特殊召唤手续：从己方场上选择能作为代价回到卡组/额外卡组的素材怪兽，通过将素材返回持有者卡组作为代价，从额外卡组特殊召唤这张卡。
	aux.AddContactFusionProcedure(c,Card.IsAbleToDeckOrExtraAsCost,LOCATION_ONFIELD,0,aux.ContactFusionSendToDeck(c))
	-- 对应效果原文“把自己场上存在的上记的卡回到卡组的场合才能从额外卡组特殊召唤（不需要「融合」）”中的“才能从额外卡组特殊召唤”部分：设置特殊召唤条件，使这张卡在额外卡组时不能被其他效果直接特殊召唤，只能通过正规融合手续出场。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c11502550.splimit)
	c:RegisterEffect(e1)
	-- 注册「新空间」融合怪兽通用的结束阶段回到额外卡组的效果，并指定回卡组时的操作函数为retop，对应效果原文“结束阶段时这张卡回到额外卡组。”。
	aux.EnableNeosReturn(c,c11502550.retop)
	-- 对应效果原文“自己基本分比对方基本分少的场合，这张卡的攻击力上升那个数值。”：设置永续效果，根据我方与对方基本分差值提升这张卡的攻击力。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetCode(EFFECT_UPDATE_ATTACK)
	e5:SetRange(LOCATION_MZONE)
	e5:SetValue(c11502550.atkval)
	c:RegisterEffect(e5)
end
c11502550.material_setcode=0x8
-- 特殊召唤条件判定函数：当这张卡当前不在额外卡组时才允许被特殊召唤；若在额外卡组则禁止，从而限制其只能通过正规融合手续从额外卡组出场。
function c11502550.splimit(e,se,sp,st)
	return not e:GetHandler():IsLocation(LOCATION_EXTRA)
end
-- 结束阶段回到额外卡组的操作函数：若这张卡仍与效果关联且不是里侧表示，则将其洗牌返回持有者的额外卡组，处理原因为效果。
function c11502550.retop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) or e:GetHandler():IsFacedown() then return end
	-- 将这张卡洗牌返回持有者的额外卡组（是额外卡组的场合送入额外卡组），处理原因为效果。
	Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
end
-- 攻击力上升数值的计算函数：获取这张卡控制者与其对方的LP，当己方LP低于对方LP时返回对方LP与己方LP的差值，否则返回0。
function c11502550.atkval(e,c)
	-- 获取这张卡当前控制者的基本分，存入变量lps。
	local lps=Duel.GetLP(c:GetControler())
	-- 获取这张卡当前控制者的对方玩家的基本分，存入变量lpo（通过1减去控制者编号得到对方玩家编号）。
	local lpo=Duel.GetLP(1-c:GetControler())
	if lps>=lpo then return 0
	else return lpo-lps end
end

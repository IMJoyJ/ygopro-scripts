--忍者マスター SAIZO
-- 效果：
-- 「忍者」怪兽2只
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡所连接区有怪兽存在，这张卡不会成为攻击对象，也不会成为对方的效果的对象。
-- ②：自己主要阶段才能发动。从卡组选1张「忍法」魔法·陷阱卡在自己场上盖放。
function c37354507.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续，使用至少2个且至多2个属于「忍者」的怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0x2b),2,2)
	-- ②：自己主要阶段才能发动。从卡组选1张「忍法」魔法·陷阱卡在自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37354507,0))
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,37354507)
	e1:SetTarget(c37354507.settg)
	e1:SetOperation(c37354507.setop)
	c:RegisterEffect(e1)
	-- ①：只要这张卡所连接区有怪兽存在，这张卡不会成为攻击对象，也不会成为对方的效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c37354507.tgcon)
	-- 设置效果值为不会成为攻击对象的过滤函数
	e2:SetValue(aux.imval1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	-- 设置效果值为不会成为对方效果的对象的过滤函数
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
end
-- 定义过滤函数，用于筛选可以盖放的「忍法」魔法·陷阱卡
function c37354507.setfilter(c)
	return c:IsSetCard(0x61) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- 设置效果的发动条件，检查是否满足盖放「忍法」魔法·陷阱卡的条件
function c37354507.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的「忍法」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c37354507.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 设置效果的发动处理，选择并盖放一张「忍法」魔法·陷阱卡
function c37354507.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从卡组中选择一张满足条件的「忍法」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c37354507.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡在自己场上盖放
		Duel.SSet(tp,g)
	end
end
-- 判断连接区是否有怪兽存在，用于效果触发条件
function c37354507.tgcon(e)
	return e:GetHandler():GetLinkedGroupCount()>0
end

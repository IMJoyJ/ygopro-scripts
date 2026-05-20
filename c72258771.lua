--コアキメイル・ヴァラファール
-- 效果：
-- 这张卡的控制者在每次自己的结束阶段从手卡把1张「核成兽的钢核」送去墓地。或者不送去墓地让这张卡破坏。这张卡可以把1只名字带有「核成」的怪兽解放作上级召唤。这张卡攻击守备表示怪兽时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。这张卡不会被陷阱卡的效果破坏。
function c72258771.initial_effect(c)
	-- 在卡片关联密码列表中添加「核成兽的钢核」的卡片密码
	aux.AddCodeList(c,36623431)
	-- 这张卡的控制者在每次自己的结束阶段从手卡把1张「核成兽的钢核」送去墓地。或者不送去墓地让这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c72258771.mtcon)
	e1:SetOperation(c72258771.mtop)
	c:RegisterEffect(e1)
	-- 这张卡可以把1只名字带有「核成」的怪兽解放作上级召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(72258771,2))  --"把1只名字带有「核成」的怪兽解放上级召唤"
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SUMMON_PROC)
	e2:SetCondition(c72258771.otcon)
	e2:SetOperation(c72258771.otop)
	e2:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e2)
	-- 这张卡攻击守备表示怪兽时，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e3)
	-- 这张卡不会被陷阱卡的效果破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(c72258771.efilter)
	c:RegisterEffect(e4)
end
-- 定义维持代价效果的发动条件函数
function c72258771.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 过滤手牌中可以作为代价送去墓地的「核成兽的钢核」
function c72258771.cfilter1(c)
	return c:IsCode(36623431) and c:IsAbleToGraveAsCost()
end
-- 定义维持代价效果的具体处理函数
function c72258771.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 选中这张卡并显示选择动画
	Duel.HintSelection(Group.FromCards(c))
	-- 获取自己手牌中满足条件的「核成兽的钢核」卡片组
	local g1=Duel.GetMatchingGroup(c72258771.cfilter1,tp,LOCATION_HAND,0,nil)
	local select=1
	if g1:GetCount()>0 then
		-- 让玩家选择是送去墓地还是破坏这张卡
		select=Duel.SelectOption(tp,aux.Stringid(72258771,0),aux.Stringid(72258771,1))  --"选择一张「核成兽的钢核」送去墓地/破坏「核成魔神 华拉法」"
	else
		-- 手牌没有「核成兽的钢核」时，玩家只能选择破坏这张卡
		select=Duel.SelectOption(tp,aux.Stringid(72258771,1))+1  --"破坏「核成魔神 华拉法」"
	end
	if select==0 then
		-- 提示玩家选择要送去墓地的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local g=g1:Select(tp,1,1,nil)
		-- 将选中的「核成兽的钢核」作为代价送去墓地
		Duel.SendtoGrave(g,REASON_COST)
	else
		-- 将这张卡作为代价破坏
		Duel.Destroy(c,REASON_COST)
	end
end
-- 过滤场上可以作为上级召唤祭品的名字带有「核成」的怪兽
function c72258771.otfilter(c,tp)
	return c:IsSetCard(0x1d) and (c:IsControler(tp) or c:IsFaceup())
end
-- 定义替代上级召唤的条件函数
function c72258771.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取双方场上可以作为祭品的名字带有「核成」的怪兽
	local mg=Duel.GetMatchingGroup(c72258771.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 判断这张卡是否为7星以上，且场上是否存在至少1只可解放的「核成」怪兽作为祭品
	return c:IsLevelAbove(7) and minc<=1 and Duel.CheckTribute(c,1,1,mg)
end
-- 定义替代上级召唤的操作函数
function c72258771.otop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 获取双方场上可以作为祭品的名字带有「核成」的怪兽
	local mg=Duel.GetMatchingGroup(c72258771.otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
	-- 让玩家选择1只「核成」怪兽作为祭品
	local sg=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(sg)
	-- 解放选中的怪兽用于上级召唤
	Duel.Release(sg,REASON_SUMMON+REASON_MATERIAL)
end
-- 过滤效果类型：判断是否为陷阱卡的效果
function c72258771.efilter(e,re,rp)
	return re:IsActiveType(TYPE_TRAP)
end

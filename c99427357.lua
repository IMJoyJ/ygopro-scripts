--サイバー・エンジェル－那沙帝弥－
-- 效果：
-- 「机械天使的仪式」降临。
-- ①：1回合1次，以自己场上1只表侧表示怪兽为对象才能发动。自己基本分回复那只怪兽的攻击力一半的数值。
-- ②：自己的仪式怪兽被选择作为攻击对象时才能发动。那次攻击无效。
-- ③：这张卡在墓地存在的场合，从自己墓地把这张卡以外的1只「电子化天使」怪兽除外，以对方场上1只怪兽为对象才能发动。这张卡从墓地特殊召唤，得到作为对象的怪兽的控制权。
function c99427357.initial_effect(c)
	-- 记录该卡记载了「机械天使的仪式」的卡名
	aux.AddCodeList(c,39996157)
	c:EnableReviveLimit()
	-- ①：1回合1次，以自己场上1只表侧表示怪兽为对象才能发动。自己基本分回复那只怪兽的攻击力一半的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(99427357,0))
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c99427357.rectg)
	e1:SetOperation(c99427357.recop)
	c:RegisterEffect(e1)
	-- ②：自己的仪式怪兽被选择作为攻击对象时才能发动。那次攻击无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(99427357,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BE_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c99427357.negcon)
	e2:SetOperation(c99427357.negop)
	c:RegisterEffect(e2)
	-- ③：这张卡在墓地存在的场合，从自己墓地把这张卡以外的1只「电子化天使」怪兽除外，以对方场上1只怪兽为对象才能发动。这张卡从墓地特殊召唤，得到作为对象的怪兽的控制权。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(99427357,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_CONTROL)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCost(c99427357.cost)
	e3:SetTarget(c99427357.target)
	e3:SetOperation(c99427357.operation)
	c:RegisterEffect(e3)
end
-- 过滤函数：用于筛选自己场上表侧表示且攻击力大于0的怪兽
function c99427357.recfilter(c)
	return c:IsFaceup() and c:GetAttack()>0
end
-- 效果①的发动判定与效果处理目标设置
function c99427357.rectg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c99427357.recfilter(chkc) end
	-- chk==0时判定自己场上是否存在符合回复效果的对象怪兽
	if chk==0 then return Duel.IsExistingTarget(c99427357.recfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择作为效果对象的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 玩家选择自己场上1只表侧表示且攻击力大于0的怪兽作为对象
	local g=Duel.SelectTarget(tp,c99427357.recfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果处理的分类为回复生命值，并预估回复数值为目标怪兽攻击力的一半
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,math.ceil(g:GetFirst():GetAttack()/2))
end
-- 效果①的效果处理函数：自己基本分回复作为对象的怪兽的攻击力一半的数值
function c99427357.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果指定的唯一对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:GetAttack()>0 then
		-- 玩家回复该目标怪兽的攻击力一半的生命值
		Duel.Recover(tp,math.ceil(tc:GetAttack()/2),REASON_EFFECT)
	end
end
-- 效果②的发动条件：自己的表侧表示仪式怪兽被选择作为攻击对象
function c99427357.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前被攻击的目标怪兽
	local d=Duel.GetAttackTarget()
	return d and d:IsControler(tp) and d:IsFaceup() and d:IsType(TYPE_RITUAL)
end
-- 效果②的效果处理函数：使那次攻击无效
function c99427357.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 无效当前的攻击
	Duel.NegateAttack()
end
-- 过滤函数：用于筛选墓地中「电子化天使」怪兽且能作为Cost被除外的卡
function c99427357.cfilter(c)
	return c:IsSetCard(0x2093) and c:IsAbleToRemoveAsCost() and c:IsType(TYPE_MONSTER)
end
-- 效果③的发动代价：从自己墓地把这张卡以外的1只「电子化天使」怪兽除外
function c99427357.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- chk==0时判定自己墓地是否存在除了自身以外的「电子化天使」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c99427357.cfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 提示玩家选择要除外的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择自己墓地中除了自身以外的1只「电子化天使」怪兽
	local g=Duel.SelectMatchingCard(tp,c99427357.cfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	-- 将选中的「电子化天使」怪兽表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果③的发动判定与效果处理目标设置
function c99427357.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsAbleToChangeControler() end
	-- chk==0时判定自己场上是否有空余的怪兽区域用于特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且判定是否能通过控制权转移效果在场上放置该怪兽
		and Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_CONTROL)>0
		-- 并且判定己方场上是否能同时容纳自身与对方怪兽
		and Duel.GetLocationCount(tp,LOCATION_MZONE,tp,0)>1
		-- 并且对方场上存在可以改变控制权的怪兽
		and Duel.IsExistingTarget(Card.IsAbleToChangeControler,tp,0,LOCATION_MZONE,1,nil)
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 提示玩家选择要取得控制权的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 玩家选择对方场上的1只怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToChangeControler,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理的分类为控制权转移，并将目标怪兽写入操作信息
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
	-- 设置效果处理的分类为特殊召唤，并将自身写入操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果③的效果处理函数：自身从墓地特殊召唤，并得到作为对象的怪兽的控制权
function c99427357.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前效果指定的对方场上取得控制权的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判定自身是否依然与效果相关联，并且成功将自身特殊召唤到场上
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0
		and tc:IsRelateToEffect(e) then
		-- 取得目标怪兽的控制权
		Duel.GetControl(tc,tp)
	end
end

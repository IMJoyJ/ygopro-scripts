--罡炎星－リシュンキ
-- 效果：
-- 炎属性调整＋调整以外的名字带有「炎星」的怪兽1只以上
-- 这张卡同调召唤成功时，可以从卡组选1张名字带有「炎舞」的魔法·陷阱卡在自己场上盖放。只要这张卡在场上表侧表示存在，对方场上的怪兽的攻击力下降自己场上表侧表示存在的魔法·陷阱卡数量×100的数值。
function c89856523.initial_effect(c)
	-- 添加同调召唤手续：炎属性调整 + 1只以上调整以外的「炎星」怪兽
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_FIRE),aux.NonTuner(Card.IsSetCard,0x79),1)
	c:EnableReviveLimit()
	-- 这张卡同调召唤成功时，可以从卡组选1张名字带有「炎舞」的魔法·陷阱卡在自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(89856523,0))  --"盖放"
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c89856523.setcon)
	e1:SetTarget(c89856523.settg)
	e1:SetOperation(c89856523.setop)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上表侧表示存在，对方场上的怪兽的攻击力下降自己场上表侧表示存在的魔法·陷阱卡数量×100的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(c89856523.atkval)
	c:RegisterEffect(e2)
end
-- 判断此卡是否是通过同调召唤方式特殊召唤成功
function c89856523.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤卡组中可以盖放的「炎舞」魔法·陷阱卡
function c89856523.filter(c)
	return c:IsSetCard(0x7c) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- 设置盖放效果的发动准备，确认卡组中是否存在可盖放的卡
function c89856523.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若为检测阶段，则检查自己卡组中是否存在可盖放的「炎舞」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c89856523.filter,tp,LOCATION_DECK,0,1,nil) end
end
-- 执行盖放效果，从卡组选择1张「炎舞」魔法·陷阱卡在自己场上盖放
function c89856523.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从卡组选择1张符合条件的「炎舞」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c89856523.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片在自己场上盖放
		Duel.SSet(tp,g:GetFirst())
	end
end
-- 过滤自己场上表侧表示存在的魔法·陷阱卡
function c89856523.atkfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 计算攻击力下降数值的函数
function c89856523.atkval(e,c)
	-- 获取自己场上表侧表示的魔陷数量并乘以-100作为攻击力改变量
	return Duel.GetMatchingGroupCount(c89856523.atkfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,0,nil)*-100
end

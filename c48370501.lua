--ヴァイロン・シグマ
-- 效果：
-- 光属性调整＋调整以外的光属性怪兽1只以上
-- 自己场上没有这张卡以外的怪兽存在的场合，这张卡的攻击宣言时才能发动。从自己卡组选择1张装备魔法卡给这张卡装备。
function c48370501.initial_effect(c)
	-- 添加同调召唤手续，需要1只光属性调整和1只以上光属性调整以外的怪兽作为素材
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_LIGHT),aux.NonTuner(Card.IsAttribute,ATTRIBUTE_LIGHT),1)
	c:EnableReviveLimit()
	-- 自己场上没有这张卡以外的怪兽存在的场合，这张卡的攻击宣言时才能发动。从自己卡组选择1张装备魔法卡给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(48370501,0))  --"装备"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(c48370501.eqcon)
	e1:SetTarget(c48370501.eqtg)
	e1:SetOperation(c48370501.eqop)
	c:RegisterEffect(e1)
end
-- 效果条件函数，判断自己场上是否只有这张卡（或没有其他怪兽）
function c48370501.eqcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否只有这张卡（或没有其他怪兽）
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)<=1
end
-- 过滤函数，用于筛选可以装备给目标怪兽的装备魔法卡
function c48370501.filter(c,ec)
	return c:IsType(TYPE_EQUIP) and c:CheckEquipTarget(ec)
end
-- 效果发动时的处理函数，判断是否满足发动条件
function c48370501.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有足够的魔法陷阱区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己卡组中是否存在满足条件的装备魔法卡
		and Duel.IsExistingMatchingCard(c48370501.filter,tp,LOCATION_DECK,0,1,nil,e:GetHandler()) end
end
-- 效果发动时的具体操作函数
function c48370501.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查是否满足发动效果的基本条件（如场地区域、卡片状态等）
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 向玩家发送提示信息，提示选择一张装备魔法卡
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(48370501,1))  --"请选择一张装备魔法卡"
	-- 从自己卡组中选择1张满足条件的装备魔法卡
	local g=Duel.SelectMatchingCard(tp,c48370501.filter,tp,LOCATION_DECK,0,1,1,nil,c)
	if g:GetCount()>0 then
		-- 将选中的装备魔法卡装备给这张卡
		Duel.Equip(tp,g:GetFirst(),c)
	end
end

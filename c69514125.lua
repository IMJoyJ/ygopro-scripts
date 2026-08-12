--神聖騎士パーシアス
-- 效果：
-- 调整＋调整以外的光属性怪兽1只以上
-- ①：1回合1次，以对方场上1只表侧表示怪兽为对象才能发动。那只对方的表侧表示怪兽的表示形式变更。
-- ②：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
function c69514125.initial_effect(c)
	-- 添加同调召唤手续：调整＋调整以外的光属性怪兽1只以上。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsAttribute,ATTRIBUTE_LIGHT),1)
	c:EnableReviveLimit()
	-- ①：1回合1次，以对方场上1只表侧表示怪兽为对象才能发动。那只对方的表侧表示怪兽的表示形式变更。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(69514125,0))  --"改变表示形式"
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c69514125.postg)
	e1:SetOperation(c69514125.posop)
	c:RegisterEffect(e1)
	-- ②：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示且可以变更表示形式的怪兽。
function c69514125.filter(c)
	return c:IsFaceup() and c:IsCanChangePosition()
end
-- 效果①的Target（发动准备）函数：进行对象选择与改变表示形式的操作信息注册。
function c69514125.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and c69514125.filter(chkc) end
	-- 判定是否能选择对方场上1只表侧表示且可变更表示形式的怪兽作为对象。
	if chk==0 then return Duel.IsExistingTarget(c69514125.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 给玩家发送提示信息，提示选择要改变表示形式的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 玩家选择对方场上1只满足条件的表侧表示怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c69514125.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁的操作信息，表示该效果的处理为改变所选怪兽的表示形式。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 效果①的Operation（效果处理）函数：变更作为对象的怪兽的表示形式。
function c69514125.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的效果对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将目标怪兽的表示形式变更（表侧攻击表示变成表侧守备表示，表侧守备表示变成表侧攻击表示）。
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,0,POS_FACEUP_ATTACK,0)
	end
end

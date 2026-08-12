--百鬼羅刹 グリアーレ三傑
-- 效果：
-- 3星怪兽×2只以上
-- ①：场上的超量素材是3个以上的场合，自己的「哥布林」怪兽可以直接攻击。
-- ②：1回合1次，这张卡在怪兽区域存在的状态，怪兽召唤·特殊召唤的场合，以那之内的1只为对象才能发动。场上1个超量素材取除，作为对象的怪兽的表示形式变更。
-- ③：1回合1次，对方怪兽的攻击宣言时才能发动。场上1个超量素材取除，那次攻击无效。
local s,id,o=GetID()
-- 初始化效果函数，设置XYZ召唤手续并注册三个触发效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加XYZ召唤手续，使用3星怪兽2只以上作为素材
	aux.AddXyzProcedure(c,nil,3,2,nil,nil,14)
	-- ①：场上的超量素材是3个以上的场合，自己的「哥布林」怪兽可以直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCondition(s.dacon)
	-- 设置效果目标为「哥布林」怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xac))
	c:RegisterEffect(e1)
	-- ②：1回合1次，这张卡在怪兽区域存在的状态，怪兽召唤·特殊召唤的场合，以那之内的1只为对象才能发动。场上1个超量素材取除，作为对象的怪兽的表示形式变更。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e2:SetTarget(s.postg)
	e2:SetOperation(s.posop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③：1回合1次，对方怪兽的攻击宣言时才能发动。场上1个超量素材取除，那次攻击无效。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(s.negcon)
	e4:SetOperation(s.negop)
	c:RegisterEffect(e4)
end
-- 判断场上的超量素材数量是否不少于3个
function s.dacon(e)
	-- 返回场上的超量素材数量是否不少于3个
	return Duel.GetOverlayCount(0,1,1)>=3
end
-- 筛选可以改变表示形式且能成为效果对象的怪兽
function s.filter(c,e)
	return c:IsCanChangePosition() and c:IsCanBeEffectTarget(e) and c:IsLocation(LOCATION_MZONE)
end
-- 处理效果2的发动条件和目标选择
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有符合条件的怪兽且能移除1个超量素材
	if chk==0 then return eg:IsExists(s.filter,1,nil,e) and not eg:IsContains(e:GetHandler()) and Duel.CheckRemoveOverlayCard(tp,1,1,1,REASON_EFFECT) end
	local tc=eg:FilterSelect(tp,s.filter,1,1,nil,e)
	-- 设置效果目标为选中的怪兽
	Duel.SetTargetCard(tc)
	-- 设置操作信息为改变表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,tc,1,0,0)
end
-- 处理效果2的发动效果
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果目标
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否存在且能移除1个超量素材
	if tc:IsRelateToEffect(e) and Duel.RemoveOverlayCard(tp,1,1,1,1,REASON_EFFECT)~=0 then
		-- 将目标怪兽变为守备表示
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
-- 判断是否为对方怪兽攻击且能移除1个超量素材
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回是否为对方怪兽攻击且能移除1个超量素材
	return Duel.GetAttacker():GetControler()~=tp and Duel.CheckRemoveOverlayCard(tp,1,1,1,REASON_EFFECT)
end
-- 处理效果3的发动效果
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否能移除1个超量素材
	if Duel.RemoveOverlayCard(tp,1,1,1,1,REASON_EFFECT)~=0 then
		-- 无效此次攻击
		Duel.NegateAttack()
	end
end

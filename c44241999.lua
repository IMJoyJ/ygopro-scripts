--百鬼羅刹 グリアーレ三傑
-- 效果：
-- 3星怪兽×2只以上
-- ①：场上的超量素材是3个以上的场合，自己的「哥布林」怪兽可以直接攻击。
-- ②：1回合1次，这张卡在怪兽区域存在的状态，怪兽召唤·特殊召唤的场合，以那之内的1只为对象才能发动。场上1个超量素材取除，作为对象的怪兽的表示形式变更。
-- ③：1回合1次，对方怪兽的攻击宣言时才能发动。场上1个超量素材取除，那次攻击无效。
local s,id,o=GetID()
-- 初始化卡片的召唤手续和全部效果：设置苏生限制、添加超量召唤手续（等级3怪兽2只以上），并注册①直接攻击永续效果、②召唤/特殊召唤时变更表示形式的诱发效果、③攻击宣言无效的诱发效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加XYZ召唤手续：以等级3的怪兽2只以上（最多14只）为素材进行超量召唤。
	aux.AddXyzProcedure(c,nil,3,2,nil,nil,14)
	-- ①：场上的超量素材是3个以上的场合，自己的「哥布林」怪兽可以直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCondition(s.dacon)
	-- 设定①效果适用的对象：我方场上持有「哥布林」系列字段（0xac）的怪兽。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0xac))
	c:RegisterEffect(e1)
	-- ②：1回合1次，这张卡在怪兽区域存在的状态，怪兽召唤的场合，以那之内的1只为对象才能发动。场上1个超量素材取除，作为对象的怪兽的表示形式变更。
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
-- ①效果的发动条件函数：检查全场超量素材合计数量是否为3个以上。
function s.dacon(e)
	-- 返回全场超量素材合计是否≥3。
	return Duel.GetOverlayCount(0,1,1)>=3
end
-- 筛选函数：判断怪兽是否位于怪兽区域、可以变更表示形式、且能成为效果对象。
function s.filter(c,e)
	return c:IsCanChangePosition() and c:IsCanBeEffectTarget(e) and c:IsLocation(LOCATION_MZONE)
end
-- ②效果的目标选择与发动条件处理：在召唤/特殊召唤成功的怪兽中确认存在满足条件的对象（且不含本卡），并确认可移除我方场上1个超量素材；选择1只为对象，登记对象并设置表示形式变更的操作信息。
function s.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 召唤/特殊召唤成功的怪兽中存在1只以上满足筛选条件的怪兽、该组中不包含本卡、且可以移除我方场上1个超量素材。
	if chk==0 then return eg:IsExists(s.filter,1,nil,e) and not eg:IsContains(e:GetHandler()) and Duel.CheckRemoveOverlayCard(tp,1,1,1,REASON_EFFECT) end
	local tc=eg:FilterSelect(tp,s.filter,1,1,nil,e)
	-- 将选择的对象怪兽设置为当前连锁的对象（取对象）。
	Duel.SetTargetCard(tc)
	-- 设置效果处理的操作信息：对选中的1只怪兽进行表示形式变更（CATEGORY_POSITION）。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,tc,1,0,0)
end
-- ②效果处理函数：若对象怪兽仍与效果关联，且成功从我方场上移除1个超量素材，则将对象怪兽的表示形式变更。
function s.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象（连锁处理时记录的目标怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽仍与本次效果关联，并成功从我方场上移除1个超量素材后，才执行表示形式变更。
	if tc:IsRelateToEffect(e) and Duel.RemoveOverlayCard(tp,1,1,1,1,REASON_EFFECT)~=0 then
		-- 变更对象怪兽的表示形式：表侧攻击表示与表侧守备表示互换，里侧攻击/守备表示变为表侧攻击表示。
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
-- ③效果的发动条件函数：对方怪兽攻击宣言时，且我方场上存在可移除的超量素材。
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回攻击怪兽的控制者不是本卡控制者，并且可以移除我方场上1个超量素材。
	return Duel.GetAttacker():GetControler()~=tp and Duel.CheckRemoveOverlayCard(tp,1,1,1,REASON_EFFECT)
end
-- ③效果处理函数：移除我方场上1个超量素材成功后，无效对方怪兽的攻击。
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 移除我方场上1个超量素材；若移除成功则继续无效攻击。
	if Duel.RemoveOverlayCard(tp,1,1,1,1,REASON_EFFECT)~=0 then
		-- 无效对方怪兽的这次攻击。
		Duel.NegateAttack()
	end
end

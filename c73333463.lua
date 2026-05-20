--アーマロイドガイデンゴー
-- 效果：
-- ①：把「机人」怪兽解放让这张卡上级召唤成功的场合发动。场上的魔法·陷阱卡全部除外。
function c73333463.initial_effect(c)
	-- ①：把「机人」怪兽解放让这张卡上级召唤成功的场合发动。场上的魔法·陷阱卡全部除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(73333463,0))  --"除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c73333463.condition)
	e1:SetTarget(c73333463.target)
	e1:SetOperation(c73333463.operation)
	c:RegisterEffect(e1)
	-- 把「机人」怪兽解放让这张卡上级召唤成功
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c73333463.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
end
-- 在召唤成功前，检查上级召唤此卡所使用的素材中是否包含「机人」怪兽，并向效果1传递标记值
function c73333463.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsSetCard,1,nil,0x16) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- 确认此卡是通过上级召唤成功，且上级召唤时解放了「机人」怪兽
function c73333463.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE) and e:GetLabel()==1
end
-- 过滤场上的魔法·陷阱卡且该卡可以被除外
function c73333463.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemove()
end
-- 效果1的发动准备，获取场上所有的魔法·陷阱卡并设置除外操作信息
function c73333463.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取双方场上所有的魔法·陷阱卡
	local g=Duel.GetMatchingGroup(c73333463.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置除外操作信息，包含要除外的卡片组及数量
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 效果1的处理，将场上所有的魔法·陷阱卡全部除外
function c73333463.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前双方场上所有的魔法·陷阱卡
	local g=Duel.GetMatchingGroup(c73333463.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if g:GetCount()>0 then
		-- 将目标卡片组以表侧表示除外
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end

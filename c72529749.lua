--トポロジック・トゥリスバエナ
-- 效果：
-- 效果怪兽2只以上
-- ①：这张卡所连接区有怪兽特殊召唤的场合发动。那些怪兽以及场上的魔法·陷阱卡全部除外，给与对方这个效果除外的对方的卡数量×500伤害。
function c72529749.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置连接召唤手续：效果怪兽2只以上
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),2)
	-- ①：这张卡所连接区有怪兽特殊召唤的场合发动。那些怪兽以及场上的魔法·陷阱卡全部除外，给与对方这个效果除外的对方的卡数量×500伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(72529749,0))  --"除外"
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c72529749.rmcon)
	e1:SetTarget(c72529749.rmtg)
	e1:SetOperation(c72529749.rmop)
	c:RegisterEffect(e1)
end
-- 过滤特殊召唤到这张卡所连接区的怪兽（包含已离场但离场前在连接区的情况）
function c72529749.cfilter(c,ec)
	if c:IsLocation(LOCATION_MZONE) then
		return ec:GetLinkedGroup():IsContains(c)
	else
		return bit.extract(ec:GetLinkedZone(c:GetPreviousControler()),c:GetPreviousSequence())~=0
	end
end
-- 判断特殊召唤成功的怪兽中是否存在于这张卡所连接区的怪兽，作为效果发动条件
function c72529749.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c72529749.cfilter,1,nil,e:GetHandler())
end
-- 效果发动的目标选择与处理准备：将特殊召唤的怪兽设为目标，并合并场上的魔法·陷阱卡，设置除外操作信息
function c72529749.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=eg:Filter(c72529749.cfilter,nil,e:GetHandler())
	local tg=g:Filter(Card.IsLocation,nil,LOCATION_MZONE)
	-- 将特殊召唤到连接区的怪兽设为效果处理的对象
	Duel.SetTargetCard(tg)
	-- 获取双方场上所有的魔法·陷阱卡
	local g2=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP)
	g:Merge(g2)
	-- 设置连锁的操作信息，表示此效果将除外这些卡片
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,g:GetCount(),0,0)
end
-- 效果处理：将目标怪兽和场上的魔法·陷阱卡全部除外，并根据除外的对方卡片数量给与对方伤害
function c72529749.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取仍与此效果相关的目标怪兽（即特殊召唤到连接区的怪兽）
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 获取当前场上所有的魔法·陷阱卡
	local g2=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,TYPE_SPELL+TYPE_TRAP)
	g:Merge(g2)
	-- 将目标怪兽和魔法·陷阱卡以表侧表示除外，若成功除外了卡片则执行后续处理
	if Duel.Remove(g,POS_FACEUP,REASON_EFFECT)~=0 then
		-- 统计本次操作中实际被除外的对方卡片的数量
		local ct=Duel.GetOperatedGroup():FilterCount(Card.IsControler,nil,1-tp)
		-- 给与对方被除外的对方卡片数量×500的伤害
		Duel.Damage(1-tp,ct*500,REASON_EFFECT)
	end
end

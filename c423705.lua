--鉄の騎士 ギア・フリード
-- 效果：
-- ①：这张卡有装备卡被装备的场合发动。那些装备卡破坏。
function c423705.initial_effect(c)
	-- ①：这张卡有装备卡被装备的场合发动。那些装备卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(423705,0))  --"装备卡破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_EQUIP)
	e1:SetTarget(c423705.destg)
	e1:SetOperation(c423705.desop)
	c:RegisterEffect(e1)
end
-- 筛选出以这张卡为装备对象的装备卡，用于确定这次装备事件中需要破坏的装备卡。
function c423705.filter(c,ec)
	return c:GetEquipTarget()==ec
end
-- 发动时的目标选取阶段：必定满足发动条件；从诱发装备事件中筛选出装备在这张卡上的装备卡，将其设为连锁对象，并登记破坏效果的操作信息。
function c423705.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local dg=eg:Filter(c423705.filter,nil,e:GetHandler())
	-- 把筛选出的装备卡登记为当前连锁的对象，以便效果处理时仍能关联到这些卡。
	Duel.SetTargetCard(dg)
	-- 设置本次连锁处理的操作信息：类别为破坏，对象为已确定的装备卡组，数量为dg:GetCount()，玩家和位置未知填0。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,dg:GetCount(),0,0)
end
-- 效果处理时，从连锁信息中取出对象卡，过滤出仍与效果关联的卡，并将它们全部破坏。
function c423705.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取出发动时登记的对象卡，并过滤出仍与当前效果存在关联的卡（防止离场等导致失去关联），作为实际破坏的对象。
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 以效果原因将这些对象卡全部破坏。
	Duel.Destroy(tg,REASON_EFFECT)
end

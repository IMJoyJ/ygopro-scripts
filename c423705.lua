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
-- 过滤函数，用于筛选装备目标为ec的装备卡
function c423705.filter(c,ec)
	return c:GetEquipTarget()==ec
end
-- 效果处理时的处理函数，用于设置破坏对象和操作信息
function c423705.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local dg=eg:Filter(c423705.filter,nil,e:GetHandler())
	-- 将当前连锁的目标卡片设置为dg
	Duel.SetTargetCard(dg)
	-- 设置当前连锁的操作信息为破坏效果，目标为dg，数量为dg的卡数
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,dg:GetCount(),0,0)
end
-- 效果发动时的处理函数，用于执行破坏效果
function c423705.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡片组，并筛选出与该效果相关的卡片
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 以效果原因将目标卡片组tg进行破坏
	Duel.Destroy(tg,REASON_EFFECT)
end

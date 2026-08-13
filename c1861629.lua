--デコード・トーカー
-- 效果：
-- 效果怪兽2只以上
-- ①：这张卡的攻击力上升这张卡所连接区的怪兽数量×500。
-- ②：自己场上的卡为对象的魔法·陷阱·怪兽的效果由对方发动时，把这张卡所连接区1只自己怪兽解放才能发动。那个发动无效并破坏。
function c1861629.initial_effect(c)
	-- 为这张卡添加连接召唤手续，素材要求为效果怪兽2只以上。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),2)
	c:EnableReviveLimit()
	-- ①：这张卡的攻击力上升这张卡所连接区的怪兽数量×500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c1861629.atkval)
	c:RegisterEffect(e1)
	-- ②：自己场上的卡为对象的魔法·陷阱·怪兽的效果由对方发动时，把这张卡所连接区1只自己怪兽解放才能发动。那个发动无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1861629,0))  --"发动无效并破坏"
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c1861629.discon)
	e2:SetCost(c1861629.discost)
	e2:SetTarget(c1861629.distg)
	e2:SetOperation(c1861629.disop)
	c:RegisterEffect(e2)
end
-- 返回这张卡所连接区的怪兽数量乘以500，作为攻击力上升的数值。
function c1861629.atkval(e,c)
	return c:GetLinkedGroupCount()*500
end
-- 筛选出场上存在的、控制者为tp的卡，用于判断对方效果是否以自己场上的卡为对象。
function c1861629.tfilter(c,tp)
	return c:IsOnField() and c:IsControler(tp)
end
-- ②效果的发动条件：对方发动以自己场上的卡为对象的魔法·陷阱·怪兽效果，且此卡未被战斗破坏确定，且该连锁可以被无效。
function c1861629.discon(e,tp,eg,ep,ev,re,r,rp)
	if rp==tp or e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	-- 获取当前连锁中对方发动效果的对象卡组。
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 判断对象卡组中存在自己场上的卡，且该连锁可以被无效。
	return tg and tg:IsExists(c1861629.tfilter,1,nil,tp) and Duel.IsChainNegatable(ev)
end
-- 筛选出位于这张卡所连接区、且未被战斗破坏确定的自己怪兽，作为可解放的代价候选。
function c1861629.cfilter(c,g)
	return g:IsContains(c) and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
-- ②效果的代价：从自己场上选择这张卡所连接区的1只自己怪兽解放。
function c1861629.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	local lg=e:GetHandler():GetLinkedGroup()
	-- 代价检查阶段：确认场上是否存在至少1只符合条件的连接区自己怪兽可解放。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c1861629.cfilter,1,nil,lg) end
	-- 选择1只符合条件的连接区自己怪兽作为解放代价。
	local g=Duel.SelectReleaseGroup(tp,c1861629.cfilter,1,1,nil,lg)
	-- 将选择的怪兽解放，作为发动代价。
	Duel.Release(g,REASON_COST)
end
-- ②效果的目标与操作信息设置：将对方发动的效果无效并破坏，同时登记对应的效果分类。
function c1861629.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本次处理包含“无效发动”，对象为对方发动的效果。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息：若该效果卡可破坏且仍与效果关联，则本次处理包含“破坏”，对象为该效果卡。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- ②效果的处理：无效对方效果的发动，并破坏那张效果卡。
function c1861629.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 若发动被成功无效，且效果卡仍与效果关联，则继续执行破坏处理。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将对方发动的那张效果卡破坏。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end

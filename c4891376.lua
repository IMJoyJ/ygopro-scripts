--鎖縛竜ザレン
-- 效果：
-- 调整＋同调怪兽1只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：把自己场上的这张卡作为同调素材的场合，可以把这张卡当作调整以外的怪兽使用。
-- ②：连锁卡的效果的发动让魔法·陷阱·怪兽的效果发动时，可以从以下效果选择1个发动。
-- ●那个效果无效并破坏。
-- ●那个效果连锁的卡的效果无效并破坏。
local s,id,o=GetID()
-- 定义锁缚龙的初始效果注册函数：注册同调召唤手续、苏生限制、①（作为同调素材时视为调整以外）以及②（连锁效果无效并破坏）的效果。
function s.initial_effect(c)
	-- 注册同调召唤手续，对应召唤条件‘调整＋同调怪兽1只以上’：允许任意调整怪兽与1只以上同调怪兽作为素材进行同调召唤。
	aux.AddSynchroMixProcedure(c,aux.Tuner(nil),nil,nil,aux.FilterBoolFunction(Card.IsSynchroType,TYPE_SYNCHRO),1,99)
	c:EnableReviveLimit()
	-- ①：把自己场上的这张卡作为同调素材的场合，可以把这张卡当作调整以外的怪兽使用。（以素材检查方式实现）
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(s.valcheck)
	c:RegisterEffect(e0)
	-- ①：把自己场上的这张卡作为同调素材的场合，可以把这张卡当作调整以外的怪兽使用。（EFFECT_NONTUNER常驻效果）
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_NONTUNER)
	e1:SetValue(s.tnval)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：连锁卡的效果的发动让魔法·陷阱·怪兽的效果发动时，可以从以下效果选择1个发动。●那个效果无效并破坏。●那个效果连锁的卡的效果无效并破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"效果无效"
	e2:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.discon)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
end
-- 素材检查回调：当同调召唤使用的素材中存在至少2只调整怪兽时，为这张卡追加一个可重置的非调整效果，用于①效果的支援。
function s.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsType,2,nil,TYPE_TUNER) then
		-- ①：把自己场上的这张卡作为同调素材的场合，可以把这张卡当作调整以外的怪兽使用。（追加的非调整效果，带重置条件）
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e1:SetCode(21142671)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- EFFECT_NONTUNER的效果值函数：当这张卡的控制者与被作为素材的同调素材怪兽控制者相同（即自己场上的场合）时，允许其视为调整以外。
function s.tnval(e,c)
	return e:GetHandler():IsControler(c:GetControler())
end
-- ②效果的发动条件：连锁数大于1，自身未被战斗破坏确定，且当前连锁或上一连锁中有可以被无效的效果。
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if ev<=1 then return false end
	return not c:IsStatus(STATUS_BATTLE_DESTROYED)
		-- 判定当前连锁效果或上一连锁效果是否可被无效，满足其一即满足发动前提。
		and (Duel.IsChainDisablable(ev) or Duel.IsChainDisablable(ev-1))
end
-- ②效果的发动目标与操作信息设定：根据玩家选择的选项（无效当前连锁效果或无效上一连锁效果），设置对应的无效/破坏目标及操作信息。
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查当前连锁（ev）的效果能否被无效，结果存入b1。
	local b1=Duel.IsChainDisablable(ev)
	-- 检查上一连锁（ev-1）的效果能否被无效，结果存入b2。
	local b2=Duel.IsChainDisablable(ev-1)
	if chk==0 then return b1 or b2 end
	-- 获取上一连锁的效果对象te，作为选项2（无效被连锁的卡的效果）的目标依据。
	local te=Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_EFFECT)
	-- 让玩家从两个可选效果中选择1个：无效并破坏当前连锁的效果，或无效并破坏上一连锁的效果。
	local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(id,2),1},  --"无效连锁的效果"
		{b2,aux.Stringid(id,3),2})  --"无效被连锁的效果"
	e:SetLabel(op)
	if op==1 then
		-- 设定操作信息：声明将无效当前连锁触发的效果，对象为eg中的连锁触发源，数量1。
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
		if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
			-- 设定操作信息：当前连锁效果持有者可破坏且与效果关联时，声明将破坏eg中的连锁触发源。
			Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
		end
	elseif op==2 then
		-- 设定操作信息：声明将无效上一连锁的效果，对象为其效果持有者te:GetHandler()。
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,te:GetHandler(),1,0,0)
		if te:GetHandler():IsDestructable() and te:GetHandler():IsRelateToEffect(te) then
			-- 设定操作信息：上一连锁效果持有者可破坏且与效果关联时，声明将破坏te:GetHandler()。
			Duel.SetOperationInfo(0,CATEGORY_DESTROY,te:GetHandler(),1,0,0)
		end
	end
end
-- ②效果处理：根据选择的选项，对应无效并破坏当前连锁或上一连锁的效果及其持有者。
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		-- 尝试无效当前连锁的效果，并确认其效果持有者仍与当前连锁关联，条件成立时执行后续破坏。
		if Duel.NegateEffect(ev) and re:GetHandler():IsRelateToChain(ev) then
			-- 以效果破坏当前连锁的触发源卡组eg。
			Duel.Destroy(eg,REASON_EFFECT)
		end
	elseif op==2 then
		-- 获取上一连锁的效果对象，用于选项2的无效果与破坏处理目标。
		local te=Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_EFFECT)
		-- 尝试无效上一连锁的效果，并确认其效果持有者仍与上一连锁关联，条件成立时执行后续破坏。
		if Duel.NegateEffect(ev-1) and te:GetHandler():IsRelateToChain(ev-1) then
			-- 以效果破坏上一连锁的效果持有者te:GetHandler()。
			Duel.Destroy(te:GetHandler(),REASON_EFFECT)
		end
	end
end

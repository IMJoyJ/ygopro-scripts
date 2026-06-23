--鎖縛竜ザレン
-- 效果：
-- 调整＋同调怪兽1只以上
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：把自己场上的这张卡作为同调素材的场合，可以把这张卡当作调整以外的怪兽使用。
-- ②：连锁卡的效果的发动让魔法·陷阱·怪兽的效果发动时，可以从以下效果选择1个发动。
-- ●那个效果无效并破坏。
-- ●那个效果连锁的卡的效果无效并破坏。
local s,id,o=GetID()
-- 初始化效果，设置同调召唤手续、启用复活限制、注册素材检查效果、注册非调整效果和连锁无效效果
function s.initial_effect(c)
	-- 添加同调召唤手续，要求至少1只调整和至少1只同调怪兽作为素材
	aux.AddSynchroMixProcedure(c,aux.Tuner(nil),nil,nil,aux.FilterBoolFunction(Card.IsSynchroType,TYPE_SYNCHRO),1,99)
	c:EnableReviveLimit()
	-- 注册一个用于检查是否包含2只以上调整的素材检查效果
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(s.valcheck)
	c:RegisterEffect(e0)
	-- 注册一个使该卡在同调召唤时可当作非调整怪兽使用的永续效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_NONTUNER)
	e1:SetValue(s.tnval)
	c:RegisterEffect(e1)
	-- 注册一个连锁发动时可选择无效并破坏效果的诱发即时效果
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
-- 检查是否有至少2只调整作为素材，若有则赋予该卡特殊效果
function s.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsType,2,nil,TYPE_TUNER) then
		-- 赋予该卡一个不能被无效且不可复制的效果（编号21142671）
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e1:SetCode(21142671)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 返回该卡是否与目标怪兽控制者相同，用于判断非调整效果的适用性
function s.tnval(e,c)
	return e:GetHandler():IsControler(c:GetControler())
end
-- 连锁发动时的条件判断，确保不是战斗破坏且当前连锁或前一连锁可被无效
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if ev<=1 then return false end
	return not c:IsStatus(STATUS_BATTLE_DESTROYED)
		-- 判断当前连锁或前一连锁是否可以被无效
		and (Duel.IsChainDisablable(ev) or Duel.IsChainDisablable(ev-1))
end
-- 设置连锁无效效果的发动条件和目标选择逻辑，包括选项选择和操作信息设定
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断当前连锁的效果是否可以被无效
	local b1=Duel.IsChainDisablable(ev)
	-- 判断前一连锁的效果是否可以被无效
	local b2=Duel.IsChainDisablable(ev-1)
	if chk==0 then return b1 or b2 end
	-- 获取前一连锁触发的效果对象
	local te=Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_EFFECT)
	-- 让玩家从两个选项中选择一个进行操作
	local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(id,2),1},  --"无效连锁的效果"
		{b2,aux.Stringid(id,3),2})  --"无效被连锁的效果"
	e:SetLabel(op)
	if op==1 then
		-- 设置操作信息为使当前连锁效果无效
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
		if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
			-- 设置操作信息为破坏当前连锁的发动对象
			Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
		end
	elseif op==2 then
		-- 设置操作信息为使前一连锁的效果无效
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,te:GetHandler(),1,0,0)
		if te:GetHandler():IsDestructable() and te:GetHandler():IsRelateToEffect(te) then
			-- 设置操作信息为破坏前一连锁的效果对象
			Duel.SetOperationInfo(0,CATEGORY_DESTROY,te:GetHandler(),1,0,0)
		end
	end
end
-- 执行连锁无效效果的操作逻辑，根据选择的选项进行对应处理
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		-- 判断是否成功使当前连锁效果无效并确认其对象是否有效
		if Duel.NegateEffect(ev) and re:GetHandler():IsRelateToChain(ev) then
			-- 破坏当前连锁的发动对象
			Duel.Destroy(eg,REASON_EFFECT)
		end
	elseif op==2 then
		-- 获取前一连锁触发的效果对象
		local te=Duel.GetChainInfo(ev-1,CHAININFO_TRIGGERING_EFFECT)
		-- 判断是否成功使前一连锁效果无效并确认其对象是否有效
		if Duel.NegateEffect(ev-1) and te:GetHandler():IsRelateToChain(ev-1) then
			-- 破坏前一连锁的效果对象
			Duel.Destroy(te:GetHandler(),REASON_EFFECT)
		end
	end
end

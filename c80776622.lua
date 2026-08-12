--ドドレミコード・クーリア
-- 效果：
-- ←1 【灵摆】 1→
-- ①：在自己的「七音服」灵摆怪兽的灵摆召唤成功时对方不能把怪兽的效果·魔法·陷阱卡发动。
-- 【怪兽效果】
-- 这个卡名的②③的怪兽效果1回合各能使用1次。
-- ①：这张卡可以把自己场上2只灵摆怪兽解放从手卡特殊召唤。
-- ②：以对方场上1张表侧表示卡为对象才能发动（自己的灵摆区域有奇数的灵摆刻度存在的场合，这个效果的对象可以变成2张）。那张卡的效果直到对方回合结束时无效。
-- ③：持有自己的灵摆区域的最高灵摆刻度×300以下的攻击力的场上的怪兽的效果发动时才能发动。那只怪兽破坏。
function c80776622.initial_effect(c)
	-- 为卡片注册灵摆怪兽属性（灵摆召唤、灵摆卡的发动等基本规则）。
	aux.EnablePendulumAttribute(c)
	-- ①：在自己的「七音服」灵摆怪兽的灵摆召唤成功时对方不能把怪兽的效果·魔法·陷阱卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCondition(c80776622.limcon)
	e1:SetOperation(c80776622.limop)
	c:RegisterEffect(e1)
	-- ①：在自己的「七音服」灵摆怪兽的灵摆召唤成功时对方不能把怪兽的效果·魔法·陷阱卡发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCode(EVENT_CHAIN_END)
	e2:SetOperation(c80776622.limop2)
	c:RegisterEffect(e2)
	-- ①：这张卡可以把自己场上2只灵摆怪兽解放从手卡特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SPSUMMON_PROC)
	e3:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e3:SetRange(LOCATION_HAND)
	e3:SetCondition(c80776622.spcon)
	e3:SetTarget(c80776622.sptg)
	e3:SetOperation(c80776622.spop)
	c:RegisterEffect(e3)
	-- ②：以对方场上1张表侧表示卡为对象才能发动（自己的灵摆区域有奇数的灵摆刻度存在的场合，这个效果的对象可以变成2张）。那张卡的效果直到对方回合结束时无效。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(80776622,0))
	e4:SetCategory(CATEGORY_DISABLE)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,80776622)
	e4:SetTarget(c80776622.distg)
	e4:SetOperation(c80776622.disop)
	c:RegisterEffect(e4)
	-- ③：持有自己的灵摆区域的最高灵摆刻度×300以下的攻击力的场上的怪兽的效果发动时才能发动。那只怪兽破坏。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(80776622,1))
	e5:SetCategory(CATEGORY_DESTROY)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_CHAINING)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,80776623)
	e5:SetCondition(c80776622.descon)
	e5:SetTarget(c80776622.destg)
	e5:SetOperation(c80776622.desop)
	c:RegisterEffect(e5)
end
-- 过滤出自己场上灵摆召唤成功的「七音服」灵摆怪兽。
function c80776622.limfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsSetCard(0x162) and c:IsType(TYPE_PENDULUM) and c:IsSummonType(SUMMON_TYPE_PENDULUM)
end
-- 检查特殊召唤成功的怪兽中是否存在自己场上灵摆召唤成功的「七音服」灵摆怪兽。
function c80776622.limcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c80776622.limfilter,1,nil,tp)
end
-- 在灵摆召唤成功时，根据当前连锁数设置对方不能发动卡的效果的限制。
function c80776622.limop(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前是否没有正在处理的连锁（即灵摆召唤成功时直接进入时点，不入连锁）。
	if Duel.GetCurrentChain()==0 then
		-- 限制对方直到连锁结束前不能发动怪兽的效果·魔法·陷阱卡。
		Duel.SetChainLimitTillChainEnd(c80776622.chainlm)
	-- 判定当前是否在连锁1的处理中（即灵摆召唤作为连锁1特殊召唤成功）。
	elseif Duel.GetCurrentChain()==1 then
		e:GetHandler():RegisterFlagEffect(80776622,RESET_EVENT+RESETS_STANDARD,0,1)
		-- ①：在自己的「七音服」灵摆怪兽的灵摆召唤成功时对方不能把怪兽的效果·魔法·陷阱卡发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAINING)
		e1:SetOperation(c80776622.resetop)
		-- 注册全局效果，在有效果发动时重置限制标记。
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EVENT_BREAK_EFFECT)
		e2:SetReset(RESET_CHAIN)
		-- 注册全局效果，在效果处理被中断时重置限制标记。
		Duel.RegisterEffect(e2,tp)
	end
end
-- 重置并清除限制对方发动的标记效果。
function c80776622.resetop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():ResetFlagEffect(80776622)
	e:Reset()
end
-- 在连锁结束时，若存在限制标记，则再次应用直到连锁结束为止的连锁限制。
function c80776622.limop2(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetFlagEffect(80776622)~=0 then
		-- 限制对方直到连锁结束前不能发动怪兽的效果·魔法·陷阱卡。
		Duel.SetChainLimitTillChainEnd(c80776622.chainlm)
	end
end
-- 连锁限制的过滤函数，允许自己发动效果，且允许对方发动非卡片发动的魔陷效果，但禁止对方发动怪兽效果及魔陷的卡片发动。
function c80776622.chainlm(e,ep,tp)
	return ep==tp or e:IsActiveType(TYPE_SPELL+TYPE_TRAP) and not e:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 过滤出可作为特殊召唤解放素材的灵摆怪兽（自己场上的，或对方场上表侧表示的）。
function c80776622.rfilter(c,tp)
	return c:IsType(TYPE_PENDULUM) and (c:IsControler(tp) or c:IsFaceup())
end
-- 检查手卡中的这张卡是否满足特殊召唤的条件（场上是否存在2只可解放的灵摆怪兽，且解放后有足够的怪兽区域）。
function c80776622.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 获取场上所有可解放的灵摆怪兽卡组。
	local rg=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c80776622.rfilter,nil,tp)
	-- 检查是否能选出2只怪兽解放，且解放后能腾出位置特殊召唤这张卡。
	return rg:CheckSubGroup(aux.mzctcheckrel,2,2,tp,REASON_SPSUMMON)
end
-- 特殊召唤的准备操作，让玩家选择要解放的2只灵摆怪兽并保存。
function c80776622.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取场上所有可解放的灵摆怪兽卡组。
	local rg=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c80776622.rfilter,nil,tp)
	-- 提示玩家选择要解放的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 玩家选择2只解放后能腾出位置特殊召唤的灵摆怪兽。
	local sg=rg:SelectSubGroup(tp,aux.mzctcheckrel,true,2,2,tp,REASON_SPSUMMON)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 执行特殊召唤的操作，解放选中的怪兽。
function c80776622.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 解放选中的怪兽。
	Duel.Release(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 过滤出灵摆刻度为奇数的卡片。
function c80776622.pfilter(c)
	return c:GetCurrentScale()%2~=0
end
-- 效果无效效果的发动准备，检查并选择对方场上的表侧表示卡片作为对象。
function c80776622.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 判定是否为符合条件（对方场上表侧表示且可被无效）的重构对象。
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and aux.NegateAnyFilter(chkc) end
	-- 判定对方场上是否存在至少1张可被无效的表侧表示卡片。
	if chk==0 then return Duel.IsExistingTarget(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil) end
	local ct=1
	-- 若自己的灵摆区域存在奇数刻度的卡，则将可选的对象数量上限提升至2张。
	if Duel.IsExistingMatchingCard(c80776622.pfilter,tp,LOCATION_PZONE,0,1,nil) then ct=2 end
	-- 提示玩家选择要无效的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择1张或最多2张对方场上的表侧表示卡片作为效果对象。
	local g=Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,ct,nil)
	-- 设置连锁的操作信息，表明此效果将无效选中的卡片。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,#g,0,0)
end
-- 过滤出仍存在于场上且可被该效果无效的对象卡片。
function c80776622.disfilter(c,e)
	return c:IsFaceup() and c:IsRelateToEffect(e) and c:IsCanBeDisabledByEffect(e,false)
end
-- 执行无效效果，使选中的对象卡片的效果直到对方回合结束时无效。
function c80776622.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中作为对象且符合无效条件的卡片。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c80776622.disfilter,nil,e)
	local tc=g:GetFirst()
	while tc do
		-- 使与目标卡片相关的连锁失效。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那张卡的效果直到对方回合结束时无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		tc:RegisterEffect(e1)
		-- 那张卡的效果直到对方回合结束时无效。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			-- 那张卡的效果直到对方回合结束时无效。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
			tc:RegisterEffect(e3)
		end
		tc=g:GetNext()
	end
end
-- 检查发动效果的怪兽是否在怪兽区，且其攻击力是否在自己灵摆区最高刻度×300以下。
function c80776622.descon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if not (rc:IsRelateToEffect(re) and rc:IsLocation(LOCATION_MZONE) and re:IsActiveType(TYPE_MONSTER)) then return false end
	-- 获取自己灵摆区域的所有卡片。
	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	if g:GetCount()==0 then return false end
	local _,max=g:GetMaxGroup(Card.GetCurrentScale)
	return rc:IsAttackBelow(max*300)
end
-- 破坏效果的发动准备，设置破坏的操作信息。
function c80776622.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁的操作信息，表明此效果将破坏发动效果的那只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
end
-- 执行破坏操作，将发动效果的那只怪兽破坏。
function c80776622.desop(e,tp,eg,ep,ev,re,r,rp)
	if re:GetHandler():IsRelateToEffect(re) then
		-- 破坏发动效果的怪兽。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end

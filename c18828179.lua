--マザー・ブレイン
-- 效果：
-- 这张卡可以把自己场上存在的1只「海洋怪鱼卫士」解放，从手卡特殊召唤。可以从手卡把1只水属性怪兽丢弃去墓地，场上盖放的1张卡破坏。
function c18828179.initial_effect(c)
	-- 这张卡可以把自己场上存在的1只「海洋怪鱼卫士」解放，从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c18828179.spcon)
	e1:SetTarget(c18828179.sptg)
	e1:SetOperation(c18828179.spop)
	c:RegisterEffect(e1)
	-- 可以从手卡把1只水属性怪兽丢弃去墓地，场上盖放的1张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(18828179,0))  --"破坏"
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c18828179.descost)
	e2:SetTarget(c18828179.destg)
	e2:SetOperation(c18828179.desop)
	c:RegisterEffect(e2)
end
-- 筛选可作为特殊召唤解放素材的卡片：卡名必须为「海洋怪鱼卫士」，且解放后当前玩家场上有空余怪兽区，并且该卡是自己控制的或表侧表示（可解放条件判定）。
function c18828179.rfilter(c,tp)
	return c:IsCode(45045866)
		-- 并且要求解放这张卡后自己场上有空余怪兽区，且这张卡是自己控制的或是表侧表示，以确保它能作为解放素材。
		and Duel.GetMZoneCount(tp,c)>0 and (c:IsControler(tp) or c:IsFaceup())
end
-- 特殊召唤规则效果的发动条件：当要特殊召唤的卡为nil时直接通过；否则判断当前玩家是否能提供1只满足rfilter条件的「海洋怪鱼卫士」作为解放素材来从手卡特殊召唤此卡。
function c18828179.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查当前玩家tp是否存在至少1只满足rfilter条件的可解放的「海洋怪鱼卫士」，作为特殊召唤的解放素材。
	return Duel.CheckReleaseGroupEx(tp,c18828179.rfilter,1,REASON_SPSUMMON,false,nil,tp)
end
-- 特殊召唤规则效果选择解放素材的阶段：从当前玩家可解放的卡中过滤出符合条件的「海洋怪鱼卫士」，提示玩家选择1张，并将所选卡记录在效果e中；选择成功则返回true，否则返回false。
function c18828179.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 取得当前玩家tp可解放的怪兽组（不含手卡），并筛选出所有可作为解放素材的「海洋怪鱼卫士」。
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c18828179.rfilter,nil,tp)
	-- 给玩家tp发送选择提示，提示内容为请选择要解放的卡（HINTMSG_RELEASE）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则效果的实际执行：取出之前选择的解放素材，并将其解放，完成特殊召唤所需的手续。
function c18828179.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将之前选择的「海洋怪鱼卫士」解放，解放原因记为REASON_SPSUMMON。
	Duel.Release(g,REASON_SPSUMMON)
end
-- 筛选可作为发动代价丢弃的水属性手卡：必须水属性、可以被丢弃、且能作为代价送去墓地。
function c18828179.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsDiscardable() and c:IsAbleToGraveAsCost()
end
-- 起动效果的代价函数：chk==0时检查手卡是否存在满足cfilter的水属性怪兽；否则选择1张水属性怪兽丢弃去墓地作为发动代价。
function c18828179.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认手卡中是否存在至少1张满足条件的水属性怪兽可以作为代价丢弃。
	if chk==0 then return Duel.IsExistingMatchingCard(c18828179.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家选择1张满足条件的水属性手卡，以cost+丢弃的理由丢弃去墓地，作为效果发动代价。
	Duel.DiscardHand(tp,c18828179.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 判断卡片是否为里侧表示，用于选择场上盖放的卡作为破坏对象。
function c18828179.filter(c)
	return c:IsFacedown()
end
-- 破坏效果的发动目标选择：连锁指定对象时校验对象是否为场上里侧表示卡；发动时检查是否存在可选的里侧表示卡，若有则提示玩家选择1张作为对象，并设置破坏的操作信息。
function c18828179.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c18828179.filter(chkc) end
	-- 目标检查：确认双方场上是否存在至少1张里侧表示的卡可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c18828179.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 给玩家tp发送选择提示，提示内容为请选择要破坏的卡（HINTMSG_DESTROY）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家tp选择1张场上里侧表示的卡作为效果对象，并自动登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c18828179.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置当前连锁的操作信息：类别为破坏（CATEGORY_DESTROY），对象为刚选择的卡，数量为1，用于后续效果处理时的检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果处理：取得连锁对象，若该卡仍在场上且为里侧表示且与效果保持关联，则将其破坏。
function c18828179.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中登记的第一张对象卡（这里就是选择的里侧表示卡）。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFacedown() and tc:IsRelateToEffect(e) then
		-- 以效果破坏的原因（REASON_EFFECT）将对象卡破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

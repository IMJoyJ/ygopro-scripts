--スクラップ・シンクロン
-- 效果：
-- 这张卡可以作为「同调士」调整的代替而成为同调素材。这个卡名的①②的效果1回合各能使用1次。
-- ①：以「同调士」调整为素材的同调怪兽同调召唤的场合，手卡的这张卡也能作为同调素材。
-- ②：自己场上的以下怪兽被战斗·效果破坏的场合，可以作为代替把场上·墓地的这张卡除外。
-- ●有「废品战士」的卡名记述的怪兽
-- ●原本卡名包含「战士」的同调怪兽
local s,id,o=GetID()
-- 注册废铁同调士的全部效果：登记「废品战士」卡名；设置这张卡可作为「同调士」调整的代替素材的规则效果；设置①从手牌作为额外同调素材的效果（含1回合1次计数）；设置②自己场上符合条件的怪兽被战斗/效果破坏时，可从场上或墓地除外代替破坏的置换效果。
function s.initial_effect(c)
	-- 将卡号60800381（「废品战士」）登记为这张卡的效果文本记载卡名，用于②效果中“有「废品战士」的卡名记述的怪兽”的判定。
	aux.AddCodeList(c,60800381)
	-- 这张卡可以作为「同调士」调整的代替而成为同调素材。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(20932152)
	c:RegisterEffect(e0)
	-- ①：以「同调士」调整为素材的同调怪兽同调召唤的场合，手卡的这张卡也能作为同调素材。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_SYNCHRO_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetValue(s.matval)
	c:RegisterEffect(e1)
	-- “这个卡名的①②的效果1回合各能使用1次。”——本段代码在①效果实际作为素材时消耗其使用次数。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BE_PRE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_EVENT_PLAYER+EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetLabelObject(e1)
	e2:SetCondition(s.hsyncon)
	e2:SetOperation(s.hsynreg)
	c:RegisterEffect(e2)
	-- ②：自己场上的以下怪兽被战斗·效果破坏的场合，可以作为代替把场上·墓地的这张卡除外。●有「废品战士」的卡名记述的怪兽 ●原本卡名包含「战士」的同调怪兽
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetRange(LOCATION_MZONE+LOCATION_GRAVE)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.reptg)
	e3:SetValue(s.repval)
	e3:SetOperation(s.repop)
	c:RegisterEffect(e3)
end
-- matval：e1的Value函数，判定这张手卡能否成为额外同调素材——要同调召唤的怪兽必须是同调怪兽，且其素材条件中包含「同调士」字段（0x1017）。
function s.matval(e,c)
	-- 判断c是否为同调怪兽并且其素材列表中包含字段0x1017（「同调士」）。满足则手卡这张卡可以作为额外同调素材。
	return c:IsType(TYPE_SYNCHRO) and aux.IsMaterialListSetCard(c,0x1017)
end
-- hsyncon：e2的触发条件——这张卡被用于同调召唤的素材（r==REASON_SYNCHRO）、同调召唤出的怪兽满足matval（素材含「同调士」字段）、而且这张卡此前位于手牌。
function s.hsyncon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return r==REASON_SYNCHRO and s.matval(nil,c:GetReasonCard()) and c:IsPreviousLocation(LOCATION_HAND)
end
-- hsynreg：e2的发动处理，调用e1的UseCountLimit(tp)消耗1回合1次的使用次数，从而落实①效果的1回合1次限制。
function s.hsynreg(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():UseCountLimit(tp)
end
-- repfilter：判定被破坏的怪兽是否属于②适用的我方怪兽——表侧表示且满足‘原本卡名包含「战士」的同调怪兽’或‘效果文本记述了「废品战士」的怪兽’；同时在场上、控制者为tp、破坏原因包含战斗或效果，且不是由代替破坏导致。
function s.repfilter(c,tp)
	return c:IsFaceup() and (c:IsOriginalSetCard(0x66) and c:IsType(TYPE_SYNCHRO)
		-- 或者该怪兽是效果文本中记载了「废品战士」（卡号60800381）的怪兽，即‘有「废品战士」的卡名记述的怪兽’。
		or aux.IsCodeListed(c,60800381) and c:IsType(TYPE_MONSTER))
		and c:IsOnField() and c:IsControler(tp) and c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
end
-- reptg：代替破坏效果的发动条件检查（chk==0）——这张卡可以除外、预定被破坏的怪兽集合eg中存在满足repfilter的我方怪兽、且这张卡自身尚未处于“预定破坏”状态（防止重复代替）。
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemove() and eg:IsExists(s.repfilter,1,c,tp)
		and not c:IsStatus(STATUS_DESTROY_CONFIRMED) end
	-- 当条件满足后，让玩家选择是否发动“把这张卡除外作为代替破坏”；选择是则返回真，继续执行代替处理。
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- repval：EFFECT_DESTROY_REPLACE的Value函数，对每个即将被破坏的怪兽c调用repfilter，判断能否用这张卡代替其被破坏。
function s.repval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
-- repop：代替破坏的实际处理，将效果持有者（这张废铁同调士）从场上或墓地除外，以代替原本的破坏。
function s.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将这张卡以表侧表示除外（REASON_EFFECT），完成代替破坏的置换处理。
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end

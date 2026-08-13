--R－ACEタービュランス
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：从自己墓地把2张「救援ACE队」卡除外才能发动。这张卡从手卡特殊召唤。
-- ②：自己主要阶段才能发动。从卡组把最多4张「救援ACE队」速攻魔法·通常陷阱卡在自己场上盖放（同名卡最多1张）。
-- ③：自己场上的其他卡因对方的效果从场上离开的场合，以场上1张卡为对象才能发动。那张卡破坏。
local s,id,o=GetID()
-- 创建并注册三个效果：①从手卡特殊召唤；②从卡组盖放救援ACE队速攻魔法/通常陷阱；③其他卡因对方效果离场时破坏场上1张卡。
function s.initial_effect(c)
	-- ①：从自己墓地把2张「救援ACE队」卡除外才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.sscost)
	e1:SetTarget(s.sstg)
	e1:SetOperation(s.ssop)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。从卡组把最多4张「救援ACE队」速攻魔法·通常陷阱卡在自己场上盖放（同名卡最多1张）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
	-- ③：自己场上的其他卡因对方的效果从场上离开的场合，以场上1张卡为对象才能发动。那张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"破坏场上1张卡"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCondition(s.descon)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
-- 过滤墓地中满足「救援ACE队」系列且可以作为代价除外的卡。
function s.costfilter(c)
	return c:IsSetCard(0x18b) and c:IsAbleToRemoveAsCost()
end
-- ①效果的代价处理：从自己墓地选择2张「救援ACE队」卡除外才能发动此效果。
function s.sscost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动代价检查：确认墓地中是否存在至少2张符合条件的「救援ACE队」卡可以除外。
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地选择2张符合条件的「救援ACE队」卡。
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 将选择的2张卡以表侧表示除外，作为发动①效果的代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ①效果的目标判定：确认手牌中的这张卡可以被特殊召唤且自己主要怪兽区有空位。
function s.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否有可用的空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置本次连锁的操作信息为特殊召唤这张卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：若这张卡仍与效果关联，则将其特殊召唤。
function s.ssop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己的主要怪兽区。
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤卡组中属于「救援ACE队」系列且可以盖放到魔陷区的速攻魔法卡或通常陷阱卡。
function s.setfilter(c)
	return c:IsSetCard(0x18b) and c:IsSSetable()
		and (c:IsType(TYPE_QUICKPLAY) or c:GetType()==TYPE_TRAP)
end
-- ②效果的目标判定：确认卡组中是否存在至少1张符合条件的「救援ACE队」速攻魔法或通常陷阱卡。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：卡组中存在可盖放的符合条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- ②效果处理：根据魔陷区空格数，从卡组选择最多4张卡名互不相同的「救援ACE队」速攻魔法/通常陷阱盖放到自己场上。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己魔陷区当前可用的空格数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if ft<=0 then return end
	if ft>=4 then ft=4 end
	-- 获取卡组中所有符合盖放条件的「救援ACE队」速攻魔法/通常陷阱卡。
	local g=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>0 then
		-- 提示玩家选择要盖放的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		-- 从符合条件的中选择1至ft张卡名各不相同的卡。
		local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,ft)
		if sg:GetCount()>0 then
			-- 将选择的卡盖放到自己的魔陷区。
			Duel.SSet(tp,sg)
		end
	end
end
-- 过滤离场卡：该卡之前由自己控制，且是由对方的效果导致离场。
function s.cfilter(c,tp)
	return c:IsPreviousControler(tp)
		and c:GetReasonPlayer()==1-tp and c:IsReason(REASON_EFFECT)
end
-- ③发动条件：自己场上的其他卡因对方效果离场，且发动效果的这张卡不在离场卡之中。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp) and not eg:IsContains(e:GetHandler())
end
-- ③效果目标：以场上1张卡为对象才能发动，并设置破坏的操作信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 确认场上存在至少1张可以作为对象的卡。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张卡作为破坏对象。
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置本次连锁的操作信息为破坏该对象卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ③效果处理：若对象卡仍与效果关联，则将其破坏。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时选择的破坏对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因破坏那张对象卡。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end

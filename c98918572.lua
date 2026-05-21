--十二獣の相剋
-- 效果：
-- 「十二兽的相克」的①的效果1回合只能使用1次。
-- ①：只要这张卡在魔法与陷阱区域存在，自己的「十二兽」超量怪兽把超量素材取除来让效果发动的场合，取除的超量素材可以从自己场上的其他的超量怪兽取除。
-- ②：把墓地的这张卡除外，以自己场上2只「十二兽」超量怪兽为对象才能发动。作为对象的怪兽中的1只在另1只下面重叠作为超量素材。
function c98918572.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 「十二兽的相克」的①的效果1回合只能使用1次。①：只要这张卡在魔法与陷阱区域存在，自己的「十二兽」超量怪兽把超量素材取除来让效果发动的场合，取除的超量素材可以从自己场上的其他的超量怪兽取除。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(98918572,0))  --"代替素材"
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_OVERLAY_REMOVE_REPLACE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,98918572)
	e2:SetCondition(c98918572.rcon)
	e2:SetOperation(c98918572.rop)
	c:RegisterEffect(e2)
	-- ②：把墓地的这张卡除外，以自己场上2只「十二兽」超量怪兽为对象才能发动。作为对象的怪兽中的1只在另1只下面重叠作为超量素材。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_GRAVE)
	-- 把墓地的这张卡除外作为发动代价
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c98918572.xyztg)
	e3:SetOperation(c98918572.xyzop)
	c:RegisterEffect(e3)
end
-- 过滤条件：自己场上表侧表示、且拥有足够数量超量素材可以取除的超量怪兽
function c98918572.rfilter(c,oc,tp)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
		and c:CheckRemoveOverlayCard(tp,oc,REASON_COST)
end
-- 代替取除素材效果的允许发动条件：作为代价取除素材、是已发动的超量怪兽的效果、由自己发动、发动怪兽是「十二兽」怪兽，且自己场上有其他可以代替取除素材的超量怪兽
function c98918572.rcon(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	return bit.band(r,REASON_COST)~=0 and re:IsActivated()
		and re:IsActiveType(TYPE_XYZ) and ep==e:GetOwnerPlayer() and rc:IsSetCard(0xf1)
		-- 检查自己场上是否存在除发动效果的怪兽以外、可以代替取除所需数量素材的超量怪兽
		and Duel.IsExistingMatchingCard(c98918572.rfilter,tp,LOCATION_MZONE,0,1,rc,ev,tp)
end
-- 代替取除素材效果的具体操作：选择自己场上1只其他的超量怪兽，取除对应数量的超量素材
function c98918572.rop(e,tp,eg,ep,ev,re,r,rp)
	local min=ev&0xffff
	local max=(ev>>16)&0xffff
	local rc=re:GetHandler()
	-- 让玩家选择自己场上1只其他的、可以代替取除素材的超量怪兽
	local tg=Duel.SelectMatchingCard(tp,c98918572.rfilter,tp,LOCATION_MZONE,0,1,1,rc,min,tp)
	return tg:GetFirst():RemoveOverlayCard(tp,min,max,REASON_EFFECT)
end
-- 过滤条件：自己场上表侧表示的、可以作为效果对象的「十二兽」超量怪兽
function c98918572.xyzfilter(c,e)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(0xf1) and c:IsCanBeEffectTarget(e)
end
-- 组检查条件：所选的卡片组中必须至少有1张卡可以作为超量素材叠放
function c98918572.gcheck(g)
	return g:IsExists(Card.IsCanOverlay,1,nil)
end
-- 效果②的靶向处理（Target）：选择自己场上2只「十二兽」超量怪兽作为对象
function c98918572.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取自己场上所有满足条件的「十二兽」超量怪兽
	local g=Duel.GetMatchingGroup(c98918572.xyzfilter,tp,LOCATION_MZONE,0,nil,e)
	if chk==0 then return g:CheckSubGroup(c98918572.gcheck,2,2) end
	-- 给玩家发送提示信息：请选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	local sg=g:SelectSubGroup(tp,c98918572.gcheck,false,2,2)
	-- 将选择的2只怪兽设置为效果的对象
	Duel.SetTargetCard(sg)
end
-- 效果②的具体操作：选择其中1只作为素材，将其及其原本的素材（送去墓地后）重叠在另1只下面
function c98918572.xyzop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在连锁处理时仍存在于场上的对象怪兽
	local g=Duel.GetTargetsRelateToChain()
	if g:GetCount()~=2 then return end
	if g:IsExists(Card.IsImmuneToEffect,1,nil,e) then return end
	-- 给玩家发送提示信息：请选择要作为超量素材的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	local xc=g:FilterSelect(tp,Card.IsCanOverlay,1,1,nil):GetFirst()
	if xc then
		local tc=(g-xc):GetFirst()
		local og=xc:GetOverlayGroup()
		if og:GetCount()>0 then
			-- 根据规则，将要作为素材的怪兽原本持有的超量素材全部送去墓地
			Duel.SendtoGrave(og,REASON_RULE)
		end
		-- 将选中的怪兽重叠在另1只怪兽下面作为超量素材
		Duel.Overlay(tc,xc)
	end
end

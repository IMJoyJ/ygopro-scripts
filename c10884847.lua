--セネトメス・ネクベト
-- 效果：
-- 「塞尼特」卡降临
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：把这张卡从手卡丢弃才能发动。从自己墓地把「塞尼特摩斯·尼库贝特」以外的1张「塞尼特」卡加入手卡。
-- ②：有装备卡装备的这张卡不会被战斗破坏。
-- ③：自己·对方回合可以发动。自己的魔法与陷阱区域1张表侧表示的通常怪兽卡特殊召唤，自己场上的这张卡当作攻击力上升2500的装备魔法卡使用给那只怪兽装备。
local s,id,o=GetID()
-- 初始化卡片效果，注册仪式召唤限制及效果①②③
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 这个卡名的①③的效果1回合各能使用1次。①：把这张卡从手卡丢弃才能发动。从自己墓地把「塞尼特摩斯·尼库贝特」以外的1张「塞尼特」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"回收"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：有装备卡装备的这张卡不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.eqcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- ③：自己·对方回合可以发动。自己的魔法与陷阱区域1张表侧表示的通常怪兽卡特殊召唤，自己场上的这张卡当作攻击力上升2500的装备魔法卡使用给那只怪兽装备。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 效果①发动Cost：把手卡的这张卡丢弃
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 把手卡中的自身作为Cost丢弃送去墓地
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 过滤条件：同名卡以外的「塞尼特」卡且可以加入手卡
function s.thfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x1eb) and c:IsAbleToHand()
end
-- 效果①发动条件判断及操作信息设置：从墓地把卡加入手卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查自己墓地是否存在同名卡以外的「塞尼特」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息：从墓地将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- 效果①处理：从自己墓地把同名卡以外的1张「塞尼特」卡加入手卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己墓地选1张不受王家长眠之谷影响的「塞尼特」卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
	if g then
		-- 将选中的卡加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果②生效条件：自身有装备卡装备
function s.eqcon(e)
	local c=e:GetHandler()
	return c:GetEquipCount()>0
end
-- 过滤条件：魔法与陷阱区域表侧表示且可以特殊召唤的通常怪兽卡
function s.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsAllCardTypes(TYPE_NORMAL+TYPE_MONSTER)
		-- 检查该卡是否可以特殊召唤且离场后自身有可用的魔法与陷阱区域
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetSZoneCount(tp,c)>0
end
-- 效果③发动条件判断及操作信息设置：特殊召唤并装备自身
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己的魔法与陷阱区域是否存在满足条件的通常怪兽卡
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_SZONE,0,1,nil,e,tp) end
	-- 设置操作信息：从魔法与陷阱区域特殊召唤1张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_SZONE)
end
-- 效果③处理：特殊召唤魔法与陷阱区域的通常怪兽，并将自身作为装备卡装备
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若没有空余的怪兽区域则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己的魔法与陷阱区域选择1张通常怪兽卡
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_SZONE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 将选中的怪兽以表侧表示特殊召唤到场上
	if g:GetCount()>0 and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 检查是否有空余的魔法与陷阱区域用于装备
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and c:IsRelateToChain() and c:IsControler(tp) then
		-- 将自身作为装备卡装备给该怪兽，若失败则结束处理
		if not Duel.Equip(tp,c,tc) then return end
		-- 自己场上的这张卡当作攻击力上升2500的装备魔法卡使用给那只怪兽装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetLabelObject(tc)
		e1:SetValue(s.eqlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 攻击力上升2500
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(2500)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
	end
end
-- 装备限制：仅能装备给特殊召唤的目标怪兽
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end

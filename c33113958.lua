--リヴァーチュ・ドラゴン
-- 效果：
-- 3星怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。从卡组把1张「善德激流弹」加入手卡。
-- ②：可以从以下效果选择1个发动。
-- ●自己场上1个超量素材取除。那之后，从自己墓地把「海善龙」以外的1只鱼族·海龙族·水族怪兽加入手卡。
-- ●以场上2只超量怪兽为对象才能发动。那之内的1只的1个超量素材作为另1只的超量素材。
local s,id,o=GetID()
-- 初始化效果函数，注册XYZ召唤手续、设置复活限制并创建三个效果
function s.initial_effect(c)
	-- 记录该卡拥有「善德激流弹」的卡名
	aux.AddCodeList(c,80534031)
	-- 设置XYZ召唤条件为3星怪兽2只
	aux.AddXyzProcedure(c,nil,3,2)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤的场合才能发动。从卡组把1张「善德激流弹」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"加入手卡"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：可以从以下效果选择1个发动。●自己场上1个超量素材取除。那之后，从自己墓地把「海善龙」以外的1只鱼族·海龙族·水族怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回收墓地"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.thtg2)
	e2:SetOperation(s.thop2)
	c:RegisterEffect(e2)
	-- ②：可以从以下效果选择1个发动。●以场上2只超量怪兽为对象才能发动。那之内的1只的1个超量素材作为另1只的超量素材。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"转移超量素材"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.xyztg)
	e3:SetOperation(s.xyzop)
	c:RegisterEffect(e3)
end
-- 检索满足条件的「善德激流弹」卡片组
function s.thfilter(c)
	return c:IsCode(80534031) and c:IsAbleToHand()
end
-- 设置效果处理时的卡组检索操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足检索条件
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理时的卡组检索操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索效果，选择并加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤满足条件的墓地怪兽
function s.thfilter2(c)
	return not c:IsCode(id) and c:IsRace(RACE_FISH+RACE_AQUA+RACE_SEASERPENT)
		and c:IsAbleToHand()
end
-- 设置效果处理时的墓地检索操作信息
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足取除超量素材并检索墓地怪兽的条件
	if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,0,1,REASON_EFFECT) and Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置效果处理时的墓地检索操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- 执行取除超量素材并检索墓地怪兽的效果
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否满足取除超量素材的条件
	if not Duel.CheckRemoveOverlayCard(tp,1,0,1,REASON_EFFECT) or not Duel.RemoveOverlayCard(tp,1,0,1,1,REASON_EFFECT) then return end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的墓地怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter2),tp,LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 将选中的墓地怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤满足条件的超量怪兽
function s.xyzfilter(c,e)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsCanBeEffectTarget(e)
end
-- 检查满足条件的超量怪兽组是否包含有超量素材的怪兽
function s.gcheck(g)
	return g:IsExists(s.xyzfilter2,1,nil)
end
-- 过滤满足条件的超量怪兽（有超量素材）
function s.xyzfilter2(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:GetOverlayGroup():GetCount()>0
end
-- 设置超量素材转移效果的目标选择处理
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取满足条件的超量怪兽组
	local g=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e)
	if chkc then return false end
	if chk==0 then return g:CheckSubGroup(s.gcheck,2,2) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	local sg=g:SelectSubGroup(tp,s.gcheck,false,2,2)
	-- 设置连锁处理的目标卡片
	Duel.SetTargetCard(sg)
end
-- 执行超量素材转移效果
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理的目标卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()~=2 or not tg:IsExists(s.xyzfilter2,1,nil) then return end
	-- 提示玩家选择失去超量素材的那只怪兽
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))  --"请选择失去超量素材的那只怪兽"
	local tg2=tg:FilterSelect(tp,s.xyzfilter2,1,1,nil)
	tg:Sub(tg2)
	local tc=tg2:GetFirst()
	local tc2=tg:GetFirst()
	if tc2 and not tc2:IsImmuneToEffect(e) then
		local og=tc:GetOverlayGroup()
		local sg=og:Select(tp,1,1,nil)
		-- 将选中的超量素材叠放到目标怪兽上
		Duel.Overlay(tc2,sg,false)
		local oc=sg:GetFirst():GetOverlayTarget()
		-- 触发超量素材脱离时点
		Duel.RaiseSingleEvent(oc,EVENT_DETACH_MATERIAL,e,0,0,0,0)
		-- 触发超量素材脱离时点
		Duel.RaiseEvent(oc,EVENT_DETACH_MATERIAL,e,0,0,0,0)
	end
end

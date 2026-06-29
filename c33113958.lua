--リヴァーチュ・ドラゴン
-- 效果：
-- 3星怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。从卡组把1张「善德激流弹」加入手卡。
-- ②：可以从以下效果选择1个发动。
-- ●自己场上1个超量素材取除。那之后，从自己墓地把「海善龙」以外的1只鱼族·海龙族·水族怪兽加入手卡。
-- ●以场上2只超量怪兽为对象才能发动。那之内的1只的1个超量素材作为另1只的超量素材。
local s,id,o=GetID()
-- 注册超量召唤素材、特召检索「善德激流弹」、以及去除素材回收墓地水属性怪兽或在超量怪兽间转移素材的效果
function s.initial_effect(c)
	-- 向系统登记此卡关联「善德激流弹」（卡片密码：80534031）
	aux.AddCodeList(c,80534031)
	-- 为卡片注册超量召唤的素材要求规程
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
	-- ②：自己场上1个超量素材去除。那之后，从自己墓地把「海善龙」以外的1只鱼族·海龙族·水族怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回收墓地"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.thtg2)
	e2:SetOperation(s.thop2)
	c:RegisterEffect(e2)
	-- ②：以场上2只超量怪兽为对象才能发动。那之内的1只的1个超量素材作为另1只的超量素材。
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
-- 可检索并加入手卡的「善德激流弹」卡片的过滤条件
function s.thfilter(c)
	return c:IsCode(80534031) and c:IsAbleToHand()
end
-- 检索效果的发动准备
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组中是否存在「善德激流弹」
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为将卡组的卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的执行
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示，请选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张「善德激流弹」
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 可回收的除自身外鱼族·海龙族·水族怪兽的过滤条件
function s.thfilter2(c)
	return not c:IsCode(id) and c:IsRace(RACE_FISH+RACE_AQUA+RACE_SEASERPENT)
		and c:IsAbleToHand()
end
-- 墓地怪兽回收效果的发动准备
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上超量怪兽是否存在可去除的素材且墓地有符合条件的怪兽
	if chk==0 then return Duel.CheckRemoveOverlayCard(tp,1,0,1,REASON_EFFECT) and Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息为将墓地的怪兽加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
-- 墓地怪兽回收效果的执行
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 去除自己场上超量怪兽的1个超量素材作为该效果的代价
	if not Duel.CheckRemoveOverlayCard(tp,1,0,1,REASON_EFFECT) or Duel.RemoveOverlayCard(tp,1,0,1,1,REASON_EFFECT)==0 then return end
	-- 向玩家发送提示，请选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从墓地选择1只满足过滤条件的水属性怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter2),tp,LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 在去除素材后切断连锁以处理后续回收
		Duel.BreakEffect()
		-- 将选中的怪兽从墓地加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的怪兽
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 可作为转移对象的场上表侧超量怪兽过滤条件
function s.xyzfilter(c,e)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsCanBeEffectTarget(e)
end
-- 检查被选中的2只超量怪兽中是否至少有1只拥有超量素材
function s.gcheck(g)
	return g:IsExists(s.xyzfilter2,1,nil)
end
-- 拥有超量素材的场上表侧超量怪兽过滤条件
function s.xyzfilter2(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:GetOverlayGroup():GetCount()>0
end
-- 超量素材转移效果的发动准备与对象选择
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取场上所有合法的表侧表示超量怪兽
	local g=Duel.GetMatchingGroup(s.xyzfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e)
	if chkc then return false end
	if chk==0 then return g:CheckSubGroup(s.gcheck,2,2) end
	-- 向玩家发送提示，请选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	local sg=g:SelectSubGroup(tp,s.gcheck,false,2,2)
	-- 将选中的2只超量怪兽作为效果的对象注册
	Duel.SetTargetCard(sg)
end
-- 超量素材转移效果的执行
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次连锁中被作为对象的2只超量怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg:GetCount()~=2 or not tg:IsExists(s.xyzfilter2,1,nil) then return end
	-- 向玩家提示选择失去超量素材的那只怪兽
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))  --"请选择失去超量素材的那只怪兽"
	local tg2=tg:FilterSelect(tp,s.xyzfilter2,1,1,nil)
	tg:Sub(tg2)
	local tc=tg2:GetFirst()
	local tc2=tg:GetFirst()
	if tc2 and not tc2:IsImmuneToEffect(e) then
		local og=tc:GetOverlayGroup()
		local sg=og:Select(tp,1,1,nil)
		-- 将失去素材的怪兽的1个素材转移重叠至另一只超量怪兽下方
		Duel.Overlay(tc2,sg,false)
		local oc=sg:GetFirst():GetOverlayTarget()
		-- 触发被剥离素材的怪兽的剥离事件
		Duel.RaiseSingleEvent(oc,EVENT_DETACH_MATERIAL,e,0,0,0,0)
		-- 在场上触发全局性的超量素材剥离事件
		Duel.RaiseEvent(oc,EVENT_DETACH_MATERIAL,e,0,0,0,0)
	end
end
